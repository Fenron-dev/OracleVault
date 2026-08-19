// Datei: lib/features/library/library_providers.dart
//
// ZWECK: Riverpod-Provider für die Library-Ansicht.
//        Trennt Datenbankzugriff von UI-Zustand.
//
// PROVIDER-ÜBERSICHT:
//   vaultDbProvider        – aktuelle VaultDatabase (null wenn kein Vault offen)
//   tableDaoProvider       – TableDao aus aktiver DB
//   entryDaoProvider       – EntryDao aus aktiver DB
//   tagDaoProvider         – TagDao aus aktiver DB
//   categoryDaoProvider    – CategoryDao aus aktiver DB
//   sourceDaoProvider      – SourceDao aus aktiver DB
//   libraryFilterProvider  – StateProvider für aktiven Filter
//   selectedTableIdProvider– StateProvider für ausgewählte Tabelle
//   panelVisibilityProvider– StateProvider für Panel-Sichtbarkeit
//   sidebarSectionProvider – StateProvider für aktive Sidebar-Sektion
//   tableListProvider      – StreamProvider: gefilterte + sortierte Tabellen-Liste
//   allTagsProvider        – StreamProvider: alle Tags
//   allCategoriesProvider  – StreamProvider: alle Kategorien
//   allSourcesProvider     – StreamProvider: alle Sources
//   selectedTableProvider  – StreamProvider: ausgewählte Tabelle + Einträge
//   entriesForTableProvider– StreamProvider: Einträge der ausgewählten Tabelle
//   tagsForTableProvider   – StreamProvider: Tags der ausgewählten Tabelle
// ABHÄNGIGKEITEN: flutter_riverpod, vault_database.dart, daos, library_state.dart
// PHASE: 1

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di.dart';
import '../../data/db/vault_database.dart';
import '../../data/db/daos/table_dao.dart';
import '../../data/db/daos/entry_dao.dart';
import '../../data/db/daos/tag_dao.dart';
import '../../data/db/daos/category_dao.dart';
import '../../data/db/daos/source_dao.dart';
import 'library_state.dart';

// ── Datenbank-Zugriff ─────────────────────────────────────────────────────────

/// Aktuelle VaultDatabase (null wenn kein Vault offen).
final vaultDbProvider = Provider<VaultDatabase?>((ref) {
  return ref.watch(activeVaultProvider)?.database;
});

final tableDaoProvider = Provider<TableDao?>((ref) {
  final db = ref.watch(vaultDbProvider);
  return db?.tableDao;
});

final entryDaoProvider = Provider<EntryDao?>((ref) {
  final db = ref.watch(vaultDbProvider);
  return db?.entryDao;
});

final tagDaoProvider = Provider<TagDao?>((ref) {
  final db = ref.watch(vaultDbProvider);
  return db?.tagDao;
});

final categoryDaoProvider = Provider<CategoryDao?>((ref) {
  final db = ref.watch(vaultDbProvider);
  return db?.categoryDao;
});

final sourceDaoProvider = Provider<SourceDao?>((ref) {
  final db = ref.watch(vaultDbProvider);
  return db?.sourceDao;
});

// ── UI-Zustand ────────────────────────────────────────────────────────────────

/// Aktiver Filter (Kategorie, Tag, Typ, Sprache, Suche).
final libraryFilterProvider =
    StateProvider<LibraryFilter>((ref) => const LibraryFilter());

/// Für Bulk-Edit ausgewählte Tabellen-IDs.
final selectedTableIdsProvider =
    StateProvider<Set<String>>((ref) => const {});

/// ID der aktuell ausgewählten Tabelle. Null = nichts ausgewählt.
final selectedTableIdProvider = StateProvider<String?>((ref) => null);

/// Sichtbarkeit von Sidebar und Detail-Panel.
final panelVisibilityProvider =
    StateProvider<PanelVisibility>((ref) => const PanelVisibility());

/// Aktive Sidebar-Sektion.
final sidebarSectionProvider =
    StateProvider<SidebarSection>((ref) => SidebarSection.categories);

// ── Reaktive Daten-Streams ────────────────────────────────────────────────────

/// Alle Tags.
final allTagsProvider = StreamProvider<List<Tag>>((ref) {
  final dao = ref.watch(tagDaoProvider);
  return dao?.watchAll() ?? const Stream.empty();
});

/// Alle Kategorien.
final allCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final dao = ref.watch(categoryDaoProvider);
  return dao?.watchAll() ?? const Stream.empty();
});

/// Alle Sources.
final allSourcesProvider = StreamProvider<List<Source>>((ref) {
  final dao = ref.watch(sourceDaoProvider);
  return dao?.watchAll() ?? const Stream.empty();
});

/// Collection zu der die aktuell ausgewählte Tabelle gehört (null = keine).
/// Wird nach Mutations via ref.invalidate() aufgefrischt.
final collectionOfSelectedTableProvider = FutureProvider<Collection?>((ref) async {
  final db = ref.watch(vaultDbProvider);
  final selectedId = ref.watch(selectedTableIdProvider);
  if (db == null || selectedId == null) return null;
  return db.collectionDao.collectionOf(selectedId);
});

