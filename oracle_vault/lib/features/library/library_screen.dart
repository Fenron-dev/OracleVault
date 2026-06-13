// Datei: lib/features/library/library_screen.dart
//
// ZWECK: Haupt-Library — 3-Panel-Desktop-Layout nach wireframe_01_library.
//        Aufbau: eigene Topbar (kein AppBar) + Chips-Leiste + Panels.
//        Topbar: Vault-Name, globale Suche (⌘K), Filter-Button, Import-Button.
//        Panels: Sidebar (200px) | Liste (flex) | Detail (280px).
// PHASE: 1

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/di.dart';
import '../../core/theme.dart';
import '../command_palette/command_palette.dart';
import 'library_providers.dart';
import 'library_state.dart';
import 'widgets/library_sidebar.dart';
import 'widgets/table_list_panel.dart';
import 'widgets/table_detail_panel.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vault = ref.watch(activeVaultProvider);
    final vaultName =
        vault?.vaultPath.split(RegExp(r'[/\\]')).last ?? 'Vault';
    final panels = ref.watch(panelVisibilityProvider);
    final filter = ref.watch(libraryFilterProvider);

    final borderColor = AppTheme.border(context);

    return Scaffold(
      body: Column(
        children: [
          // ── Topbar ──────────────────────────────────────────────────
          _Topbar(
            vaultName: vaultName,
            onPaletteOpen: () => CommandPalette.show(context, ref),
            onSidebarToggle: () => ref
                .read(panelVisibilityProvider.notifier)
                .state = panels.copyWith(sidebar: !panels.sidebar),
            onDetailToggle: () => ref
                .read(panelVisibilityProvider.notifier)
                .state = panels.copyWith(detail: !panels.detail),
            sidebarVisible: panels.sidebar,
            detailVisible: panels.detail,
            onSettings: () => context.push(AppRoutes.settings),
          ),

          Divider(height: 1, color: borderColor),

          // ── Filter-Chip-Leiste (wenn aktiv) ────────────────────────
          if (filter.isActive) ...[
            _FilterChipsBar(filter: filter),
            Divider(height: 1, color: borderColor),
          ],

          // ── 3-Panel-Layout ──────────────────────────────────────────
          Expanded(
            child: Row(
              children: [
                if (panels.sidebar) ...[
                  SizedBox(
                    width: AppTheme.sidebarWidth,
                    child: const LibrarySidebar(),
                  ),
                  VerticalDivider(width: 1, color: borderColor),
                ],
                const Expanded(child: TableListPanel()),
                if (panels.detail) ...[
                  VerticalDivider(width: 1, color: borderColor),
                  SizedBox(
                    width: AppTheme.detailWidth,
                    child: const TableDetailPanel(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Topbar ────────────────────────────────────────────────────────────────────

class _Topbar extends StatelessWidget {
  final String vaultName;
  final VoidCallback onPaletteOpen;
  final VoidCallback onSidebarToggle;
  final VoidCallback onDetailToggle;
  final bool sidebarVisible;
  final bool detailVisible;
  final VoidCallback onSettings;

  const _Topbar({
    required this.vaultName,
    required this.onPaletteOpen,
    required this.onSidebarToggle,
    required this.onDetailToggle,
    required this.sidebarVisible,
    required this.detailVisible,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgSec = AppTheme.bgSecondary(context);

    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp16),
        child: Row(
          children: [
            // Vault-Name
            Icon(Icons.auto_stories_outlined,
                size: 15, color: cs.onSurfaceVariant),
            const SizedBox(width: AppTheme.sp8),
            Text(
              vaultName,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),

            // Suche (zeigt ⌘K hint, öffnet Palette)
            const SizedBox(width: AppTheme.sp16),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: GestureDetector(
                  onTap: onPaletteOpen,
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.sp12),
                    decoration: BoxDecoration(
                      color: bgSec,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppTheme.border(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            size: 14,
                            color: cs.onSurfaceVariant),
                        const SizedBox(width: AppTheme.sp8),
                        Expanded(
                          child: Text(
                            'Tabellen, Einträge, Tags durchsuchen…',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppTheme.border(context)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '⌘K',
                            style: TextStyle(
                                fontSize: 10,
                                color: cs.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Aktions-Buttons
            _TopbarBtn(
              icon: Icons.filter_alt_outlined,
              label: 'Filter',
              onTap: () {},
            ),
            const SizedBox(width: AppTheme.sp4),
            _TopbarBtn(
              icon: Icons.file_upload_outlined,
              label: 'Import',
              onTap: () => context.push(AppRoutes.importScreen),
            ),
            const SizedBox(width: AppTheme.sp8),
            // Panel-Toggles
            _IconBtn(
              icon: sidebarVisible
                  ? Icons.view_sidebar
                  : Icons.view_sidebar_outlined,
              tooltip: sidebarVisible
                  ? 'Sidebar ausblenden'
                  : 'Sidebar einblenden',
              onTap: onSidebarToggle,
            ),
            _IconBtn(
              icon: detailVisible
                  ? Icons.table_chart
                  : Icons.table_chart_outlined,
              tooltip: detailVisible
                  ? 'Detail ausblenden'
                  : 'Detail einblenden',
              onTap: onDetailToggle,
            ),
            _IconBtn(
              icon: Icons.settings_outlined,
              tooltip: 'Einstellungen',
              onTap: onSettings,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopbarBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TopbarBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.sp12, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border(context)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: cs.onSurface),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(fontSize: 12, color: cs.onSurface)),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _IconBtn(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

// ── Filter-Chip-Leiste ────────────────────────────────────────────────────────

class _FilterChipsBar extends ConsumerWidget {
  final LibraryFilter filter;
  const _FilterChipsBar({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.sp16, vertical: 6),
        children: [
          if (filter.categoryId != null)
            _ActiveChip(
              label: 'Kategorie',
              onDelete: () => ref
                  .read(libraryFilterProvider.notifier)
                  .state = filter.copyWith(categoryId: null),
            ),
          if (filter.tagId != null)
            _ActiveChip(
              label: 'Tag',
              onDelete: () => ref
                  .read(libraryFilterProvider.notifier)
                  .state = filter.copyWith(tagId: null),
            ),
          if (filter.oracleType != null)
            _ActiveChip(
              label: _typeLabel(filter.oracleType!),
              onDelete: () => ref
                  .read(libraryFilterProvider.notifier)
                  .state = filter.copyWith(oracleType: null),
            ),
          if (filter.language != null)
            _ActiveChip(
              label: filter.language!.toUpperCase(),
              onDelete: () => ref
                  .read(libraryFilterProvider.notifier)
                  .state = filter.copyWith(language: null),
            ),
          const SizedBox(width: AppTheme.sp8),
          GestureDetector(
            onTap: () => ref
                .read(libraryFilterProvider.notifier)
                .state = filter.cleared(),
            child: Text(
              'Alle löschen',
              style: TextStyle(
                  fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  String _typeLabel(String type) => switch (type) {
        'uniform' => 'Gleichverteilt',
        'weighted' => 'Gewichtet',
        'dice' => 'Würfel',
        'deck' => 'Deck',
        _ => type,
      };
}

class _ActiveChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;
  const _ActiveChip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final accentBg = AppTheme.accentBg(context);
    final accentText = AppTheme.accentText(context);

    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.sp8),
      child: GestureDetector(
        onTap: onDelete,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.sp12, vertical: 3),
          decoration: BoxDecoration(
            color: accentBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: accentText)),
              const SizedBox(width: 4),
              Icon(Icons.close, size: 11, color: accentText),
            ],
          ),
        ),
      ),
    );
  }
}
