// Datei: lib/data/db/daos/edge_dao.dart
//
// ZWECK: Zugriff auf die generische Verknüpfungstabelle (Edges).
//        Aktuell primär für translation_of-Relationen zwischen Tabellen genutzt.
//        Phase 5 ergänzt: wikilink, subtable, embed.
// PHASE: 3 (Übersetzungen); voll aktiv ab Phase 5

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../vault_database.dart';
import '../tables/edges.dart';
import '../tables/oracle_tables.dart';

part 'edge_dao.g.dart';

const _uuid = Uuid();

@DriftAccessor(tables: [Edges, OracleTables])
class EdgeDao extends DatabaseAccessor<VaultDatabase> with _$EdgeDaoMixin {
  EdgeDao(super.db);

  // ── Schreiben ──────────────────────────────────────────────────────────────

  Future<void> linkTranslation({
    required String sourceTableId,
    required String translationTableId,
  }) async {
    await into(edges).insertOnConflictUpdate(EdgesCompanion.insert(
      id: _uuid.v4(),
      fromType: 'table',
      fromId: translationTableId,
      toType: 'table',
      toId: sourceTableId,
      relation: 'translation_of',
    ));
  }

  Future<void> deleteEdge(String id) =>
      (delete(edges)..where((e) => e.id.equals(id))).go();

  /// Ersetzt alle Wiki-Link-Edges ('wikilink' + 'embed') die von
  /// [fromType]/[fromId] ausgehen durch [newEdges] — der Save-Hook ruft das
  /// nach jedem Speichern auf, damit die Edges den aktuellen Text spiegeln.
  /// Läuft in einer Transaktion (kein Zwischenzustand sichtbar).
  Future<void> replaceWikiLinkEdges({
    required String fromType,
    required String fromId,
    required List<EdgesCompanion> newEdges,
  }) async {
    await transaction(() async {
      await (delete(edges)
            ..where((e) =>
                e.fromType.equals(fromType) &
                e.fromId.equals(fromId) &
                e.relation.isIn(const ['wikilink', 'embed'])))
          .go();
      for (final edge in newEdges) {
        await into(edges).insert(edge);
      }
    });
  }

  /// Baut eine Wikilink-/Embed-Edge (ohne sie zu speichern).
  static EdgesCompanion buildLinkEdge({
    required String fromType,
    required String fromId,
    required String toType,
    required String toId,
    required bool isEmbed,
    String? metadataJson,
  }) =>
      EdgesCompanion.insert(
        id: _uuid.v4(),
        fromType: fromType,
        fromId: fromId,
        toType: toType,
        toId: toId,
        relation: isEmbed ? 'embed' : 'wikilink',
        metadataJson: Value(metadataJson),
      );

  // ── Lesen ──────────────────────────────────────────────────────────────────

  /// Alle Wiki-Link-/Embed-Edges, die auf [toType]/[toId] zeigen — Backlinks.
  /// Eine einzige Query über die Edges-Tabelle (siehe edges.dart-Konzept).
  Stream<List<Edge>> watchBacklinksTo(String toType, String toId) =>
      (select(edges)
            ..where((e) =>
                e.toType.equals(toType) &
                e.toId.equals(toId) &
                e.relation.isIn(const ['wikilink', 'embed'])))
          .watch();

  /// Alle ausgehenden Wiki-Link-/Embed-Edges von [fromType]/[fromId].
  Future<List<Edge>> fetchOutgoingLinks(String fromType, String fromId) =>
      (select(edges)
            ..where((e) =>
                e.fromType.equals(fromType) &
                e.fromId.equals(fromId) &
                e.relation.isIn(const ['wikilink', 'embed'])))
          .get();

  /// Alle Übersetzungs-Tabellen für [sourceTableId]:
  /// Gibt OracleTable-Objekte zurück (language, name etc. schon bekannt).
  Future<List<OracleTable>> translationsOf(String sourceTableId) async {
    final query = select(oracleTables).join([
      innerJoin(
        edges,
        edges.fromId.equalsExp(oracleTables.id) &
            edges.toId.equals(sourceTableId) &
            edges.relation.equals('translation_of'),
      ),
    ]);
    return query.map((row) => row.readTable(oracleTables)).get();
  }

  /// Gibt die Quell-Tabelle zurück, von der [translationTableId] eine Übersetzung ist.
  /// Null wenn die Tabelle keine Übersetzung ist (sie IST das Original).
  Future<OracleTable?> originalOf(String translationTableId) async {
    final edgeQuery = select(edges)
      ..where((e) =>
          e.fromId.equals(translationTableId) &
          e.relation.equals('translation_of'));
    final edge = await edgeQuery.getSingleOrNull();
    if (edge == null) return null;

    return (select(oracleTables)
          ..where((t) => t.id.equals(edge.toId)))
        .getSingleOrNull();
  }

  /// True wenn [tableId] eine Übersetzung einer anderen Tabelle ist.
  Future<bool> isTranslation(String tableId) async {
    final count = await (select(edges)
          ..where((e) =>
              e.fromId.equals(tableId) &
              e.relation.equals('translation_of')))
        .get();
    return count.isNotEmpty;
  }

  /// Alle IDs von Tabellen, die Übersetzungen sind (d.h. die fromId-Seite einer
  /// translation_of-Edge). Für das Ausblenden aus der Library-Liste.
  Future<Set<String>> fetchAllTranslationTableIds() async {
    final result = await (select(edges)
          ..where((e) => e.relation.equals('translation_of')))
        .get();
    return result.map((e) => e.fromId).toSet();
  }

  /// Beobachtet alle Sprachvarianten einer Tabelle (Original + Übersetzungen).
  /// Reagiert auf Änderungen in der Edges-Tabelle (z. B. nach dem Speichern
  /// einer neuen Übersetzung). Gibt immer das Original als erstes Element zurück.
  Stream<List<OracleTable>> watchVariantsFor(String tableId) {
    // Beobachtet alle Edges die diese Tabelle als Original oder Übersetzung haben.
    final relatedEdgesQuery = select(edges)
      ..where((e) =>
          (e.fromId.equals(tableId) | e.toId.equals(tableId)) &
          e.relation.equals('translation_of'));

    return relatedEdgesQuery.watch().asyncMap((relatedEdges) async {
      if (relatedEdges.isEmpty) return <OracleTable>[];

      // Ist tableId eine Übersetzung? → Quell-ID bestimmen.
      final asTranslation =
          relatedEdges.where((e) => e.fromId == tableId).firstOrNull;
      final sourceId = asTranslation?.toId ?? tableId;

      // Alle Übersetzungs-Edges des Originals laden.
      final translationEdges = await (select(edges)
            ..where((e) =>
                e.toId.equals(sourceId) &
                e.relation.equals('translation_of')))
          .get();

      if (translationEdges.isEmpty) return <OracleTable>[];

      // Alle beteiligten Tabellen in einem Query laden.
      final allIds = {sourceId, ...translationEdges.map((e) => e.fromId)};
      if (allIds.length < 2) return <OracleTable>[];

      final tables = await (select(oracleTables)
            ..where((t) => t.id.isIn(allIds.toList())))
          .get();

      final source = tables.where((t) => t.id == sourceId).firstOrNull;
      if (source == null) return <OracleTable>[];

      final translations = tables.where((t) => t.id != sourceId).toList();
      return [source, ...translations];
    });
  }
}
