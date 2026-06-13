// Datei: lib/data/db/daos/table_dao.dart
//
// ZWECK: Datenbankzugriff für Oracle-Tabellen.
//        Reaktive Streams via .watch() für Riverpod-StreamProvider.
// ABHÄNGIGKEITEN: drift, vault_database.dart
// PHASE: 1

import 'package:drift/drift.dart';

import '../vault_database.dart';
import '../tables/oracle_tables.dart';
import '../tables/tags.dart';
import '../tables/entries.dart';

part 'table_dao.g.dart';

@DriftAccessor(tables: [OracleTables, Entries, Tags, TableTags])
class TableDao extends DatabaseAccessor<VaultDatabase> with _$TableDaoMixin {
  TableDao(super.db);

  // ── Lesen ─────────────────────────────────────────────────────────────────

  /// Alle Tabellen, neueste zuerst.
  Stream<List<OracleTable>> watchAll() =>
      (select(oracleTables)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();

  /// Alle Tabellen einmalig (für Exports, Command-Palette).
  Future<List<OracleTable>> fetchAll() =>
      (select(oracleTables)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();

  /// Eine Tabelle per ID.
  Future<OracleTable?> fetchById(String id) =>
      (select(oracleTables)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<OracleTable?> watchById(String id) =>
      (select(oracleTables)..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// Tabellen einer Kategorie.
  Stream<List<OracleTable>> watchByCategory(String categoryId) =>
      (select(oracleTables)
            ..where((t) => t.categoryId.equals(categoryId))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();

  /// Tags einer Tabelle.
  Future<List<Tag>> fetchTagsFor(String tableId) async {
    final query = select(tags).join([
      innerJoin(tableTags, tableTags.tagId.equalsExp(tags.id)),
    ])
      ..where(tableTags.tableId.equals(tableId));
    return query.map((row) => row.readTable(tags)).get();
  }

  Stream<List<Tag>> watchTagsFor(String tableId) {
    final query = select(tags).join([
      innerJoin(tableTags, tableTags.tagId.equalsExp(tags.id)),
    ])
      ..where(tableTags.tableId.equals(tableId));
    return query.map((row) => row.readTable(tags)).watch();
  }

  /// FTS5-Volltextsuche: gibt Tabellen-IDs zurück, die zu [query] passen.
  /// Leerer Query → leere Liste.
  Future<List<String>> searchTableIds(String query) async {
    if (query.trim().isEmpty) return [];
    // FTS5-Match mit Wildcard am Ende für Prefix-Suche.
    final safeQuery = '${query.trim().replaceAll('"', '')}*';
    final rows = await db.customSelect(
      'SELECT DISTINCT table_id FROM entries_fts WHERE entries_fts MATCH ? ORDER BY rank',
      variables: [Variable.withString(safeQuery)],
    ).get();
    return rows.map((r) => r.read<String>('table_id')).toList();
  }

  // ── Schreiben ──────────────────────────────────────────────────────────────

  Future<void> insertTable(OracleTablesCompanion table) =>
      into(oracleTables).insert(table);

  // replace() würde DELETE+INSERT machen und alle Felder benötigen.
  // write() aktualisiert nur Felder mit Value(...), überspringt Value.absent().
  Future<int> updateTable(OracleTablesCompanion table) =>
      (update(oracleTables)..where((t) => t.id.equals(table.id.value)))
          .write(table);

  Future<int> deleteTable(String id) =>
      (delete(oracleTables)..where((t) => t.id.equals(id))).go();

  Future<void> bulkDelete(List<String> ids) => transaction(() async {
        for (final id in ids) {
          await (delete(oracleTables)..where((t) => t.id.equals(id))).go();
        }
      });

  Future<void> bulkUpdateLanguage(List<String> ids, String language) =>
      transaction(() async {
        final now = DateTime.now();
        for (final id in ids) {
          await (update(oracleTables)..where((t) => t.id.equals(id))).write(
            OracleTablesCompanion(
              language: Value(language),
              updatedAt: Value(now),
            ),
          );
        }
      });

  Future<void> bulkUpdateCategory(
          List<String> ids, String? categoryId) =>
      transaction(() async {
        final now = DateTime.now();
        for (final id in ids) {
          await (update(oracleTables)..where((t) => t.id.equals(id))).write(
            OracleTablesCompanion(
              categoryId: Value(categoryId),
              updatedAt: Value(now),
            ),
          );
        }
      });

  // ── Tags einer Tabelle setzen (ersetzt vollständig) ────────────────────────

  Future<void> setTagsFor(String tableId, List<String> tagIds) async {
    await transaction(() async {
      await (delete(tableTags)
            ..where((tt) => tt.tableId.equals(tableId)))
          .go();
      for (final tagId in tagIds) {
        await into(tableTags).insertOnConflictUpdate(
            TableTagsCompanion.insert(tableId: tableId, tagId: tagId));
      }
    });
  }
}
