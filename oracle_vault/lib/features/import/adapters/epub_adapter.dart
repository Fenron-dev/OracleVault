// Datei: lib/features/import/adapters/epub_adapter.dart
//
// ZWECK: Adapter für ePub-Dateien.
//
// ABLAUF:
//   1. epubx: EpubReader.readBook(bytes) → EpubBook
//   2. Spine-Reihenfolge der HTML-Kapitel einhalten
//   3. HTML-Tags via html-Paket strippen → Fließtext
//   4. Fließtext durch TextAdapter-Heuristik jagen
//   5. Metadaten (Titel, Autor) aus ePub-Manifest lesen
//
// WARUM kein direktes Parsen?
//   ePub 2/3 XHTML kann verschachteltes HTML, Tabellen, Fußnoten usw. haben.
//   Das html-Paket normalisiert das zuverlässiger als Regex.
// PHASE: 2

import 'dart:io';

import 'package:epubx/epubx.dart';
import 'package:html/parser.dart' as html_parser;

import '../import_state.dart';
import 'import_adapter.dart';
import 'text_adapter.dart';

class EpubAdapter implements ImportAdapter {
  @override
  bool canHandle(ImportSource source) {
    if (source.type != ImportSourceType.file) return false;
    final ext = source.raw.split('.').last.toLowerCase();
    final mime = source.mimeType ?? '';
    return ext == 'epub' ||
        mime == 'application/epub+zip' ||
        mime == 'application/epub';
  }

  @override
  Future<RawCandidate> parse(ImportSource source) async {
    final bytes = await File(source.raw).readAsBytes();
    final book = await EpubReader.readBook(bytes);

    final title = (book.Title ?? '').trim();
    final author = (book.Author ?? '').trim();
    final name = title.isNotEmpty
        ? title
        : _guessName(source.raw);

    // ── HTML-Kapitel extrahieren ──────────────────────────────────────────
    final textBuffer = StringBuffer();

    final htmlChapters = book.Content?.Html?.values.toList() ?? [];
    for (final chapter in htmlChapters) {
      final html = chapter.Content ?? '';
      if (html.trim().isEmpty) continue;

      final text = _stripHtml(html);
      if (text.trim().length > 20) {
        textBuffer.writeln(text.trim());
        textBuffer.writeln(); // Kapitel-Trennung
      }
    }

    final fullText = textBuffer.toString().trim();

    if (fullText.isEmpty) {
      throw const ImportParseException(
          'ePub enthält keinen lesbaren Text');
    }

    // ── TextAdapter-Heuristiken ───────────────────────────────────────────
    final textSource = ImportSource(
      type: ImportSourceType.paste,
      raw: fullText,
    );
    final textAdapter = TextAdapter();
    RawCandidate textCandidate;
    try {
      textCandidate = await textAdapter.parse(textSource);
    } catch (_) {
      textCandidate = RawCandidate(
        name: name,
        entries: const [],
        sourceText: fullText,
      );
    }

    return RawCandidate(
      name: name,
      oracleType: textCandidate.oracleType,
      diceExpr: textCandidate.diceExpr,
      entries: textCandidate.entries,
      language: detectLanguage(fullText),
      overallConfidence: 0.85,
      sourceText: fullText.length > 3000
          ? '${fullText.substring(0, 3000)}…'
          : fullText,
      sourceTitle: title.isNotEmpty ? title : null,
      sourceAuthor: author.isNotEmpty ? author : null,
    );
  }

  // ── Hilfsmethoden ─────────────────────────────────────────────────────────

  String _stripHtml(String html) {
    try {
      final doc = html_parser.parse(html);
      // Navigationselemente und Metadaten überspringen.
      doc.querySelectorAll('nav, head, script, style').forEach((e) => e.remove());
      return doc.body?.text ?? doc.documentElement?.text ?? '';
    } catch (_) {
      // Fallback: einfaches Regex-Strippen.
      return html
          .replaceAll(RegExp(r'<[^>]+>'), ' ')
          .replaceAll(RegExp(r'\s{2,}'), ' ')
          .trim();
    }
  }

  String _guessName(String path) {
    final base = path.split(RegExp(r'[/\\]')).last;
    return base.contains('.')
        ? base.substring(0, base.lastIndexOf('.'))
        : base;
  }
}
