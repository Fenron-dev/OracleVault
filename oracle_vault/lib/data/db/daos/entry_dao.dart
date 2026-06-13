// Datei: lib/data/db/daos/entry_dao.dart
//
// ZWECK: Datenbankzugriff für Einträge einer Oracle-Tabelle.
//        Schreib-Operationen aktualisieren auch updatedAt der Eltern-Tabelle.
// ABHÄNGIGKEITEN: drift, vault_database.dart
// PHASE: 1

import 'package:drift/drift.dart';

import '../vault_database.dart';
import '../tables/entries.dart';
import '../tables/oracle_tables.dart';

part 'entry_dao.g.dart';

@DriftAccessor(tables: [Entries, OracleTables])
class EntryDao extends DatabaseAccessor<VaultDatabase> with _$EntryDaoMixin {
  EntryDao(super.db);

  // ── Lesen ─────────────────────────────────────────────────────────────────

  /// Alle Einträge einer Tabelle, sortiert nach Position.
  Stream<List<Entry>> watchForTable(String tableId) =>
      (select(entries)
            ..where((e) => e.tableId.equals(tableId))
            ..orderBy([(e) => OrderingTerm.asc(e.position)]))
          .watch();

  Future<List<Entry>> fetchForTable(String tableId) =>
      (select(entries)
            ..where((e) => e.tableId.equals(tableId))
            ..orderBy([(e) => OrderingTerm.asc(e.position)]))
          .get();

  Future<int> countForTable(String tableId) async {
    final count = countAll();
    final query = selectOnly(entries)
      ..addColumns([count])
      ..where(entries.tableId.equals(tableId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // ── Schreiben ──────────────────────────────────────────────────────────────

  Future<void> insertEntry(EntriesCompanion entry) async {
    await into(entries).insert(entry);
    await _touchTable(entry.tableId.value);
  }

  Future<bool> updateEntry(EntriesCompanion entry) async {
    final ok = await update(entries).replace(entry);
    await _touchTable(entry.tableId.value);
    return ok;
  }

  Future<int> deleteEntry(String id, String tableId) async {
    final count = await (delete(entries)..where((e) => e.id.equals(id))).go();
    await _touchTable(tableId);
    return count;
  }

  /// Ersetzt alle Einträge einer Tabelle auf einmal (Bulk-Speichern).
  /// Fügt neue Einträge hinzu ohne bestehende zu löschen (für KI-Erweiterung).
  Future<void> insertAll(List<EntriesCompanion> newEntries) async {
    if (newEntries.isEmpty) return;
    await transaction(() async {
      for (final entry in newEntries) {
        await into(entries).insert(entry);
      }
      if (newEntries.isNotEmpty) {
        await _touchTable(newEntries.first.tableId.value);
      }
    });
  }

  Future<void> replaceAll(String tableId, List<EntriesCompanion> all) async {
    await transaction(() async {
      await (delete(entries)..where((e) => e.tableId.equals(tableId))).go();
      for (final entry in all) {
        await into(entries).insert(entry);
      }
      await _touchTable(tableId);
    });
  }

  Future<void> _touchTable(String tableId) async {
    await (update(oracleTables)..where((t) => t.id.equals(tableId))).write(
      OracleTablesCompanion(updatedAt: Value(DateTime.now())),
    );
  }
}
