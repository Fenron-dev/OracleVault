// Datei: lib/data/db/vault_database.dart
//
// ZWECK: Zentrale Drift-Datenbank des Vaults.
//        Öffnet die DB aus einem nutzer-gewählten Vault-Ordner (kein fixer
//        App-Dokumentenpfad). Führt Schema-Migrationen durch, legt FTS5-Index
//        und Synchronisierungs-Trigger an.
//
// WICHTIG: `part 'vault_database.g.dart'` erfordert, dass drift_dev via
//   build_runner ausgeführt wurde:
//   dart run build_runner build --delete-conflicting-outputs
//
// MIGRATIONSREGEL: onUpgrade-Blöcke NIE nachträglich ändern, nur neue anfügen.
//   schemaVersion NUR erhöhen, nie verringern.
// ABHÄNGIGKEITEN: drift, drift/native.dart, alle Tabellen-Dateien
// PHASE: 0 – Grundgerüst. Phase 1: DAOs hinzugefügt.

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'tables/sources.dart';
import 'tables/categories.dart';
import 'tables/oracle_tables.dart';
import 'tables/entries.dart';
import 'tables/media_files.dart';
import 'tables/tags.dart';
import 'tables/collections.dart';
import 'tables/edges.dart';
import 'tables/smart_filters.dart';
import 'tables/watch_sources.dart';
import 'tables/inbox_items.dart';
import 'daos/collection_dao.dart';
import 'daos/edge_dao.dart';
import 'daos/table_dao.dart';
import 'daos/entry_dao.dart';
import 'daos/tag_dao.dart';
import 'daos/category_dao.dart';
import 'daos/source_dao.dart';
import 'daos/media_dao.dart';

part 'vault_database.g.dart';

/// Drift-Datenbank eines einzelnen Vaults.
///
/// INSTANZIIERUNG: Wird von [VaultManager] erzeugt, der den Pfad zur DB-Datei
/// kennt. Ein offener Vault = eine VaultDatabase-Instanz.
///
/// WARUM NativeDatabase statt driftDatabase()?
/// driftDatabase() aus drift_flutter öffnet immer im App-Dokumentenverzeichnis.
/// Vaults sind nutzer-gewählte Ordner, deshalb NativeDatabase.createInBackground()
/// mit dem expliziten Pfad.
@DriftDatabase(
  tables: [
    Sources,
    Categories,
    OracleTables,
    Entries,
    MediaFiles,
    Tags,
    TableTags,
    Collections,
    CollectionTables,
    Edges,
    SmartFilters,
    WatchSources,
    InboxItems,
  ],
  daos: [
    CollectionDao,
    EdgeDao,
    TableDao,
    EntryDao,
    TagDao,
    CategoryDao,
    SourceDao,
    MediaDao,
  ],
)
class VaultDatabase extends _$VaultDatabase {
  VaultDatabase(String dbPath)
      : super(NativeDatabase.createInBackground(File(dbPath)));

  /// Für Tests: In-Memory-Datenbank.
  VaultDatabase.inMemory() : super(NativeDatabase.memory());

