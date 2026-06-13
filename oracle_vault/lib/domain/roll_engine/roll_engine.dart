// Datei: lib/domain/roll_engine/roll_engine.dart
//
// ZWECK: Implementiert alle vier Zieh-Modi für Oracle-Tabellen.
//        Diese Engine liegt im Vault und wird von Downstream-RPG-Tools
//        direkt importiert. Im Vault selbst wird sie nur für Validierungs-Würfe
//        verwendet.
//
// MODI:
//   uniform  – Gleichverteilung, alle Einträge gleich wahrscheinlich
//   weighted – Gewichtetes Ziehen nach Entry.weight
//   dice     – Würfelausdruck auswerten, Ergebnis auf rollMin/rollMax mappen
//   deck     – Ziehen ohne Zurücklegen; DeckState ist persistierbar
//
// REKURSION: Subtable-Verweise werden automatisch aufgelöst.
//            Zyklus-Erkennung via visitedTableIds-Set; bei Zyklus Abbruch mit Fehler.
//
// ABHÄNGIGKEITEN: dart:math, dice_parser.dart, vault_database.dart
// PHASE: 0 – Pflichtmodul.

import 'dart:convert';
import 'dart:math';

import 'dice_parser.dart';

// ── Datenklassen ──────────────────────────────────────────────────────────────

/// Ein einzelner Schritt in der Auflösungskette (für Subtable-Traversierung).
class RollStep {
  final String tableId;
  final String tableName;
  final String entryId;
  final String entryContent;

  const RollStep({
    required this.tableId,
    required this.tableName,
    required this.entryId,
    required this.entryContent,
  });
}

/// Ergebnis eines Ziehvorgangs.
class RollResult {
  /// Der finale Eintrag (nach Subtable-Auflösung).
  final RollEntry entry;

  /// Traversierungs-Pfad (leer wenn keine Subtables involviert).
  final List<RollStep> path;

  /// Modifier-Daten des Eintrags, z. B. {reversed: true} für Tarot.
  final Map<String, dynamic> modifiers;

  const RollResult({
    required this.entry,
    this.path = const [],
    this.modifiers = const {},
  });
}

/// Eintrag, wie er von der Roll-Engine genutzt wird (entkoppelt von Drift).
///
/// Der Caller übergibt diese Objekte; die Engine kennt kein Drift-Schema.
/// Das ermöglicht einfaches Testen ohne Datenbankverbindung.
class RollEntry {
  final String id;
  final String content;
  final String? bodyMd;
  final double weight;
  final int? rollMin;
  final int? rollMax;
  final String? subtableId;
  final String? modifierJson;

  const RollEntry({
    required this.id,
    required this.content,
    this.bodyMd,
    this.weight = 1.0,
    this.rollMin,
    this.rollMax,
    this.subtableId,
    this.modifierJson,
  });
}

/// Tabellen-Metadaten, wie sie von der Roll-Engine benötigt werden.
class RollTable {
  final String id;
  final String name;
  final String oracleType; // 'uniform' | 'weighted' | 'dice' | 'deck'
  final String? diceExpr;
  final List<RollEntry> entries;

  const RollTable({
    required this.id,
    required this.name,
    required this.oracleType,
    this.diceExpr,
    required this.entries,
  });
}

/// Zustand eines Deck-Modus (welche Karten wurden bereits gezogen).
///
/// Persistierbar: JSON-Serialisierung für späteren Restore (Phase 4).
class DeckState {
  final String tableId;
  final List<String> remainingIds;
  final List<String> drawnIds;

  const DeckState({
    required this.tableId,
    required this.remainingIds,
    this.drawnIds = const [],
  });

  bool get isEmpty => remainingIds.isEmpty;
  int get remaining => remainingIds.length;
  int get drawn => drawnIds.length;

  DeckState copyWith({
    List<String>? remainingIds,
    List<String>? drawnIds,
  }) =>
      DeckState(
        tableId: tableId,
        remainingIds: remainingIds ?? this.remainingIds,
        drawnIds: drawnIds ?? this.drawnIds,
      );

  Map<String, dynamic> toJson() => {
        'table_id': tableId,
        'remaining_ids': remainingIds,
        'drawn_ids': drawnIds,
      };

