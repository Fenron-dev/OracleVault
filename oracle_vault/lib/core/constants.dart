// Datei: lib/core/constants.dart
//
// ZWECK: Zentrale Konstanten — Routen-Pfade und App-weite Strings.
// ABHÄNGIGKEITEN: keine
// PHASE: 0 – Grundgerüst. Phase 1: Tabellen-Routen hinzugefügt.

/// Routen-Pfade der App.
///
/// Alle Pfade hier definieren, nie als Inline-Strings in Router oder Screens.
abstract class AppRoutes {
  /// Vault-Auswahl-/Start-Screen.
  static const String vaultPicker = '/';

  /// Hauptansicht der Library (3-Panel-Desktop, Bottom-Nav Mobile).
  static const String library = '/library';

  /// Neue Tabelle anlegen.
  static const String tableNew = '/table/new';

  /// Tabelle bearbeiten (Pfad + '/:id' wird im Router zusammengesetzt).
  static const String tableEdit = '/table/edit';

  /// Import-Screen.
  static const String importScreen = '/import';

  /// KI-Generierungs-Screen.
  static const String aiGenerate = '/ai/generate';

  /// KI-Einstellungen.
  static const String aiSettings = '/settings/ai';

  /// Einstellungen.
  static const String settings = '/settings';

  /// Backup-/Restore-Unterseite der Einstellungen.
  static const String backupSettings = '/settings/backup';

  /// Übersetzungs-Screen (Pfad + '/:id' im Router).
  static const String tableTranslate = '/table/translate';
}
