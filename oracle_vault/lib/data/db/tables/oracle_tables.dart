// Datei: lib/data/db/tables/oracle_tables.dart
//
// ZWECK: Drift-Tabellendefinition für Oracle-Tabellen (die ziehbaren Sammlungen).
//        Dateiname 'oracle_tables' statt 'tables', weil 'tables' mit dem
//        Drift-internen Bezeichner kollidiert.
// ABHÄNGIGKEITEN: drift, categories.dart, sources.dart
// PHASE: 0 – Grundschema.

import 'package:drift/drift.dart';

import 'categories.dart';
import 'sources.dart';

/// Die ziehbare Tabelle / das Orakel — zentrales Datenmodell.
///
/// [oracleType] steuert die Zieh-Mechanik:
///   'uniform'  – Gleichverteilung
///   'weighted' – gewichtet nach Entry.weight
///   'dice'     – Würfelausdruck [diceExpr] wird ausgewertet, Ergebnis auf rollMin/rollMax gemappt
///   'deck'     – Ziehen ohne Zurücklegen; DeckState wird separat persistiert
///
/// [language] ist ISO 639-1 ('de', 'en', ...).
/// Mehrsprachige Versionen sind EIGENE Tabellen, verbunden via Edge(relation='translation_of').
class OracleTables extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();

  /// Zieh-Mechanik: 'uniform' | 'weighted' | 'dice' | 'deck'
  TextColumn get oracleType => text().withDefault(const Constant('uniform'))();

  /// Würfelausdruck für oracleType='dice', z. B. '1d20', '2d6+3'.
  TextColumn get diceExpr => text().nullable()();

  TextColumn get genre => text().nullable()();
  TextColumn get theme => text().nullable()();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get sourceId => text().nullable().references(Sources, #id)();

  /// ISO 639-1 Sprachcode der Einträge.
  TextColumn get language => text().withDefault(const Constant('de'))();

  /// Flexibles JSON-Feld für zukünftige Metadaten ohne Schema-Änderung.
  TextColumn get metadataJson => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
