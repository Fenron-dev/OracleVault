// Datei: lib/domain/roll_engine/dice_parser.dart
//
// ZWECK: Parser für Würfel-Notation (XdY+Z, XdYkH, XdYkL).
//        Kein externes Paket — selbst implementiert für volle Kontrolle
//        und Offline-Betrieb.
//
// UNTERSTÜTZTE SYNTAX:
//   d20          1 Würfel W20
//   3d6          3 Würfel W6
//   2d10+3       2 Würfel W10 plus Konstante 3
//   4d6-1        4 Würfel W6 minus Konstante 1
//   4d6kH3       4 Würfel W6, behalte die 3 höchsten (keep highest)
//   4d6kL2       4 Würfel W6, behalte die 2 niedrigsten (keep lowest)
//   1d100        W100 (Perzentilwürfel)
//
// ABHÄNGIGKEITEN: dart:math
// PHASE: 0 – Roll-Engine.

import 'dart:math';

/// Ergebnis eines geparseten Würfelausdrucks.
class DiceExpression {
  final int count;    // Anzahl der Würfel
  final int sides;    // Seiten pro Würfel
  final int modifier; // Addierter/subtrahierter Wert
  final int? keepN;   // Wie viele Würfel behalten (null = alle)
  final bool keepHighest; // true = höchste behalten, false = niedrigste

  const DiceExpression({
    required this.count,
    required this.sides,
    this.modifier = 0,
    this.keepN,
    this.keepHighest = true,
  });

  /// Wirft die Würfel und gibt das Gesamtergebnis zurück.
  ///
  /// [random] ist optional injizierbar — für Tests mit fester Seed-Zahl.
  int roll({Random? random}) {
    final rng = random ?? Random();
    final rolls = List.generate(count, (_) => rng.nextInt(sides) + 1);

    if (keepN != null) {
      rolls.sort();
      final kept = keepHighest
          ? rolls.sublist(rolls.length - keepN!)
          : rolls.sublist(0, keepN!);
      return kept.fold(0, (sum, v) => sum + v) + modifier;
    }

    return rolls.fold(0, (sum, v) => sum + v) + modifier;
  }

  @override
  String toString() {
    final base = '${count}d$sides';
    final keep = keepN == null
        ? ''
        : 'k${keepHighest ? 'H' : 'L'}$keepN';
    final mod = modifier == 0
        ? ''
        : (modifier > 0 ? '+$modifier' : '$modifier');
    return '$base$keep$mod';
  }
}

/// Parst einen Würfelausdruck-String in eine [DiceExpression].
///
/// Wirft [FormatException] bei unbekanntem Format.
///
/// Beispiele:
///   DiceParser.parse('d20')      → DiceExpression(1, 20)
///   DiceParser.parse('3d6')      → DiceExpression(3, 6)
///   DiceParser.parse('2d10+3')   → DiceExpression(2, 10, modifier: 3)
///   DiceParser.parse('4d6kH3')   → DiceExpression(4, 6, keepN: 3, keepHighest: true)
abstract class DiceParser {
  // Regex: optional count, 'd', sides, optional kH/kL+n, optional +/-modifier
  static final _pattern = RegExp(
    r'^(\d*)d(\d+)(?:k([HhLl])(\d+))?([+-]\d+)?$',
    caseSensitive: false,
  );

  static DiceExpression parse(String expr) {
    final trimmed = expr.trim().toLowerCase();
    final match = _pattern.firstMatch(trimmed);
    if (match == null) {
      throw FormatException('Ungültige Würfel-Notation: "$expr"');
    }

    final countStr = match.group(1);
    final count = (countStr == null || countStr.isEmpty) ? 1 : int.parse(countStr);
    final sides = int.parse(match.group(2)!);

    if (sides < 2) {
      throw FormatException('Würfel muss mindestens 2 Seiten haben: "$expr"');
    }
    if (count < 1) {
      throw FormatException('Anzahl Würfel muss mindestens 1 sein: "$expr"');
    }

    final keepDir = match.group(3);
    final keepNStr = match.group(4);
    final modStr = match.group(5);

    int? keepN;
    bool keepHighest = true;
    if (keepDir != null && keepNStr != null) {
      keepHighest = keepDir.toLowerCase() == 'h';
      keepN = int.parse(keepNStr);
      if (keepN < 1 || keepN > count) {
        throw FormatException(
            'keep-Anzahl ($keepN) muss zwischen 1 und $count liegen: "$expr"');
      }
    }

    final modifier = modStr == null ? 0 : int.parse(modStr);

    return DiceExpression(
      count: count,
      sides: sides,
      modifier: modifier,
      keepN: keepN,
      keepHighest: keepHighest,
    );
  }

  /// Gibt null zurück wenn der Ausdruck ungültig ist (statt Exception).
  static DiceExpression? tryParse(String expr) {
    try {
      return parse(expr);
    } on FormatException {
      return null;
    }
  }
}
