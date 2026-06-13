// Datei: lib/data/db/tables/categories.dart
//
// ZWECK: Hierarchische Kategorien für Tabellen (z. B. Bestiarium > Goblins).
// ABHÄNGIGKEITEN: drift
// PHASE: 0 – Grundschema.

import 'package:drift/drift.dart';

/// Kategorie-Baum für Tabellen.
///
/// [parentId] verweist auf die übergeordnete Kategorie in derselben Tabelle.
/// NULL bedeutet Top-Level-Kategorie.
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Eltern-Kategorie. Null = Top-Level.
  TextColumn get parentId => text().nullable().references(Categories, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
