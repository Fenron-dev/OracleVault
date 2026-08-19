// Datei: test/data/vault_recovery_test.dart
//
// ZWECK: Öffnen eines Vaults mit WAL-Resten (Issue #13).
//
// HINTERGRUND (nachgemessen): SQLite verwirft ein kaputtes -wal/-shm beim
// Öffnen stillschweigend — daran scheitert also nichts. Der Schaden entsteht
// woanders: ein liegengebliebenes WAL wird eingespielt, auch wenn die
// Hauptdatei inzwischen eine andere ist. Deshalb wird nach einem unsauberen
// Ende geprüft und das WAL beim Öffnen eingefaltet, statt es liegen zu lassen.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oracle_vault/data/db/vault_database.dart';
import 'package:oracle_vault/data/vault/vault_manager.dart';
import 'package:oracle_vault/data/vault/vault_recovery.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late String vaultPath;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('ov_recovery_test');
    vaultPath = p.join(root.path, 'vault');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  Future<void> seedVault() async {
    final created =
        await VaultManager.create(vaultPath, name: 'Test', language: 'de');
    final now = DateTime.now();
    await created.database.tableDao.insertTable(OracleTablesCompanion.insert(
      id: 't1',
      name: 'Wildnis',
      createdAt: now,
      updatedAt: now,
    ));
    await created.database.close();
  }

  File walFile() => File('${VaultManager.dbPath(vaultPath)}-wal');

  test('sauber geschlossener Vault öffnet ohne Hinweis', () async {
    await seedVault();

    final opened = await VaultManager.open(vaultPath);
    expect(opened.warning, isNull);
    await opened.database.close();
  });

  test('WAL-Reste werden eingefaltet, der Ordner bleibt portabel', () async {
    await seedVault();
    // Unsauberes Ende simulieren: Daten schreiben und die Datei-Handles
    // fallen lassen, ohne zu schließen — das WAL bleibt stehen.
    final db = VaultDatabase(VaultManager.dbPath(vaultPath));
    final now = DateTime.now();
    await db.tableDao.insertTable(OracleTablesCompanion.insert(
      id: 't2',
      name: 'Stadt',
      createdAt: now,
      updatedAt: now,
    ));
    await db.customStatement('PRAGMA wal_checkpoint(PASSIVE)');
    expect(walFile().existsSync(), isTrue);
    expect(walFile().lengthSync(), greaterThan(0));
    await db.close();

    // close() macht selbst einen Checkpoint — für den Testfall wieder füllen.
    final second = VaultDatabase(VaultManager.dbPath(vaultPath));
    await second.tableDao.insertTable(OracleTablesCompanion.insert(
      id: 't3',
      name: 'Wüste',
      createdAt: now,
      updatedAt: now,
    ));
    expect(walFile().lengthSync(), greaterThan(0));

    final notice = await VaultRecovery.prepare(vaultPath);
    expect(notice, contains('nicht sauber geschlossen'));
    expect(walFile().existsSync() ? walFile().lengthSync() : 0, 0,
        reason: 'nach dem Checkpoint muss der Stand in index.db stehen');

    // Nichts verloren: alle drei Tabellen sind da.
    final reopened = VaultDatabase(VaultManager.dbPath(vaultPath));
    final tables = await reopened.tableDao.fetchAll();
    expect(tables.map((t) => t.id).toSet(), {'t1', 't2', 't3'});
    await reopened.close();
    await second.close();
  });

  test('kaputtes WAL verhindert das Öffnen nicht', () async {
    await seedVault();
    walFile().writeAsBytesSync(List.filled(8192, 0x41));

    final opened = await VaultManager.open(vaultPath);
    final tables = await opened.database.tableDao.fetchAll();
    expect(tables.map((t) => t.id), ['t1']);
    await opened.database.close();
  });

  test('beschädigte index.db: verständlicher Fehler statt SqliteException',
      () async {
    await seedVault();
    // Datei zerschießen, WAL-Rest daneben legen → Integritätsprüfung greift.
    final dbFile = File(VaultManager.dbPath(vaultPath));
    final bytes = dbFile.readAsBytesSync();
    for (var i = 4096; i < bytes.length; i++) {
      bytes[i] = 0x00;
    }
    dbFile.writeAsBytesSync(bytes);
    walFile().writeAsBytesSync(List.filled(64, 0x41));

    // expectLater, nicht expect: bei einem asynchronen Aufruf kann die
    // Zusicherung sonst durchrutschen, ohne je gewartet zu haben.
    await expectLater(
      VaultManager.open(vaultPath),
      throwsA(isA<VaultDatabaseUnreadableException>()),
    );
  });

  test('die Fehlermeldung nennt die neueste Sicherung', () {
    final backups = Directory(VaultManager.backupsDir(vaultPath))
      ..createSync(recursive: true);
    File(p.join(backups.path, 'auto-2026-08-18.db')).writeAsStringSync('x');
    File(p.join(backups.path, 'auto-2026-08-19.db')).writeAsStringSync('x');

    final message =
        VaultDatabaseUnreadableException(vaultPath, 'Testgrund').toString();
    expect(message, contains('auto-2026-08-19.db'));
    expect(message, contains('index.db-wal'));
  });
}
