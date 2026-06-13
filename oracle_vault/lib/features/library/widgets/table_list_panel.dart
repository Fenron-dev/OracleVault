// Datei: lib/features/library/widgets/table_list_panel.dart
//
// ZWECK: Mittleres Panel nach wireframe_01_library.
//        Zeilen: Typ-Icon/Checkbox | Name + Meta | Indikatoren.
//        Ausgewählte Zeile: Teal Border-Left + Accent-Hintergrund.
//        Bulk-Edit: Hover zeigt Checkbox; Shift-Click für Bereich;
//                   Aktionsleiste für Sprache, Collection, Kategorie, Löschen.
// PHASE: 1

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HardwareKeyboard;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../data/db/vault_database.dart';
import '../library_providers.dart';

const _kLangOptions = {
  'de': 'Deutsch',
  'en': 'Englisch',
  'fr': 'Français',
  'es': 'Español',
  'it': 'Italiano',
  'pt': 'Português',
  'nl': 'Nederlands',
  'pl': 'Polski',
  'ja': '日本語',
};

class TableListPanel extends ConsumerStatefulWidget {
  const TableListPanel({super.key});

  @override
  ConsumerState<TableListPanel> createState() => _TableListPanelState();
}

class _TableListPanelState extends ConsumerState<TableListPanel> {
  final _searchController = TextEditingController();
  int? _anchorIndex;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCheckboxTap(int index, List<OracleTable> tables) {
    final current = ref.read(selectedTableIdsProvider);
    final isShift = HardwareKeyboard.instance.isShiftPressed;

    if (isShift && _anchorIndex != null) {
      final lo = _anchorIndex! < index ? _anchorIndex! : index;
      final hi = _anchorIndex! < index ? index : _anchorIndex!;
      final rangeIds = tables
          .skip(lo)
          .take(hi - lo + 1)
          .map((t) => t.id)
          .toSet();
      ref.read(selectedTableIdsProvider.notifier).state = {
        ...current,
        ...rangeIds,
      };
    } else {
      _anchorIndex = index;
      final next = Set<String>.from(current);
      if (next.contains(tables[index].id)) {
        next.remove(tables[index].id);
      } else {
        next.add(tables[index].id);
      }
      ref.read(selectedTableIdsProvider.notifier).state = next;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tablesAsync = ref.watch(tableListProvider);
    final filter = ref.watch(libraryFilterProvider);
    final selectedIds = ref.watch(selectedTableIdsProvider);
    final borderColor = AppTheme.border(context);
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // ── Such-Toolbar ─────────────────────────────────────────────
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.sp12, vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Suchen …',
                    hintStyle: TextStyle(
                        fontSize: 12, color: cs.onSurfaceVariant),
                    prefixIcon: Icon(Icons.search,
                        size: 14, color: cs.onSurfaceVariant),
                    suffixIcon: filter.searchQuery.isNotEmpty
                        ? InkWell(
                            onTap: () {
                              _searchController.clear();
                              ref
                                  .read(libraryFilterProvider.notifier)
                                  .state =
                                  filter.copyWith(searchQuery: '');
                            },
                            child: Icon(Icons.close,
                                size: 12, color: cs.onSurfaceVariant),
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.sp12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                          color: AppTheme.accentBorder(context)),
                    ),
                    filled: false,
                  ),
                  onChanged: (q) => ref
                      .read(libraryFilterProvider.notifier)
                      .state = filter.copyWith(searchQuery: q),
                ),
              ),
              const SizedBox(width: AppTheme.sp8),
              _SmallBtn(
                label: '+ Neu',
                onTap: () => context.push(AppRoutes.tableNew),
              ),
            ],
          ),
        ),

        Divider(height: 1, color: borderColor),

        // ── Liste ─────────────────────────────────────────────────────
        Expanded(
          child: tablesAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Fehler: $e')),
            data: (tables) {
              if (tables.isEmpty) {
                return _EmptyState(hasFilter: filter.isActive);
              }
              return ListView.builder(
                itemCount: tables.length,
                itemBuilder: (ctx, i) => _TableRow(
                  table: tables[i],
                  onCheckboxTap: () => _onCheckboxTap(i, tables),
                ),
              );
            },
          ),
        ),

        // ── Bulk-Aktionsleiste ────────────────────────────────────────
        if (selectedIds.isNotEmpty)
          _BulkActionBar(selectedIds: selectedIds),
      ],
    );
  }
}

// ── Tabellen-Zeile ────────────────────────────────────────────────────────────

class _TableRow extends ConsumerStatefulWidget {
  final OracleTable table;
  final VoidCallback onCheckboxTap;

  const _TableRow({
    required this.table,
    required this.onCheckboxTap,
  });

