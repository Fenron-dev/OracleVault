// Datei: lib/data/db/tables/entries.dart
//
// ZWECK: Einzelne Einträge einer Oracle-Tabelle.
//        Ein Eintrag kann reiner Text, Text+Medium, Medium allein,
//        Subtable-Verweis oder Wiki-Link-Ziel sein.
// ABHÄNGIGKEITEN: drift, oracle_tables.dart, media_files.dart
// PHASE: 0 – Grundschema.

import 'package:drift/drift.dart';

import 'oracle_tables.dart';
import 'media_files.dart';

// @ReferenceName wird benötigt weil Entries zwei FK-Spalten auf OracleTables hat
// (tableId und subtableId) — ohne Annotation erzeugt Drift doppelte Manager-Namen.

/// Einzelner Eintrag innerhalb einer [OracleTables]-Zeile.
///
/// [weight]   wird bei oracleType='weighted' als relatives Gewicht genutzt.
/// [rollMin]/[rollMax] definieren den W.-Bereich bei oracleType='dice'.
/// [confidenceLow] kennzeichnet KI-importierte Einträge mit niedriger Konfidenz
///   (gelbe Hervorhebung im UI, wird bei manueller Bearbeitung gelöscht).
/// [modifierJson] enthält Entry-spezifische Zusatzdaten, z. B.
///   {reversed_possible: true} für Tarot-Karten.
class Entries extends Table {
  TextColumn get id => text()();
  @ReferenceName('entries')
  TextColumn get tableId => text().references(OracleTables, #id)();

  /// Anzeigereihenfolge innerhalb der Tabelle.
  IntColumn get position => integer()();

  /// Kurztext / Hauptinhalt des Eintrags.
  TextColumn get content => text()();

  /// Optionaler Langtext in Markdown für reichhaltige Einträge (NSCs, Locations).
  TextColumn get bodyMd => text().nullable()();

  /// Relatives Gewicht für oracleType='weighted'. Default = 1.
  RealColumn get weight => real().withDefault(const Constant(1.0))();

  /// Inklusiver Mindestwert für dice-Mapping. Null wenn kein dice-Typ.
  IntColumn get rollMin => integer().nullable()();

  /// Inklusiver Maximalwert für dice-Mapping. Null wenn kein dice-Typ.
  IntColumn get rollMax => integer().nullable()();

  /// Verweis auf ein Media-Asset (Bild, Audio, ...).
  TextColumn get mediaId => text().nullable().references(MediaFiles, #id)();

  /// Verweis auf eine Unter-Tabelle, die bei Ziehen automatisch aufgelöst wird.
  /// Zyklus-Erkennung erfolgt in der Roll-Engine.
  @ReferenceName('subtableEntries')
  TextColumn get subtableId => text().nullable().references(OracleTables, #id)();

  /// KI-Import-Marker: true = niedriger Konfidenz-Score, gelbe Hervorhebung.
  BoolColumn get confidenceLow =>
      boolean().withDefault(const Constant(false))();

  /// Entry-spezifische Zusatzdaten als JSON.
  TextColumn get modifierJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
