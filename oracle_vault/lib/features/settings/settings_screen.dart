// Datei: lib/features/settings/settings_screen.dart
//
// ZWECK: Einstellungen-Hauptscreen.
//        Phase 0: Backup-Link + Theme-Toggle.
//        Phase 1: Vollständiges Settings-Inventar (siehe Konzept Sektion 14).
// ABHÄNGIGKEITEN: flutter_riverpod, go_router, di.dart
// PHASE: 0 – Grundgerüst.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/di.dart';

/// Einstellungen-Screen.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeStringProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        children: [
          // ── Aussehen ────────────────────────────────────────────────
          const _SectionHeader('Aussehen'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Theme'),
            subtitle: Text(_themeModeLabel(themeMode)),
            onTap: () => _showThemePicker(context, ref, themeMode),
          ),

          const Divider(indent: 16, endIndent: 16),

          // ── Backup & Daten ───────────────────────────────────────────
          const _SectionHeader('Backup & Daten'),
          ListTile(
            leading: const Icon(Icons.backup_outlined),
            title: const Text('Backup & Wiederherstellen'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.backupSettings),
          ),

          const Divider(indent: 16, endIndent: 16),

          // ── KI ───────────────────────────────────────────────────────
          const _SectionHeader('KI'),
          ListTile(
            leading: const Icon(Icons.auto_awesome_outlined),
            title: const Text('KI-Provider & Modelle'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.aiSettings),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(String mode) => switch (mode) {
        'light' => 'Hell',
        'dark' => 'Dunkel',
        _ => 'System',
      };

  void _showThemePicker(
      BuildContext context, WidgetRef ref, String current) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _ThemePicker(
        current: current,
        onSelected: (value) {
          ref.read(themeModeStringProvider.notifier).state = value;
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  final String current;
  final ValueChanged<String> onSelected;

  const _ThemePicker({required this.current, required this.onSelected});

  static const _options = [
    ('system', 'System'),
    ('light', 'Hell'),
    ('dark', 'Dunkel'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RadioGroup<String>(
        groupValue: current,
        onChanged: (v) { if (v != null) onSelected(v); },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _options
              .map((opt) => ListTile(
                    title: Text(opt.$2),
                    leading: Radio<String>(value: opt.$1),
                    onTap: () => onSelected(opt.$1),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
