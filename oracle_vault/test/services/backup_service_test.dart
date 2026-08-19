// Datei: test/services/backup_service_test.dart
//
// ZWECK: Regressionstests für Snapshot und Restore (Issues #19, #20).
//        Vorher: Backups waren reine File.copy — im WAL-Modus steht der
//        aktuelle Stand aber in index.db-wal, nicht in index.db. Und der
//        Restore ließ das alte WAL liegen, das SQLite danach über die
//        eingespielte Datei laufen ließ: die Wiederherstellung verpuffte.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oracle_vault/data/db/vault_database.dart';
import 'package:oracle_vault/data/vault/vault_manager.dart';
import 'package:oracle_vault/services/backup_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late String vaultPath;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('ov_backup_test');
    vaultPath = p.join(root.path, 'vault');
    await VaultManager.create(vaultPath, name: 'Test', language: 'de')
        .then((v) => v.database.close());
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  Future<VaultDatabase> openDb() async {
    final db = VaultDatabase(VaultManager.dbPath(vaultPath));
    await db.customSelect('SELECT 1').get();
    return db;
  }

  Future<void> addTable(VaultDatabase db, String id, String name) async {
    final now = DateTime.now();
    await db.tableDao.insertTable(OracleTablesCompanion.insert(
      id: id,
      name: name,
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<List<String>> tableNames() async {
    final db = await openDb();
    final rows = await db.select(db.oracleTables).get();
    await db.close();
    return rows.map((t) => t.name).toList()..sort();
  }

  group('Snapshot', () {
    test('erfasst Daten, die noch im WAL stehen', () async {
      final db = await openDb();
      await addTable(db, 't1', 'Wildnis');

      // Bewusst OHNE close(): genau dann liegen die Daten im WAL und ein
      // File.copy der index.db würde sie verlieren.
      final result = await BackupService.createAutoBackup(vaultPath);
      expect(result.success, isTrue, reason: result.error);

      await db.close();

      final snapshot = VaultDatabase(result.path!);
      final rows = await snapshot.select(snapshot.oracleTables).get();
      await snapshot.close();
      expect(rows.map((t) => t.name), ['Wildnis']);
    });

    test('zweites Backup am selben Tag überschreibt statt zu scheitern',
        () async {
      final db = await openDb();
      await addTable(db, 't1', 'Erst');
      expect((await BackupService.createAutoBackup(vaultPath)).success, isTrue);

      await addTable(db, 't2', 'Zweit');
      final second = await BackupService.createAutoBackup(vaultPath);
      await db.close();
      expect(second.success, isTrue, reason: second.error);

      final snapshot = VaultDatabase(second.path!);
      final rows = await snapshot.select(snapshot.oracleTables).get();
      await snapshot.close();
      expect(rows.length, 2);
    });
  });

  group('Pre-Migration-Snapshot', () {
    test('kein Snapshot, wenn die Datei schon aktuell ist', () async {
      final result = await BackupService.createPreMigrationSnapshotIfNeeded(
          vaultPath, VaultDatabase.kSchemaVersion);
      expect(result, isNull);
    });

    test('zieht einen Snapshot, wenn eine Migration ansteht', () async {
      final result = await BackupService.createPreMigrationSnapshotIfNeeded(
          vaultPath, VaultDatabase.kSchemaVersion + 1);
      expect(result?.success, isTrue, reason: result?.error);
      expect(p.basename(result!.path!),
          startsWith('pre-migration-v${VaultDatabase.kSchemaVersion}-'));
    });
  });

  group('Restore', () {
    test('spielt den Snapshot ein und räumt das alte WAL weg', () async {
      var db = await openDb();
      await addTable(db, 't1', 'Alt');
      final backup = await BackupService.createAutoBackup(vaultPath);
      expect(backup.success, isTrue, reason: backup.error);

      // Nach dem Backup weitergearbeitet — dieser Stand soll verschwinden.
      await addTable(db, 't2', 'Neu');
      await db.close();

      final result =
          await BackupService.restoreFromDbSnapshot(vaultPath, backup.path!);
      expect(result.success, isTrue, reason: result.error);

      final wal = File('${VaultManager.dbPath(vaultPath)}-wal');
      expect(wal.existsSync(), isFalse,
          reason: 'ein liegengebliebenes WAL würde den Restore überschreiben');

      expect(await tableNames(), ['Alt']);
    });

    test('sichert den bisherigen Stand vorher als pre-restore', () async {
      final db = await openDb();
      await addTable(db, 't1', 'Alt');
      final backup = await BackupService.createAutoBackup(vaultPath);
      await addTable(db, 't2', 'Neu');
      await db.close();

      await BackupService.restoreFromDbSnapshot(vaultPath, backup.path!);

      final backups = await BackupService.listBackups(vaultPath);
      final safety =
          backups.where((b) => b.type == BackupType.preRestore).toList();
      expect(safety, hasLength(1));

      final saved = VaultDatabase(safety.first.path);
      final rows = await saved.select(saved.oracleTables).get();
      await saved.close();
      expect(rows.length, 2, reason: 'der überschriebene Stand muss drin sein');
    });

    test('lehnt einen beschädigten Snapshot ab und lässt den Vault stehen',
        () async {
      final db = await openDb();
      await addTable(db, 't1', 'Alt');
      await db.close();

      final broken = File(p.join(root.path, 'kaputt.db'));
      await broken.writeAsBytes(List.filled(4096, 0x42));

      final result =
          await BackupService.restoreFromDbSnapshot(vaultPath, broken.path);
      expect(result.success, isFalse);
      expect(await tableNames(), ['Alt']);
    });

    test('lehnt einen Snapshot aus einer neueren App-Version ab', () async {
      final db = await openDb();
      await addTable(db, 't1', 'Alt');
      final backup = await BackupService.createAutoBackup(vaultPath);
      await db.close();

      // Schema-Version künstlich hochdrehen: so sähe eine Datei aus, die eine
      // neuere App-Version geschrieben hat. Zurück migrieren kann niemand.
      final future = VaultDatabase(backup.path!);
      await future.customStatement(
          'PRAGMA user_version = ${VaultDatabase.kSchemaVersion + 1}');
      await future.close();

      final result =
          await BackupService.restoreFromDbSnapshot(vaultPath, backup.path!);
      expect(result.success, isFalse);
      expect(result.error, contains('neueren App-Version'));
      expect(await tableNames(), ['Alt']);
    });
  });
}
