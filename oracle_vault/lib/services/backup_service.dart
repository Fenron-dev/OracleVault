// Datei: lib/services/backup_service.dart
//
// ZWECK: Backup- und Restore-Funktionen für einen Vault.
//        Drei Mechanismen:
//          1. Pre-Migration-Snapshot (automatisch vor jedem Schema-Update)
//          2. Auto-Backup (täglich, konfigurierbare Aufbewahrungszeit)
//          3. Manuelles Backup (ZIP des gesamten Vaults inkl. Medien)
//          4. JSON-Voll-Export (schema-unabhängig, wiederherstellbar)
//
// DESIGN: Statische Methoden, kein Zustand.
//         Aufgerufen von BackupSettingsScreen (manuell) und AutoBackupService (automatisch).
// ABHÄNGIGKEITEN: dart:io, dart:convert, archive, intl, path, vault_manager.dart,
//                 vault_database.dart
// PHASE: 0 – Pflichtfeature.

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../data/db/vault_database.dart';
import '../data/vault/vault_manager.dart';

/// Ergebnis einer Backup-Operation.
class BackupResult {
  final bool success;
  final String? path;
  final String? error;

  const BackupResult.ok(this.path)
      : success = true,
        error = null;
  const BackupResult.err(this.error)
      : success = false,
        path = null;
}

/// Eintrag in der Backup-Liste (für die UI in BackupSettingsScreen).
class BackupEntry {
  final String path;
  final BackupType type;
  final DateTime createdAt;
  final int sizeBytes;

  const BackupEntry({
    required this.path,
    required this.type,
    required this.createdAt,
    required this.sizeBytes,
  });

  String get filename => p.basename(path);
}

enum BackupType { preMigration, preRestore, auto, manual, jsonExport }

/// Backup- und Restore-Service für einen Vault.
abstract class BackupService {
  // ── Pre-Migration-Snapshot ─────────────────────────────────────────────────

  /// Zieht einen Snapshot, WENN die vorhandene index.db eine ältere
  /// Schema-Version hat als [targetSchemaVersion] — also unmittelbar bevor
  /// Drifts onUpgrade laufen wird.
  ///
  /// WARUM HIER UND NICHT IN onUpgrade?
  /// Der Snapshot nutzt `VACUUM INTO`, und VACUUM kann nicht innerhalb einer
  /// Transaktion laufen. Drift führt onUpgrade aber in einer Transaktion aus.
  /// Deshalb prüft [VaultManager.open] die `user_version` der Datei, bevor
  /// überhaupt eine Drift-Verbindung aufgebaut wird.
  ///
  /// Gibt null zurück, wenn kein Upgrade ansteht (Normalfall) — der Aufrufer
  /// muss dann nichts melden.
  static Future<BackupResult?> createPreMigrationSnapshotIfNeeded(
    String vaultPath,
    int targetSchemaVersion,
  ) async {
    final dbFile = VaultManager.dbPath(vaultPath);
    if (!File(dbFile).existsSync()) return null;

    final int current;
    try {
      current = _readUserVersion(dbFile);
    } catch (e) {
      return BackupResult.err('Schema-Version nicht lesbar: $e');
    }

    // user_version == 0 → frisch angelegte, noch leere Datei (onCreate folgt).
    if (current == 0 || current >= targetSchemaVersion) return null;

    final ts = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final dest = p.join(VaultManager.backupsDir(vaultPath),
        'pre-migration-v$current-$ts.db');
    return _snapshot(dbFile, dest, 'Pre-Migration-Snapshot');
  }

  // ── Auto-Backup ────────────────────────────────────────────────────────────

