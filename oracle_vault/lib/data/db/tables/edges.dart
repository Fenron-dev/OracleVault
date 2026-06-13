// Datei: lib/data/db/tables/edges.dart
//
// ZWECK: Generische Verknüpfungstabelle zwischen allen Entitäten.
//        Statt FK-Spalten in jeder Tabelle werden alle Relationen hier gespeichert.
//        Dadurch sind beliebige Relationstypen ohne Schema-Änderung möglich
//        und Backlinks liefert eine einzige Query.
// ABHÄNGIGKEITEN: drift
// PHASE: 0 – Grundschema (aktiv ab Phase 5 für Wiki-Links).

import 'package:drift/drift.dart';

/// Eine gerichtete Verknüpfung zwischen zwei Entitäten.
///
/// [fromType] / [toType]: 'table' | 'entry' | 'media' | 'source' | 'tag' | 'collection'
/// [relation]: 'wikilink' | 'subtable' | 'embed' | 'translation_of' | 'used_in' | …
///
/// [metadataJson] für relations-spezifische Zusatzdaten.
class Edges extends Table {
  TextColumn get id => text()();
  TextColumn get fromType => text()();
  TextColumn get fromId => text()();
  TextColumn get toType => text()();
  TextColumn get toId => text()();

  /// Typ der Relation.
  TextColumn get relation => text()();

  /// Optionale Zusatzdaten als JSON.
  TextColumn get metadataJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
