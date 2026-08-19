// Datei: test/data/table_filter_test.dart
//
// ZWECK: TableDao.watchFiltered — die Library-Liste als eine SQL-Abfrage
//        (Issue #22). Vorher lud der Provider bei jeder Änderung alle Tabellen
//        und filterte in Dart; dieser Test hält das Verhalten fest, damit die
//        SQL-Variante dieselbe Liste liefert.

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:oracle_vault/data/db/vault_database.dart';

void main() {
  late VaultDatabase db;

  setUp(() async {
    db = VaultDatabase.inMemory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  var clock = DateTime(2026, 1, 1);

  Future<void> addTable(
    String id,
    String name, {
    String? categoryId,
    String? sourceId,
    String oracleType = 'uniform',
    String language = 'de',
    String? description,
    List<String> entries = const [],
  }) async {
    clock = clock.add(const Duration(minutes: 1));
    await db.tableDao.insertTable(OracleTablesCompanion.insert(
      id: id,
      name: name,
      description: Value(description),
      categoryId: Value(categoryId),
      sourceId: Value(sourceId),
      oracleType: Value(oracleType),
      language: Value(language),
      createdAt: clock,
      updatedAt: clock,
    ));
    for (var i = 0; i < entries.length; i++) {
      await db.entryDao.insertEntry(EntriesCompanion.insert(
        id: '$id-e$i',
        tableId: id,
        position: i,
        content: entries[i],
      ));
    }
  }

  Future<List<String>> ids({
    String? categoryId,
    String? sourceId,
    String? oracleType,
    String? language,
    String? tagId,
    String? collectionId,
    String searchQuery = '',
  }) async {
    final rows = await db.tableDao
        .watchFiltered(
          categoryId: categoryId,
          sourceId: sourceId,
          oracleType: oracleType,
          language: language,
          tagId: tagId,
          collectionId: collectionId,
          searchQuery: searchQuery,
        )
        .first;
    return rows.map((t) => t.id).toList();
  }

  test('ohne Filter: alle Tabellen, zuletzt geänderte zuerst', () async {
    await addTable('t1', 'Alt');
    await addTable('t2', 'Neu');
    expect(await ids(), ['t2', 't1']);
  });

  group('Einzelfilter', () {
    setUp(() async {
      await db.into(db.categories).insert(
          CategoriesCompanion.insert(id: 'c1', name: 'Wildnis'));
      await db.sourceDao.insertSource(SourcesCompanion.insert(
          id: 's1', type: 'book', createdAt: DateTime(2026)));
      await addTable('t1', 'A',
          categoryId: 'c1', sourceId: 's1', oracleType: 'deck');
      await addTable('t2', 'B', language: 'en');
    });

    test('Kategorie', () async => expect(await ids(categoryId: 'c1'), ['t1']));
    test('Quelle', () async => expect(await ids(sourceId: 's1'), ['t1']));
    test('Typ', () async => expect(await ids(oracleType: 'deck'), ['t1']));
    test('Sprache', () async => expect(await ids(language: 'en'), ['t2']));

    test('Filter kombinieren sich mit UND', () async {
      expect(await ids(categoryId: 'c1', language: 'en'), isEmpty);
      expect(await ids(categoryId: 'c1', language: 'de'), ['t1']);
    });
  });

  test('Tag-Filter', () async {
    await addTable('t1', 'A');
    await addTable('t2', 'B');
    final tag = await db.tagDao.findOrCreate('horror', 'tag1');
    await db.tableDao.setTagsFor('t1', [tag.id]);

    expect(await ids(tagId: tag.id), ['t1']);
  });

  test('Collection-Filter', () async {
    await addTable('t1', 'A');
    await addTable('t2', 'B');
    final collectionId = await db.collectionDao
        .createCollection(name: 'Deck', type: 'deck');
    await db.collectionDao.addTables(collectionId, ['t2']);

    expect(await ids(collectionId: collectionId), ['t2']);
  });

  test('Übersetzungen erscheinen nicht als eigene Zeile', () async {
    await addTable('t1', 'Original');
    await addTable('t2', 'Translation', language: 'en');
    await db.edgeDao
        .linkTranslation(sourceTableId: 't1', translationTableId: 't2');

    expect(await ids(), ['t1']);
    // Explizit angefordert bleibt sie sichtbar.
    expect(
      await db.tableDao.watchFiltered(hideTranslations: false).first,
      hasLength(2),
    );
  });

  test('Suche greift auf Name, Beschreibung und Eintragstext', () async {
    await addTable('t1', 'Wildnis', entries: ['Ein Goblin lauert']);
    await addTable('t2', 'Stadt', description: 'Voller Goblins');
    await addTable('t3', 'Goblinmarkt');
    await addTable('t4', 'Taverne', entries: ['Ein Wachmann grüßt']);

    expect((await ids(searchQuery: 'Goblin')).toSet(), {'t1', 't2', 't3'});
  });

  test('Suche und Filter greifen gemeinsam', () async {
    await addTable('t1', 'Goblinlager', language: 'de');
    await addTable('t2', 'Goblin camp', language: 'en');

    expect(await ids(searchQuery: 'Goblin', language: 'en'), ['t2']);
  });

  test('Suche ohne Treffer liefert eine leere Liste', () async {
    await addTable('t1', 'Wildnis', entries: ['Ein Goblin lauert']);
    expect(await ids(searchQuery: 'Drache'), isEmpty);
  });

  test('Suchbegriff aus reiner Interpunktion wirft nicht', () async {
    await addTable('t1', 'Wildnis', entries: ['Ein Goblin lauert']);
    for (final q in ['(', '"', '-', '*', 'a-b', 'foo:bar']) {
      await expectLater(ids(searchQuery: q), completes,
          reason: 'Suchbegriff „$q" darf die Liste nicht sprengen');
    }
  });
}
