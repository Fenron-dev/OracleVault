// Datei: lib/features/import/adapters/text_adapter.dart
//
// ZWECK: Adapter für TXT- und Markdown-Dateien sowie eingefügten Text.
//
// ERKANNTE FORMATE:
//   Nummerierte Listen:  "1. Text", "01. Text", "1- Text", "1) Text"
//   Würfelbereiche:      "01-05 Text", "1-5 | Text", "01-05. Text"
//   Markdown-Tabellen:   "| Num | Text |" (Header ignoriert)
//   Einfache Zeilen:     eine Tabelle = eine Zeile (Fallback)
//
// Die Heuristik prüft die Formate in dieser Reihenfolge und nimmt das
// erste das auf ≥60% der Zeilen passt.
// PHASE: 2

import 'dart:io';

import '../import_state.dart';
import 'import_adapter.dart';

class TextAdapter implements ImportAdapter {
  @override
  bool canHandle(ImportSource source) {
    if (source.type == ImportSourceType.paste) return true;
    final mime = source.mimeType ?? '';
    final ext = source.raw.split('.').last.toLowerCase();
    return mime.startsWith('text/') ||
        ext == 'txt' ||
        ext == 'md' ||
        ext == 'markdown';
  }

  @override
  Future<RawCandidate> parse(ImportSource source) async {
    final text = await _readText(source);
    if (text.trim().isEmpty) {
      throw const ImportParseException('Datei ist leer');
    }

    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Tabellen-Namen aus erster Zeile ableiten (wenn sie kein Eintrag ist).
    final firstName = _guessTitle(lines, source);

    final parsedEntries = _parseEntries(lines);

    final hasRanges = parsedEntries.any((e) => e.rollMin != null);
    final oracleType = detectOracleType(
        hasRanges: hasRanges, hasWeights: false);
    final diceExpr = hasRanges
        ? _guessDiceExpr(parsedEntries)
        : detectDiceExpr(firstName);

    return RawCandidate(
      name: firstName,
      oracleType: oracleType,
      diceExpr: diceExpr,
      entries: parsedEntries,
      language: detectLanguage(text),
      overallConfidence: 0.9,
      sourceText: text,
      sourceTitle: firstName,
    );
  }

  // ── Interne Hilfsmethoden ──────────────────────────────────────────────────

  Future<String> _readText(ImportSource source) async {
    final raw = switch (source.type) {
      ImportSourceType.paste => source.raw,
      ImportSourceType.file => await File(source.raw).readAsString(),
      _ => throw const ImportParseException('TextAdapter: unerwarteter Typ'),
    };
    return _sanitize(raw);
  }

  static String _sanitize(String raw) => raw
      .replaceAll('\x00', '')
      .replaceAllMapped(
          RegExp(r'[\x01-\x08\x0B\x0C\x0E-\x1F\x7F]'), (_) => '')
      .replaceAll(''', "'")
      .replaceAll(''', "'")
      .replaceAll('"', '"')
      .replaceAll('"', '"')
      .replaceAll('…', '...');

  String _guessTitle(List<String> lines, ImportSource source) {
    // Wenn erste Zeile kein Eintrag-Muster → als Titel verwenden.
    if (lines.isNotEmpty && !_isEntry(lines.first)) {
      // Markdown-H1 entfernen.
      return lines.first.replaceAll(RegExp(r'^#+\s*'), '').trim();
    }
    // Fallback: Dateiname ohne Extension.
    if (source.type == ImportSourceType.file) {
      final base = source.raw.split(RegExp(r'[/\\]')).last;
      return base.contains('.')
          ? base.substring(0, base.lastIndexOf('.'))
          : base;
    }
    return 'Importierte Tabelle';
  }

  bool _isEntry(String line) {
    return _kNumberedList.hasMatch(line) ||
        _kDiceRange.hasMatch(line) ||
        _kMarkdownRow.hasMatch(line);
  }

  List<RawEntry> _parseEntries(List<String> lines) {
    // Vor der Muster-Erkennung: zwei-spaltige PDFs aufteilen
    // ("1 Text A 51 Text B" → zwei Einträge).
    final processedLines = _splitMergedTwoColumns(lines);

    // Erkennungs-Strategie: höchste Match-Rate gewinnt.
    final numbered =
        processedLines.where((l) => _kNumberedList.hasMatch(l)).length;
    final numberedPlain =
        processedLines.where((l) => _kNumberedPlain.hasMatch(l)).length;
    final diceRange =
        processedLines.where((l) => _kDiceRange.hasMatch(l)).length;
    final mdTable =
        processedLines.where((l) => _kMarkdownRow.hasMatch(l)).length;

    final total = processedLines.length;
    final threshold = (total * 0.4).round();

    if (diceRange >= threshold) return _parseDiceRange(processedLines);
    if (mdTable >= threshold) return _parseMdTable(processedLines);
    if (numbered >= threshold) return _parseNumbered(processedLines);
    // Reine Zahlen-Listen ohne Interpunktion (häufig in PDF-Extraktion)
    if (numberedPlain >= threshold) return _parseNumberedPlain(processedLines);
    return _parsePlainLines(processedLines);
  }

