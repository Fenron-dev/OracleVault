// Datei: lib/services/media/media_service.dart
//
// ZWECK: Import und Verwaltung von Datei-Assets innerhalb eines Vaults.
//        - kopiert Dateien in media/<subtype>/ (relativ zum Vault-Ordner)
//        - berechnet einen SHA-256-Hash per Streaming (auch für große Videos)
//        - dedupliziert: identischer Inhalt wird nur einmal gespeichert
//        - löscht physische Dateien nur, wenn kein DB-Record mehr darauf zeigt
//
// ABHÄNGIGKEITEN: dart:io, dart:convert, crypto, mime, path, uuid
// PHASE: 4

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../data/db/daos/media_dao.dart';
import '../../data/db/vault_database.dart';
import '../../data/vault/vault_manager.dart';

/// Verwaltet Datei-Assets eines geöffneten Vaults.
///
/// INSTANZIIERUNG: über `mediaServiceProvider` in di.dart, gebunden an den
/// aktuell geöffneten Vault.
class MediaService {
  final VaultDatabase db;
  final String vaultPath;

  MediaService({required this.db, required this.vaultPath});

  static const _uuid = Uuid();

  MediaDao get _dao => db.mediaDao;

  // ── Import ──────────────────────────────────────────────────────────────

  /// Importiert [source] in den Vault und legt einen [MediaFile]-Record an.
  ///
  /// DEDUPLIZIERUNG: Existiert bereits ein Asset mit demselben SHA-256-Hash,
  /// wird dieses zurückgegeben und nichts kopiert.
  Future<MediaFile> importFile(
    File source, {
    String? title,
    Map<String, dynamic>? metadata,
  }) async {
    if (!await source.exists()) {
      throw MediaImportException('Datei nicht gefunden: ${source.path}');
    }

    final hash = await _hashFile(source);

    final existing = await _dao.fetchByHash(hash);
    if (existing != null) return existing;

    final mime = lookupMimeType(source.path);
    final type = mediaTypeFor(mime, source.path);
    final subtype = _subdirFor(type);

    // Zieldateiname aus Hash-Präfix + Originalendung → kollisionsfrei und
    // deterministisch (gleicher Inhalt ⇒ gleicher Name).
    final ext = p.extension(source.path).toLowerCase();
    final fileName = '${hash.substring(0, 16)}$ext';

    final destDir = VaultManager.mediaDir(vaultPath, subtype);
    await Directory(destDir).create(recursive: true);
    final destPath = p.join(destDir, fileName);
    final destFile = File(destPath);
    if (!await destFile.exists()) {
      await source.copy(destPath);
    }

    final relPath = p.join('media', subtype, fileName);
    final bytes = await source.length();
    final meta = <String, dynamic>{...?metadata, 'bytes': bytes};
    final id = _uuid.v4();

    await _dao.insertMedia(MediaFilesCompanion.insert(
      id: id,
      type: type,
      filePath: relPath,
      hash: hash,
      mime: Value(mime),
      title: Value(title ?? p.basenameWithoutExtension(source.path)),
      metadataJson: Value(jsonEncode(meta)),
      createdAt: DateTime.now(),
    ));

    return (await _dao.fetchById(id))!;
  }

  // ── Pfad-Auflösung ──────────────────────────────────────────────────────

  /// Absoluter Pfad eines Assets (vaultPath + relativer filePath).
  String absolutePath(MediaFile media) => p.join(vaultPath, media.filePath);

  File fileFor(MediaFile media) => File(absolutePath(media));

  // ── Löschen ─────────────────────────────────────────────────────────────

  /// Entfernt den DB-Record. Die physische Datei wird nur gelöscht, wenn kein
  /// weiterer Record denselben Hash referenziert (deduplizierte Assets können
  /// sich eine Datei teilen).
  Future<void> deleteMedia(MediaFile media, {bool removeFile = true}) async {
    await _dao.deleteMedia(media.id);
    if (!removeFile) return;
    final remaining = await _dao.countByHash(media.hash);
    if (remaining == 0) {
      final f = fileFor(media);
      if (await f.exists()) await f.delete();
    }
  }

  // ── Helfer ──────────────────────────────────────────────────────────────

  /// SHA-256 per Streaming — lädt die Datei nicht komplett in den Speicher.
  Future<String> _hashFile(File f) async {
    Digest? digest;
    final sink = ChunkedConversionSink<Digest>.withCallback(
      (digests) => digest = digests.single,
    );
    final input = sha256.startChunkedConversion(sink);
    await for (final chunk in f.openRead()) {
      input.add(chunk);
    }
    input.close();
    return digest!.toString();
  }

  /// Leitet den Asset-Typ aus MIME-Type bzw. Dateiendung ab.
  static String mediaTypeFor(String? mime, String path) {
    final m = mime ?? '';
    if (m.startsWith('image/')) return 'image';
    if (m.startsWith('audio/')) return 'audio';
    if (m.startsWith('video/')) return 'video';
    if (m.isNotEmpty) return 'document';

    final ext = p.extension(path).toLowerCase().replaceFirst('.', '');
    const img = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'tiff', 'tif'};
    const aud = {'mp3', 'wav', 'ogg', 'flac', 'm4a', 'aac'};
    const vid = {'mp4', 'mov', 'mkv', 'webm', 'avi'};
    if (img.contains(ext)) return 'image';
    if (aud.contains(ext)) return 'audio';
    if (vid.contains(ext)) return 'video';
    return 'document';
  }

  static String _subdirFor(String type) => switch (type) {
        'image' => 'images',
        'audio' => 'audio',
        'video' => 'video',
        _ => 'documents',
      };
}

class MediaImportException implements Exception {
  final String message;
  MediaImportException(this.message);
  @override
  String toString() => 'MediaImportException: $message';
}
