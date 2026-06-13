// Datei: lib/data/db/daos/source_dao.dart
//
// ZWECK: Datenbankzugriff für Quellen (Sources).
// ABHÄNGIGKEITEN: drift, vault_database.dart
// PHASE: 1

import 'package:drift/drift.dart';

import '../vault_database.dart';
import '../tables/sources.dart';

part 'source_dao.g.dart';

@DriftAccessor(tables: [Sources])
class SourceDao extends DatabaseAccessor<VaultDatabase> with _$SourceDaoMixin {
  SourceDao(super.db);

  Stream<List<Source>> watchAll() =>
      (select(sources)..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
          .watch();

  Future<List<Source>> fetchAll() =>
      (select(sources)..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
          .get();

  Future<Source?> fetchById(String id) =>
      (select(sources)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<void> insertSource(SourcesCompanion src) =>
      into(sources).insert(src);

  Future<bool> updateSource(SourcesCompanion src) =>
      update(sources).replace(src);

  Future<int> deleteSource(String id) =>
      (delete(sources)..where((s) => s.id.equals(id))).go();
}
