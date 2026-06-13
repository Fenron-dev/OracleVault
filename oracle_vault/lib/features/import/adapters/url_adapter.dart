// Datei: lib/features/import/adapters/url_adapter.dart
//
// ZWECK: Adapter für URL-Import (HTML-Seiten, Reddit-Posts).
//
// STRATEGIE:
//   Reddit: old.reddit.com verwenden (statisches HTML, kein JS, keine Auth nötig).
//           www.reddit.com liefert seit 2024 nur noch gerenderte SPA-HTML zurück.
//           old.reddit.com hat post body in <ol><li><p>…</p></li></ol>.
//
//   Andere Seiten: html-Paket zum Parsen, <ol>/<ul> extrahieren.
//
// WARUM old.reddit.com statt JSON API?
//   Die Reddit JSON API (*.json) liefert im Browser/Script-Kontext ohne Auth
//   ab 2024 eine consent-wall (HTML statt JSON). old.reddit.com ist deterministisch
//   parsbar und benötigt keinen API-Schlüssel.
// PHASE: 2

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../import_state.dart';
import 'import_adapter.dart';

class UrlAdapter implements ImportAdapter {
  static const String _kUserAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/125.0.0.0 Safari/537.36';

  @override
  bool canHandle(ImportSource source) =>
      source.type == ImportSourceType.url;

  @override
  Future<RawCandidate> parse(ImportSource source) async {
    final url = source.raw.trim();
    if (url.isEmpty) throw const ImportParseException('URL ist leer');

    final uri = Uri.tryParse(url);
    if (uri == null) throw ImportParseException('Ungültige URL: $url');

    if (_isReddit(uri)) {
      return await _parseReddit(uri, url);
    }
    return await _parseHtml(uri, url);
  }

  // ── Reddit ──────────────────────────────────────────────────────────────────

  bool _isReddit(Uri uri) =>
      uri.host.contains('reddit.com') || uri.host.contains('redd.it');

  /// Ladet den Post über old.reddit.com (statisches HTML, kein Auth nötig).
  Future<RawCandidate> _parseReddit(Uri uri, String originalUrl) async {
    // old.reddit.com erzwingen — new Reddit ist SPA mit JavaScript-Rendering.
    final oldUri = uri.replace(host: 'old.reddit.com');

    final response = await http
        .get(oldUri, headers: {'User-Agent': _kUserAgent})
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw ImportParseException(
          'Reddit antwortet mit HTTP ${response.statusCode}. '
          'Bitte die URL prüfen.');
    }

    final doc = html_parser.parse(response.body);

    // Seitentitel
    final title = _extractRedditTitle(doc);

    // Autor aus .tagline .author
    final author = doc
            .querySelector('.thing.link .tagline .author')
            ?.text
            .trim() ??
        '';

    // Post-Body: der längste <ol>-Block im .expando (post content area).
    final entries = _extractRedditEntries(doc);

    if (entries.isEmpty) {
      throw const ImportParseException(
          'Keine Listeneinträge gefunden. '
          'Der Post hat möglicherweise keinen text-basierten Inhalt '
          'oder die Liste ist in einem anderen Format.');
    }

    final hasRanges = entries.any((e) => e.rollMin != null);

