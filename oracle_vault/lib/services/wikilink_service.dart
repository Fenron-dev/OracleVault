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
  Future<void> materializeForTable(String tableId) async {
    final table = await db.tableDao.fetchById(tableId);
    if (table == null) return;

    // ── Tabellen-Beschreibung ────────────────────────────────────────────────
    final tableEdges = await _resolveLinks(
      fromType: 'table',
      fromId: tableId,
      text: table.description ?? '',
    );
    await db.edgeDao.replaceWikiLinkEdges(
      fromType: 'table',
      fromId: tableId,
      newEdges: tableEdges,
    );

    // ── Einträge ─────────────────────────────────────────────────────────────
    final entries = await db.entryDao.fetchForTable(tableId);
    for (final entry in entries) {
      final text = '${entry.content}\n${entry.bodyMd ?? ''}';
      final entryEdges = await _resolveLinks(
        fromType: 'entry',
        fromId: entry.id,
        text: text,
      );
      await db.edgeDao.replaceWikiLinkEdges(
        fromType: 'entry',
        fromId: entry.id,
        newEdges: entryEdges,
      );
    }
  }

  /// Parst [text] und löst jeden Link gegen die DB auf.
  /// Doppelte Ziele (gleiches to + Relation) werden nur einmal materialisiert.
  Future<List<EdgesCompanion>> _resolveLinks({
    required String fromType,
    required String fromId,
    required String text,
  }) async {
    final links = parseWikiLinks(text);
    if (links.isEmpty) return const [];

    final result = <EdgesCompanion>[];
    final seen = <String>{}; // "$relation:$toType:$toId"

    for (final link in links) {
      final resolved = await _resolveTarget(link);
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

  /// Löst das Ziel eines Links auf → (toType, toId) oder null.
  Future<(String, String)?> _resolveTarget(WikiLink link) async {
    if (link.isEmbed) {
      final media = await db.mediaDao.fetchByTitle(link.target);
      return media == null ? null : ('media', media.id);
    }

    final table = await db.tableDao.fetchByName(link.target);
    if (table == null) return null;

    if (link.entry != null) {
      final entry = await db.entryDao.fetchByContent(table.id, link.entry!);
      if (entry != null) return ('entry', entry.id);
      // Eintrag (noch) nicht vorhanden → wenigstens auf die Tabelle zeigen.
    }
    return ('table', table.id);
  }
}
