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
import '../services/backup_service.dart';
import '../services/media/media_service.dart';
import '../services/media/thumbnail_service.dart';

/// Der aktuell geöffnete Vault.
///
/// Null = kein Vault offen (VaultPickerScreen wird angezeigt).
/// Gesetzt von vaultPickerProvider.notifier.openVault() und createVault().
final activeVaultProvider =
    StateProvider<OpenedVault?>((ref) => null);

/// Einmalige Meldung zum offenen Vault, die die Library beim nächsten Aufbau
/// als SnackBar zeigt und danach löscht.
///
/// WOFÜR? Manches passiert, während gerade kein Screen da ist, der es anzeigen
/// könnte: das Tages-Backup läuft beim Öffnen (der Picker verschwindet sofort
/// danach), und ein Restore tauscht den Vault aus, wobei der auslösende
/// Backup-Screen abgeräumt wird.
final vaultNoticeProvider = StateProvider<String?>((ref) => null);

/// Lebenszyklus des offenen Vaults.
///
/// Liegt bewusst im Provider-Container und nicht in einem Widget: ein Restore
/// überlebt den Screen, von dem er gestartet wurde (das Abkoppeln des Vaults
/// schickt den Router zurück zum Picker, wodurch der Screen verschwindet).
class VaultSession {
  final Ref _ref;
  VaultSession(this._ref);

  /// Spielt einen DB-Snapshot ein und hängt den Vault danach neu ein.
  ///
  /// Die offene Verbindung muss dafür geschlossen werden: sie hält Handles auf
  /// index.db und deren WAL und würde beim Schließen über die gerade
  /// eingespielte Datei schreiben. Zuerst wird abgekoppelt, damit die Library
  /// nicht noch auf die schließende Verbindung zugreift.
  Future<BackupResult> restoreSnapshot(String snapshotPath) async {
    final vault = _ref.read(activeVaultProvider);
    if (vault == null) return const BackupResult.err('Kein Vault geöffnet');
    final vaultPath = vault.vaultPath;

    _ref.read(activeVaultProvider.notifier).state = null;
    await vault.database.close();

    final result =
        await BackupService.restoreFromDbSnapshot(vaultPath, snapshotPath);

    // Auch nach einem Fehlschlag wieder öffnen: bricht die Prüfung ab, bleibt
    // die alte index.db unangetastet — der Nutzer soll nicht ausgesperrt sein.
    try {
      final reopened = await VaultManager.open(vaultPath);
      _ref.read(activeVaultProvider.notifier).state = reopened;
    } catch (e) {
      // activeVaultProvider bleibt null → Router zeigt den Vault-Picker.
      return BackupResult.err(
          '${result.success ? "Backup eingespielt, aber der" : "${result.error} — der"}'
          ' Vault ließ sich nicht neu öffnen: $e');
    }
    return result;
  }
}

final vaultSessionProvider = Provider<VaultSession>(VaultSession.new);

/// Theme-Modus als String: 'system' | 'light' | 'dark'.
/// Phase 1: wird aus config.json des Vaults gelesen.
final themeModeStringProvider =
    StateProvider<String>((ref) => 'system');

/// Medien-Service des aktuell geöffneten Vaults (null = kein Vault offen).
/// Phase 4: Import, Deduplizierung und Verwaltung von Datei-Assets.
final mediaServiceProvider = Provider<MediaService?>((ref) {
  final vault = ref.watch(activeVaultProvider);
  if (vault == null) return null;
  return MediaService(db: vault.database, vaultPath: vault.vaultPath);
});

/// Thumbnail-Service des aktuell geöffneten Vaults (null = kein Vault offen).
/// Phase 4: cached Bild-Thumbnails in .oraclevault/thumbnails/ (Isolate-Pool).
final thumbnailServiceProvider = Provider<ThumbnailService?>((ref) {
  final vault = ref.watch(activeVaultProvider);
  if (vault == null) return null;
  return ThumbnailService(vaultPath: vault.vaultPath);
});
