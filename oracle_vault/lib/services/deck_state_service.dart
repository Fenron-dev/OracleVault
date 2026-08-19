// Datei: lib/services/deck_state_service.dart
//
// ZWECK: Persistenz des Deck-Zustands (Ziehen ohne Zurücklegen).
//        Die Roll-Engine ist bewusst zustandslos — sie gibt einen DeckState
//        zurück, aufbewahren muss ihn jemand anders. Ohne diesen Service war
//        nach jedem App-Neustart jede angefangene Tarot-Hand weg, obwohl das
//        Schema „DeckState wird separat persistiert" zusagt.
//
// ABLAGE: oracle_tables.metadata_json unter dem Schlüssel 'deck_state'.
//         Keine eigene Tabelle, weil der Zustand ausschließlich zu genau einer
//         Tabelle gehört und mit ihr gelöscht werden soll.
// PHASE: 4

import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../data/db/vault_database.dart';
import '../domain/roll_engine/roll_engine.dart';

class DeckStateService {
  final VaultDatabase db;

  DeckStateService({required this.db});

  static const _key = 'deck_state';

  /// Gespeicherter Zustand oder null, wenn das Deck noch nie gemischt wurde.
  Future<DeckState?> load(String tableId) async {
    final table = await db.tableDao.fetchById(tableId);
    final raw = _metadata(table?.metadataJson)[_key];
    if (raw is! Map) return null;
    try {
      return DeckState.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      // Unbrauchbarer Altbestand — lieber neu mischen als hier scheitern.
      return null;
    }
  }

  Future<void> save(DeckState state) => _write(state.tableId, state.toJson());

  /// Verwirft den Zustand (Deck neu mischen).
  Future<void> clear(String tableId) => _write(tableId, null);

  /// Schreibt nur den deck_state-Schlüssel und lässt andere Metadaten stehen.
  Future<void> _write(String tableId, Map<String, dynamic>? value) async {
    final table = await db.tableDao.fetchById(tableId);
    if (table == null) return;
    final metadata = _metadata(table.metadataJson);
    if (value == null) {
      metadata.remove(_key);
    } else {
      metadata[_key] = value;
    }
    await db.tableDao.updateTable(OracleTablesCompanion(
      id: Value(tableId),
      metadataJson:
          Value(metadata.isEmpty ? null : jsonEncode(metadata)),
    ));
  }

  static Map<String, dynamic> _metadata(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : {};
    } catch (_) {
      return {};
    }
  }
}
