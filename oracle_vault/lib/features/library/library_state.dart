// Datei: lib/features/library/library_state.dart
//
// ZWECK: Modelle für den Library-Zustand (Filter, UI-Panels, Selektion).
//        Kein Drift-Abhängigkeit — reine Dart-Klassen.
// PHASE: 1

/// Aktiver Filter in der Library-Liste.
class LibraryFilter {
  final String? categoryId;
  final String? tagId;
  final String? sourceId;     // Quellen-Filter
  final String? oracleType;   // 'uniform' | 'weighted' | 'dice' | 'deck'
  final String? language;     // ISO 639-1
  final String? collectionId; // Collection-Filter (Supplement/Deck)
  final String searchQuery;   // FTS5-Suchbegriff

  const LibraryFilter({
    this.categoryId,
    this.tagId,
    this.sourceId,
    this.oracleType,
    this.language,
    this.collectionId,
    this.searchQuery = '',
  });

  bool get isActive =>
      categoryId != null ||
      tagId != null ||
      sourceId != null ||
      oracleType != null ||
      language != null ||
      collectionId != null ||
      searchQuery.isNotEmpty;

  LibraryFilter copyWith({
    Object? categoryId = _sentinel,
    Object? tagId = _sentinel,
    Object? sourceId = _sentinel,
    Object? oracleType = _sentinel,
    Object? language = _sentinel,
    Object? collectionId = _sentinel,
    String? searchQuery,
  }) =>
      LibraryFilter(
        categoryId: categoryId == _sentinel
            ? this.categoryId
            : categoryId as String?,
        tagId: tagId == _sentinel ? this.tagId : tagId as String?,
        sourceId:
            sourceId == _sentinel ? this.sourceId : sourceId as String?,
        oracleType: oracleType == _sentinel
            ? this.oracleType
            : oracleType as String?,
        language:
            language == _sentinel ? this.language : language as String?,
        collectionId: collectionId == _sentinel
            ? this.collectionId
            : collectionId as String?,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  LibraryFilter cleared() => const LibraryFilter();
}

// Sentinel-Objekt für copyWith (unterscheidet null von "nicht angegeben").
const _sentinel = Object();

/// Sichtbarkeit der drei Library-Panels.
class PanelVisibility {
  final bool sidebar;
  final bool detail;

  const PanelVisibility({this.sidebar = true, this.detail = true});

  PanelVisibility copyWith({bool? sidebar, bool? detail}) => PanelVisibility(
        sidebar: sidebar ?? this.sidebar,
        detail: detail ?? this.detail,
      );
}

/// Sidebar-Sektion, die gerade aktiv ist.
enum SidebarSection { categories, tags, sources, smartFilters }

/// Ergebnis eines Test-Wurfs im Detail-Panel.
class TestRollResult {
  final String content;
  final String? bodyMd;
  final List<String> path; // Tabellen-Namen der Subtable-Kette
  final Map<String, dynamic> modifiers;

  const TestRollResult({
    required this.content,
    this.bodyMd,
    this.path = const [],
    this.modifiers = const {},
  });
}
