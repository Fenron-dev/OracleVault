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

  /// Aktuelle Schema-Version.
  ///
  /// Als Konstante verfügbar, weil [VaultManager.open] sie kennen muss, BEVOR
  /// eine Verbindung aufgebaut wird — nur so kann vor einer Migration ein
  /// Snapshot gezogen werden (VACUUM INTO geht nicht innerhalb einer
  /// Transaktion, siehe BackupService).
  ///
  /// NUR erhöhen, nie verringern. Jede Erhöhung erfordert einen neuen
  /// onUpgrade-Block.
  static const int kSchemaVersion = 2;

  @override
  int get schemaVersion => kSchemaVersion;

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
        ///
        /// Ein Pre-Migration-Snapshot wird von [VaultManager.open] gezogen,
        /// bevor diese Verbindung überhaupt geöffnet wird.
        onUpgrade: (Migrator m, int from, int to) async {
          // ── v1 → v2 ──────────────────────────────────────────────────────
          // 1. FTS5-Index war unbrauchbar: als external-content-Tabelle mit
          //    content='entries' deklariert, enthielt aber die Spalte
          //    table_name, die es in entries nicht gibt. Jede MATCH-Abfrage
          //    lief deshalb auf "no such column: T.table_name". Index und
          //    Trigger werden vollständig neu aufgebaut.
          // 2. Fremdschlüssel bekommen ON DELETE-Regeln. SQLite kann FKs nicht
          //    per ALTER TABLE ändern — Drift baut die Tabellen deshalb neu auf
          //    und kopiert die Daten. Dafür müssen FKs kurzzeitig aus sein,
          //    was innerhalb einer Transaktion nicht geht: daher exclusively().
          if (from < 2) {
            await _dropFts5AndTriggers();
            await _createFts5AndTriggers();
            await _rebuildFtsIndex();

            // ignore: deprecated_member_use, experimental_member_use
            final rebuild = <TableInfo<Table, dynamic>>[
              entries,
              tableTags,
              collectionTables,
              oracleTables,
              categories,
              inboxItems,
            ];
            await exclusively(() async {
              await customStatement('PRAGMA foreign_keys = OFF');
              await transaction(() async {
                for (final table in rebuild) {
                  // ignore: experimental_member_use
                  await m.alterTable(TableMigration(table));
                }
              });
              await customStatement('PRAGMA foreign_keys = ON');
            });

            await _createIndexes();
          }
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

  /// Verwirft Index und Trigger — Voraussetzung für einen Neuaufbau.
  Future<void> _dropFts5AndTriggers() async {
    for (final trigger in ['entries_ai', 'entries_ad', 'entries_au']) {
      await customStatement('DROP TRIGGER IF EXISTS $trigger');
    }
    await customStatement('DROP TABLE IF EXISTS entries_fts');
  }

  Future<void> _createFts5AndTriggers() async {
    // content='entries': external-content-Tabelle — der Index speichert die
    // Texte nicht selbst, sondern liest sie bei Bedarf aus entries nach.
    //
    // ACHTUNG: Genau deshalb dürfen hier NUR Spalten stehen, die es in entries
    // wirklich gibt. Eine zusätzliche Spalte (etwa der Tabellenname aus
    // oracle_tables) lässt jede MATCH-Abfrage mit "no such column" scheitern,
    // auch wenn die Trigger einen Wert hineinschreiben.
    // Der Tabellenname wird stattdessen in TableDao.searchTableIds separat
    // per LIKE gesucht.
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS entries_fts
      USING fts5(
        content,
        body_md,
        content='entries',
        content_rowid='rowid'
      )
    ''');

    // Bei external content hält SQLite den Index nicht selbst aktuell —
    // das müssen Trigger erledigen.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS entries_ai AFTER INSERT ON entries BEGIN
        INSERT INTO entries_fts(rowid, content, body_md)
          VALUES (new.rowid, new.content, new.body_md);
      END
    ''');

    // FTS5 löscht über einen 'delete'-Befehl, dem die ALTEN Werte mitgegeben
    // werden müssen — nur damit findet der Index die zu entfernenden Einträge.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS entries_ad AFTER DELETE ON entries BEGIN
        INSERT INTO entries_fts(entries_fts, rowid, content, body_md)
          VALUES ('delete', old.rowid, old.content, old.body_md);
      END
    ''');

    // FTS5 kennt kein UPDATE: erst löschen, dann neu einfügen.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS entries_au AFTER UPDATE ON entries BEGIN
        INSERT INTO entries_fts(entries_fts, rowid, content, body_md)
          VALUES ('delete', old.rowid, old.content, old.body_md);
        INSERT INTO entries_fts(rowid, content, body_md)
          VALUES (new.rowid, new.content, new.body_md);
      END
    ''');
  }

  /// Baut den Index aus der Content-Tabelle neu auf — nötig nach einem
  /// Neuaufbau der FTS-Tabelle, weil die Trigger nur künftige Änderungen sehen.
  Future<void> _rebuildFtsIndex() async {
    await customStatement(
        "INSERT INTO entries_fts(entries_fts) VALUES('rebuild')");
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

    // edges nach relation: jede Backlink- und Übersetzungs-Abfrage filtert
    // zusätzlich darauf.
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_edges_relation ON edges(relation)');

    // entries nach media_id: Medien-Grid einer Collection und die Prüfung,
    // ob ein Asset noch referenziert wird.
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_entries_media ON entries(media_id)');

    // oracle_tables nach name: Wiki-Link-Auflösung schlägt jeden [[Link]]
    // einzeln nach.
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_tables_name ON oracle_tables(name)');

    // Sidebar-Filter nach Kategorie bzw. Quelle.
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_tables_category ON oracle_tables(category_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_tables_source ON oracle_tables(source_id)');
  }
}
