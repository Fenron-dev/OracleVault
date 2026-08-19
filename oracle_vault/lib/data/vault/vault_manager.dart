// Datei: lib/data/vault/vault_manager.dart
//
// ZWECK: Verwaltet das Vault-Ordner-Format und die Datenbank-Verbindung.
//        Ein Vault ist ein gewöhnlicher Ordner; alle Verwaltungsdaten liegen
//        im versteckten Unterordner .oraclevault/.
//
// VAULT-STRUKTUR:
//   <vault>/
//   ├── .oraclevault/
//   │   ├── index.db          Drift-Datenbank
//   │   ├── thumbnails/       Regenerierbarer Cache (nicht im Backup)
//   │   ├── backups/          Auto-Snapshots und tägliche Backups
//   │   └── config.json       Vault-spezifische Einstellungen
//   ├── media/
//   │   ├── images/
//   │   ├── audio/
//   │   ├── video/
//   │   └── documents/
//   └── README.md             Auto-generiert
//
// ABHÄNGIGKEITEN: dart:io, path, vault_database.dart
// PHASE: 0 – Grundgerüst.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../services/backup_service.dart';
import '../db/vault_database.dart';
import 'vault_recovery.dart';

/// Ergebnis von [VaultManager.open] und [VaultManager.create].
class OpenedVault {
  final String vaultPath;
  final VaultDatabase database;

  /// Nicht-kritischer Hinweis aus dem Öffnungsvorgang, z. B. ein
  /// fehlgeschlagenes Tages-Backup. Null = alles glatt gelaufen.
  final String? warning;

  const OpenedVault({
    required this.vaultPath,
    required this.database,
    this.warning,
  });
}

/// Verwaltet das Vault-Ordner-Format.
///
/// MUSTER: Statische Hilfsmethoden — kein Zustand. VaultDatabase wird vom
///         Aufrufer gehalten (Riverpod-Provider in di.dart).
abstract class VaultManager {
  // ── Pfad-Helfer ────────────────────────────────────────────────────────────

  /// Pfad zum internen .oraclevault/-Ordner.
  static String internalDir(String vaultPath) =>
      p.join(vaultPath, '.oraclevault');

  /// Pfad zur index.db-Datenbankdatei.
  static String dbPath(String vaultPath) =>
      p.join(internalDir(vaultPath), 'index.db');

  /// Pfad zum Backups-Ordner.
  static String backupsDir(String vaultPath) =>
      p.join(internalDir(vaultPath), 'backups');

  /// Pfad zum Thumbnails-Cache.
  static String thumbnailsDir(String vaultPath) =>
      p.join(internalDir(vaultPath), 'thumbnails');

  /// Pfad zur config.json.
  static String configPath(String vaultPath) =>
      p.join(internalDir(vaultPath), 'config.json');

  /// Pfad zum Media-Ordner (für Untertyp: 'images', 'audio', 'video', 'documents').
  static String mediaDir(String vaultPath, String subtype) =>
      p.join(vaultPath, 'media', subtype);

  // ── Vault erkennen ─────────────────────────────────────────────────────────

  /// Prüft ob [path] ein gültiger Vault-Ordner ist (index.db vorhanden).
  static bool isVault(String path) =>
      File(dbPath(path)).existsSync();

  // ── Vault öffnen ───────────────────────────────────────────────────────────

  /// Öffnet einen bestehenden Vault.
  ///
  /// Erstellt fehlende Unterordner (thumbnails, backups), falls diese nach einem
  /// Teilbackup-Restore fehlen. Wirft [VaultNotFoundException] wenn index.db fehlt.
  static Future<OpenedVault> open(String vaultPath) async {
    if (!isVault(vaultPath)) {
      throw VaultNotFoundException(vaultPath);
    }
    await _ensureSubdirs(vaultPath);

    // ── Zustand der Datei prüfen ────────────────────────────────────────────
    // Muss ganz am Anfang stehen: alles Weitere (Snapshot, Migration) setzt
    // eine lesbare index.db voraus. Wirft, wenn die Datei beschädigt ist —
    // dann wird der Vault nicht geöffnet.
    final recoveryNotice = await VaultRecovery.prepare(vaultPath);

    // ── Pre-Migration-Snapshot ───────────────────────────────────────────────
    // Muss VOR dem Öffnen laufen: sobald Drift die Verbindung aufbaut, migriert
    // es, und der Snapshot nutzt VACUUM INTO — das geht nicht innerhalb einer
    // Transaktion, also auch nicht aus onUpgrade heraus.
    //
    // Scheitert der Snapshot, wird NICHT geöffnet. Eine Migration ohne
    // Sicherung ist genau das Szenario, das hier verhindert werden soll — der
    // Vault bleibt unangetastet und der Nutzer kann Platz schaffen und es
    // erneut versuchen.
    final snapshot = await BackupService.createPreMigrationSnapshotIfNeeded(
        vaultPath, VaultDatabase.kSchemaVersion);
    if (snapshot != null && !snapshot.success) {
      throw VaultMigrationBackupException(snapshot.error ?? 'unbekannt');
    }

    final db = VaultDatabase(dbPath(vaultPath));
    // Verbindung sofort erzwingen, damit die Migration hier läuft (und nicht
    // irgendwann später bei der ersten Query im UI).
    await db.customSelect('SELECT 1').get();

    // ── Tages-Backup ────────────────────────────────────────────────────────
    // Nicht kritisch: schlägt es fehl, ist der Vault trotzdem benutzbar.
    String? warning = recoveryNotice;
    try {
      if (!await BackupService.autoBackupExistsForToday(vaultPath)) {
        final config = await readConfig(vaultPath);
        final keep = (config['backupKeepCount'] as num?)?.toInt() ?? 7;
        final result =
            await BackupService.createAutoBackup(vaultPath, keepCount: keep);
        if (!result.success) warning = _join(warning, result.error);
      }
    } catch (e) {
      warning = _join(warning, 'Tages-Backup fehlgeschlagen: $e');
    }

    return OpenedVault(
        vaultPath: vaultPath, database: db, warning: warning);
  }