/// Alle Collections (Supplement-Gruppen).
final allCollectionsProvider = StreamProvider<List<Collection>>((ref) {
  final db = ref.watch(vaultDbProvider);
  return db?.collectionDao.watchAll() ?? const Stream.empty();
});

/// Die aktuell im Filter aktive Collection (null wenn keine gefiltert wird).
final activeCollectionProvider = FutureProvider<Collection?>((ref) async {
  final db = ref.watch(vaultDbProvider);
  final id = ref.watch(libraryFilterProvider).collectionId;
  if (db == null || id == null) return null;
  return db.collectionDao.fetchById(id);
});

/// Einträge mit angehängtem Medium für die aktive Collection — Medien-Grid.
final collectionMediaEntriesProvider = StreamProvider<List<Entry>>((ref) {
  final db = ref.watch(vaultDbProvider);
  final id = ref.watch(libraryFilterProvider).collectionId;
  if (db == null || id == null) return const Stream.empty();
  return db.collectionDao.watchMediaEntriesFor(id);
});

/// Ansichtsmodus des mittleren Panels: Liste oder Medien-Grid.
/// Grid ist nur sinnvoll, wenn eine Collection aktiv ist.
final libraryViewModeProvider =
    StateProvider<LibraryViewMode>((ref) => LibraryViewMode.list);

/// Tabellen-Liste nach aktivem Filter und Suche.
///
/// Filtern und Suchen passiert vollständig in SQL (siehe
/// TableDao.watchFiltered). Vorher lud dieser Provider bei jeder Änderung die
/// gesamte Bibliothek in den Speicher und filterte in Dart — pro Tastendruck
/// im Suchfeld einmal quer durch alle Tabellen.
final tableListProvider = StreamProvider<List<OracleTable>>((ref) {
  final dao = ref.watch(tableDaoProvider);
  if (dao == null) return const Stream.empty();

  final filter = ref.watch(libraryFilterProvider);
  return dao.watchFiltered(
    categoryId: filter.categoryId,
    sourceId: filter.sourceId,
    oracleType: filter.oracleType,
    language: filter.language,
    tagId: filter.tagId,
    collectionId: filter.collectionId,
    searchQuery: filter.searchQuery,
  );
});

/// Einträge der ausgewählten Tabelle.
final entriesForSelectedTableProvider = StreamProvider<List<Entry>>((ref) {
  final dao = ref.watch(entryDaoProvider);
  final selectedId = ref.watch(selectedTableIdProvider);
  if (dao == null || selectedId == null) return const Stream.empty();
  return dao.watchForTable(selectedId);
});

/// Tags der ausgewählten Tabelle.
final tagsForSelectedTableProvider = StreamProvider<List<Tag>>((ref) {
  final dao = ref.watch(tableDaoProvider);
  final selectedId = ref.watch(selectedTableIdProvider);
  if (dao == null || selectedId == null) return const Stream.empty();
  return dao.watchTagsFor(selectedId);
});

/// Die ausgewählte Tabelle selbst (für Header-Daten im Detail-Panel).
final selectedTableProvider = StreamProvider<OracleTable?>((ref) {
  final dao = ref.watch(tableDaoProvider);
  final selectedId = ref.watch(selectedTableIdProvider);
  if (dao == null || selectedId == null) return const Stream.empty();
  return dao.watchById(selectedId);
});

/// Backlinks der ausgewählten Tabelle: alle Wiki-Link-/Embed-Edges, die auf
/// die Tabelle oder einen ihrer Einträge zeigen — aufgelöst zu Quell-Tabelle
/// (+ ggf. Quell-Eintrag). Selbstverweise und verwaiste Edges filtert bereits
/// die Abfrage; pro Quelle erscheint nur ein Backlink.
final backlinksForSelectedTableProvider =
    StreamProvider<List<Backlink>>((ref) {
  final db = ref.watch(vaultDbProvider);
  final selectedId = ref.watch(selectedTableIdProvider);
  if (db == null || selectedId == null) return const Stream.empty();

  return db.edgeDao.watchBacklinkRows(selectedId).map((rows) {
    final seen = <String>{};
    return [
      for (final row in rows)
        if (seen.add(row.fromId))
          Backlink(
            sourceTableId: row.sourceTableId,
            sourceTableName: row.sourceTableName,
            sourceEntryContent: row.entryContent,
            isEmbed: row.isEmbed,
          ),
    ];
  });
});

/// Alle Sprachvarianten der ausgewählten Tabelle (Original + Übersetzungen).
/// Gibt eine geordnete Liste zurück: erstes Element ist immer das Original.
/// Leere Liste = keine Übersetzungen vorhanden → kein Switcher nötig.
/// Wird nach dem Speichern einer Übersetzung via ref.invalidate() aufgefrischt.
final translationVariantsProvider =
    FutureProvider<List<OracleTable>>((ref) async {
  final db = ref.watch(vaultDbProvider);
  final selectedId = ref.watch(selectedTableIdProvider);
  if (db == null || selectedId == null) return [];

  final original = await db.edgeDao.originalOf(selectedId);
  final sourceId = original?.id ?? selectedId;
  final translations = await db.edgeDao.translationsOf(sourceId);

  if (translations.isEmpty) return [];

  final source = original ?? await db.tableDao.fetchById(selectedId);
  if (source == null) return [];

  return [source, ...translations];
});
