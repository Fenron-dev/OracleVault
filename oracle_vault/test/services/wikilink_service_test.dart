// Tests für WikiLinkService — Materialisierung von [[Links]] als Edges.

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oracle_vault/data/db/vault_database.dart';
import 'package:oracle_vault/services/wikilink_service.dart';

void main() {
  late VaultDatabase db;
  late WikiLinkService svc;

  setUp(() {
    db = VaultDatabase.inMemory();
    svc = WikiLinkService(db: db);
  });
  tearDown(() => db.close());

  Future<void> insertTable(String id, String name, {String? description}) {
    final now = DateTime.now();
    return db.into(db.oracleTables).insert(OracleTablesCompanion.insert(
          id: id,
          name: name,
          description: Value(description),
          createdAt: now,
          updatedAt: now,
        ));
  }

  Future<void> insertEntry(String id, String tableId, int pos, String content,
      {String? bodyMd}) {
    return db.into(db.entries).insert(EntriesCompanion.insert(
          id: id,
          tableId: tableId,
          position: pos,
          content: content,
          bodyMd: Value(bodyMd),
        ));
  }

  Future<void> insertMedia(String id, String title) {
    return db.into(db.mediaFiles).insert(MediaFilesCompanion.insert(
          id: id,
          type: 'image',
          filePath: 'media/images/$id.png',
          hash: 'hash-$id',
          title: Value(title),
          createdAt: DateTime.now(),
        ));
  }

  test('[[Table]] im Eintrag erzeugt wikilink-Edge entry→table', () async {
    await insertTable('t1', 'Quelle');
    await insertTable('t2', 'Monster');
    await insertEntry('e1', 't1', 0, 'Begegne [[Monster]] im Wald');

    await svc.materializeForTable('t1');

    final edges = await db.edgeDao.fetchOutgoingLinks('entry', 'e1');
    expect(edges, hasLength(1));
    expect(edges.single.relation, 'wikilink');
    expect(edges.single.toType, 'table');
    expect(edges.single.toId, 't2');
  });

  test('Tabellenname wird case-insensitiv aufgelöst', () async {
    await insertTable('t1', 'Quelle');
    await insertTable('t2', 'Monster');
    await insertEntry('e1', 't1', 0, 'siehe [[monster]]');

    await svc.materializeForTable('t1');

    final edges = await db.edgeDao.fetchOutgoingLinks('entry', 'e1');
    expect(edges.single.toId, 't2');
  });

  test('[[Table#Entry]] zeigt auf den Eintrag; Fallback auf Tabelle',
      () async {
    await insertTable('t1', 'Quelle');
    await insertTable('t2', 'Monster');
    await insertEntry('goblin', 't2', 0, 'Goblin');
    await insertEntry('e1', 't1', 0, '[[Monster#Goblin]] und [[Monster#Drache]]');

    await svc.materializeForTable('t1');

    final edges = await db.edgeDao.fetchOutgoingLinks('entry', 'e1');
    expect(edges, hasLength(2));
    final byType = {for (final e in edges) e.toType: e.toId};
    expect(byType['entry'], 'goblin'); // aufgelöst
    expect(byType['table'], 't2'); // Drache existiert nicht → Tabelle
  });

  test('![[name.png]] erzeugt embed-Edge auf Media (Titel ohne Endung)',
      () async {
    await insertTable('t1', 'Quelle');
    await insertMedia('m1', 'battlemap_01');
    await insertEntry('e1', 't1', 0, 'Karte: ![[battlemap_01.png]]');

    await svc.materializeForTable('t1');

    final edges = await db.edgeDao.fetchOutgoingLinks('entry', 'e1');
    expect(edges.single.relation, 'embed');
    expect(edges.single.toType, 'media');
    expect(edges.single.toId, 'm1');
  });

  test('Links in bodyMd und description werden materialisiert', () async {
    await insertTable('t2', 'Monster');
    await insertTable('t1', 'Quelle', description: 'Basiert auf [[Monster]]');
    await insertEntry('e1', 't1', 0, 'Eintrag', bodyMd: 'mehr zu [[Monster]]');

    await svc.materializeForTable('t1');

    final tableEdges = await db.edgeDao.fetchOutgoingLinks('table', 't1');
    expect(tableEdges.single.toId, 't2');
    final entryEdges = await db.edgeDao.fetchOutgoingLinks('entry', 'e1');
    expect(entryEdges.single.toId, 't2');
  });

  test('unauflösbare Ziele erzeugen keine Edge', () async {
    await insertTable('t1', 'Quelle');
    await insertEntry('e1', 't1', 0, '[[Gibts nicht]] und ![[fehlt.png]]');

    await svc.materializeForTable('t1');

    expect(await db.edgeDao.fetchOutgoingLinks('entry', 'e1'), isEmpty);
  });

  test('erneutes Speichern ersetzt Edges (idempotent, keine Duplikate)',
      () async {
    await insertTable('t1', 'Quelle');
    await insertTable('t2', 'Monster');
    await insertTable('t3', 'Schätze');
    await insertEntry('e1', 't1', 0, '[[Monster]]');

    await svc.materializeForTable('t1');
    await svc.materializeForTable('t1'); // zweiter Lauf → keine Duplikate

    var edges = await db.edgeDao.fetchOutgoingLinks('entry', 'e1');
    expect(edges, hasLength(1));

    // Text ändert sich: Link zeigt jetzt auf Schätze.
    await (db.update(db.entries)..where((e) => e.id.equals('e1')))
        .write(const EntriesCompanion(content: Value('[[Schätze]]')));
    await svc.materializeForTable('t1');

    edges = await db.edgeDao.fetchOutgoingLinks('entry', 'e1');
    expect(edges.single.toId, 't3'); // alte Edge weg, neue da
  });

  test('doppelter Link im selben Text ergibt nur eine Edge', () async {
    await insertTable('t1', 'Quelle');
    await insertTable('t2', 'Monster');
    await insertEntry('e1', 't1', 0, '[[Monster]] und nochmal [[Monster]]');

    await svc.materializeForTable('t1');

    expect(await db.edgeDao.fetchOutgoingLinks('entry', 'e1'), hasLength(1));
  });

  test('translation_of-Edges bleiben beim Ersetzen unberührt', () async {
    await insertTable('t1', 'Quelle');
    await insertTable('t2', 'Monster');
    await db.edgeDao.linkTranslation(
        sourceTableId: 't2', translationTableId: 't1');
    await insertEntry('e1', 't1', 0, 'kein Link');

    await svc.materializeForTable('t1');

    expect(await db.edgeDao.isTranslation('t1'), isTrue);
  });

  test('watchBacklinksToTable: Links auf Tabelle UND ihre Einträge', () async {
    // t2 „Monster" hat den Eintrag „Goblin". Zwei Quellen verlinken:
    // t1/e1 → auf die Tabelle, t3/e3 → auf den Eintrag.
    await insertTable('t1', 'Quelle A');
    await insertTable('t2', 'Monster');
    await insertTable('t3', 'Quelle B');
    await insertEntry('goblin', 't2', 0, 'Goblin');
    await insertEntry('e1', 't1', 0, '[[Monster]]');
    await insertEntry('e3', 't3', 0, '[[Monster#Goblin]]');

    await svc.materializeForTable('t1');
    await svc.materializeForTable('t3');

    final backlinks = await db.edgeDao.watchBacklinksToTable('t2').first;
    expect(backlinks, hasLength(2));
    expect(backlinks.map((e) => e.fromId).toSet(), {'e1', 'e3'});

    // Fremde Tabelle ohne Links auf t2 → keine Backlinks.
    expect(await db.edgeDao.watchBacklinksToTable('t1').first, isEmpty);
  });

  test('watchBacklinksTo liefert eingehende Links', () async {
    await insertTable('t1', 'Quelle');
    await insertTable('t2', 'Monster');
    await insertEntry('e1', 't1', 0, '[[Monster]]');

    await svc.materializeForTable('t1');

    final backlinks = await db.edgeDao.watchBacklinksTo('table', 't2').first;
    expect(backlinks, hasLength(1));
    expect(backlinks.single.fromType, 'entry');
    expect(backlinks.single.fromId, 'e1');
  });
}