  /// Erkennt zusammengeführte Zwei-Spalten-Zeilen und teilt sie auf.
  /// Typisches PDF-Muster: "1 Text A 51 Text B" (linke + rechte Spalte).
  List<String> _splitMergedTwoColumns(List<String> lines) {
    // Schritt 1: Spaltversatz aus den ersten Zeilen ermitteln.
    int? offset;
    int matches = 0;
    for (final line in lines.take(15)) {
      final m = _kNumberedPlain.firstMatch(line);
      if (m == null) continue;
      final n1 = int.tryParse(m.group(1)!) ?? 0;
      final rest = m.group(2)!;
      final inline = _kInlineNumber.firstMatch(rest);
      if (inline == null) continue;
      final n2 = int.tryParse(inline.group(1)!) ?? 0;
      if (n2 > n1 + 5) {
        final candidate = n2 - n1;
        if (offset == null) {
          offset = candidate;
          matches = 1;
        } else if ((offset - candidate).abs() <= 3) {
          matches++;
        }
      }
    }

    // Nicht genug Evidenz → keine Aufteilung.
    if (offset == null || matches < 2) return lines;

    // Schritt 2: Jede Zeile am Trennpunkt aufteilen.
    final result = <String>[];
    for (final line in lines) {
      final m = _kNumberedPlain.firstMatch(line);
      if (m == null) {
        result.add(line);
        continue;
      }
      final n1 = int.parse(m.group(1)!);
      final rest = m.group(2)!;
      bool didSplit = false;

      for (int delta = 0; delta <= 3 && !didSplit; delta++) {
        for (final candidate in [n1 + offset + delta, n1 + offset - delta]) {
          if (candidate <= n1) continue;
          final marker = ' $candidate ';
          final idx = rest.indexOf(marker);
          if (idx > 0) {
            result.add('${m.group(1)} ${rest.substring(0, idx).trim()}');
            result.add('$candidate ${rest.substring(idx + marker.length).trim()}');
            didSplit = true;
            break;
          }
        }
      }
      if (!didSplit) result.add(line);
    }
    return result;
  }

  List<RawEntry> _parseDiceRange(List<String> lines) {
    final entries = <RawEntry>[];
    for (final line in lines) {
      final m = _kDiceRange.firstMatch(line);
      if (m == null) continue;
      final min = int.tryParse(m.group(1)!);
      final max = int.tryParse(m.group(2)!);
      final content = (m.group(3) ?? '').trim();
      if (content.isEmpty) continue;
      entries.add(RawEntry(content: content, rollMin: min, rollMax: max));
    }
    return entries;
  }

  List<RawEntry> _parseMdTable(List<String> lines) {
    final entries = <RawEntry>[];
    for (final line in lines) {
      if (!_kMarkdownRow.hasMatch(line)) continue;
      // Trennzeile (|---|---) überspringen.
      if (line.contains('---') || line.contains('===')) continue;
      final cells = line
          .split('|')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();
      if (cells.isEmpty) continue;
      // Erste Zelle kann Nummer sein → ignorieren, zweite ist Content.
      final content = cells.length >= 2
          ? cells[1]
          : cells[0];
      if (content.isEmpty || int.tryParse(content) != null) continue;
      entries.add(RawEntry(content: content));
    }
    return entries;
  }

  List<RawEntry> _parseNumbered(List<String> lines) {
    final entries = <RawEntry>[];
    for (final line in lines) {
      final m = _kNumberedList.firstMatch(line);
      if (m == null) continue;
      final content = (m.group(1) ?? '').trim();
      if (content.isEmpty) continue;
      entries.add(RawEntry(content: content));
    }
    return entries;
  }

  /// Parst Zahlen-Listen ohne Interpunktion: "1 Text", "51 Text".
  /// Filtert gleichzeitig reine Header-Zeilen heraus (URL, kein Satzzeichen).
  List<RawEntry> _parseNumberedPlain(List<String> lines) {
    final entries = <RawEntry>[];
    for (final line in lines) {
      final m = _kNumberedPlain.firstMatch(line);
      if (m == null) continue;
      final content = m.group(2)!.trim();
      if (content.isEmpty) continue;
      entries.add(RawEntry(content: content));
    }
    return entries;
  }

