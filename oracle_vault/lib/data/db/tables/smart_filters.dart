// Datei: lib/data/db/tables/smart_filters.dart
//
// ZWECK: Gespeicherte Filterdefinitionen.
//        Das {logic, rules}-JSON-Format ist identisch mit MediaShelf,
//        damit Filter portierbar bleiben.
// ABHÄNGIGKEITEN: drift
// PHASE: 0 – Grundschema (Nutzung ab Phase 1).

import 'package:drift/drift.dart';

/// Ein gespeicherter, wiederverwendbarer Filter.
///
/// [filterJson] folgt dem Schema:
///   { "logic": "and" | "or", "rules": [ {field, op, value}, … ] }
class SmartFilters extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// Filter-Definition als JSON. Kompatibel mit MediaShelf-SmartFilters.
  TextColumn get filterJson => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
