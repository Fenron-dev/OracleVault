// Datei: lib/services/media/thumbnail_service.dart
//
// ZWECK: Generiert und cached Thumbnails für Bild-Assets.
//        - Cache liegt in .oraclevault/thumbnails/ (regenerierbar, nicht im Backup)
//        - Cache-Key = <hash>_<size>.jpg → deduplizierungsfreundlich
//        - Decodierung/Skalierung läuft in einem Isolate (UI bleibt flüssig)
//        - begrenzte Parallelität (Pool): max. [maxConcurrent] Isolates gleichzeitig
//
// ABHÄNGIGKEITEN: dart:io, dart:async, dart:isolate, image, path
// PHASE: 4

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../data/db/vault_database.dart';
import '../../data/vault/vault_manager.dart';

/// Erzeugt Thumbnails für Bild-Assets und cached sie im Vault.
///
/// INSTANZIIERUNG: über `thumbnailServiceProvider` in di.dart.
class ThumbnailService {
  final String vaultPath;

  /// Maximale Anzahl gleichzeitig laufender Generierungs-Isolates.
  final int maxConcurrent;

  ThumbnailService({required this.vaultPath, this.maxConcurrent = 4});

  // Semaphore zur Begrenzung paralleler Isolates.
  int _active = 0;
  final _waiters = <Completer<void>>[];

  String cacheDir() => VaultManager.thumbnailsDir(vaultPath);

  /// Cache-Pfad eines Thumbnails (nach Inhalts-Hash + Kantenlänge).
  String cachePathFor(String hash, int size) =>
      p.join(cacheDir(), '${hash}_$size.jpg');

  /// Liefert die Thumbnail-Datei für [media], erzeugt sie bei Bedarf.
  ///
  /// Gibt null zurück für Nicht-Bild-Assets, fehlende Quelldateien oder wenn
  /// die Decodierung fehlschlägt. [size] ist die längere Kante in Pixeln.
  Future<File?> thumbnailFor(MediaFile media, {int size = 256}) async {
    if (media.type != 'image') return null;

    final dest = cachePathFor(media.hash, size);
    final destFile = File(dest);
    if (await destFile.exists()) return destFile;

    final srcPath = p.join(vaultPath, media.filePath);
    if (!await File(srcPath).exists()) return null;

    await Directory(cacheDir()).create(recursive: true);

    await _acquire();
    try {
      final ok = await Isolate.run(
        () => _generateThumbnail(srcPath, dest, size),
      );
      if (!ok) return null;
    } finally {
      _release();
    }
    return await destFile.exists() ? destFile : null;
  }

  /// Entfernt alle gecachten Thumbnails eines Assets (z. B. nach dem Löschen).
  Future<void> evict(MediaFile media) async {
    final dir = Directory(cacheDir());
    if (!await dir.exists()) return;
    await for (final e in dir.list()) {
      if (e is File && p.basename(e.path).startsWith('${media.hash}_')) {
        await e.delete();
      }
    }
  }

  // ── Semaphore ─────────────────────────────────────────────────────────────

  Future<void> _acquire() {
    if (_active < maxConcurrent) {
      _active++;
      return Future.value();
    }
    final c = Completer<void>();
    _waiters.add(c);
    return c.future; // erhält beim Freiwerden direkt einen Slot
  }

  void _release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0).complete(); // Slot direkt weiterreichen
    } else {
      _active--;
    }
  }
}

/// Top-Level-Funktion (Isolate-Entry): decodiert, skaliert proportional auf
/// [size] längere Kante (ohne Hochskalieren) und schreibt ein JPEG.
/// Synchrones IO ist im Isolate unkritisch und vereinfacht die Übergabe.
bool _generateThumbnail(String srcPath, String destPath, int size) {
  try {
    final bytes = File(srcPath).readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return false;

    final longest =
        decoded.width >= decoded.height ? decoded.width : decoded.height;

    final img.Image out;
    if (longest <= size) {
      out = decoded; // nicht hochskalieren
    } else if (decoded.width >= decoded.height) {
      out = img.copyResize(decoded, width: size);
    } else {
      out = img.copyResize(decoded, height: size);
    }

    File(destPath).writeAsBytesSync(img.encodeJpg(out, quality: 80));
    return true;
  } catch (_) {
    return false;
  }
}
