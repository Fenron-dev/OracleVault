// Datei: lib/features/import/adapters/import_adapter.dart
//
// ZWECK: Abstraktes Interface für alle Import-Adapter.
//        Jeder Adapter implementiert parse() und gibt einen RawCandidate zurück.
//        Format-Erweiterung = neuer Adapter, keine Änderung am Rest.
// PHASE: 2

import '../import_state.dart';

/// Basis-Interface für alle Import-Adapter.
abstract class ImportAdapter {
  /// Parst die [source] und gibt einen RawCandidate zurück.
  /// Wirft [ImportParseException] bei unbehebbarem Fehler.
  Future<RawCandidate> parse(ImportSource source);

  /// Liefert true wenn dieser Adapter für [source] zuständig ist.
  bool canHandle(ImportSource source);
}

class ImportParseException implements Exception {
  final String message;
  const ImportParseException(this.message);
  @override
  String toString() => 'ImportParseException: $message';
}

// ── Dice-Ausdruck-Erkennung (shared) ─────────────────────────────────────────

/// Erkennt ob ein String wie eine d-Notation aussieht: d20, d100, 2d6, etc.
/// Gibt den erkannten Ausdruck zurück oder null.
String? detectDiceExpr(String text) {
  final match = RegExp(
    r'\b(\d*d\d+(?:[+-]\d+)?)\b',
    caseSensitive: false,
  ).firstMatch(text.toLowerCase());
  return match?.group(1);
}

/// Erkennt die Oracle-Typ-Heuristik aus einem Listentyp.
/// Wenn rollMin/rollMax vorhanden → 'dice'. Sonst 'uniform'.
String detectOracleType({
  required bool hasRanges,
  required bool hasWeights,
}) {
  if (hasRanges) return 'dice';
  if (hasWeights) return 'weighted';
  return 'uniform';
}

/// Erkennt die Sprache heuristisch aus dem Text (einfach: häufige Wörter).
/// Korrekte Erkennung kommt in Phase 3 via google_mlkit_language_id.
String detectLanguage(String text) {
  final lower = text.toLowerCase();
  // Häufige deutsche Funktionswörter
  final deWords = ['der', 'die', 'das', 'und', 'ist', 'ein', 'eine', 'mit'];
  // Häufige englische Funktionswörter
  final enWords = ['the', 'and', 'is', 'a', 'an', 'with', 'of', 'in'];
  int deScore = 0, enScore = 0;
  for (final w in deWords) {
    if (lower.contains(' $w ')) deScore++;
  }
  for (final w in enWords) {
    if (lower.contains(' $w ')) enScore++;
  }
  return enScore > deScore ? 'en' : 'de';
}
