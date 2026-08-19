// Datei: test/data/table_search_test.dart
//
// ZWECK: Regressionstests für TableDao.searchTableIds (Issues #16, #17).
//        Vor dem Fix warf JEDE Suche — der FTS-Index deklarierte eine Spalte
//        (table_name), die es in der Content-Tabelle `entries` nicht gibt.
//        Zusätzlich landete der Rohtext ungequotet im MATCH-Ausdruck, sodass
//        gewöhnliche Interpunktion einen fts5-Syntaxfehler auslöste.

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:oracle_vault/data/db/daos/table_dao.dart';
import 'package:oracle_vault/data/db/vault_database.dart';

void main() {
  late VaultDatabase db;

  setUp(() async {
    db = VaultDatabase.inMemory();
    await db.customSelect('SELECT 1').get();
  });

  tearDown(() => db.close());

  Future<void> addTable(String id, String name,
      {String? description, List<String> entries = const []}) async {
    final now = DateTime.now();
    await db.tableDao.insertTable(OracleTablesCompanion.insert(
      id: id,
      name: name,
      description: Value(description),
      createdAt: now,
      updatedAt: now,
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

  group('FTS-Suche über Einträge', () {
    test('findet Tabelle über den Eintragstext', () async {
      await addTable('t1', 'Wildnis', entries: ['Ein Goblin lauert im Gebüsch']);
      await addTable('t2', 'Stadt', entries: ['Ein Wachmann grüßt']);

      expect(await db.tableDao.searchTableIds('Goblin'), ['t1']);
    });

    test('sucht als Präfix', () async {
      await addTable('t1', 'Wildnis', entries: ['Goblinhorde']);
      expect(await db.tableDao.searchTableIds('Gobl'), ['t1']);
    });

    test('durchsucht auch body_md', () async {
      await addTable('t1', 'NSCs');
      await db.entryDao.insertEntry(EntriesCompanion.insert(
        id: 'e1',
        tableId: 't1',
        position: 0,
        content: 'Namenlos',
        bodyMd: const Value('Trägt einen **Rubinring** am Finger.'),
      ));
      expect(await db.tableDao.searchTableIds('Rubinring'), ['t1']);
    });

    test('Treffer verschwindet, wenn der Eintrag gelöscht wird', () async {
      await addTable('t1', 'Wildnis', entries: ['Goblin']);
      expect(await db.tableDao.searchTableIds('Goblin'), ['t1']);

      await db.entryDao.deleteEntry('t1-e0', 't1');
      expect(await db.tableDao.searchTableIds('Goblin'), isEmpty);
    });

    test('Treffer folgt einer Änderung des Eintrags', () async {
      await addTable('t1', 'Wildnis', entries: ['Goblin']);
      final entry = await db.entryDao.fetchById('t1-e0');

      await db.entryDao.updateEntry(
          entry!.copyWith(content: 'Kobold').toCompanion(true));

      expect(await db.tableDao.searchTableIds('Goblin'), isEmpty);
      expect(await db.tableDao.searchTableIds('Kobold'), ['t1']);
    });
  });

  group('Suche über Tabellenname und Beschreibung', () {
    test('findet Tabelle über ihren Namen, auch ohne passende Einträge',
        () async {
      await addTable('t1', 'Bestiarium', entries: ['irgendwas']);
      expect(await db.tableDao.searchTableIds('Bestiarium'), ['t1']);
    });

    test('findet Tabelle über die Beschreibung', () async {
      await addTable('t1', 'Liste',
          description: 'Zufallsbegegnungen im Sumpf');
      expect(await db.tableDao.searchTableIds('Sumpf'), ['t1']);
    });

    test('% und _ werden wörtlich gesucht, nicht als Platzhalter', () async {
      await addTable('t1', 'Rabatt 50% Tabelle');
      await addTable('t2', 'Voellig anderer Name');

      expect(await db.tableDao.searchTableIds('50%'), ['t1']);
      // '_' würde als LIKE-Platzhalter jedes Einzelzeichen matchen.
      expect(await db.tableDao.searchTableIds('_'), isEmpty);
    });
  });

  group('Sonderzeichen lösen keinen fts5-Syntaxfehler aus', () {
    // Vor dem Fix warf jeder dieser Begriffe eine SqliteException.
    const tricky = [
      'Rock (Hard)',
      'a-b',
      'foo:bar',
      'OR',
      'AND',
      'NOT',
      'NEAR',
      '*',
      '"',
      '((( ',
      '^start',
      'a OR b',
      'ä ö ü',
      "it's",
    ];

    for (final q in tricky) {
      test('Suche nach "$q" wirft nicht', () async {
        await addTable('t1', 'Wildnis', entries: ['Ein Goblin (klein) lauert']);
        await expectLater(db.tableDao.searchTableIds(q), completes);
      });
    }

    test('findet Text mit Klammern', () async {
      await addTable('t1', 'Wildnis', entries: ['Ein Goblin (klein) lauert']);
      expect(await db.tableDao.searchTableIds('Goblin (klein)'), ['t1']);
    });
  });

  group('Randfälle', () {
    test('leerer Query liefert leere Liste', () async {
      await addTable('t1', 'Wildnis', entries: ['Goblin']);
      expect(await db.tableDao.searchTableIds(''), isEmpty);
      expect(await db.tableDao.searchTableIds('   '), isEmpty);
    });

    test('ftsPrefixQuery quotet und hängt den Präfix-Stern an', () {
      expect(TableDao.ftsPrefixQuery('Goblin'), '"Goblin"*');
      expect(TableDao.ftsPrefixQuery('Rock (Hard)'), '"Rock (Hard)"*');
    });

    test('ftsPrefixQuery gibt null ohne verwertbares Token', () {
      expect(TableDao.ftsPrefixQuery('((('), isNull);
      expect(TableDao.ftsPrefixQuery('"'), isNull);
      expect(TableDao.ftsPrefixQuery('   '), isNull);
    });
  });
}
