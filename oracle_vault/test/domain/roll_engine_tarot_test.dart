// Tests für den Tarot reversed/upright-Modifier der Roll-Engine.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:oracle_vault/domain/roll_engine/roll_engine.dart';

void main() {
  RollTable deckOf(List<RollEntry> entries) => RollTable(
        id: 't1',
        name: 'Tarot',
        oracleType: 'deck',
        entries: entries,
      );

  test('reversible Karte erhält reversed-Modifier (bool)', () {
    final engine = RollEngine(random: Random(1));
    final table = deckOf([
      const RollEntry(
        id: 'c1',
        content: 'Der Magier',
        modifierJson: '{"reversed_possible": true}',
      ),
    ]);
    final state = DeckState(tableId: 't1', remainingIds: const ['c1']);

    final result = engine.drawFromDeck(state, table)!;
    expect(result.modifiers.containsKey('reversed'), isTrue);
    expect(result.modifiers['reversed'], isA<bool>());
  });

  test('nicht-reversible Karte hat keine Modifier', () {
    final engine = RollEngine(random: Random(1));
    final table = deckOf([
      const RollEntry(id: 'c2', content: 'Schlichte Karte'),
    ]);
    final state = DeckState(tableId: 't1', remainingIds: const ['c2']);

    final result = engine.drawFromDeck(state, table)!;
    expect(result.modifiers, isEmpty);
  });

  test('über viele Ziehungen kommen beide Orientierungen vor', () {
    final engine = RollEngine(random: Random(42));
    final table = deckOf([
      const RollEntry(
        id: 'c1',
        content: 'X',
        modifierJson: '{"reversed_possible": true}',
      ),
    ]);
    final orientations = <bool>{};
    for (var i = 0; i < 50; i++) {
      final r = engine.drawFromDeck(
        DeckState(tableId: 't1', remainingIds: const ['c1']),
        table,
      )!;
      orientations.add(r.modifiers['reversed'] as bool);
    }
    expect(orientations, containsAll(<bool>{true, false}));
  });

  test('defektes modifierJson führt nicht zum Absturz', () {
    final engine = RollEngine(random: Random(1));
    final table = deckOf([
      const RollEntry(id: 'c3', content: 'Y', modifierJson: 'kein json'),
    ]);
    final state = DeckState(tableId: 't1', remainingIds: const ['c3']);

    final result = engine.drawFromDeck(state, table)!;
    expect(result.modifiers, isEmpty);
  });

  test('rollOnce reicht reversed-Modifier ebenfalls durch', () async {
    final engine = RollEngine(random: Random(7));
    final table = RollTable(
      id: 'u1',
      name: 'Uniform mit reversible Eintrag',
      oracleType: 'uniform',
      entries: const [
        RollEntry(
          id: 'e1',
          content: 'Nur dieser',
          modifierJson: '{"reversed_possible": true}',
        ),
      ],
    );
    final result = await engine.rollOnce(table);
    expect(result.modifiers.containsKey('reversed'), isTrue);
  });
}