  factory DeckState.fromJson(Map<String, dynamic> json) => DeckState(
        tableId: json['table_id'] as String,
        remainingIds: List<String>.from(json['remaining_ids'] as List),
        drawnIds: List<String>.from(json['drawn_ids'] as List),
      );
}

// ── Callback-Typen für Subtable-Auflösung ────────────────────────────────────

/// Callback: Gibt die [RollTable] für eine tableId zurück.
/// Muss vom Caller bereitgestellt werden (z. B. aus Riverpod-Provider).
typedef TableLoader = Future<RollTable?> Function(String tableId);

// ── Engine ────────────────────────────────────────────────────────────────────

/// Kernlogik für alle Zieh-Modi.
///
/// MUSTER: Zustandslos. Deck-Zustand wird als [DeckState] vom Caller verwaltet.
///         Injiziertes [Random]-Objekt für Testbarkeit.
class RollEngine {
  final Random _random;

  RollEngine({Random? random}) : _random = random ?? Random();

  // ── Öffentliche API ────────────────────────────────────────────────────────

  /// Zieht einmal auf [table] und löst Subtable-Verweise rekursiv auf.
  ///
  /// [tableLoader] wird nur aufgerufen, wenn der Eintrag einen Subtable-Verweis hat.
  /// [visitedTableIds] verhindert Endlosschleifen bei zyklischen Subtable-Verweisen.
  Future<RollResult> rollOnce(
    RollTable table, {
    TableLoader? tableLoader,
    Set<String>? visitedTableIds,
  }) async {
    final visited = visitedTableIds ?? {};
    if (visited.contains(table.id)) {
      // Zyklus erkannt – gib einen Fehler-Eintrag zurück statt Endlosschleife.
      return RollResult(
        entry: RollEntry(
          id: 'cycle-error',
          content:
              '[Zyklus erkannt: Tabelle "${table.name}" verweist auf sich selbst]',
        ),
      );
    }
    visited.add(table.id);

    final entry = _pickEntry(table);
    final path = <RollStep>[
      RollStep(
        tableId: table.id,
        tableName: table.name,
        entryId: entry.id,
        entryContent: entry.content,
      ),
    ];

    // Subtable-Auflösung
    if (entry.subtableId != null && tableLoader != null) {
      final subtable = await tableLoader(entry.subtableId!);
      if (subtable != null) {
        final subResult = await rollOnce(
          subtable,
          tableLoader: tableLoader,
          visitedTableIds: visited,
        );
        return RollResult(
          entry: subResult.entry,
          path: [...path, ...subResult.path],
          modifiers: subResult.modifiers,
        );
      }
    }

    return RollResult(
      entry: entry,
      path: path,
      modifiers: _resolveModifiers(entry),
    );
  }

  /// Zieht [count] Mal auf [table].
  Future<List<RollResult>> rollMany(
    RollTable table,
    int count, {
    TableLoader? tableLoader,
    bool withReplacement = true,
  }) async {
    assert(count >= 1, 'count muss mindestens 1 sein');
    if (withReplacement) {
      return Future.wait(List.generate(
        count,
        (_) => rollOnce(table, tableLoader: tableLoader),
      ));
    }
    // Ohne Zurücklegen: Entry-Pool sequenziell schrumpfen.
    final available = List<RollEntry>.from(table.entries);
    final results = <RollResult>[];
    final limited = min(count, available.length);
    for (var i = 0; i < limited; i++) {
      final entry = _pickFromList(available, table.oracleType, table.diceExpr);
      available.remove(entry);
      results.add(RollResult(
        entry: entry,
        modifiers: _resolveModifiers(entry),
        path: [
          RollStep(
            tableId: table.id,
            tableName: table.name,
            entryId: entry.id,
            entryContent: entry.content,
          )
        ],
      ));
    }
    return results;
  }

  // ── Deck-Modus ─────────────────────────────────────────────────────────────

  /// Erstellt einen neuen, gemischten DeckState für [table].
  DeckState shuffleDeck(RollTable table) {
    final ids = table.entries.map((e) => e.id).toList();
    ids.shuffle(_random);
    return DeckState(tableId: table.id, remainingIds: ids);
  }

