// Datei: lib/features/library/widgets/library_sidebar.dart
//
// ZWECK: Linkes Panel nach wireframe_01_library.
//        Flache Sektion-Struktur (keine Tab-Icons oben):
//          Kategorien  – mit Icon + Count
//          Quellen     – flat list
//          Sammlung    – SmartFilter + Inbox (mit Badge)
// PHASE: 1 – redesigned nach Mockup.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../data/db/vault_database.dart';
import '../library_providers.dart';

class LibrarySidebar extends ConsumerWidget {
  const LibrarySidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgSec = AppTheme.bgSecondary(context);

    return Container(
      color: bgSec,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.sp8),
        children: const [
          _CategoriesSection(),
          _SupplementsSection(),
          _SourcesSection(),
          _CollectionSection(),
        ],
      ),
    );
  }
}

// ── Sektion-Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 4),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 10,
            color: AppTheme.textTertiary(context),
            fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ── Nav-Item ──────────────────────────────────────────────────────────────────

class _NavItem extends ConsumerWidget {
  final IconData? icon;
  final String label;
  final int? count;
  final bool selected;
  final bool countIsAccent; // Inbox-Badge: teal statt grau
  final VoidCallback onTap;

  const _NavItem({
    this.icon,
    required this.label,
    this.count,
    required this.selected,
    this.countIsAccent = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final accentBg = AppTheme.accentBg(context);
    final accentText = AppTheme.accentText(context);
    final tertiary = AppTheme.textTertiary(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 5),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? accentBg : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: AppTheme.sp8),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? accentText : cs.onSurface,
                  fontWeight:
                      selected ? FontWeight.w500 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: AppTheme.sp4),
              countIsAccent
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: accentBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                            fontSize: 10, color: accentText),
                      ),
                    )
                  : Text(
                      '$count',
                      style: TextStyle(fontSize: 11, color: tertiary),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Kategorien-Sektion ────────────────────────────────────────────────────────

class _CategoriesSection extends ConsumerWidget {
  const _CategoriesSection();

  // Icon je Kategorie-Name (heuristisch — Phase 1).
  static IconData _guessIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('bestiarium') || n.contains('monster')) {
      return Icons.pest_control;
    }
    if (n.contains('nsc') || n.contains('npc') || n.contains('person')) {
      return Icons.person_outline;
    }
    if (n.contains('dungeon') || n.contains('location')) {
      return Icons.location_city_outlined;
    }
    if (n.contains('wetter') || n.contains('weather')) {
      return Icons.cloud_outlined;
    }
    if (n.contains('item') || n.contains('schatz')) {
      return Icons.inventory_2_outlined;
    }
    if (n.contains('battlemap') || n.contains('map')) {
      return Icons.map_outlined;
    }
    if (n.contains('ambient') || n.contains('sound')) {
      return Icons.music_note_outlined;
    }
    return Icons.folder_outlined;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final filter = ref.watch(libraryFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Kategorien'),
        _NavItem(
          icon: Icons.table_rows_outlined,
          label: 'Alle Tabellen',
          selected: filter.categoryId == null && !filter.isActive,
          onTap: () => ref
              .read(libraryFilterProvider.notifier)
              .state = filter.cleared(),
        ),
        categoriesAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (cats) => Column(
            children: cats
                .where((c) => c.parentId == null)
                .map((cat) => _NavItem(
                      icon: _guessIcon(cat.name),
                      label: cat.name,
                      selected: filter.categoryId == cat.id,
                      onTap: () => ref
                          .read(libraryFilterProvider.notifier)
                          .state = filter.copyWith(categoryId: cat.id),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ── Supplements / Collections ─────────────────────────────────────────────────

class _SupplementsSection extends ConsumerWidget {
  const _SupplementsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(allCollectionsProvider);
    final filter = ref.watch(libraryFilterProvider);

    return collectionsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (collections) {
        if (collections.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader('Supplements'),
            ...collections.map((c) => _NavItem(
                  icon: _collectionIcon(c),
                  label: c.name,
                  selected: filter.collectionId == c.id,
                  onTap: () {
                    final notifier = ref.read(libraryFilterProvider.notifier);
                    if (filter.collectionId == c.id) {
                      notifier.state = filter.copyWith(collectionId: null);
                    } else {
                      notifier.state = filter.copyWith(collectionId: c.id);
                    }
                  },
                )),
          ],
        );
      },
    );
  }

  IconData _collectionIcon(Collection c) => switch (c.type) {
        'deck' => Icons.style_outlined,
        'supplement' => Icons.menu_book_outlined,
        _ => Icons.folder_special_outlined,
      };
}

// ── Quellen-Sektion ───────────────────────────────────────────────────────────

class _SourcesSection extends ConsumerWidget {
  const _SourcesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sourcesAsync = ref.watch(allSourcesProvider);
    final filter = ref.watch(libraryFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Quellen'),
        sourcesAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (sources) {
            if (sources.isEmpty) return const SizedBox.shrink();
            return Column(
              children: sources.take(8).map((s) {
                final isSelected = filter.sourceId == s.id;
                return _NavItem(
                  label: s.title ?? s.type,
                  selected: isSelected,
                  onTap: () {
                    ref.read(libraryFilterProvider.notifier).state =
                        isSelected
                            ? filter.copyWith(sourceId: null)
                            : filter.copyWith(sourceId: s.id);
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ── Sammlung-Sektion (SmartFilter + Inbox) ────────────────────────────────────

class _CollectionSection extends ConsumerWidget {
  const _CollectionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader('Sammlung'),
        _NavItem(
          icon: Icons.bookmark_outline,
          label: 'Smart Filter',
          count: 0,
          selected: false,
          onTap: () {},
        ),
        // Inbox: Inbox-Badge in Teal wenn > 0 (Phase 6).
        _NavItem(
          icon: Icons.inbox_outlined,
          label: 'Inbox',
          count: 0,
          countIsAccent: true,
          selected: false,
          onTap: () {},
        ),
      ],
    );
  }
}