  @override
  ConsumerState<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends ConsumerState<_TableRow> {
  // ── Bulk-Selection ─────────────────────────────────────────────────────────

  void _startBulkSelect() {
    final ids = ref.read(selectedTableIdsProvider);
    ref.read(selectedTableIdsProvider.notifier).state = {
      ...ids,
      widget.table.id,
    };
  }

  Future<void> _showContextMenu(Offset globalPos) async {
    final ids = ref.read(selectedTableIdsProvider);
    final isBulkSelected = ids.contains(widget.table.id);
    final tableId = widget.table.id;
    final errorColor = Theme.of(context).colorScheme.error;

    final rect = RelativeRect.fromLTRB(
        globalPos.dx, globalPos.dy, globalPos.dx + 1, globalPos.dy + 1);

    final value = await showMenu<String>(
      context: context,
      position: rect,
      items: [
        PopupMenuItem(
          value: 'select',
          child: _MenuRow(
            icon: isBulkSelected
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            label: isBulkSelected ? 'Auswahl aufheben' : 'Auswählen',
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: _MenuRow(icon: Icons.edit_outlined, label: 'Bearbeiten'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: _MenuRow(
            icon: Icons.delete_outline,
            label: 'Löschen',
            color: errorColor,
          ),
        ),
      ],
    );

    if (!mounted || value == null) return;
    switch (value) {
      case 'select':
        widget.onCheckboxTap();
      case 'edit':
        // ignore: use_build_context_synchronously
        context.push('${AppRoutes.tableEdit}/$tableId');
      case 'delete':
        _confirmDelete();
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tabelle löschen'),
        content: Text('"${widget.table.name}" unwiderruflich löschen?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final db = ref.read(vaultDbProvider);
    if (db == null) return;
    await db.tableDao.deleteTable(widget.table.id);
    if (ref.read(selectedTableIdProvider) == widget.table.id) {
      ref.read(selectedTableIdProvider.notifier).state = null;
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final detailSelected =
        ref.watch(selectedTableIdProvider) == widget.table.id;
    final selectedIds = ref.watch(selectedTableIdsProvider);
    final bulkSelected = selectedIds.contains(widget.table.id);
    final anyBulkSelected = selectedIds.isNotEmpty;

    final accentBg = AppTheme.accentBg(context);
    final accentText = AppTheme.accentText(context);
    final accentBorder = AppTheme.accentBorder(context);
    final borderColor = AppTheme.border(context);
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
        // Rechtsklick → Kontextmenü
        onSecondaryTapUp: (d) => _showContextMenu(d.globalPosition),
        child: InkWell(
          onTap: () {
            if (anyBulkSelected) {
              widget.onCheckboxTap();
            } else {
              ref.read(selectedTableIdProvider.notifier).state =
                  widget.table.id;
            }
          },
          // Long-press → Bulk-Auswahl starten
          onLongPress: _startBulkSelect,
          onDoubleTap: () =>
              context.push('${AppRoutes.tableEdit}/${widget.table.id}'),
          child: Container(
            decoration: BoxDecoration(
              color: detailSelected ? accentBg : null,
              border: Border(
                left: detailSelected
                    ? BorderSide(color: accentBorder, width: 3)
                    : BorderSide.none,
                bottom: BorderSide(color: borderColor, width: 1),
              ),
            ),
            padding: EdgeInsets.fromLTRB(
                detailSelected ? 11 : 14, 10, 14, 10),
            child: Row(
              children: [
                // Icon / Checkbox-Bereich
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onCheckboxTap,
                  child: SizedBox(
                    width: 22,
                    height: 20,
                    child: anyBulkSelected
                        ? Icon(
                            bulkSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            size: 18,
                            color: bulkSelected
                                ? cs.primary
                                : cs.onSurfaceVariant,
                          )
                        : Icon(
                            _typeIcon(widget.table.oracleType),
                            size: 18,
                            color: detailSelected
                                ? accentText
                                : cs.onSurfaceVariant,
                          ),
                  ),
                ),
                const SizedBox(width: AppTheme.sp12),

                // Name + Meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.table.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: detailSelected
                              ? accentText
                              : cs.onSurface,
                          fontWeight: detailSelected
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                      _MetaLine(
                          table: widget.table,
                          selected: detailSelected),
                    ],
                  ),
                ),

                // Seiten-Indikatoren
                if (widget.table.language != 'de')
                  Icon(Icons.translate,
                      size: 14, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
    );
  }

  IconData _typeIcon(String type) => switch (type) {
        'deck' => Icons.style_outlined,
        'dice' => Icons.casino_outlined,
        'weighted' => Icons.balance_outlined,
        _ => Icons.table_rows_outlined,
      };
}

// ── Meta-Zeile ────────────────────────────────────────────────────────────────

class _MetaLine extends StatelessWidget {
  final OracleTable table;
  final bool selected;
  const _MetaLine({required this.table, required this.selected});

  @override
  Widget build(BuildContext context) {
    final tertiary = AppTheme.textTertiary(context);
    final accentText = AppTheme.accentText(context);
    final color =
        selected ? accentText.withAlpha(200) : AppTheme.textTertiary(context);
    final style = TextStyle(fontSize: 11, color: color);
    final dot = TextSpan(
        text: ' · ', style: TextStyle(fontSize: 11, color: tertiary));

    final parts = <InlineSpan>[];
    if (table.genre != null) {
      parts.add(TextSpan(text: table.genre!, style: style));
      parts.add(dot);
    }
    if (table.language.isNotEmpty) {
      parts.add(
          TextSpan(text: table.language.toUpperCase(), style: style));
    }
    if (parts.isEmpty) {
      parts.add(TextSpan(text: _typeLabel(table.oracleType), style: style));
    }

    return Text.rich(TextSpan(children: parts),
        maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  String _typeLabel(String type) => switch (type) {
        'uniform' => 'Gleichverteilt',
        'weighted' => 'Gewichtet',
        'dice' => 'Würfel',
        'deck' => 'Deck',
        _ => type,
      };
}

// ── Bulk-Aktionsleiste ─────────────────────────────────────────────────────────

class _BulkActionBar extends ConsumerWidget {
  final Set<String> selectedIds;
  const _BulkActionBar({required this.selectedIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderColor = AppTheme.border(context);
    final cs = Theme.of(context).colorScheme;
    final tertiary = AppTheme.textTertiary(context);

    void clear() =>
        ref.read(selectedTableIdsProvider.notifier).state = const {};

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Row(
        children: [
          Text('${selectedIds.length} ausgewählt',
              style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: clear,
            child: Icon(Icons.close, size: 14, color: tertiary),
          ),
          const Spacer(),
          _BulkBtn(
            icon: Icons.language,
            label: 'Sprache',
            onTap: () => showDialog(
              context: context,
              builder: (_) =>
                  _BulkLanguageDialog(selectedIds: selectedIds),
            ),
          ),
          const SizedBox(width: 8),
          _BulkBtn(
            icon: Icons.folder_special_outlined,
            label: 'Collection',
            onTap: () => showDialog(
              context: context,
              builder: (_) =>
                  _BulkCollectionDialog(selectedIds: selectedIds),
            ),
          ),
          const SizedBox(width: 8),
          _BulkBtn(
            icon: Icons.folder_outlined,
            label: 'Kategorie',
            onTap: () => showDialog(
              context: context,
              builder: (_) =>
                  _BulkCategoryDialog(selectedIds: selectedIds),
            ),
          ),
          const SizedBox(width: 8),
          _BulkBtn(
            icon: Icons.delete_outline,
            label: 'Löschen',
            isDestructive: true,
            onTap: () => showDialog(
              context: context,
              builder: (_) =>
                  _BulkDeleteDialog(selectedIds: selectedIds),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulkBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _BulkBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isDestructive ? cs.error : cs.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Bulk-Dialoge ───────────────────────────────────────────────────────────────

class _BulkLanguageDialog extends ConsumerWidget {
  final Set<String> selectedIds;
  const _BulkLanguageDialog({required this.selectedIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> setLang(String lang) async {
      final db = ref.read(vaultDbProvider);
      if (db == null) return;
      await db.tableDao.bulkUpdateLanguage(selectedIds.toList(), lang);
      ref.read(selectedTableIdsProvider.notifier).state = const {};
      if (context.mounted) Navigator.pop(context);
    }

    return AlertDialog(
      title: Text('Sprache setzen (${selectedIds.length})'),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SizedBox(
        width: 280,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _kLangOptions.entries
                .map((e) => ListTile(
                      title: Text(e.value,
                          style: const TextStyle(fontSize: 13)),
                      trailing: Text(e.key.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey)),
                      dense: true,
                      onTap: () => setLang(e.key),
                    ))
                .toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen')),
      ],
    );
  }
}

class _BulkCollectionDialog extends ConsumerStatefulWidget {
  final Set<String> selectedIds;
  const _BulkCollectionDialog({required this.selectedIds});

  @override
  ConsumerState<_BulkCollectionDialog> createState() =>
      _BulkCollectionDialogState();
}

class _BulkCollectionDialogState
    extends ConsumerState<_BulkCollectionDialog> {
  bool _creatingNew = false;
  bool _saving = false;
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _assign(String collectionId) async {
    setState(() => _saving = true);
    final db = ref.read(vaultDbProvider);
    if (db == null) return;
    await db.collectionDao
        .bulkAssignToCollection(collectionId, widget.selectedIds.toList());
    ref.read(selectedTableIdsProvider.notifier).state = const {};
    if (mounted) Navigator.pop(context);
  }

  Future<void> _createAndAssign() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    final db = ref.read(vaultDbProvider);
    if (db == null) return;
    final id = await db.collectionDao
        .createCollection(name: name, type: 'supplement');
    await db.collectionDao
        .bulkAssignToCollection(id, widget.selectedIds.toList());
    ref.read(selectedTableIdsProvider.notifier).state = const {};
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(allCollectionsProvider);

    return AlertDialog(
      title: Text('Collection (${widget.selectedIds.length} Tabellen)'),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SizedBox(
        width: 300,
        child: _saving
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            : collectionsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) =>
                    const Text('Fehler beim Laden der Collections'),
                data: (collections) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...collections.map((c) => ListTile(
                          leading: Icon(_icon(c.type), size: 16),
                          title: Text(c.name,
                              style: const TextStyle(fontSize: 13)),
                          dense: true,
                          onTap: _saving ? null : () => _assign(c.id),
                        )),
                    const Divider(height: 8),
                    if (_creatingNew)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameCtrl,
                                autofocus: true,
                                style: const TextStyle(fontSize: 13),
                                decoration: const InputDecoration(
                                  hintText: 'Name der Collection …',
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                ),
                                onSubmitted: (_) => _createAndAssign(),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check, size: 16),
                              onPressed:
                                  _saving ? null : _createAndAssign,
                            ),
                          ],
                        ),
                      )
                    else
                      ListTile(
                        leading: const Icon(Icons.add, size: 16),
                        title: const Text('Neue Collection …',
                            style: TextStyle(fontSize: 13)),
                        dense: true,
                        onTap: () =>
                            setState(() => _creatingNew = true),
                      ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen')),
      ],
    );
  }

  IconData _icon(String type) => switch (type) {
        'deck' => Icons.style_outlined,
        'supplement' => Icons.menu_book_outlined,
        _ => Icons.folder_special_outlined,
      };
}

class _BulkCategoryDialog extends ConsumerWidget {
  final Set<String> selectedIds;
  const _BulkCategoryDialog({required this.selectedIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    Future<void> setCategory(String? categoryId) async {
      final db = ref.read(vaultDbProvider);
      if (db == null) return;
      await db.tableDao
          .bulkUpdateCategory(selectedIds.toList(), categoryId);
      ref.read(selectedTableIdsProvider.notifier).state = const {};
      if (context.mounted) Navigator.pop(context);
    }

    return AlertDialog(
      title: Text('Kategorie (${selectedIds.length} Tabellen)'),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SizedBox(
        width: 280,
        child: categoriesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) =>
              const Text('Fehler beim Laden der Kategorien'),
          data: (categories) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.clear, size: 16),
                title: const Text('Keine Kategorie',
                    style: TextStyle(fontSize: 13)),
                dense: true,
                onTap: () => setCategory(null),
              ),
              if (categories.isNotEmpty) const Divider(height: 4),
              ...categories
                  .where((c) => c.parentId == null)
                  .map((c) => ListTile(
                        leading: const Icon(Icons.folder_outlined,
                            size: 16),
                        title: Text(c.name,
                            style: const TextStyle(fontSize: 13)),
                        dense: true,
                        onTap: () => setCategory(c.id),
                      )),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen')),
      ],
    );
  }
}

class _BulkDeleteDialog extends ConsumerWidget {
  final Set<String> selectedIds;
  const _BulkDeleteDialog({required this.selectedIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> delete() async {
      final db = ref.read(vaultDbProvider);
      if (db == null) return;
      await db.tableDao.bulkDelete(selectedIds.toList());
      ref.read(selectedTableIdsProvider.notifier).state = const {};
      ref.read(selectedTableIdProvider.notifier).state = null;
      if (context.mounted) Navigator.pop(context);
    }

    return AlertDialog(
      title: const Text('Tabellen löschen'),
      content: Text(
          '${selectedIds.length} Tabellen und alle ihre Einträge unwiderruflich löschen?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen')),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error),
          onPressed: delete,
          child: Text('${selectedIds.length} löschen'),
        ),
      ],
    );
  }
}

// ── Hilfsmethoden ─────────────────────────────────────────────────────────────

/// Zeile im Kontextmenü der Tabellen-Zeile.
class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _MenuRow({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? cs.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: c),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13, color: c)),
      ],
    );
  }
}

class _SmallBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SmallBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.sp12, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border(context)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 12, color: cs.onSurface)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  const _EmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.sp32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.table_rows_outlined,
                size: 40, color: cs.onSurfaceVariant.withAlpha(80)),
            const SizedBox(height: AppTheme.sp12),
            Text(
              hasFilter
                  ? 'Keine Tabellen für diesen Filter'
                  : 'Noch keine Tabellen',
              style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
            ),
            if (!hasFilter) ...[
              const SizedBox(height: AppTheme.sp8),
              Text(
                '+ Neu drücken oder ⌘N um eine Tabelle anzulegen.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