  // schemaVersion NUR erhöhen, nie verringern.
  // Jede Erhöhung erfordert einen neuen onUpgrade-Block.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        /// onCreate: Erstinstallation — legt alle Tabellen, FTS5, Trigger und
        /// Indizes an.
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createFts5AndTriggers();
          await _createIndexes();
        },

        /// onUpgrade: Wird bei schemaVersion-Erhöhung aufgerufen.
        /// REGEL: Blöcke nie nachträglich ändern, nur neue if-Blöcke anfügen.
        onUpgrade: (Migrator m, int from, int to) async {
          // Phase 0: schemaVersion=1, noch keine Upgrades nötig.
          // Nächster Block hier anfügen wenn schemaVersion auf 2 steigt.
        },

        /// beforeOpen: Läuft bei JEDEM App-Start nach der Migration.
        /// SQLite-PRAGMAs müssen pro Verbindung gesetzt werden.
        beforeOpen: (OpeningDetails details) async {
          // Fremdschlüssel-Prüfung ist in SQLite standardmäßig deaktiviert.
          await customStatement('PRAGMA foreign_keys = ON');

          // WAL ermöglicht gleichzeitige Lesezugriffe während Schreiboperationen —
          // wichtig für Riverpod-StreamProvider (liest) + BackupService (schreibt).
          await customStatement('PRAGMA journal_mode = WAL');

          // NORMAL ist mit WAL sicher und ca. 3× schneller als FULL (Standard).
          await customStatement('PRAGMA synchronous = NORMAL');
        },
      );

  // ── FTS5-Volltext-Index und Synchronisierungs-Trigger ─────────────────────

  Future<void> _createFts5AndTriggers() async {
    // FTS5 als Content-Table verknüpft mit 'entries'.
    // content='entries': highlight() und snippet() funktionieren damit.
    // content_rowid='rowid': Drift vergibt automatisch integer rowids,
    //   auch bei UUID-PKs.
    // ACHTUNG: Bei Content-Tables muss die FTS5-Synchronisation via Trigger
    //   erfolgen (SQLite aktualisiert den Index nicht automatisch).
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS entries_fts
      USING fts5(
        content,
        body_md,
        table_name,
        table_id UNINDEXED,
        content='entries',
        content_rowid='rowid'
      )
    ''');

    // Trigger: NACH INSERT in entries → FTS5 einfügen.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS entries_ai AFTER INSERT ON entries BEGIN
        INSERT INTO entries_fts(rowid, content, body_md, table_name, table_id)
          SELECT new.rowid, new.content, new.body_md, t.name, new.table_id
          FROM oracle_tables t WHERE t.id = new.table_id;
      END
    ''');

    // Trigger: NACH DELETE in entries → FTS5-Eintrag entfernen.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS entries_ad AFTER DELETE ON entries BEGIN
        INSERT INTO entries_fts(entries_fts, rowid, content, body_md, table_name, table_id)
          SELECT 'delete', old.rowid, old.content, old.body_md, t.name, old.table_id
          FROM oracle_tables t WHERE t.id = old.table_id;
      END
    ''');

    // Trigger: NACH UPDATE in entries → FTS5 zuerst löschen, dann neu einfügen.
    // FTS5 kennt kein direktes UPDATE.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS entries_au AFTER UPDATE ON entries BEGIN
        INSERT INTO entries_fts(entries_fts, rowid, content, body_md, table_name, table_id)
          SELECT 'delete', old.rowid, old.content, old.body_md, t.name, old.table_id
          FROM oracle_tables t WHERE t.id = old.table_id;
        INSERT INTO entries_fts(rowid, content, body_md, table_name, table_id)
          SELECT new.rowid, new.content, new.body_md, t.name, new.table_id
          FROM oracle_tables t WHERE t.id = new.table_id;
      END
    ''');
  }

  // ── Indizes ───────────────────────────────────────────────────────────────

  Future<void> _createIndexes() async {
    // entries nach tableId: häufigste Abfrage (alle Einträge einer Tabelle).
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_entries_table_id ON entries(table_id)');

    // edges-Indizes: from-Richtung (alle Verknüpfungen von X) und
    //                to-Richtung (Backlinks zu X).
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_edges_from ON edges(from_type, from_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_edges_to ON edges(to_type, to_id)');

    // media-Hash: Dublettenerkennung beim Import.
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_media_hash ON media_files(hash)');

    // oracle_tables nach updatedAt: Feed/Listenansicht sortiert nach Änderungsdatum.
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_tables_updated ON oracle_tables(updated_at DESC)');

    // tags nach name: Eindeutigkeit und schnelles Lookup beim Import.
    await customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_tags_name ON tags(name)');
  }
}
