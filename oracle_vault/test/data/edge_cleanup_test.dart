// Datei: test/data/edge_cleanup_test.dart
//
// ZWECK: Aufräumen der generischen Edge-Tabelle (Issue #23).
//        edges hat bewusst keine Fremdschlüssel — ohne eigenes Aufräumen
//        bleiben beim Löschen von Tabellen, Einträgen und Medien Zeilen liegen,
//        die den Graph später verfälschen.

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:oracle_vault/data/db/vault_database.dart';
import 'package:oracle_vault/services/wikilink_service.dart';

void main() {
  late VaultDatabase db;

  setUp(() async {
    db = VaultDatabase.inMemory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  Future<void> addTable(String id, String name, {String? description}) async {
    final now = DateTime.now();
    await db.tableDao.insertTable(OracleTablesCompanion.insert(
      id: id,
      name: name,
      description: Value(description),
      createdAt: now,
      updatedAt: now,
    ));
  }

  Future<void> addEntry(String id, String tableId, String content) =>
      db.entryDao.insertEntry(EntriesCompanion.insert(
        id: id,
        tableId: tableId,
        position: 0,
        content: content,
      ));

  Future<int> edgeCount() async => (await db.select(db.edges).get()).length;

  test('Löschen eines Eintrags nimmt seine Edges mit', () async {
    await addTable('t1', 'Quelle');
    await addTable('t2', 'Ziel');
    await addEntry('e1', 't1', 'siehe [[Ziel]]');
    await WikiLinkService(db: db).materializeForTable('t1');
    expect(await edgeCount(), 1);

    await db.entryDao.deleteEntry('e1', 't1');
    expect(await edgeCount(), 0);
  });

  test('Löschen einer Tabelle nimmt eingehende wie ausgehende Edges mit',
      () async {
    await addTable('t1', 'Quelle');
    await addTable('t2', 'Ziel', description: 'zurück zu [[Quelle]]');
    await addEntry('e1', 't1', 'siehe [[Ziel]]');
    final svc = WikiLinkService(db: db);
    await svc.materializeForTable('t1');
    await svc.materializeForTable('t2');
    expect(await edgeCount(), 2);

    await db.tableDao.deleteTable('t1');
    expect(await edgeCount(), 0);
  });

  test('purgeOrphans räumt Altbestände auf, lässt gültige Edges stehen',
      () async {
    await addTable('t1', 'Quelle');
    await addTable('t2', 'Ziel');
    await addEntry('e1', 't1', 'siehe [[Ziel]]');
    await WikiLinkService(db: db).materializeForTable('t1');

    // Verwaiste Edges, wie sie vor den Aufräum-Pfaden entstanden sind.
    await db.edgeDao
        .linkTranslation(sourceTableId: 'gibt-es-nicht', translationTableId: 't2');
    await db.into(db.edges).insert(EdgesCompanion.insert(
          id: 'orphan-entry',
          fromType: 'entry',
          fromId: 'weg',
          toType: 'table',
          toId: 't2',
          relation: 'wikilink',
        ));
    await db.into(db.edges).insert(EdgesCompanion.insert(
          id: 'orphan-media',
          fromType: 'entry',
          fromId: 'e1',
          toType: 'media',
          toId: 'weg',
          relation: 'embed',
        ));
    expect(await edgeCount(), 4);

    expect(await db.edgeDao.purgeOrphans(), 3);
    final rest = await db.select(db.edges).get();
    expect(rest.map((e) => e.fromId), ['e1']);
  });

  test('purgeOrphans lässt eine saubere Datenbank unangetastet', () async {
    await addTable('t1', 'Quelle');
    await addTable('t2', 'Ziel');
    await addEntry('e1', 't1', 'siehe [[Ziel]]');
    await WikiLinkService(db: db).materializeForTable('t1');

    expect(await db.edgeDao.purgeOrphans(), 0);
    expect(await edgeCount(), 1);
  });
}
