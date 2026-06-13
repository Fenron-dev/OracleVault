// Datei: lib/data/db/daos/media_dao.dart
//
// ZWECK: Datenbankzugriff für Datei-Assets (MediaFiles).
//        Deduplizierung erfolgt über den SHA-256-Hash (fetchByHash).
// ABHÄNGIGKEITEN: drift, vault_database.dart
// PHASE: 4

import 'package:drift/drift.dart';

import '../vault_database.dart';
import '../tables/media_files.dart';

part 'media_dao.g.dart';

@DriftAccessor(tables: [MediaFiles])
class MediaDao extends DatabaseAccessor<VaultDatabase> with _$MediaDaoMixin {
  MediaDao(super.db);

  Stream<List<MediaFile>> watchAll() =>
      (select(mediaFiles)..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
          .watch();

  Future<List<MediaFile>> fetchAll() =>
      (select(mediaFiles)..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
          .get();

  /// Alle Assets eines Typs ('image' | 'audio' | 'video' | 'document').
  Stream<List<MediaFile>> watchByType(String type) =>
      (select(mediaFiles)
            ..where((m) => m.type.equals(type))
            ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
          .watch();

  Future<MediaFile?> fetchById(String id) =>
      (select(mediaFiles)..where((m) => m.id.equals(id))).getSingleOrNull();

  /// Dublettenerkennung: liefert ein bereits importiertes Asset mit gleichem
  /// Inhalt (gleichem SHA-256-Hash), sonst null.
  Future<MediaFile?> fetchByHash(String hash) =>
      (select(mediaFiles)..where((m) => m.hash.equals(hash)))
          .getSingleOrNull();

  /// Zählt, wie viele Records auf denselben Hash zeigen — wird vor dem Löschen
  /// der physischen Datei geprüft, damit kein noch referenziertes Asset
  /// entfernt wird.
  Future<int> countByHash(String hash) async {
    final count = mediaFiles.id.count();
    final query = selectOnly(mediaFiles)
      ..addColumns([count])
      ..where(mediaFiles.hash.equals(hash));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  Future<void> insertMedia(MediaFilesCompanion media) =>
      into(mediaFiles).insert(media);

  Future<bool> updateMedia(MediaFilesCompanion media) =>
      update(mediaFiles).replace(media);

  Future<int> deleteMedia(String id) =>
      (delete(mediaFiles)..where((m) => m.id.equals(id))).go();
}
