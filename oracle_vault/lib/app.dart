// Datei: lib/app.dart
//
// ZWECK: Wurzel-Widget der App. Verbindet MaterialApp.router mit go_router
//        und Theme-Provider.
// ABHÄNGIGKEITEN: flutter_riverpod, go_router, core/di.dart, core/router.dart, core/theme.dart
// PHASE: 0 – Grundgerüst.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'widgets/keyboard_shortcuts.dart';

/// Haupteinstieg-Widget.
///
/// ConsumerWidget statt StatelessWidget, weil wir routerProvider und
/// themeModeStringProvider beobachten.
class OracleVaultApp extends ConsumerWidget {
  const OracleVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeModeStr = ref.watch(themeModeStringProvider);

    final themeMode = switch (themeModeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp.router(
      title: 'OracleVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      // Keyboard-Shortcuts (Cmd+K, Cmd+N, Cmd+,) für den gesamten App-Baum.
      builder: (context, child) =>
          KeyboardShortcutsWrapper(child: child ?? const SizedBox.shrink()),
    );
  }
}