  /// Zieht eine Karte aus dem [state] (ohne Zurücklegen).
  ///
  /// Gibt null zurück wenn das Deck leer ist.
  RollResult? drawFromDeck(DeckState state, RollTable table) {
    if (state.isEmpty) return null;
    final drawnId = state.remainingIds.first;
    final entry =
        table.entries.firstWhere((e) => e.id == drawnId, orElse: () {
      // Eintrag nicht mehr in der Tabelle — überspringen.
      return RollEntry(id: drawnId, content: '[Gelöscht]');
    });
    return RollResult(
      entry: entry,
      modifiers: _resolveModifiers(entry),
      path: [
        RollStep(
          tableId: table.id,
          tableName: table.name,
          entryId: entry.id,
          entryContent: entry.content,
        )
      ],
    );
  }

  /// Gibt den neuen [DeckState] nach dem Ziehen zurück.
  DeckState advanceDeck(DeckState state) {
    if (state.isEmpty) return state;
    final drawn = state.remainingIds.first;
    return state.copyWith(
      remainingIds: state.remainingIds.sublist(1),
      drawnIds: [...state.drawnIds, drawn],
    );
  }

  // ── Modifier (Tarot reversed/upright u. a.) ─────────────────────────────────

  /// Wertet [RollEntry.modifierJson] aus und erzeugt die Lauf­zeit-Modifier
  /// eines Ziehvorgangs.
  ///
  /// Tarot: Ist `reversed_possible == true`, wird pro Ziehung zufällig
  /// `{reversed: true|false}` (upright/reversed) bestimmt. Andere Modifier-
  /// Felder werden unverändert durchgereicht.
  Map<String, dynamic> _resolveModifiers(RollEntry entry) {
    if (entry.modifierJson == null || entry.modifierJson!.isEmpty) {
      return const {};
    }
    try {
      final raw = jsonDecode(entry.modifierJson!) as Map<String, dynamic>;
      final result = <String, dynamic>{};
      if (raw['reversed_possible'] == true) {
        result['reversed'] = _random.nextBool();
      }
      return result;
    } catch (_) {
      return const {};
    }
  }

  // ── Interne Picker ─────────────────────────────────────────────────────────

  RollEntry _pickEntry(RollTable table) {
    if (table.entries.isEmpty) {
      return RollEntry(id: 'empty', content: '[Leere Tabelle]');
    }
    return switch (table.oracleType) {
      'weighted' => _pickWeighted(table.entries),
      'dice' => _pickDice(table.entries, table.diceExpr),
      _ => _pickUniform(table.entries),
    };
  }

  RollEntry _pickFromList(
      List<RollEntry> entries, String oracleType, String? diceExpr) {
    if (entries.isEmpty) {
      return RollEntry(id: 'empty', content: '[Leere Tabelle]');
    }
    return switch (oracleType) {
      'weighted' => _pickWeighted(entries),
      'dice' => _pickDice(entries, diceExpr),
      _ => _pickUniform(entries),
    };
  }

  RollEntry _pickUniform(List<RollEntry> entries) {
    return entries[_random.nextInt(entries.length)];
  }

  RollEntry _pickWeighted(List<RollEntry> entries) {
    final totalWeight = entries.fold(0.0, (sum, e) => sum + e.weight);
    if (totalWeight <= 0) return _pickUniform(entries);
    var threshold = _random.nextDouble() * totalWeight;
    for (final entry in entries) {
      threshold -= entry.weight;
      if (threshold <= 0) return entry;
    }
    return entries.last;
  }

  RollEntry _pickDice(List<RollEntry> entries, String? diceExpr) {
    if (diceExpr == null) return _pickUniform(entries);
    final expr = DiceParser.tryParse(diceExpr);
    if (expr == null) return _pickUniform(entries);
    final result = expr.roll(random: _random);
    // Suche den ersten Eintrag dessen rollMin/rollMax den Wert umfasst.
    for (final entry in entries) {
      if (entry.rollMin != null &&
          entry.rollMax != null &&
          result >= entry.rollMin! &&
          result <= entry.rollMax!) {
        return entry;
      }
    }
    // Fallback: Uniform wenn kein Bereich passt.
    return _pickUniform(entries);
  }
}
