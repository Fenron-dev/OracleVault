// Datei: lib/core/router.dart
//
// ZWECK: go_router-Konfiguration.
//        Redirect-Logik: kein Vault → VaultPicker; Vault offen → Library.
//
// ABHÄNGIGKEITEN: go_router, flutter_riverpod, di.dart, alle Screen-Klassen
// PHASE: 0 – Grundgerüst. Phase 1: Tabellen-Routen hinzugefügt.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'constants.dart';
import 'di.dart';
import '../features/vault_picker/vault_picker_screen.dart';
import '../features/library/library_screen.dart';
import '../features/import/import_screen.dart';
import '../features/tables/table_form_screen.dart';
import '../features/tables/translation_screen.dart';
import '../features/tables/ai_generate_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/backup_settings_screen.dart';
import '../features/settings/ai_settings_screen.dart';

/// GoRouter als Riverpod-Provider.
///
/// WARUM ref.watch(activeVaultProvider)?
/// Wenn der Vault-Zustand wechselt, wird der Provider neu erzeugt und der
/// Router verwendet die aktualisierte Redirect-Logik.
final routerProvider = Provider<GoRouter>((ref) {
  final vault = ref.watch(activeVaultProvider);

  return GoRouter(
    initialLocation: AppRoutes.vaultPicker,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final vaultOpen = vault != null;
      final isOnPicker = state.matchedLocation == AppRoutes.vaultPicker;

      if (!vaultOpen && !isOnPicker) return AppRoutes.vaultPicker;
      if (vaultOpen && isOnPicker) return AppRoutes.library;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.vaultPicker,
        builder: (_, __) => const VaultPickerScreen(),
      ),
      GoRoute(
        path: AppRoutes.library,
        builder: (_, __) => const LibraryScreen(),
      ),
      GoRoute(
        path: AppRoutes.importScreen,
        builder: (_, state) => ImportScreen(
          initialUrl: state.uri.queryParameters['url'],
        ),
      ),
      GoRoute(
        path: AppRoutes.tableNew,
        builder: (_, __) => const TableFormScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.tableEdit}/:id',
        builder: (_, state) =>
            TableFormScreen(tableId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '${AppRoutes.tableTranslate}/:id',
        builder: (_, state) =>
            TranslationScreen(tableId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.aiGenerate,
        builder: (_, __) => const AiGenerateScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'backup',
            builder: (_, __) => const BackupSettingsScreen(),
          ),
          GoRoute(
            path: 'ai',
            builder: (_, __) => const AiSettingsScreen(),
          ),
        ],
      ),
    ],
  );
}, name: 'routerProvider');
