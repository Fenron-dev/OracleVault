// Datei: lib/data/db/tables/sources.dart
//
// ZWECK: Drift-Tabellendefinition für Quellen (Sources).
//        Eine Source beschreibt die Herkunft einer Tabelle: Buch, URL, PDF,
//        manuelle Eingabe oder KI-Generierung.
// ABHÄNGIGKEITEN: drift
// PHASE: 0 – Grundschema.

import 'package:drift/drift.dart';

/// Herkunft einer Tabelle oder Sammlung.
///
/// Für KI-generierte Inhalte enthält [aiProviderJson] ein Objekt mit
/// {provider, model, model_version_seen_at, system_prompt, user_prompt, params, seed},
/// das eine spätere Reproduktion ermöglicht.
class Sources extends Table {
  // UUID als Primary Key – Pflicht für Sync und Bundle-Export.
  TextColumn get id => text()();

  /// Typ der Quelle.
  /// Erlaubte Werte: 'book' | 'url' | 'pdf' | 'file' | 'manual' |
  ///                 'ai_generation' | 'reddit' | 'rss'
  TextColumn get type => text()();

  TextColumn get title => text().nullable()();
  TextColumn get author => text().nullable()();
  TextColumn get url => text().nullable()();
  TextColumn get license => text().nullable()();

  /// JSON-Objekt bei type='ai_generation':
  /// {provider, model, model_version_seen_at, system_prompt, user_prompt, params, seed}
  TextColumn get aiProviderJson => text().nullable()();

  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
