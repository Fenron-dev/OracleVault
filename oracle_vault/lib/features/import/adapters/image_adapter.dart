// Datei: lib/features/import/adapters/image_adapter.dart
//
// ZWECK: Adapter für Bilddateien (JPEG, PNG, TIFF, WebP, BMP, GIF).
//
// ABLAUF:
//   1. OcrService.recognizeFile() → extrahiert Text (iOS/Android)
//      Auf macOS: OCR nicht verfügbar → Eintrag mit niedrigem Konfidenzwert
//   2. Erkannten Text durch TextAdapter-Heuristiken jagen
//   3. sourceImagePath für Quellansicht im Import-Screen setzen
//
// PHASE 4: OcrService mit Apple-Vision für macOS vervollständigen.
// PHASE: 2

import '../import_state.dart';
import '../../../services/ocr_service.dart';
import 'import_adapter.dart';
import 'text_adapter.dart';

class ImageAdapter implements ImportAdapter {
  static const _kSupportedExts = {
    'jpg', 'jpeg', 'png', 'tiff', 'tif', 'bmp', 'webp', 'gif',
  };

  @override
  bool canHandle(ImportSource source) {
    if (source.type != ImportSourceType.file) return false;
    final ext = source.raw.split('.').last.toLowerCase();
    final mime = source.mimeType ?? '';
    return _kSupportedExts.contains(ext) || mime.startsWith('image/');
  }

  @override
  Future<RawCandidate> parse(ImportSource source) async {
    final path = source.raw;
    final name = _guessName(path);
    final ocr = OcrService();

    String ocrText = '';
    String note = '';

    if (ocr.isAvailable) {
      ocrText = await ocr.recognizeFile(path);
      await ocr.dispose();
    } else {
      note = '[OCR auf diesem Gerät nicht verfügbar – '
          'Einträge bitte manuell eintragen. '
          'Vollständige OCR-Unterstützung folgt in Phase 4.]\n\n';
    }

    // Erkannten Text durch TextAdapter-Heuristiken jagen.
    final textAdapter = TextAdapter();
    if (ocrText.trim().isNotEmpty) {
      final textSource = ImportSource(
        type: ImportSourceType.paste,
        raw: ocrText,
      );
      try {
        final textCandidate = await textAdapter.parse(textSource);
        return RawCandidate(
          name: textCandidate.name.isEmpty ? name : textCandidate.name,
          oracleType: textCandidate.oracleType,
          diceExpr: textCandidate.diceExpr,
          entries: textCandidate.entries,
          language: textCandidate.language,
          overallConfidence: 0.7, // OCR kann Fehler haben
          sourceText: '$note$ocrText',
          sourceTitle: name,
          sourceImagePath: path,
        );
      } catch (_) {
        // Fallthrough: leere Einträge zurückgeben
      }
    }

    // Kein OCR-Text → leerer Kandidat, Nutzer trägt manuell ein.
    return RawCandidate(
      name: name,
      entries: const [],
      overallConfidence: 0.0,
      sourceText: '${note}Datei: $path',
      sourceTitle: name,
      sourceImagePath: path,
    );
  }

  String _guessName(String path) {
    final base = path.split(RegExp(r'[/\\]')).last;
    return base.contains('.')
        ? base.substring(0, base.lastIndexOf('.'))
        : base;
  }
}