  List<RawEntry> _parsePlainLines(List<String> lines) {
    return lines
        .where((l) => l.length > 2 && !l.startsWith('#'))
        // URL-Zeilen und reine Zahlen-Zeilen als Header-Kandidaten ausschließen.
        .where((l) => !_kUrlLine.hasMatch(l) && int.tryParse(l) == null)
        .map((l) => RawEntry(content: l))
        .toList();
  }

  String? _guessDiceExpr(List<RawEntry> entries) {
    if (entries.isEmpty) return null;
    final maxRoll = entries
        .where((e) => e.rollMax != null)
        .fold<int>(0, (m, e) => e.rollMax! > m ? e.rollMax! : m);
    if (maxRoll <= 0) return null;
    return '1d$maxRoll';
  }

  // ── Multi-Tabellen-Split ───────────────────────────────────────────────────

  /// Erkennt Abschnittsüberschriften und teilt den Text in mehrere Tabellen auf.
  ///
  /// Erkannte Header-Formate:
  ///   [1] … Titel       → nummerierte Sektionen (Pet-Generator-Stil)
  ///   ## Überschrift    → Markdown H2/H3
  ///   **Fetttext**      → Markdown fett als Heading
  ///
  /// Gibt eine leere Liste zurück wenn < 2 Sektionen gefunden werden
  /// (= kein Multi-Tabellen-Dokument).
  static Future<List<RawCandidate>> splitByHeaders(String text) async {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .toList();

    // Muster für Abschnittsüberschriften
    final bracketSection = RegExp(r'^\[(\d+)\]\s*[\.…\-]*\s*(.+)$');
    final mdHeading = RegExp(r'^#{1,3}\s+(.+)$');
    final mdBold = RegExp(r'^\*\*(.+)\*\*:?$');

    // Alle Header-Positionen sammeln
    final headers = <({int line, String name})>[];
    for (int i = 0; i < lines.length; i++) {
      final l = lines[i];
      final m1 = bracketSection.firstMatch(l);
      if (m1 != null) {
        headers.add((line: i, name: '${m1.group(1)}. ${m1.group(2)!.trim()}'));
        continue;
      }
      final m2 = mdHeading.firstMatch(l);
      if (m2 != null) {
        headers.add((line: i, name: m2.group(1)!.trim()));
        continue;
      }
      final m3 = mdBold.firstMatch(l);
      if (m3 != null) {
        headers.add((line: i, name: m3.group(1)!.trim()));
      }
    }

    if (headers.length < 2) return [];

    // Jede Sektion parsen
    final adapter = TextAdapter();
    final candidates = <RawCandidate>[];

    for (int i = 0; i < headers.length; i++) {
      final start = headers[i].line + 1;
      final end = i + 1 < headers.length ? headers[i + 1].line : lines.length;
      final sectionLines = lines
          .sublist(start, end.clamp(0, lines.length))
          .where((l) => l.isNotEmpty)
          .toList();
      if (sectionLines.length < 2) continue;

      final sectionText = sectionLines.join('\n');
      try {
        final src = ImportSource(type: ImportSourceType.paste, raw: sectionText);
        final c = await adapter.parse(src);
        if (c.entries.isEmpty) continue;
        candidates.add(RawCandidate(
          name: headers[i].name,
          oracleType: c.oracleType,
          diceExpr: c.diceExpr,
          entries: c.entries,
          language: c.language,
          overallConfidence: 0.85,
          sourceText: sectionText,
        ));
      } catch (_) {}
    }

    return candidates;
  }

  // ── Reguläre Ausdrücke ─────────────────────────────────────────────────────

  // "1. Text", "01. Text", "1- Text", "1) Text"
  static final _kNumberedList =
      RegExp(r'^\d+[.\-\)]\s+(.+)$');

  // "1 Text", "51 Text" – ohne Interpunktion (häufig in PDF-Extraktion)
  static final _kNumberedPlain = RegExp(r'^(\d+)\s+(.+)$');

  // Inline-Zahl in Zeilen-Rest ("... 51 Text B")
  static final _kInlineNumber = RegExp(r'\s(\d+)\s+\S');

  // "01-05 Text", "01-05. Text", "1-5 | Text"
  static final _kDiceRange =
      RegExp(r'^(\d{1,3})\s*[-–]\s*(\d{1,3})[.\s|]+(.+)$');

  // Markdown-Tabellen-Zeile: "| ... | ... |"
  static final _kMarkdownRow = RegExp(r'^\|.+\|$');

  // URL-artige Zeilen: enthalten "://" oder ".com/.org/.de" → Header-Kandidaten
  static final _kUrlLine = RegExp(r'https?://|www\.|\.com\b|\.org\b|\.de\b');
}
