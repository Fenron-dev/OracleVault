// Datei: lib/services/wikilink_service.dart
//
// ZWECK: Save-Hook für Wiki-Links (Phase 5).
//        Parst nach jedem Speichern einer Tabelle deren description sowie
//        content/body_md aller Einträge, löst die gefundenen [[Links]] /
//        ![[Embeds]] gegen die DB auf und materialisiert sie als Edge-Records.
//        Der Rohtext bleibt unangetastet — Edges sind redundant, aber abfragbar
//        (Backlinks, Graph).
//
// AUFLÖSUNG:
//   [[Table]]        → OracleTable per Name (case-insensitiv) → 'wikilink'
//   [[Table#Entry]]  → Entry per content in dieser Tabelle    → 'wikilink'
//                      (Eintrag nicht gefunden → Fallback auf die Tabelle)
//   ![[name.png]]    → MediaFile per Titel                    → 'embed'
//   Unauflösbare Ziele erzeugen keine Edge (Text bleibt ja erhalten und wird
//   beim nächsten Speichern erneut geprüft).
// PHASE: 5

import '../data/db/daos/edge_dao.dart';
import '../data/db/vault_database.dart';
import '../domain/wikilink/wikilink.dart';

class WikiLinkService {
  final VaultDatabase db;

  WikiLinkService({required this.db});

  /// Materialisiert alle Wiki-Link-Edges für [tableId]:
  /// Tabellen-description (from = table) und alle Einträge (from = entry).
  /// Ersetzt vorhandene wikilink/embed-Edges der jeweiligen Quelle vollständig.
  ///
  /// Alles läuft in EINER Transaktion und die Ziel-Auflösung teilt sich einen
  /// Cache: vorher gab es pro Eintrag eine eigene Transaktion und pro Link
  /// eine Namensabfrage — bei einer d1000-Tabelle also je tausend.
  Future<void> materializeForTable(String tableId) async {
    final table = await db.tableDao.fetchById(tableId);
    if (table == null) return;

    final resolver = _TargetResolver(db);
    final newEdges = <EdgesCompanion>[];

    // ── Tabellen-Beschreibung ────────────────────────────────────────────────
    newEdges.addAll(await _resolveLinks(
      resolver: resolver,
      fromType: 'table',
      fromId: tableId,
      text: table.description ?? '',
    ));

    // ── Einträge ─────────────────────────────────────────────────────────────
    final entries = await db.entryDao.fetchForTable(tableId);
    for (final entry in entries) {
      newEdges.addAll(await _resolveLinks(
        resolver: resolver,
        fromType: 'entry',
        fromId: entry.id,
        text: '${entry.content}\n${entry.bodyMd ?? ''}',
      ));
    }

    await db.edgeDao.replaceWikiLinkEdgesForTable(
      tableId: tableId,
      entryIds: entries.map((e) => e.id).toList(),
      newEdges: newEdges,
    );
  }

  /// Parst [text] und löst jeden Link gegen die DB auf.
  /// Doppelte Ziele (gleiches to + Relation) werden nur einmal materialisiert.
  Future<List<EdgesCompanion>> _resolveLinks({
    required _TargetResolver resolver,
    required String fromType,
    required String fromId,
    required String text,
  }) async {
    final links = parseWikiLinks(text);
    if (links.isEmpty) return const [];

    final result = <EdgesCompanion>[];
    final seen = <String>{}; // "$relation:$toType:$toId"

    for (final link in links) {
      final resolved = await resolver.resolve(link);
      if (resolved == null) continue;

      final key = '${link.isEmbed}:${resolved.$1}:${resolved.$2}';
      if (!seen.add(key)) continue;

      result.add(EdgeDao.buildLinkEdge(
        fromType: fromType,
        fromId: fromId,
        toType: resolved.$1,
        toId: resolved.$2,
        isEmbed: link.isEmbed,
        metadataJson: null,
      ));
    }
    return result;
  }
}

/// Löst Link-Ziele auf und merkt sich, was schon nachgeschlagen wurde.
///
/// Lebt genau einen materializeForTable-Lauf lang: Tabellen kommen einmal
/// komplett, Einträge und Medien landen beim ersten Zugriff im Cache. In einer
/// Tabelle zeigen viele Zeilen auf dieselben Ziele — vorher war das jedes Mal
/// eine eigene Abfrage.
class _TargetResolver {
  final VaultDatabase db;
  _TargetResolver(this.db);

  Map<String, String>? _tableIdsByName;
  final Map<String, Map<String, String>> _entryIdsByTable = {};
  final Map<String, String?> _mediaIdsByTitle = {};

  /// Löst das Ziel eines Links auf → (toType, toId) oder null.
  Future<(String, String)?> resolve(WikiLink link) async {
    if (link.isEmbed) {
      final id = await _mediaId(link.target);
      return id == null ? null : ('media', id);
    }

    final tableId = (await _tableIds())[_key(link.target)];
    if (tableId == null) return null;

    if (link.entry != null) {
      final entryId = (await _entryIds(tableId))[_key(link.entry!)];
      // Eintrag (noch) nicht vorhanden → wenigstens auf die Tabelle zeigen.
      if (entryId != null) return ('entry', entryId);
    }
    return ('table', tableId);
  }

  static String _key(String raw) => raw.toLowerCase().trim();

  /// Bei mehreren Tabellen gleichen Namens gewinnt die älteste — dieselbe
  /// Regel wie in TableDao.fetchByName. (Rückwärts eingetragen, damit der
  /// erste Treffer den späteren überschreibt.)
  Future<Map<String, String>> _tableIds() async {
    if (_tableIdsByName != null) return _tableIdsByName!;
    final tables = await db.tableDao.fetchAll()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return _tableIdsByName = {
      for (final t in tables.reversed) _key(t.name): t.id,
    };
  }

  /// Bei gleichem Inhalt gewinnt die kleinste position — dieselbe Regel wie in
  /// EntryDao.fetchByContent.
  Future<Map<String, String>> _entryIds(String tableId) async {
    final cached = _entryIdsByTable[tableId];
    if (cached != null) return cached;
    final entries = await db.entryDao.fetchForTable(tableId)
      ..sort((a, b) => a.position.compareTo(b.position));
    return _entryIdsByTable[tableId] = {
      for (final e in entries.reversed) _key(e.content): e.id,
    };
  }

  Future<String?> _mediaId(String target) async {
    final key = _key(target);
    if (_mediaIdsByTitle.containsKey(key)) return _mediaIdsByTitle[key];
    final media = await db.mediaDao.fetchByTitle(target);
    return _mediaIdsByTitle[key] = media?.id;
  }
}
