// Datei: test/features/import_wikilink_test.dart
//
// ZWECK: Der Import muss denselben Save-Hook auslösen wie das manuelle
//        Speichern (Issue #21). Vorher bekamen importierte und KI-generierte
//        Tabellen keine Edges: sie tauchten in keinem Backlink-Panel auf und
//        fehlten im Graph, bis jemand sie zufällig von Hand speicherte.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oracle_vault/core/di.dart';
import 'package:oracle_vault/data/db/vault_database.dart';
import 'package:oracle_vault/data/vault/vault_manager.dart';
import 'package:oracle_vault/features/import/import_controller.dart';
import 'package:oracle_vault/features/import/import_state.dart';

void main() {
  late VaultDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = VaultDatabase.inMemory();
    await db.customSelect('SELECT 1').get();
    container = ProviderContainer(overrides: [
      activeVaultProvider.overrideWith(
          (ref) => OpenedVault(vaultPath: '/tmp/ov-test', database: db)),
    ]);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Ziel, auf das die importierten Links zeigen.
  Future<void> addLinkTarget(String id, String name) async {
    final now = DateTime.now();
    await db.tableDao.insertTable(OracleTablesCompanion.insert(
      id: id,
      name: name,
      createdAt: now,
      updatedAt: now,
    ));
  }

  test('Import mit [[Ziel]] im Eintragstext erzeugt eine wikilink-Edge',
      () async {
    await addLinkTarget('ziel', 'Wildnis');

    final controller = container.read(importControllerProvider.notifier);
    await controller.loadSource(const ImportSource(
      type: ImportSourceType.paste,
      raw: 'Ein Goblin flieht Richtung [[Wildnis]]\nEin Händler rastet',
    ));

    final tableId = await controller.save();
    expect(tableId, isNotNull);

    final edges = await db.select(db.edges).get();
    expect(
      edges.where((e) => e.relation == 'wikilink' && e.toId == 'ziel'),
      hasLength(1),
    );
  });

  test('Links in der Beschreibung werden ebenfalls materialisiert', () async {
    await addLinkTarget('ziel', 'Wildnis');

    final controller = container.read(importControllerProvider.notifier);
    await controller.loadSource(const ImportSource(
      type: ImportSourceType.paste,
      raw: 'Ein Goblin flieht',
    ));
    controller.updateDraft((d) => d..description = 'Siehe [[Wildnis]]');

    final tableId = await controller.save();
    final edges = await db.select(db.edges).get();
    expect(
      edges.where((e) =>
          e.relation == 'wikilink' &&
          e.fromType == 'table' &&
          e.fromId == tableId &&
          e.toId == 'ziel'),
      hasLength(1),
    );
  });

  test('unauflösbare Links erzeugen keine Edge', () async {
    final controller = container.read(importControllerProvider.notifier);
    await controller.loadSource(const ImportSource(
      type: ImportSourceType.paste,
      raw: 'Verweist auf [[Gibt Es Nicht]]',
    ));

    expect(await controller.save(), isNotNull);
    expect(await db.select(db.edges).get(), isEmpty);
  });
}