    return RawCandidate(
      name: title,
      oracleType: detectOracleType(hasRanges: hasRanges, hasWeights: false),
      diceExpr:
          hasRanges ? _guessDiceExpr(entries) : detectDiceExpr(title),
      entries: entries,
      language: detectLanguage(entries.map((e) => e.content).join(' ')),
      overallConfidence: 0.9,
      sourceText: '${title.isNotEmpty ? "$title\n\n" : ""}'
          '${entries.take(10).map((e) => e.content).join('\n')}',
      sourceTitle: title,
      sourceAuthor: author.isEmpty ? null : 'u/$author',
      sourceUrl: originalUrl,
    );
  }

  String _extractRedditTitle(dom.Document doc) {
    // old.reddit: .thing.link .title .title a.title enthält den Post-Titel.
    return doc
            .querySelector('.thing.link .title a.title')
            ?.text
            .trim() ??
        doc.head?.querySelector('title')?.text.trim() ??
        'Reddit-Import';
  }

  List<RawEntry> _extractRedditEntries(dom.Document doc) {
    // Post-Body in old.reddit ist in .thing.link .usertext-body .md
    // Die eigentliche Liste ist darin als <ol> oder <ul> formatiert.

    // Alle <ol>-Blöcke im Dokument sammeln, längsten nehmen.
    final ols = doc.querySelectorAll('ol');
    if (ols.isNotEmpty) {
      // Längster <ol> ist (fast immer) die d100-Liste.
      final best = ols.reduce(
          (a, b) => a.querySelectorAll('li').length >=
                  b.querySelectorAll('li').length
              ? a
              : b);
      final items = best.querySelectorAll('li');
      if (items.length >= 2) {
        return items
            .map((li) => RawEntry(content: _cleanText(li.text)))
            .where((e) => e.content.isNotEmpty)
            .toList();
      }
    }

    // Fallback: <ul> im Post-Body
    final postBody = doc.querySelector('.thing.link .usertext-body');
    if (postBody != null) {
      final uls = postBody.querySelectorAll('ul');
      for (final ul in uls) {
        final items = ul.querySelectorAll('li');
        if (items.length >= 3) {
          return items
              .map((li) => RawEntry(content: _cleanText(li.text)))
              .where((e) => e.content.isNotEmpty)
              .toList();
        }
      }

      // Fallback: Text des Post-Bodies mit numerierter Listen-Heuristik parsen
      final text = postBody.text;
      if (text.isNotEmpty) {
        final helper = _TextParseHelper();
        final entries = helper.parseEntries(text);
        if (entries.length >= 2) return entries;
      }
    }

    return [];
  }

  // ── Generischer HTML-Parser ─────────────────────────────────────────────────

  Future<RawCandidate> _parseHtml(Uri uri, String originalUrl) async {
    final response = await http
        .get(uri, headers: {'User-Agent': _kUserAgent})
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw ImportParseException(
          'HTTP ${response.statusCode}: Seite konnte nicht geladen werden');
    }

    final doc = html_parser.parse(response.body);
    final title = doc.head?.querySelector('title')?.text.trim() ??
        doc.body?.querySelector('h1')?.text.trim() ??
        uri.host;
    final bodyText = doc.body?.text ?? '';

    final entries = _extractHtmlEntries(doc);

    if (entries.length < 2) {
      throw ImportParseException(
          'Keine ausreichende Listenstruktur gefunden '
          '(${entries.length} Einträge erkannt). '
          'Versuche es mit Kopieren & Einfügen (Paste).');
    }

    final hasRanges = entries.any((e) => e.rollMin != null);

    return RawCandidate(
      name: title,
      oracleType: detectOracleType(hasRanges: hasRanges, hasWeights: false),
      diceExpr:
          hasRanges ? _guessDiceExpr(entries) : detectDiceExpr(title),
      entries: entries,
      language: detectLanguage(bodyText),
      overallConfidence: 0.75,
      sourceText: _extractReadableText(doc),
      sourceTitle: title,
      sourceUrl: originalUrl,
    );
  }

  List<RawEntry> _extractHtmlEntries(dom.Document doc) {
    // 1. Nummerierte Liste <ol>
    final ols = doc.body?.querySelectorAll('ol') ?? [];
    for (final ol in ols) {
      final items = ol.querySelectorAll('li');
      if (items.length >= 3) {
        final entries = items
            .map((li) => RawEntry(content: _cleanText(li.text)))
            .where((e) => e.content.isNotEmpty)
            .toList();
        if (entries.length >= 3) return entries;
      }
    }

    // 2. Ungeordnete Liste <ul> — größte nehmen
    final uls = doc.body?.querySelectorAll('ul') ?? [];
    dom.Element? bestUl;
    int bestCount = 0;
    for (final ul in uls) {
      final count = ul.querySelectorAll('li').length;
      if (count > bestCount) {
        bestCount = count;
        bestUl = ul;
      }
    }
    if (bestUl != null && bestCount >= 5) {
      return bestUl
          .querySelectorAll('li')
          .map((li) => RawEntry(content: _cleanText(li.text)))
          .where((e) => e.content.isNotEmpty)
          .toList();
    }

    // 3. Text-Heuristik aus Paragraphen
    final paras = doc.body?.querySelectorAll('p') ?? [];
    final allText = paras.map((p) => p.text).join('\n');
    final helper = _TextParseHelper();
    final fromParas = helper.parseEntries(allText);
    if (fromParas.length >= 3) return fromParas;

    return [];
  }

  String _extractReadableText(dom.Document doc) {
    doc.querySelectorAll('nav, script, style, header, footer, aside')
        .forEach((e) => e.remove());
    return doc.body?.text
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .take(60)
            .join('\n') ??
        '';
  }

  // ── Hilfsmethoden ──────────────────────────────────────────────────────────

  String _cleanText(String text) {
    // HTML-Entities dekodieren und überschüssige Whitespace entfernen.
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? _guessDiceExpr(List<RawEntry> entries) {
    final maxRoll = entries
        .where((e) => e.rollMax != null)
        .fold<int>(0, (m, e) => e.rollMax! > m ? e.rollMax! : m);
    return maxRoll > 0 ? '1d$maxRoll' : '1d${entries.length}';
  }
}

// ── Wiederverwendeter Text-Parser ─────────────────────────────────────────────

class _TextParseHelper {
  static final _kNumberedList = RegExp(r'^\d+[.\-\)]\s+(.+)$', multiLine: true);
  static final _kDiceRange =
      RegExp(r'^(\d{1,3})\s*[-–]\s*(\d{1,3})[.\s|]+(.+)$', multiLine: true);

  List<RawEntry> parseEntries(String text) {
    // Normalisiere Zeilenenden
    final normalized = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final lines = normalized
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final diceMatches =
        lines.where((l) => _kDiceRange.hasMatch(l)).length;
    if (diceMatches >= lines.length * 0.4) {
      return _kDiceRange.allMatches(normalized).map((m) {
        return RawEntry(
          content: m.group(3)?.trim() ?? '',
          rollMin: int.tryParse(m.group(1)!),
          rollMax: int.tryParse(m.group(2)!),
        );
      }).where((e) => e.content.isNotEmpty).toList();
    }

    final numberedMatches =
        lines.where((l) => _kNumberedList.hasMatch(l)).length;
    if (numberedMatches >= lines.length * 0.4) {
      return _kNumberedList.allMatches(normalized).map((m) {
        return RawEntry(content: m.group(1)?.trim() ?? '');
      }).where((e) => e.content.isNotEmpty).toList();
    }

    return lines
        .where((l) => l.length > 2)
        .map((l) => RawEntry(content: l))
        .toList();
  }
}
