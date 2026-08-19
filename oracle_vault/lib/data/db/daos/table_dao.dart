// Datei: lib/data/db/daos/table_dao.dart
//
// ZWECK: Datenbankzugriff für Oracle-Tabellen.
//        Reaktive Streams via .watch() für Riverpod-StreamProvider.
// ABHÄNGIGKEITEN: drift, vault_database.dart
// PHASE: 1

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../vault_database.dart';
import '../tables/oracle_tables.dart';
import '../tables/tags.dart';
import '../tables/entries.dart';
import '../tables/edges.dart';
import '../tables/collections.dart';

part 'table_dao.g.dart';

@DriftAccessor(
    tables: [OracleTables, Entries, Tags, TableTags, Edges, CollectionTables])
class TableDao extends DatabaseAccessor<VaultDatabase> with _$TableDaoMixin {
  TableDao(super.db);

  // ── Lesen ─────────────────────────────────────────────────────────────────

  /// Alle Tabellen, neueste zuerst.
  Stream<List<OracleTable>> watchAll() =>
      (select(oracleTables)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();

  /// Alle Tabellen einmalig (für Exports, Command-Palette).
  Future<List<OracleTable>> fetchAll() =>
      (select(oracleTables)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .get();

  /// Eine Tabelle per ID.
  Future<OracleTable?> fetchById(String id) =>
      (select(oracleTables)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<OracleTable?> watchById(String id) =>
      (select(oracleTables)..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// Erste Tabelle mit passendem Namen (case-insensitiv) — für Wiki-Link-
  /// Auflösung. Null wenn keine existiert.
  Future<OracleTable?> fetchByName(String name) =>
      (select(oracleTables)
            ..where((t) => t.name.lower().equals(name.toLowerCase().trim()))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  /// Tabellen einer Kategorie.
  Stream<List<OracleTable>> watchByCategory(String categoryId) =>
      (select(oracleTables)
            ..where((t) => t.categoryId.equals(categoryId))
            ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
          .watch();

  /// Tags einer Tabelle.
  Future<List<Tag>> fetchTagsFor(String tableId) async {
    final query = select(tags).join([
      innerJoin(tableTags, tableTags.tagId.equalsExp(tags.id)),
    ])
      ..where(tableTags.tableId.equals(tableId));
    return query.map((row) => row.readTable(tags)).get();
  }

  Stream<List<Tag>> watchTagsFor(String tableId) {
    final query = select(tags).join([
      innerJoin(tableTags, tableTags.tagId.equalsExp(tags.id)),
    ])
      ..where(tableTags.tableId.equals(tableId));
    return query.map((row) => row.readTable(tags)).watch();
  }

  /// Volltextsuche: gibt Tabellen-IDs zurück, die zu [query] passen.
  ///
  /// Zwei Quellen werden vereinigt:
  ///   1. FTS5 über content/body_md aller Einträge (Präfix-Suche)
  ///   2. LIKE über Name und Beschreibung der Tabelle selbst
  ///
  /// Punkt 2 ist nötig, weil der Tabellenname nicht im FTS-Index liegen kann:
  /// entries_fts ist eine external-content-Tabelle über `entries`, und dort
  /// gibt es keine Namensspalte (siehe VaultDatabase._createFts5AndTriggers).
  ///
  /// Leerer Query → leere Liste.
  Future<List<String>> searchTableIds(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final ids = <String>{};

    // ── 1. Einträge via FTS5 ────────────────────────────────────────────────
    final match = ftsPrefixQuery(trimmed);
    if (match != null) {
      // Kein ORDER BY rank: die Reihenfolge geht ohnehin verloren, weil der
      // Aufrufer (tableListProvider) nach updatedAt sortiert — und DISTINCT
      // verträgt sich nicht mit einem ORDER BY auf einer nicht selektierten
      // Spalte.
      // entries_fts NICHT aliasen: der MATCH-Operator verlangt links den
      // echten Tabellennamen, ein Alias ergibt "no such column".
      final rows = await db.customSelect(
        'SELECT DISTINCT e.table_id AS table_id '
        'FROM entries_fts JOIN entries e ON e.rowid = entries_fts.rowid '
        'WHERE entries_fts MATCH ?',
        variables: [Variable.withString(match)],
        readsFrom: {entries},
      ).get();
      ids.addAll(rows.map((r) => r.read<String>('table_id')));
    }

    // ── 2. Tabellenname / Beschreibung via LIKE ─────────────────────────────
    final rows = await db.customSelect(
      "SELECT id FROM oracle_tables "
      "WHERE name LIKE ?1 ESCAPE '\\' "
      "   OR IFNULL(description, '') LIKE ?1 ESCAPE '\\'",
      variables: [Variable.withString('%${_escapeLike(trimmed)}%')],
      readsFrom: {oracleTables},
    ).get();
    ids.addAll(rows.map((r) => r.read<String>('id')));

    return ids.toList();
  }

  /// Baut aus roher Nutzer-Eingabe einen gültigen FTS5-Präfix-Ausdruck.
  ///
  /// Der Begriff wird als Phrase gequotet. Ohne das interpretiert FTS5
  /// Interpunktion und Schlüsselwörter als Syntax — `Rock (Hard)` ergibt
  /// „syntax error", `a-b` ergibt „no such column: b", `foo:bar` ergibt
  /// „no such column: foo".
  ///
  /// Gibt null zurück, wenn der Begriff kein einziges Token enthält (z. B. nur
  /// Klammern) — eine leere Phrase wäre wieder ein Syntaxfehler.
  @visibleForTesting
  static String? ftsPrefixQuery(String raw) {
    // Anführungszeichen beenden die Phrase vorzeitig → durch Leerzeichen
    // ersetzen statt zu verdoppeln (Nutzer meinen selten eine echte Phrase).
    final cleaned = raw.replaceAll('"', ' ').trim();
    if (cleaned.isEmpty) return null;
    if (!RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(cleaned)) return null;
    return '"$cleaned"*';
  }

  /// Maskiert LIKE-Platzhalter, damit % und _ aus der Eingabe wörtlich suchen.
  static String _escapeLike(String raw) => raw
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');

  // ── Schreiben ──────────────────────────────────────────────────────────────

  Future<void> insertTable(OracleTablesCompanion table) =>
      into(oracleTables).insert(table);

  // replace() würde DELETE+INSERT machen und alle Felder benötigen.
  // write() aktualisiert nur Felder mit Value(...), überspringt Value.absent().
  Future<int> updateTable(OracleTablesCompanion table) =>
      (update(oracleTables)..where((t) => t.id.equals(table.id.value)))
          .write(table);

  /// Löscht eine Tabelle samt allem, was an ihr hängt.
  ///
  /// Einträge, Tag- und Collection-Zuordnungen räumt SQLite selbst per
  /// ON DELETE CASCADE weg (siehe Schema, ab schemaVersion 2). Was NICHT
  /// kaskadieren kann, sind die Edges: die Verknüpfungstabelle ist bewusst
  /// generisch (from_type/from_id statt echter Fremdschlüssel) und würde sonst
  /// verwaiste Zeilen behalten. Deshalb werden sie hier explizit entfernt.
  Future<void> deleteTable(String id) => transaction(() async {
        await _purgeRelations(id);
        await (delete(oracleTables)..where((t) => t.id.equals(id))).go();
      });

  Future<void> bulkDelete(List<String> ids) => transaction(() async {
        for (final id in ids) {
          await _purgeRelations(id);
          await (delete(oracleTables)..where((t) => t.id.equals(id))).go();
        }
      });

  /// Entfernt alle Edges, die auf [tableId] oder einen ihrer Einträge zeigen —
  /// in beide Richtungen. Muss VOR dem Löschen laufen, weil die Eintrags-IDs
  /// danach nicht mehr ermittelbar sind.
  Future<void> _purgeRelations(String tableId) async {
    final rows = await (selectOnly(entries)
          ..addColumns([entries.id])
          ..where(entries.tableId.equals(tableId)))
        .get();
    final entryIds = rows.map((r) => r.read(entries.id)!).toList();

    await (delete(edges)
          ..where((e) =>
              (e.fromType.equals('table') & e.fromId.equals(tableId)) |
              (e.toType.equals('table') & e.toId.equals(tableId)) |
              (e.fromType.equals('entry') & e.fromId.isIn(entryIds)) |
              (e.toType.equals('entry') & e.toId.isIn(entryIds))))
        .go();
  }

  Future<void> bulkUpdateLanguage(List<String> ids, String language) =>
      transaction(() async {
        final now = DateTime.now();
        for (final id in ids) {
          await (update(oracleTables)..where((t) => t.id.equals(id))).write(
            OracleTablesCompanion(
              language: Value(language),
              updatedAt: Value(now),
            ),
          );
        }
      });

  Future<void> bulkUpdateCategory(
          List<String> ids, String? categoryId) =>
      transaction(() async {
        final now = DateTime.now();
        for (final id in ids) {
          await (update(oracleTables)..where((t) => t.id.equals(id))).write(
            OracleTablesCompanion(
              categoryId: Value(categoryId),
              updatedAt: Value(now),
            ),
          );
        }
      });

  // ── Tags einer Tabelle setzen (ersetzt vollständig) ────────────────────────

  Future<void> setTagsFor(String tableId, List<String> tagIds) async {
    await transaction(() async {
      await (delete(tableTags)
            ..where((tt) => tt.tableId.equals(tableId)))
          .go();
      for (final tagId in tagIds) {
        await into(tableTags).insertOnConflictUpdate(
            TableTagsCompanion.insert(tableId: tableId, tagId: tagId));
      }
    });
  }
}