  /// Erstellt ein tägliches Backup der index.db im Backups-Ordner.
  ///
  /// Löscht alte Backups über [keepCount]. Der Dateiname enthält das Datum,
  /// damit mehrere Backups desselben Tages nicht überschrieben werden.
  static Future<BackupResult> createAutoBackup(
    String vaultPath, {
    int keepCount = 7,
  }) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dest =
        p.join(VaultManager.backupsDir(vaultPath), 'auto-$date.db');
    final result =
        await _snapshot(VaultManager.dbPath(vaultPath), dest, 'Auto-Backup');
    if (!result.success) return result;
    try {
      await _pruneAutoBackups(vaultPath, keepCount);
    } catch (e) {
      return BackupResult.err('Aufräumen alter Backups fehlgeschlagen: $e');
    }
    return result;
  }

  /// Prüft ob heute bereits ein Auto-Backup erstellt wurde.
  static Future<bool> autoBackupExistsForToday(String vaultPath) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return File(
            p.join(VaultManager.backupsDir(vaultPath), 'auto-$date.db'))
        .existsSync();
  }

  // ── Manuelles ZIP-Backup ──────────────────────────────────────────────────

  /// Erstellt ein ZIP-Archiv des gesamten Vaults (Medien + DB).
  ///
  /// [destDir] ist der Zielordner außerhalb des Vaults (z. B. Downloads).
  /// Thumbnails werden nicht archiviert (regenerierbar).
  static Future<BackupResult> createZipBackup(
    String vaultPath,
    String destDir,
  ) async {
    final ts = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final vaultName = p.basename(vaultPath);
    final destFile = p.join(destDir, 'oraclevault-$vaultName-$ts.zip');
    try {
      // WAL zurückschreiben, sonst archiviert das ZIP eine veraltete index.db.
      await _checkpointWal(VaultManager.dbPath(vaultPath));
      final encoder = ZipFileEncoder();
      encoder.create(destFile);
      // .oraclevault/ ohne thumbnails/
      final internal = Directory(VaultManager.internalDir(vaultPath));
      await for (final entity in internal.list(recursive: true)) {
        if (entity is File) {
          final rel = p.relative(entity.path, from: vaultPath);
          // Thumbnails überspringen.
          if (rel.startsWith('.oraclevault/thumbnails')) continue;
          encoder.addFile(entity, rel);
        }
      }
      // media/
      final media = Directory(p.join(vaultPath, 'media'));
      if (media.existsSync()) {
        await for (final entity in media.list(recursive: true)) {
          if (entity is File) {
            final rel = p.relative(entity.path, from: vaultPath);
            encoder.addFile(entity, rel);
          }
        }
      }
      encoder.close();
      return BackupResult.ok(destFile);
    } catch (e) {
      return BackupResult.err('ZIP-Backup fehlgeschlagen: $e');
    }
  }

  // ── JSON-Voll-Export ──────────────────────────────────────────────────────

  /// Exportiert alle Datenbankentitäten als schema-unabhängiges JSON.
  ///
  /// Dieses Format bleibt lesbar, auch wenn das Drift-Schema sich ändert,
  /// und kann von Folge-Apps (Downstream-RPG-Tools) direkt gelesen werden.
  /// Media-Dateien werden als Pfad-Verweis exportiert (kein Base64-Encoding).
  static Future<BackupResult> createJsonExport(
    VaultDatabase db,
    String vaultPath,
    String destDir,
  ) async {
    final ts = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final vaultName = p.basename(vaultPath);
    final destFile = p.join(destDir, 'oraclevault-$vaultName-$ts.json');
    try {
      final data = await _buildExportMap(db);
      await File(destFile)
          .writeAsString(const JsonEncoder.withIndent('  ').convert(data));
      return BackupResult.ok(destFile);
    } catch (e) {
      return BackupResult.err('JSON-Export fehlgeschlagen: $e');
    }
  }

  // ── Restore ───────────────────────────────────────────────────────────────

  /// Stellt einen Vault aus einem DB-Snapshot wieder her.
  ///
  /// Schließt [db] NICHT — der Aufrufer muss die Datenbankverbindung vorher
  /// schließen und den Vault danach neu öffnen.
  ///
  /// WARUM MEHR ALS EIN File.copy?
  /// Neben index.db liegen im WAL-Modus index.db-wal und index.db-shm. Bleiben
  /// die stehen, spielt SQLite beim nächsten Öffnen das alte WAL auf die frisch
  /// kopierte Datei — die Wiederherstellung verpufft und die Datei wird obendrein
  /// beschädigt, weil WAL und Hauptdatei aus verschiedenen Datenbanken stammen.
  /// Deshalb: erst prüfen, dann sichern, dann Seitendateien löschen, dann kopieren.
  static Future<BackupResult> restoreFromDbSnapshot(
    String vaultPath,
    String snapshotPath,
  ) async {
    final target = VaultManager.dbPath(vaultPath);

    if (!File(snapshotPath).existsSync()) {
      return BackupResult.err('Restore fehlgeschlagen: $snapshotPath fehlt');
    }

    // ── 1. Snapshot prüfen ──────────────────────────────────────────────────
    // Lieber hier abbrechen als eine funktionierende index.db durch eine
    // kaputte Datei zu ersetzen.
    try {
      final check = _inspectSnapshot(snapshotPath);
      if (check != null) return BackupResult.err('Restore abgebrochen: $check');
    } catch (e) {
      return BackupResult.err('Restore abgebrochen: Snapshot unlesbar ($e)');
    }

    // ── 2. Aktuellen Stand sichern ──────────────────────────────────────────
    // Der Dialog sagt „kann nicht rückgängig gemacht werden" — stimmt für die
    // UI, aber die Datei soll trotzdem nicht einfach verschwinden.
    if (File(target).existsSync()) {
      final ts = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final safety =
          p.join(VaultManager.backupsDir(vaultPath), 'pre-restore-$ts.db');
      final saved = await _snapshot(target, safety, 'Sicherung vor Restore');
      if (!saved.success) return saved;
    }

    // ── 3. Ersetzen ─────────────────────────────────────────────────────────
    try {
      for (final suffix in ['', '-wal', '-shm']) {
        final f = File('$target$suffix');
        if (f.existsSync()) await f.delete();
      }
      await File(snapshotPath).copy(target);
      return BackupResult.ok(target);
    } catch (e) {
      return BackupResult.err('Restore fehlgeschlagen: $e');
    }
  }

  /// Prüft einen Snapshot vor dem Zurückspielen.
  /// Gibt null zurück, wenn alles in Ordnung ist, sonst den Grund.
  static String? _inspectSnapshot(String snapshotPath) {
    final db = sqlite3.open(snapshotPath, mode: OpenMode.readOnly);
    try {
      final integrity =
          db.select('PRAGMA quick_check').first.values.first as String?;
      if (integrity != 'ok') return 'Snapshot ist beschädigt ($integrity)';

      final version = db.select('PRAGMA user_version').first.values.first as int?;
      if (version != null && version > VaultDatabase.kSchemaVersion) {
        // Rückwärts-Migration gibt es nicht — eine neuere Datei würde die App
        // beim nächsten Start mit unklaren Fehlern begrüßen.
        return 'Snapshot stammt aus einer neueren App-Version '
            '(Schema v$version > v${VaultDatabase.kSchemaVersion})';
      }
      return null;
    } finally {
      db.dispose();
    }
  }

  // ── Backup-Liste ──────────────────────────────────────────────────────────

  /// Gibt alle vorhandenen Backups im Backups-Ordner zurück, neueste zuerst.
  static Future<List<BackupEntry>> listBackups(String vaultPath) async {
    final dir = Directory(VaultManager.backupsDir(vaultPath));
    if (!dir.existsSync()) return [];
    final entries = <BackupEntry>[];
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      BackupType? type;
      if (name.startsWith('pre-migration-')) {
        type = BackupType.preMigration;
      } else if (name.startsWith('pre-restore-')) {
        type = BackupType.preRestore;
      } else if (name.startsWith('auto-')) {
        type = BackupType.auto;
      } else if (name.startsWith('manual-')) {
        type = BackupType.manual;
      }
      if (type == null) continue;
      final stat = await entity.stat();
      entries.add(BackupEntry(
        path: entity.path,
        type: type,
        createdAt: stat.modified,
        sizeBytes: stat.size,
      ));
    }
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  // ── Interne Helfer ────────────────────────────────────────────────────────

  /// Konsistenter Datei-Snapshot einer SQLite-DB via `VACUUM INTO`.
  ///
  /// WARUM NICHT File.copy?
  /// Die DB läuft im WAL-Modus. Frisch committete Transaktionen stehen dann in
  /// index.db-wal, NICHT in index.db — eine reine Dateikopie kann beliebig alt
  /// sein. `VACUUM INTO` schreibt dagegen den aktuellen Zustand inklusive WAL
  /// in eine einzelne, defragmentierte Zieldatei.
  ///
  /// Läuft über package:sqlite3 statt über Drift, weil VACUUM nicht innerhalb
  /// einer Transaktion ausgeführt werden darf.
  static Future<BackupResult> _snapshot(
    String dbPath,
    String destPath,
    String label,
  ) async {
    if (!File(dbPath).existsSync()) {
      return BackupResult.err('$label fehlgeschlagen: $dbPath existiert nicht');
    }
    try {
      await Directory(p.dirname(destPath)).create(recursive: true);
      // VACUUM INTO bricht ab, wenn das Ziel schon existiert (z. B. zweites
      // Auto-Backup am selben Tag) — deshalb vorher entfernen.
      final destFile = File(destPath);
      if (destFile.existsSync()) await destFile.delete();

      final db = sqlite3.open(dbPath);
      try {
        db.execute('VACUUM INTO ?', [destPath]);
      } finally {
        db.dispose();
      }
      return BackupResult.ok(destPath);
    } catch (e) {
      return BackupResult.err('$label fehlgeschlagen: $e');
    }
  }

  /// Liest `PRAGMA user_version` — Drift speichert dort die schemaVersion.
  /// 0 = Datei noch ohne Schema.
  static int _readUserVersion(String dbPath) {
    final db = sqlite3.open(dbPath);
    try {
      final row = db.select('PRAGMA user_version').first;
      return row.values.first as int? ?? 0;
    } finally {
      db.dispose();
    }
  }

  /// Schreibt offene WAL-Transaktionen zurück in die Hauptdatei, damit ein
  /// dateibasiertes Backup (ZIP) den aktuellen Stand enthält.
  static Future<void> _checkpointWal(String dbPath) async {
    if (!File(dbPath).existsSync()) return;
    try {
      final db = sqlite3.open(dbPath);
      try {
        db.execute('PRAGMA wal_checkpoint(TRUNCATE)');
      } finally {
        db.dispose();
      }
    } catch (_) {
      // Checkpoint ist eine Optimierung — schlägt er fehl (z. B. weil eine
      // andere Verbindung schreibt), wird trotzdem archiviert.
    }
  }

  static Future<void> _pruneAutoBackups(
      String vaultPath, int keepCount) async {
    final dir = Directory(VaultManager.backupsDir(vaultPath));
    final autoFiles = <File>[];
    await for (final entity in dir.list()) {
      if (entity is File && p.basename(entity.path).startsWith('auto-')) {
        autoFiles.add(entity);
      }
    }
    // Neueste zuerst.
    autoFiles.sort((a, b) => b.path.compareTo(a.path));
    // Alte Dateien löschen.
    for (final file in autoFiles.skip(keepCount)) {
      await file.delete();
    }
  }

  static Future<Map<String, dynamic>> _buildExportMap(
      VaultDatabase db) async {
    final sources = await db.select(db.sources).get();
    final categories = await db.select(db.categories).get();
    final tables = await db.select(db.oracleTables).get();
    final entries = await db.select(db.entries).get();
    final media = await db.select(db.mediaFiles).get();
    final tags = await db.select(db.tags).get();
    final tableTags = await db.select(db.tableTags).get();
    final collections = await db.select(db.collections).get();
    final collectionTables = await db.select(db.collectionTables).get();
    final edges = await db.select(db.edges).get();
    final smartFilters = await db.select(db.smartFilters).get();

    return {
      'format_version': '1.0',
      'exported_at': DateTime.now().toIso8601String(),
      'sources': sources
          .map((s) => {
                'id': s.id,
                'type': s.type,
                'title': s.title,
                'author': s.author,
                'url': s.url,
                'license': s.license,
                'ai_provider_json': s.aiProviderJson,
                'notes': s.notes,
                'created_at': s.createdAt.toIso8601String(),
              })
          .toList(),
      'categories': categories
          .map((c) => {'id': c.id, 'name': c.name, 'parent_id': c.parentId})
          .toList(),
      'tables': tables
          .map((t) => {
                'id': t.id,
                'name': t.name,
                'description': t.description,
                'oracle_type': t.oracleType,
                'dice_expr': t.diceExpr,
                'genre': t.genre,
                'theme': t.theme,
                'category_id': t.categoryId,
                'source_id': t.sourceId,
                'language': t.language,
                'metadata_json': t.metadataJson,
                'created_at': t.createdAt.toIso8601String(),
                'updated_at': t.updatedAt.toIso8601String(),
              })
          .toList(),
      'entries': entries
          .map((e) => {
                'id': e.id,
                'table_id': e.tableId,
                'position': e.position,
                'content': e.content,
                'body_md': e.bodyMd,
                'weight': e.weight,
                'roll_min': e.rollMin,
                'roll_max': e.rollMax,
                'media_id': e.mediaId,
                'subtable_id': e.subtableId,
                'confidence_low': e.confidenceLow,
                'modifier_json': e.modifierJson,
              })
          .toList(),
      'media': media
          .map((m) => {
                'id': m.id,
                'type': m.type,
                'file_path': m.filePath,
                'mime': m.mime,
                'hash': m.hash,
                'title': m.title,
                'metadata_json': m.metadataJson,
                'created_at': m.createdAt.toIso8601String(),
              })
          .toList(),
      'tags': tags.map((t) => {'id': t.id, 'name': t.name}).toList(),
      'table_tags': tableTags
          .map((tt) => {'table_id': tt.tableId, 'tag_id': tt.tagId})
          .toList(),
      'collections': collections
          .map((c) => {
                'id': c.id,
                'name': c.name,
                'description': c.description,
                'type': c.type,
              })
          .toList(),
      'collection_tables': collectionTables
          .map((ct) => {
                'collection_id': ct.collectionId,
                'table_id': ct.tableId,
                'position': ct.position,
              })
          .toList(),
      'edges': edges
          .map((e) => {
                'id': e.id,
                'from_type': e.fromType,
                'from_id': e.fromId,
                'to_type': e.toType,
                'to_id': e.toId,
                'relation': e.relation,
                'metadata_json': e.metadataJson,
              })
          .toList(),
      'smart_filters': smartFilters
          .map((sf) => {
                'id': sf.id,
                'name': sf.name,
                'filter_json': sf.filterJson,
                'created_at': sf.createdAt.toIso8601String(),
              })
          .toList(),
    };
  }
}
