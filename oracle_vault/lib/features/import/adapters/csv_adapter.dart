// Datei: lib/features/import/adapters/csv_adapter.dart
//
// ZWECK: Adapter für CSV- und XLSX-Dateien.
//
// CSV: erkennt Separator automatisch (Komma, Semikolon, Tab).
//      Spaltenmapping: erste Spalte mit Text → content,
//      erkannte Num-Spalten → rollMin/rollMax oder weight.
//
// XLSX: liest erstes Sheet, behandelt es wie CSV nach der Extraktion.
// PHASE: 2

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

import '../import_state.dart';
import 'import_adapter.dart';

class CsvAdapter implements ImportAdapter {
  @override
  bool canHandle(ImportSource source) {
    if (source.type != ImportSourceType.file) return false;
    final ext = source.raw.split('.').last.toLowerCase();
    final mime = source.mimeType ?? '';
    return ext == 'csv' ||
        ext == 'tsv' ||
        ext == 'xlsx' ||
        ext == 'xls' ||
        mime.contains('csv') ||
        mime.contains('spreadsheet') ||
        mime.contains('excel');
  }

  @override
  Future<RawCandidate> parse(ImportSource source) async {
    final ext = source.raw.split('.').last.toLowerCase();
    final rows = (ext == 'xlsx' || ext == 'xls')
        ? await _readXlsx(source.raw)
        : await _readCsv(source.raw);

    if (rows.isEmpty) {
      throw const ImportParseException('Keine Daten in der Datei');
    }

    final name = _guessName(source);
    final mapping = _detectColumnMapping(rows);
    final entries = _buildEntries(rows, mapping);

    if (entries.isEmpty) {
      throw const ImportParseException(
          'Keine Einträge erkannt — bitte Spaltenzuordnung prüfen');
    }

    final hasRanges =
        mapping.rollMinCol != null && mapping.rollMaxCol != null;
    final hasWeights = mapping.weightCol != null;

    return RawCandidate(
      name: name,
      oracleType:
          detectOracleType(hasRanges: hasRanges, hasWeights: hasWeights),
      diceExpr: hasRanges ? _guessDiceExpr(entries) : null,
      entries: entries,
      language: detectLanguage(entries.map((e) => e.content).join(' ')),
      overallConfidence: 0.85,
      sourceText: _rowsToPreview(rows),
      sourceTitle: name,
    );
  }

  // ── CSV lesen ──────────────────────────────────────────────────────────────

  Future<List<List<dynamic>>> _readCsv(String path) async {
    final content = await File(path).readAsString();
    // Separator automatisch erkennen: Tab > Semikolon > Komma.
    final sep = _detectSeparator(content);
    const converter = CsvToListConverter();
    return converter.convert(content,
        fieldDelimiter: sep, eol: '\n');
  }

  String _detectSeparator(String content) {
    final firstLine = content.split('\n').first;
    if (firstLine.contains('\t')) return '\t';
    if (firstLine.contains(';')) return ';';
    return ',';
  }

  // ── XLSX lesen ─────────────────────────────────────────────────────────────

  Future<List<List<dynamic>>> _readXlsx(String path) async {
    final bytes = await File(path).readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.sheets.values.first;
    final rows = <List<dynamic>>[];
    for (final row in sheet.rows) {
      rows.add(row.map((cell) => cell?.value?.toString() ?? '').toList());
    }
    return rows;
  }

  // ── Spaltenmapping ──────────────────────────────────────────────────────────

