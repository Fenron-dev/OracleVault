// Datei: lib/core/di.dart
//
// ZWECK: Riverpod-Provider für Dependency Injection.
//        Öffnet VaultDatabase als Riverpod-StateProvider, damit alle Features
//        denselben Datenbankzugriff teilen.
//
// WICHTIG: activeVaultProvider enthält die geöffnete VaultDatabase (oder null).
//          Er wird gesetzt, wenn der Nutzer einen Vault im VaultPickerScreen
//          auswählt oder anlegt.
// ABHÄNGIGKEITEN: flutter_riverpod, vault_database.dart, vault_manager.dart
// PHASE: 0 – Grundgerüst.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/vault/vault_manager.dart';

/// Der aktuell geöffnete Vault.
///
/// Null = kein Vault offen (VaultPickerScreen wird angezeigt).
/// Gesetzt von vaultPickerProvider.notifier.openVault() und createVault().
final activeVaultProvider =
    StateProvider<OpenedVault?>((ref) => null);

/// Theme-Modus als String: 'system' | 'light' | 'dark'.
/// Phase 1: wird aus config.json des Vaults gelesen.
final themeModeStringProvider =
    StateProvider<String>((ref) => 'system');
