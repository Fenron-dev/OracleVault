// Datei: lib/features/import/adapters/pdf_adapter.dart
//
// ZWECK: Adapter für PDF-Dateien.
//
// STRATEGIE (zweistufig):
//   Stufe 1 – Textextraktion via pdfrx (pdfrx nutzt PDFKit auf Apple-Plattformen,
//              pdfium auf Windows/Linux/Android).
//              Jede Seite, die weniger als [_kSparseThreshold] Zeichen enthält,
//              gilt als „möglicherweise gescannt".
//
//   Stufe 2 – OCR-Fallback via OcrService:
//              iOS/Android: ML Kit Latin-Script.
//              macOS: Stub (Phase 4 bringt Apple Vision).
//              Für jeden sparse Seitenblock wird ein Hinweis in sourceText notiert.
//
//   Den gesamten extrahierten Text durchläuft danach die TextAdapter-Heuristik,
//   um Einträge, Typen und Würfelausdrücke zu erkennen.
//
// METADATEN: Titel und Autor werden aus den PDF-Dokumentinformationen gezogen.
// PHASE: 2

import 'package:flutter/painting.dart' show Color;
import 'package:pdfrx/pdfrx.dart';

import '../import_state.dart';
import '../../../services/ocr_service.dart';
import 'import_adapter.dart';
import 'text_adapter.dart';

/// Unter dieser Zeichenzahl pro Seite → Seite als gescannt markieren.
const _kSparseThreshold = 80;

class PdfAdapter implements ImportAdapter {
  @override
  bool canHandle(ImportSource source) {
    if (source.type != ImportSourceType.file) return false;
    final ext = source.raw.split('.').last.toLowerCase();
    final mime = source.mimeType ?? '';
    return ext == 'pdf' || mime == 'application/pdf';
  }

  @override
  Future<RawCandidate> parse(ImportSource source) async {
    final path = source.raw;
    final doc = await PdfDocument.openFile(path);

    try {
      return await _parsePdf(doc, source);
    } finally {
      await doc.dispose();
    }
  }

  Future<RawCandidate> _parsePdf(PdfDocument doc, ImportSource source) async {
    final ocr = OcrService();
    final pageCount = doc.pages.length;

    final textBuffer = StringBuffer();
    final scannedPages = <int>[];

    for (int i = 0; i < pageCount; i++) {
      final page = doc.pages[i];
      final pageText = await _extractPageText(page);

      if (pageText.trim().length < _kSparseThreshold) {
        // Seite ist sparse → OCR versuchen.
        scannedPages.add(i + 1);
        if (ocr.isAvailable) {
          final ocrText = await _ocrPage(ocr, page);
          if (ocrText.trim().isNotEmpty) {
            textBuffer.writeln(ocrText);
          } else {
            textBuffer.writeln(
                '[Seite ${i + 1}: Gescannt – OCR hat keinen Text erkannt]');
          }
        } else {
          textBuffer.writeln(
              '[Seite ${i + 1}: Gescannt – OCR auf diesem Gerät nicht verfügbar]');
        }
      } else {
        textBuffer.writeln(pageText);
      }
    }

    await ocr.dispose();

    final fullText = textBuffer.toString().trim();

    if (fullText.isEmpty || fullText.startsWith('[')) {
      throw const ImportParseException(
          'Kein Text extrahierbar. PDF könnte vollständig gescannt sein.');
    }

    final docTitle = _guessTitle(source.raw);
    final docAuthor = _extractAuthor(doc);

    // OCR-Hinweis ans Ende des sourceText hängen.
    String sourceText = fullText;
    if (scannedPages.isNotEmpty) {
      final hint = ocr.isAvailable
          ? 'OCR auf ${scannedPages.length} Seite(n) angewendet.'
          : 'Seite(n) ${scannedPages.join(', ')} scheinen gescannt – '
              'OCR folgt in Phase 4 (Apple Vision / ML Kit).';
      sourceText += '\n\n[$hint]';
    }

    // Confidence: wird leicht reduziert wenn gescannte Seiten dabei waren.
    final confidence = scannedPages.isEmpty ? 0.9 : 0.65;

    // Einträge via TextAdapter-Heuristik aus dem Fließtext.
    final textSource = ImportSource(type: ImportSourceType.paste, raw: fullText);
    final textAdapter = TextAdapter();
    RawCandidate textCandidate;
    try {
      textCandidate = await textAdapter.parse(textSource);
    } catch (_) {
      textCandidate = RawCandidate(
        name: docTitle,
        entries: const [],
        sourceText: sourceText,
      );
    }

    return RawCandidate(
      name: docTitle,
      oracleType: textCandidate.oracleType,
      diceExpr: textCandidate.diceExpr,
      entries: textCandidate.entries,
      language: detectLanguage(fullText),
      overallConfidence: confidence,
      sourceText: sourceText,
      sourceTitle: docTitle,
      sourceAuthor: docAuthor.isEmpty ? null : docAuthor,
    );
  }

  // ── Seiten-Textextraktion ──────────────────────────────────────────────────

  Future<String> _extractPageText(PdfPage page) async {
    try {
      final textContent = await page.loadText();
      return _sanitize(textContent.fullText);
    } catch (_) {
      return '';
    }
  }

  /// Bereinigt PDF-Rohtext von Kodierungsartefakten.
  /// PDFKit/PDFium gibt für unbekannte Glyphen manchmal Null-Bytes zurück,
  /// die C-String-Verarbeitung und Dart-Regex vorzeitig terminieren können.
  static String _sanitize(String raw) => raw
      .replaceAll('\x00', '') // Null-Bytes → weg
      .replaceAllMapped( // weitere Steuerzeichen außer \n/\t → weg
          RegExp(r'[\x01-\x08\x0B\x0C\x0E-\x1F\x7F]'), (_) => '')
      .replaceAll('‘', "'") // ' → '
      .replaceAll('’', "'") // ' → '
      .replaceAll('“', '"') // " → "
      .replaceAll('”', '"') // " → "
      .replaceAll('…', '...'); // … → ...

  // ── OCR auf gerenderter Seite ──────────────────────────────────────────────

  Future<String> _ocrPage(OcrService ocr, PdfPage page) async {
    try {
      // Seite mit 2× Skalierung rendern für bessere OCR-Qualität.
      const scale = 2.0;
      final image = await page.render(
        width: (page.width * scale).round(),
        height: (page.height * scale).round(),
        backgroundColor: const Color(0xFFFFFFFF),
      );
      if (image == null) return '';

      return await ocr.recognizeBytes(
        image.pixels,
        image.width,
        image.height,
      );
    } catch (_) {
      return '';
    }
  }

  // ── Hilfsmethoden ─────────────────────────────────────────────────────────

  String _guessTitle(String path) {
    final base = path.split(RegExp(r'[/\\]')).last;
    return base.contains('.')
        ? base.substring(0, base.lastIndexOf('.'))
        : base;
  }

  String _extractAuthor(PdfDocument doc) {
    // pdfrx stellt Dokumentinfo über permissions/metadata bereit.
    // Autor ist derzeit nicht direkt aus der API lesbar ohne
    // PdfDocument.loadPage(0).loadAnnotations() → komplexer Pfad.
    // Phase 4: PdfDocumentRef.loadInfo() wenn API stabil.
    return '';
  }
}
