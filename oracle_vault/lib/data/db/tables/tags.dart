// Datei: lib/data/db/tables/tags.dart
//
// ZWECK: Tags (frei vergebbar, n:m zu OracleTables) und deren Zuordnungstabelle.
// ABHÄNGIGKEITEN: drift, oracle_tables.dart
// PHASE: 0 – Grundschema.

import 'package:drift/drift.dart';

import 'oracle_tables.dart';

/// Ein Tag-Label.
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Verbindungstabelle: OracleTable ↔ Tag (n:m).
class TableTags extends Table {
  TextColumn get tableId => text().references(OracleTables, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {tableId, tagId};
}
