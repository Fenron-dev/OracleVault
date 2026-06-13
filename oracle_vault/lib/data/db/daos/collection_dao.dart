// Datei: lib/data/db/daos/collection_dao.dart
//
// ZWECK: Zugriff auf Collections und CollectionTables.
//        Eine Collection bündelt zusammengehörige OracleTables
//        (z. B. ein RPG-Supplement oder ein Tarot-Deck).
// PHASE: 4

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../vault_database.dart';
import '../tables/collections.dart';
import '../tables/oracle_tables.dart';

part 'collection_dao.g.dart';

const _uuid = Uuid();

@DriftAccessor(tables: [Collections, CollectionTables, OracleTables])
class CollectionDao extends DatabaseAccessor<VaultDatabase>
    with _$CollectionDaoMixin {
  CollectionDao(super.db);

  // ── Schreiben ──────────────────────────────────────────────────────────────

  /// Legt eine neue Collection an und gibt ihre ID zurück.
  Future<String> createCollection({
    required String name,
    String? description,
    String type = 'generic',
  }) async {
    final id = _uuid.v4();
    await into(collections).insert(CollectionsCompanion.insert(
      id: id,
      name: name,
      description: Value(description),
      type: Value(type),
    ));
    return id;
  }

  /// Fügt eine Tabelle zu einer Collection hinzu.
  Future<void> addTable(String collectionId, String tableId,
      {int position = 0}) async {
    await into(collectionTables).insertOnConflictUpdate(
      CollectionTablesCompanion.insert(
        collectionId: collectionId,
        tableId: tableId,
        position: position,
      ),
    );
  }

  /// Fügt mehrere Tabellen zu einer Collection hinzu (in Reihenfolge).
  Future<void> addTables(String collectionId, List<String> tableIds) async {
    for (int i = 0; i < tableIds.length; i++) {
      await addTable(collectionId, tableIds[i], position: i);
    }
  }

  /// Löst alle bisherigen Collection-Zuordnungen der Tabellen auf und
  /// weist sie der angegebenen Collection zu (atomare Transaktion).
  Future<void> bulkAssignToCollection(
      String collectionId, List<String> tableIds) async {
    await transaction(() async {
      for (final tid in tableIds) {
        await (delete(collectionTables)
              ..where((t) => t.tableId.equals(tid)))
            .go();
      }
      for (int i = 0; i < tableIds.length; i++) {
        await into(collectionTables).insertOnConflictUpdate(
          CollectionTablesCompanion.insert(
            collectionId: collectionId,
            tableId: tableIds[i],
            position: i,
          ),
        );
      }
    });
  }

  Future<void> deleteCollection(String id) async {
    await (delete(collectionTables)
          ..where((t) => t.collectionId.equals(id)))
        .go();
    await (delete(collections)..where((c) => c.id.equals(id))).go();
  }

  Future<void> removeTable(String collectionId, String tableId) async {
    await (delete(collectionTables)
          ..where((t) =>
              t.collectionId.equals(collectionId) &
              t.tableId.equals(tableId)))
        .go();
  }

  // ── Lesen ──────────────────────────────────────────────────────────────────

  Stream<List<Collection>> watchAll() =>
      (select(collections)..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .watch();

  Future<Collection?> fetchById(String id) =>
      (select(collections)..where((c) => c.id.equals(id)))
          .getSingleOrNull();

  /// Alle Tabellen einer Collection, nach Position sortiert.
  Stream<List<OracleTable>> watchTablesFor(String collectionId) {
    final query = select(oracleTables).join([
      innerJoin(
        collectionTables,
        collectionTables.tableId.equalsExp(oracleTables.id) &
            collectionTables.collectionId.equals(collectionId),
      ),
    ])
      ..orderBy([
        OrderingTerm.asc(collectionTables.position),
      ]);
    return query.map((row) => row.readTable(oracleTables)).watch();
  }

  /// IDs aller Tabellen die zu einer Collection gehören.
  Future<Set<String>> fetchTableIdsFor(String collectionId) async {
    final rows = await (select(collectionTables)
          ..where((t) => t.collectionId.equals(collectionId)))
        .get();
    return rows.map((r) => r.tableId).toSet();
  }

  /// Collection in der eine Tabelle enthalten ist (null = keine).
  Future<Collection?> collectionOf(String tableId) async {
    final row = await (select(collectionTables)
          ..where((t) => t.tableId.equals(tableId)))
        .getSingleOrNull();
    if (row == null) return null;
    return fetchById(row.collectionId);
  }
}
