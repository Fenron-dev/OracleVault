// Datei: lib/data/db/tables/inbox_items.dart
//
// ZWECK: Staging-Einträge aus Beobachtungsquellen.
//        Neue Funde landen hier mit Status 'pending', bis der Nutzer
//        sie akzeptiert oder verwirft – nie direkt in der Hauptlibrary.
// ABHÄNGIGKEITEN: drift, watch_sources.dart, oracle_tables.dart
// PHASE: 0 – Grundschema (aktiv ab Phase 6).

import 'package:drift/drift.dart';

import 'watch_sources.dart';
import 'oracle_tables.dart';

/// Ein gefundener, noch nicht verarbeiteter Eintrag aus einer [WatchSources]-Quelle.
///
/// [status]: 'pending' | 'accepted' | 'dismissed' | 'auto_imported'
/// [rawDataJson]: das vollständige Roh-Item zur späteren Verarbeitung
///   (Titel, URL, Inhalt, Metadaten je nach Quellen-Typ).
class InboxItems extends Table {
  TextColumn get id => text()();
  TextColumn get watchSourceId => text().references(WatchSources, #id)();

  /// Verarbeitungsstatus: 'pending' | 'accepted' | 'dismissed' | 'auto_imported'
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// Vollständige Roh-Daten als JSON für nachträgliche Verarbeitung.
  TextColumn get rawDataJson => text()();

  /// Verknüpfte OracleTable nach erfolgtem Import. Null solange pending.
  TextColumn get importedTableId =>
      text().nullable().references(OracleTables, #id)();

  DateTimeColumn get foundAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
