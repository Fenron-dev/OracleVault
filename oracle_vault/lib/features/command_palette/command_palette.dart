// Datei: lib/features/command_palette/command_palette.dart
//
// ZWECK: Globale Command-Palette (Cmd+K).
//        Durchsucht: Tabellen-Namen, App-Aktionen.
//        Öffnet via showDialog — kein eigener Screen.
//        Phase 1: Tabellen + Aktionen. Phase 5: Einträge + Tags.
// ABHÄNGIGKEITEN: flutter_riverpod, go_router, library_providers.dart
// PHASE: 1

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/di.dart';
import '../../core/theme.dart';
import '../library/library_providers.dart';

/// Ein Ergebnis in der Command-Palette.
class _PaletteItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback action;
  final bool isAction; // true = App-Aktion, false = Tabellen-Treffer

  const _PaletteItem({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.action,
    this.isAction = false,
  });
}

/// Öffnet die Command-Palette als Dialog.
class CommandPalette {
  static void show(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => _CommandPaletteDialog(
        outerRef: ref,
        outerContext: context,
      ),
    );
  }
}

class _CommandPaletteDialog extends ConsumerStatefulWidget {
  final WidgetRef outerRef;
  final BuildContext outerContext;

  const _CommandPaletteDialog(
      {required this.outerRef, required this.outerContext});

  @override
  ConsumerState<_CommandPaletteDialog> createState() =>
      _CommandPaletteDialogState();
}

class _CommandPaletteDialogState
    extends ConsumerState<_CommandPaletteDialog> {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  List<_PaletteItem> _results = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateResults('');
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateResults(String query) {
    final q = query.toLowerCase().trim();
    final items = <_PaletteItem>[];

    // ── App-Aktionen ─────────────────────────────────────────────
    final actions = _buildActions(widget.outerContext);
    for (final action in actions) {
      if (q.isEmpty ||
          action.title.toLowerCase().contains(q) ||
          (action.subtitle?.toLowerCase().contains(q) ?? false)) {
        items.add(action);
      }
    }

    // ── Tabellen-Treffer ────────────────────────────────────────
    final tablesAsync = ref.read(tableListProvider);
    tablesAsync.whenData((tables) {
      for (final table in tables) {
        if (q.isEmpty || table.name.toLowerCase().contains(q)) {
          items.add(_PaletteItem(
            title: table.name,
            subtitle: '${_typeLabel(table.oracleType)} · ${table.language.toUpperCase()}',
            icon: Icons.table_rows_outlined,
            action: () {
              Navigator.of(context).pop();
              ref.read(selectedTableIdProvider.notifier).state = table.id;
            },
          ));
        }
      }
    });

    setState(() {
      _results = items.take(12).toList();
      _selectedIndex = 0;
    });
  }

  List<_PaletteItem> _buildActions(BuildContext ctx) => [
        _PaletteItem(
          title: 'Neue Tabelle',
          subtitle: '⌘N',
          icon: Icons.add_circle_outline,
          isAction: true,
          action: () {
            Navigator.of(context).pop();
            ctx.push(AppRoutes.tableNew);
          },
        ),
        _PaletteItem(
          title: 'Importieren',
          subtitle: 'URL, Datei, CSV, XLSX, MD',
          icon: Icons.file_upload_outlined,
          isAction: true,
          action: () {
            Navigator.of(context).pop();
            ctx.push(AppRoutes.importScreen);
          },
        ),
        _PaletteItem(
          title: 'Vault schließen',
          icon: Icons.logout_outlined,
          isAction: true,
          action: () {
            Navigator.of(context).pop();
            widget.outerRef.read(activeVaultProvider.notifier).state =
                null;
          },
        ),
        _PaletteItem(
          title: 'Einstellungen',
          icon: Icons.settings_outlined,
          isAction: true,
          action: () {
            Navigator.of(context).pop();
            ctx.push(AppRoutes.settings);
          },
        ),
        _PaletteItem(
          title: 'Backup erstellen',
          icon: Icons.backup_outlined,
          isAction: true,
          action: () {
            Navigator.of(context).pop();
            ctx.push(AppRoutes.backupSettings);
          },
        ),
      ];

  void _runSelected() {
    if (_results.isEmpty) return;
    _results[_selectedIndex.clamp(0, _results.length - 1)].action();
  }

  String _typeLabel(String type) => switch (type) {
        'uniform' => 'Gleichverteilt',
        'weighted' => 'Gewichtet',
        'dice' => 'Würfel',
        'deck' => 'Deck',
        _ => type,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
          horizontal: 120, vertical: 120),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 560,
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) {
            if (event is KeyDownEvent) {
              if (event.logicalKey.keyLabel == 'Arrow Down') {
                setState(() => _selectedIndex =
                    (_selectedIndex + 1).clamp(0, _results.length - 1));
              } else if (event.logicalKey.keyLabel == 'Arrow Up') {
                setState(() => _selectedIndex =
                    (_selectedIndex - 1).clamp(0, _results.length - 1));
              } else if (event.logicalKey.keyLabel == 'Enter') {
                _runSelected();
              }
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Suche ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppTheme.sp16),
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Tabelle suchen oder Aktion …',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: _updateResults,
                ),
              ),

              if (_results.isNotEmpty)
                const Divider(height: 1),

              // ── Ergebnisse ─────────────────────────────────────────
              if (_results.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _results.length,
                    itemBuilder: (ctx, i) {
                      final item = _results[i];
                      final selected = i == _selectedIndex;
                      return ListTile(
                        leading: Icon(item.icon,
                            size: 18,
                            color: item.isAction
                                ? cs.primary
                                : cs.onSurface),
                        title: Text(item.title,
                            style: theme.textTheme.bodyMedium),
                        subtitle: item.subtitle != null
                            ? Text(item.subtitle!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant))
                            : null,
                        selected: selected,
                        selectedTileColor:
                            cs.primaryContainer.withAlpha(120),
                        dense: true,
                        visualDensity: VisualDensity.compact,
                        onTap: item.action,
                      );
                    },
                  ),
                )
              else if (_ctrl.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppTheme.sp24),
                  child: Text(
                    'Keine Ergebnisse für „${_ctrl.text}"',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),

              const Gap(AppTheme.sp4),
            ],
          ),
        ),
      ),
    );
  }
}
