// Tests für CollectionType — stabile Wire-Werte + robustes Parsen.

import 'package:flutter_test/flutter_test.dart';
import 'package:oracle_vault/domain/collection_type.dart';

void main() {
  group('CollectionType', () {
    test('Wire-Werte sind stabil (nicht ändern!)', () {
      expect(CollectionType.deck.wireValue, 'deck');
      expect(CollectionType.supplement.wireValue, 'supplement');
      expect(CollectionType.battlemap.wireValue, 'battlemap');
      expect(CollectionType.tokens.wireValue, 'tokens');
      expect(CollectionType.generic.wireValue, 'generic');
    });

    test('fromWire mappt bekannte Werte zurück', () {
      for (final t in CollectionType.values) {
        expect(CollectionType.fromWire(t.wireValue), t);
      }
    });

    test('fromWire fällt bei unbekannt/null auf generic zurück', () {
      expect(CollectionType.fromWire('was-auch-immer'), CollectionType.generic);
      expect(CollectionType.fromWire(null), CollectionType.generic);
      expect(CollectionType.fromWire(''), CollectionType.generic);
    });

    test('jeder Typ hat ein nicht-leeres Label', () {
      for (final t in CollectionType.values) {
        expect(t.label.trim(), isNotEmpty);
      }
    });
  });
}
