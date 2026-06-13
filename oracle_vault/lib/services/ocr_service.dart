// Datei: lib/services/ocr_service.dart
//
// ZWECK: Platform-aware OCR-Wrapper.
//
//   macOS / iOS  → apple_vision_recognize_text (Apple Vision Framework, lokal/offline)
//   Android      → vision_text_recognition (MLKit)
//   Andere       → Stub (gibt leeren String zurück)
//
// Verwendung:
//   final ocr = OcrService();
//   if (ocr.isAvailable) {
//     final text = await ocr.recognizeFile('/path/to/image.jpg');
//   }
// PHASE: 4

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:apple_vision_recognize_text/apple_vision_recognize_text.dart';
import 'package:flutter/material.dart';
import 'package:vision_text_recognition/vision_text_recognition.dart'
    hide RecognitionLevel;

// ── Plattform-Interfaces ──────────────────────────────────────────────────────

abstract class _OcrImpl {
  bool get isAvailable;
  Future<String> recognizeFile(String path);
  Future<String> recognizeBytes(Uint8List bytes, int width, int height);
  Future<void> dispose();
}

// ── macOS + iOS: Apple Vision ─────────────────────────────────────────────────

class _AppleVisionOcrImpl implements _OcrImpl {
  final _ctrl = AppleVisionRecognizeTextController(numberOfCandidates: 1);

  @override
  bool get isAvailable => true;

  @override
  Future<String> recognizeFile(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final size = await _sizeFromEncoded(bytes);
      return _process(bytes, size);
    } catch (_) {
      return '';
    }
  }

  @override
  Future<String> recognizeBytes(Uint8List bytes, int width, int height) async {
    try {
      // bytes sind rohe RGBA-Pixel → erst als PNG kodieren.
      final pngBytes = await _rgbaToPng(bytes, width, height);
      return _process(pngBytes, Size(width.toDouble(), height.toDouble()));
    } catch (_) {
      return '';
    }
  }

  Future<String> _process(Uint8List bytes, Size size) async {
    final result = await _ctrl.processImage(RecognizeTextData(
      image: bytes,
      imageSize: size,
      recognitionLevel: RecognitionLevel.accurate,
      automaticallyDetectsLanguage: true,
    ));
    if (result == null || result.isEmpty) return '';
    return _groupByRows(result);
  }

  /// Gruppiert erkannte Text-Blöcke in visuelle Zeilen und gibt sie als String zurück.
  ///
  /// Apple Vision verwendet ein gespiegeltes Koordinatensystem (y=0 unten, y=1 oben).
  /// Durch `screenY = 1.0 - center.dy` wird auf Standard-Bildschirmkoordinaten
  /// (0=oben) normalisiert. Blöcke auf ähnlicher Höhe (innerhalb einer Blockzeilen-
  /// höhe) werden zur selben Zeile zusammengefasst und darin links→rechts sortiert.
  /// Dadurch werden z. B. "1-3" + "Unlocked." zu einer Zeile "1-3 Unlocked.".
  static String _groupByRows(List<RecognizedText> blocks) {
    if (blocks.isEmpty) return '';

    // y-Achse normalisieren: Apple Vision hat 0=unten, 1=oben → umkehren.
    final items = blocks.map((b) {
      final sy = 1.0 - b.boundingBox.center.dy; // screen-y: 0=oben, 1=unten
      final sx = b.boundingBox.center.dx;        // x unverändert
      final h = b.boundingBox.height;            // normalisierte Blockhöhe
      return (sy: sy, sx: sx, h: h, text: b.listText.first.trim());
    }).where((e) => e.text.isNotEmpty).toList()
      ..sort((a, b) => a.sy.compareTo(b.sy)); // oben → unten

    // Zeilengruppen bilden: gleiche Zeile wenn y-Abstand < Blockhöhe des Vorgängers.
    final rows = <List<({double sy, double sx, double h, String text})>>[];
    var row = [items.first];

    for (var i = 1; i < items.length; i++) {
      final prev = row.last;
      final curr = items[i];
      if (curr.sy - prev.sy < prev.h) {
        row.add(curr);
      } else {
        rows.add(row);
        row = [curr];
      }
    }
    rows.add(row);

    // Innerhalb jeder Zeile: links→rechts sortieren, mit Leerzeichen verbinden.
    return rows.map((r) {
      final s = r.toList()..sort((a, b) => a.sx.compareTo(b.sx));
      return s.map((e) => e.text).join(' ');
    }).join('\n');
  }

  /// Dekodiert ein JPEG/PNG-Byte-Array und liefert seine Dimensionen.
  static Future<Size> _sizeFromEncoded(Uint8List bytes) async {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    final img = await completer.future;
    final size = Size(img.width.toDouble(), img.height.toDouble());
    img.dispose();
    return size;
  }

  /// Konvertiert rohes RGBA zu PNG (Apple Vision akzeptiert kein RAW).
  static Future<Uint8List> _rgbaToPng(
      Uint8List rgba, int width, int height) async {
    final completer = Completer<Uint8List>();
    ui.decodeImageFromPixels(
      rgba,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (img) async {
        final bd = await img.toByteData(format: ui.ImageByteFormat.png);
        img.dispose();
        completer.complete(bd!.buffer.asUint8List());
      },
    );
    return completer.future;
  }

  @override
  Future<void> dispose() async {}
}

// ── Android: vision_text_recognition ─────────────────────────────────────────

class _VisionTextOcrImpl implements _OcrImpl {
  @override
  bool get isAvailable => true;

  @override
  Future<String> recognizeFile(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      return recognizeBytes(bytes, 0, 0);
    } catch (_) {
      return '';
    }
  }

  @override
  Future<String> recognizeBytes(
      Uint8List bytes, int width, int height) async {
    try {
      final result = await VisionTextRecognition.recognizeText(bytes);
      return result.fullText;
    } catch (_) {
      return '';
    }
  }

  @override
  Future<void> dispose() async {}
}

// ── Stub (Windows / Linux) ────────────────────────────────────────────────────

class _StubOcrImpl implements _OcrImpl {
  @override
  bool get isAvailable => false;

  @override
  Future<String> recognizeFile(String path) async => '';

  @override
  Future<String> recognizeBytes(
      Uint8List bytes, int width, int height) async => '';

  @override
  Future<void> dispose() async {}
}

// ── Öffentliche Fassade ────────────────────────────────────────────────────────

class OcrService {
  final _OcrImpl _impl;

  OcrService._(_OcrImpl impl) : _impl = impl;

  factory OcrService() {
    if (Platform.isMacOS || Platform.isIOS) {
      return OcrService._(_AppleVisionOcrImpl());
    }
    if (Platform.isAndroid) {
      return OcrService._(_VisionTextOcrImpl());
    }
    return OcrService._(_StubOcrImpl());
  }

  /// True wenn OCR auf dieser Plattform verfügbar ist.
  bool get isAvailable => _impl.isAvailable;

  /// Erkennt Text in einer Bilddatei (JPEG, PNG, TIFF, …).
  Future<String> recognizeFile(String path) => _impl.recognizeFile(path);

  /// Erkennt Text aus rohen RGBA-Pixeldaten (z. B. gerenderte PDF-Seite).
  Future<String> recognizeBytes(Uint8List bytes, int width, int height) =>
      _impl.recognizeBytes(bytes, width, height);

  Future<void> dispose() => _impl.dispose();
}
