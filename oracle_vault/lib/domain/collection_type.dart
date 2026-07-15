// Datei: lib/domain/collection_type.dart
//
// ZWECK: Kanonische Liste der Collection-Typen mit stabilem Wire-Wert
//        (in der DB-Spalte `collections.type` gespeichert) und Anzeige-Label.
//        Bewusst ohne Flutter-Abhängigkeit — Icons werden im UI aus [wireValue]
//        gemappt. Damit teilen Erstell-Dialog und Sidebar dieselbe Quelle.
// PHASE: 4

/// Die von OracleVault unterstützten Collection-Typen.
///
/// Der [wireValue] wird persistiert und darf nicht geändert werden.
/// Neue Typen hinten anhängen. Unbekannte/alte Werte fallen auf
/// [CollectionType.generic] zurück.
enum CollectionType {
  /// Kartendeck (z. B. Tarot mit upright/reversed).
  deck('deck', 'Deck'),

  /// Quellenbuch / RPG-Supplement.
  supplement('supplement', 'Supplement'),

  /// Battlemap-Sammlung.
  battlemap('battlemap', 'Battlemaps'),

  /// Token-/Marker-Sammlung.
  tokens('tokens', 'Tokens'),

  /// Allgemeine Gruppierung (Standard).
  generic('generic', 'Sammlung');

  const CollectionType(this.wireValue, this.label);

  /// In der DB gespeicherter, stabiler Bezeichner.
  final String wireValue;

  /// Für die Anzeige im UI.
  final String label;

  /// Wandelt einen gespeicherten Wire-Wert in den Enum-Wert um.
  /// Unbekannte Werte ergeben [CollectionType.generic].
  static CollectionType fromWire(String? value) {
    for (final t in CollectionType.values) {
      if (t.wireValue == value) return t;
    }
    return CollectionType.generic;
  }
}
