// Datei: lib/data/db/tables/collections.dart
//
// ZWECK: Sammlungen, die mehrere OracleTables gruppieren
//        (z. B. ein Tarot-Deck, ein Token-Pack, ein Quellenbuch).
// ABHÄNGIGKEITEN: drift, oracle_tables.dart
// PHASE: 0 – Grundschema (Nutzung ab Phase 4).

import 'package:drift/drift.dart';

import 'oracle_tables.dart';

/// Eine benannte Sammlung mehrerer Oracle-Tabellen.
///
/// [type]: 'deck' | 'supplement' | 'generic'
class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();

  /// Art der Sammlung: 'deck' | 'supplement' | 'generic'
  TextColumn get type => text().withDefault(const Constant('generic'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Verbindungstabelle: Collection ↔ OracleTable, geordnet nach [position].
class CollectionTables extends Table {
  TextColumn get collectionId => text().references(Collections, #id)();
  TextColumn get tableId => text().references(OracleTables, #id)();

  /// Reihenfolge der Tabelle innerhalb der Sammlung.
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {collectionId, tableId};
}
