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

enum BackupType { preMigration, auto, manual, jsonExport }

/// Backup- und Restore-Service für einen Vault.
abstract class BackupService {
  // ── Pre-Migration-Snapshot ─────────────────────────────────────────────────

  /// Erstellt einen SQLite-DB-Snapshot vor einem Schema-Upgrade.
  ///
  /// Wird von vault_database.dart VOR dem onUpgrade-Aufruf aufgerufen.
  /// Einfaches Kopieren der index.db — SQLite-Datei ist in WAL-Modus konsistent.
  static Future<BackupResult> createPreMigrationSnapshot(
      String vaultPath) async {
    final ts = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final dest = p.join(
        VaultManager.backupsDir(vaultPath), 'pre-migration-$ts.db');
    try {
      await File(VaultManager.dbPath(vaultPath)).copy(dest);
      return BackupResult.ok(dest);
    } catch (e) {
      return BackupResult.err('Pre-Migration-Snapshot fehlgeschlagen: $e');
    }
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
    try {
      await File(VaultManager.dbPath(vaultPath)).copy(dest);
      await _pruneAutoBackups(vaultPath, keepCount);
      return BackupResult.ok(dest);
    } catch (e) {
      return BackupResult.err('Auto-Backup fehlgeschlagen: $e');
    }
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
  /// schließen und danach neu öffnen.
  static Future<BackupResult> restoreFromDbSnapshot(
    String vaultPath,
    String snapshotPath,
  ) async {
    try {
      await File(snapshotPath).copy(VaultManager.dbPath(vaultPath));
      return BackupResult.ok(VaultManager.dbPath(vaultPath));
    } catch (e) {
      return BackupResult.err('Restore fehlgeschlagen: $e');
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
