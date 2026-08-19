// Datei: test/data/migration_test.dart
//
// ZWECK: Der Weg durch VaultManager.open bei anstehender Migration (Issue #19):
//        vor dem Upgrade muss ein Snapshot liegen, danach müssen FTS-Index und
//        Trigger wieder benutzbar sein.
//
// HINWEIS: Die alte v1-Datei wird simuliert, indem user_version zurückgesetzt
//          wird. Das prüft nicht die Spaltenänderungen selbst, wohl aber, dass
//          der onUpgrade-Block vollständig durchläuft — er baut FTS neu auf und
//          lässt Drift Tabellen kopieren, beides außerhalb einer Transaktion.

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
    root = await Directory.systemTemp.createTemp('ov_migration_test');
    vaultPath = p.join(root.path, 'vault');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  Future<void> seed({required int downgradeTo}) async {
    final created =
        await VaultManager.create(vaultPath, name: 'Test', language: 'de');
    final db = created.database;
    final now = DateTime.now();
    await db.tableDao.insertTable(OracleTablesCompanion.insert(
      id: 't1',
      name: 'Wildnis',
      createdAt: now,
      updatedAt: now,
    ));
    await db.entryDao.insertEntry(EntriesCompanion.insert(
      id: 'e1',
      tableId: 't1',
      position: 0,
      content: 'Ein Goblin lauert im Gebüsch',
    ));
    // Datei auf eine ältere Schema-Version zurückstellen, damit beim nächsten
    // Öffnen onUpgrade läuft.
    await db.customStatement('PRAGMA user_version = $downgradeTo');
    await db.close();
  }

  test('Migration zieht vorher einen Snapshot und die Suche läuft danach',
      () async {
    await seed(downgradeTo: 1);

    final opened = await VaultManager.open(vaultPath);

    final backups = await BackupService.listBackups(vaultPath);
    expect(
      backups.where((b) => b.type == BackupType.preMigration),
      hasLength(1),
      reason: 'ohne Sicherung darf keine Migration laufen',
    );

    // Bestand unverändert, Volltextsuche wieder benutzbar.
    expect(await opened.database.tableDao.searchTableIds('Goblin'), ['t1']);
    await opened.database.close();
  });

  test('ohne anstehende Migration entsteht kein Pre-Migration-Snapshot',
      () async {
    await seed(downgradeTo: VaultDatabase.kSchemaVersion);

    final opened = await VaultManager.open(vaultPath);
    final backups = await BackupService.listBackups(vaultPath);
    expect(backups.where((b) => b.type == BackupType.preMigration), isEmpty);
    await opened.database.close();
  });
}