  /// Fügt zwei Hinweise zu einer Meldung zusammen (beide können null sein).
  static String? _join(String? a, String? b) {
    final parts = [a, b].whereType<String>().where((s) => s.isNotEmpty);
    return parts.isEmpty ? null : parts.join(' ');
  }

  // ── Vault anlegen ──────────────────────────────────────────────────────────

  /// Legt einen neuen Vault im angegebenen Ordner an.
  ///
  /// Erstellt die komplette Ordnerstruktur, eine leere Datenbank,
  /// eine config.json mit Defaults und eine README.md.
  /// Wirft [VaultAlreadyExistsException] wenn index.db bereits existiert.
  static Future<OpenedVault> create(
    String vaultPath, {
    String? name,
    String language = 'de',
  }) async {
    if (isVault(vaultPath)) {
      throw VaultAlreadyExistsException(vaultPath);
    }

    await _ensureSubdirs(vaultPath);

    // config.json mit Vault-Defaults anlegen.
    final vaultName = name ?? p.basename(vaultPath);
    await _writeConfig(vaultPath, vaultName, language);

    // README.md anlegen.
    await _writeReadme(vaultPath, vaultName);

    final db = VaultDatabase(dbPath(vaultPath));
    // Erste Verbindung öffnen – löst onCreate aus (erstellt Schema, FTS5, Indizes).
    await db.customSelect('SELECT 1').get();

    return OpenedVault(vaultPath: vaultPath, database: db);
  }

  // ── config.json ────────────────────────────────────────────────────────────

  /// Liest die Vault-Konfiguration. Gibt Defaults zurück wenn config.json fehlt.
  static Future<Map<String, dynamic>> readConfig(String vaultPath) async {
    final file = File(configPath(vaultPath));
    if (!file.existsSync()) return _defaultConfig(p.basename(vaultPath), 'de');
    try {
      return jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      return _defaultConfig(p.basename(vaultPath), 'de');
    }
  }

  /// Schreibt einzelne Felder in config.json (merge, kein Überschreiben).
  static Future<void> updateConfig(
      String vaultPath, Map<String, dynamic> updates) async {
    final current = await readConfig(vaultPath);
    current.addAll(updates);
    final file = File(configPath(vaultPath));
    await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(current));
  }

  // ── Interne Hilfsmethoden ──────────────────────────────────────────────────

  static Future<void> _ensureSubdirs(String vaultPath) async {
    for (final dir in [
      internalDir(vaultPath),
      backupsDir(vaultPath),
      thumbnailsDir(vaultPath),
      mediaDir(vaultPath, 'images'),
      mediaDir(vaultPath, 'audio'),
      mediaDir(vaultPath, 'video'),
      mediaDir(vaultPath, 'documents'),
    ]) {
      await Directory(dir).create(recursive: true);
    }
  }

  static Future<void> _writeConfig(
      String vaultPath, String name, String language) async {
    final config = _defaultConfig(name, language);
    await File(configPath(vaultPath)).writeAsString(
        const JsonEncoder.withIndent('  ').convert(config));
  }

  static Map<String, dynamic> _defaultConfig(String name, String language) => {
        'name': name,
        'language': language,
        'accentColor': 'petrol',
        'theme': 'system',
        'density': 'dense',
        'createdAt': DateTime.now().toIso8601String(),
      };

  static Future<void> _writeReadme(String vaultPath, String vaultName) async {
    final content = '''# $vaultName

Dieser Ordner ist ein OracleVault — eine lokale Sammlung von Random-Tabellen, Orakeln und Medien für Pen-&-Paper- und Solo-RPGs.

Verwaltet mit **OracleVault** (https://oraclevault.app).

## Inhalt

- `.oraclevault/` — Datenbank und Verwaltungsdaten (nicht manuell bearbeiten)
- `media/` — Originaldateien (Bilder, Audio, Video, Dokumente)

## Portabilität

Diesen Ordner auf einen USB-Stick kopieren oder in einem Cloud-Sync-Ordner ablegen — OracleVault öffnet ihn ohne weitere Konfiguration.
''';
    final readme = File(p.join(vaultPath, 'README.md'));
    // README nur anlegen wenn noch nicht vorhanden (z. B. bei bestehendem Ordner).
    if (!readme.existsSync()) {
      await readme.writeAsString(content);
    }
  }
}

// ── Exceptions ────────────────────────────────────────────────────────────────

class VaultNotFoundException implements Exception {
  final String path;
  VaultNotFoundException(this.path);
  @override
  String toString() => 'Kein gültiger Vault unter: $path';
}

/// Der Pre-Migration-Snapshot konnte nicht erstellt werden — der Vault wurde
/// deshalb NICHT geöffnet und nicht migriert.
class VaultMigrationBackupException implements Exception {
  final String reason;
  VaultMigrationBackupException(this.reason);
  @override
  String toString() =>
      'Sicherung vor dem Schema-Update fehlgeschlagen, Vault nicht geöffnet: '
      '$reason';
}

class VaultAlreadyExistsException implements Exception {
  final String path;
  VaultAlreadyExistsException(this.path);
  @override
  String toString() => 'Vault existiert bereits unter: $path';
}