  _ColumnMapping _detectColumnMapping(List<List<dynamic>> rows) {
    if (rows.isEmpty) return const _ColumnMapping(contentCol: 0);

    final header = rows.first.map((c) => c.toString().toLowerCase()).toList();

    int contentCol = 0;
    int? rollMinCol, rollMaxCol, weightCol;

    // Suche nach Header-Labels.
    for (var i = 0; i < header.length; i++) {
      final h = header[i];
      if (h.contains('min') || h.contains('von') || h == 'from') {
        rollMinCol = i;
      } else if (h.contains('max') || h.contains('bis') || h == 'to') {
        rollMaxCol = i;
      } else if (h.contains('weight') || h.contains('gewicht')) {
        weightCol = i;
      } else if (h.contains('content') ||
          h.contains('text') ||
          h.contains('eintrag') ||
          h.contains('entry') ||
          h.contains('result') ||
          h.contains('ergebnis')) {
        contentCol = i;
      }
    }

    // Fallback: wenn keine Label erkannt, prüfe erste Nicht-Header-Zeile.
    if (rows.length > 1) {
      final firstData = rows[1];
      // Erste Spalte, die aussieht wie eine Zahl → Bereichs-Kandidat.
      for (var i = 0; i < firstData.length; i++) {
        final val = firstData[i].toString().trim();
        if (double.tryParse(val) != null) {
          if (rollMinCol == null) {
            rollMinCol = i;
          } else if (rollMaxCol == null && i != rollMinCol) {
            rollMaxCol = i;
          }
        }
      }
      // Längste Textspalte → content.
      int maxLen = 0;
      for (var i = 0; i < firstData.length; i++) {
        final len = firstData[i].toString().length;
        if (len > maxLen &&
            i != rollMinCol &&
            i != rollMaxCol &&
            i != weightCol) {
          maxLen = len;
          contentCol = i;
        }
      }
    }

    return _ColumnMapping(
      contentCol: contentCol,
      rollMinCol: rollMinCol,
      rollMaxCol: rollMaxCol,
      weightCol: weightCol,
    );
  }

  List<RawEntry> _buildEntries(
      List<List<dynamic>> rows, _ColumnMapping m) {
    final entries = <RawEntry>[];
    // Erste Zeile überspringen wenn sie ein Header zu sein scheint.
    final start =
        _isHeader(rows.first) ? 1 : 0;

    for (var i = start; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= m.contentCol) continue;
      final content = row[m.contentCol].toString().trim();
      if (content.isEmpty) continue;

      final min = m.rollMinCol != null && m.rollMinCol! < row.length
          ? int.tryParse(row[m.rollMinCol!].toString())
          : null;
      final max = m.rollMaxCol != null && m.rollMaxCol! < row.length
          ? int.tryParse(row[m.rollMaxCol!].toString())
          : null;
      final weight = m.weightCol != null && m.weightCol! < row.length
          ? double.tryParse(row[m.weightCol!].toString()) ?? 1.0
          : 1.0;

      entries.add(RawEntry(
        content: content,
        rollMin: min,
        rollMax: max,
        weight: weight,
      ));
    }
    return entries;
  }

  bool _isHeader(List<dynamic> row) {
    // Eine Zeile ist wahrscheinlich ein Header, wenn alle Zellen Text sind
    // und keine Zahlen oder Bereiche enthält.
    return row.every((c) => double.tryParse(c.toString()) == null);
  }

  String? _guessDiceExpr(List<RawEntry> entries) {
    final maxRoll = entries
        .where((e) => e.rollMax != null)
        .fold<int>(0, (m, e) => e.rollMax! > m ? e.rollMax! : m);
    return maxRoll > 0 ? '1d$maxRoll' : null;
  }

  String _guessName(ImportSource source) {
    final base = source.raw.split(RegExp(r'[/\\]')).last;
    return base.contains('.')
        ? base.substring(0, base.lastIndexOf('.'))
        : base;
  }

  String _rowsToPreview(List<List<dynamic>> rows) {
    return rows.take(10).map((r) => r.join(' | ')).join('\n');
  }
}

class _ColumnMapping {
  final int contentCol;
  final int? rollMinCol;
  final int? rollMaxCol;
  final int? weightCol;

  const _ColumnMapping({
    required this.contentCol,
    this.rollMinCol,
    this.rollMaxCol,
    this.weightCol,
  });
}
