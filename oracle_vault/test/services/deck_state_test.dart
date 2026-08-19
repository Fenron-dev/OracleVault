// Datei: test/services/deck_state_test.dart
//
// ZWECK: Persistenz des Deck-Zustands (Issue #23). Die Roll-Engine ist
//        zustandslos — ohne diesen Service war nach jedem App-Neustart jede
//        angefangene Tarot-Hand weg, obwohl das Schema zusagt, dass der
//        DeckState separat persistiert wird.

import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:oracle_vault/data/db/vault_database.dart';
import 'package:oracle_vault/domain/roll_engine/roll_engine.dart';
import 'package:oracle_vault/services/deck_state_service.dart';

void main() {
  late VaultDatabase db;
  late DeckStateService service;
  late RollEngine engine;

  setUp(() async {
    db = VaultDatabase.inMemory();
    await db.customSelect('SELECT 1').get();
    service = DeckStateService(db: db);
    engine = RollEngine(random: Random(42));
  });

  tearDown(() => db.close());

  Future<RollTable> addDeck(String id, List<String> cards,
      {String? metadataJson}) async {
    final now = DateTime.now();
    await db.tableDao.insertTable(OracleTablesCompanion.insert(
      id: id,
      name: 'Tarot',
      oracleType: const Value('deck'),
      metadataJson: Value(metadataJson),
      createdAt: now,
      updatedAt: now,
    ));
    for (var i = 0; i < cards.length; i++) {
      await db.entryDao.insertEntry(EntriesCompanion.insert(
        id: cards[i],
        tableId: id,
        position: i,
        content: 'Karte ${cards[i]}',
      ));
    }
    return RollTable(
      id: id,
      name: 'Tarot',
      oracleType: 'deck',
      entries: [
        for (final c in cards) RollEntry(id: c, content: 'Karte $c'),
      ],
    );
  }

  test('ohne gespeicherten Zustand: null', () async {
    await addDeck('t1', ['c1', 'c2']);
    expect(await service.load('t1'), isNull);
  });

  test('gezogene Karten überleben das Neuladen', () async {
    final table = await addDeck('t1', ['c1', 'c2', 'c3']);

    var state = engine.shuffleDeck(table);
    state = engine.advanceDeck(state);
    await service.save(state);

    final loaded = await service.load('t1');
    expect(loaded!.remainingIds, state.remainingIds);
    expect(loaded.drawnIds, state.drawnIds);
    expect(loaded.remaining, 2);
  });

  test('clear verwirft den Zustand', () async {
    final table = await addDeck('t1', ['c1', 'c2']);
    await service.save(engine.advanceDeck(engine.shuffleDeck(table)));

    await service.clear('t1');
    expect(await service.load('t1'), isNull);
  });

  test('fremde Metadaten bleiben erhalten', () async {
    final table =
        await addDeck('t1', ['c1'], metadataJson: '{"import":"csv"}');
    await service.save(engine.shuffleDeck(table));
    await service.clear('t1');

    final stored = (await db.tableDao.fetchById('t1'))!.metadataJson;
    expect(jsonDecode(stored!), {'import': 'csv'});
  });

  test('unlesbarer Altbestand führt nicht zum Absturz', () async {
    await addDeck('t1', ['c1'], metadataJson: '{"deck_state":"kaputt"}');
    expect(await service.load('t1'), isNull);
  });

  group('reconcileDeck', () {
    test('entfernt gelöschte Karten aus Stapel und Ablage', () async {
      final full = await addDeck('t1', ['c1', 'c2', 'c3']);
      final state = DeckState(
        tableId: 't1',
        remainingIds: const ['c1', 'weg'],
        drawnIds: const ['c2', 'auch-weg'],
      );

      final fixed = engine.reconcileDeck(state, full);
      expect(fixed.remainingIds, contains('c1'));
      expect(fixed.remainingIds, isNot(contains('weg')));
      expect(fixed.drawnIds, ['c2']);
    });

    test('neue Karten landen im Reststapel, nicht garantiert zuletzt',
        () async {
      final table = await addDeck('t1', ['c1', 'c2', 'c3', 'c4', 'c5']);
      // Zustand kennt nur c1; c2–c5 sind seither dazugekommen.
      const state =
          DeckState(tableId: 't1', remainingIds: ['c1'], drawnIds: []);

      final fixed = engine.reconcileDeck(state, table);
      expect(fixed.remainingIds.toSet(), {'c1', 'c2', 'c3', 'c4', 'c5'});
      expect(fixed.remainingIds.last, isNot('c1'),
          reason: 'neue Karten werden einsortiert, nicht angehängt');
    });

    test('leerer Stapel bleibt leer', () async {
      final table = await addDeck('t1', ['c1']);
      const state =
          DeckState(tableId: 't1', remainingIds: [], drawnIds: ['c1']);

      expect(engine.reconcileDeck(state, table).isEmpty, isTrue);
    });
  });
}
