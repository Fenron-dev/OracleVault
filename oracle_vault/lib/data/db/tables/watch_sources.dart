// Datei: lib/data/db/tables/watch_sources.dart
//
// ZWECK: Konfiguration wiederkehrender Beobachtungsquellen
//        (Reddit-Sub, RSS-Feed, lokaler Ordner).
// ABHÄNGIGKEITEN: drift
// PHASE: 0 – Grundschema (aktiv ab Phase 6).

import 'package:drift/drift.dart';

/// Konfiguration einer Beobachtungsquelle.
///
/// [type]: 'reddit' | 'rss' | 'folder'
/// [config]: JSON mit quellenspezifischen Feldern:
///   reddit: {subreddit, keywords, min_score}
///   rss:    {url, css_selector}
///   folder: {path}
class WatchSources extends Table {
  TextColumn get id => text()();

  /// Art der Quelle: 'reddit' | 'rss' | 'folder'
  TextColumn get type => text()();

  /// Quellenspezifische Konfiguration als JSON.
  TextColumn get config => text()();

  /// Neue Funde direkt importieren ohne Inbox-Review.
  BoolColumn get autoApprove =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get lastChecked => dateTime().nullable()();

  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
