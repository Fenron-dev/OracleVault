// Datei: lib/widgets/keyboard_shortcuts.dart
//
// ZWECK: App-weiter Keyboard-Shortcuts-Wrapper.
//        Fängt macOS-Shortcuts ab und löst Aktionen aus.
//        Muss innerhalb von MaterialApp (für Router-Zugriff via context) liegen.
//
// SHORTCUTS:
//   Cmd+K    → Command-Palette öffnen
//   Cmd+N    → Neue Tabelle
//   Cmd+,    → Einstellungen
//
// ABHÄNGIGKEITEN: flutter, flutter_riverpod, go_router
// PHASE: 1

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';
import '../features/command_palette/command_palette.dart';

/// Wrapper-Widget das Keyboard-Shortcuts für die gesamte App abfängt.
///
/// Muss INNERHALB von MaterialApp platziert werden (in app.dart als builder),
/// damit context.push() und GoRouter-Zugriff funktionieren.
class KeyboardShortcutsWrapper extends ConsumerWidget {
  final Widget child;
  const KeyboardShortcutsWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Shortcuts(
      shortcuts: {
        // Cmd+K: Command-Palette
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _OpenPaletteIntent(),
        // Cmd+N: Neue Tabelle
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true):
            _NewTableIntent(),
        // Cmd+,: Einstellungen
        const SingleActivator(LogicalKeyboardKey.comma, meta: true):
            _OpenSettingsIntent(),
      },
      child: Actions(
        actions: {
          _OpenPaletteIntent: CallbackAction<_OpenPaletteIntent>(
            onInvoke: (_) {
              CommandPalette.show(context, ref);
              return null;
            },
          ),
          _NewTableIntent: CallbackAction<_NewTableIntent>(
            onInvoke: (_) {
              context.push(AppRoutes.tableNew);
              return null;
            },
          ),
          _OpenSettingsIntent: CallbackAction<_OpenSettingsIntent>(
            onInvoke: (_) {
              context.push(AppRoutes.settings);
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}

// ── Intent-Klassen ────────────────────────────────────────────────────────────

class _OpenPaletteIntent extends Intent {
  const _OpenPaletteIntent();
}

class _NewTableIntent extends Intent {
  const _NewTableIntent();
}

class _OpenSettingsIntent extends Intent {
  const _OpenSettingsIntent();
}
