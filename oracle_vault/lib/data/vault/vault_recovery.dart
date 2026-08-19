// Datei: lib/data/vault/vault_recovery.dart
//
// ZWECK: Zustand der index.db prüfen, BEVOR Drift sie öffnet.
//        Ein Vault ist ein portabler Ordner — er kann von einem USB-Stick
//        kommen, mitten im Schreiben abgezogen worden sein, oder jemand hat
//        von Hand ein Backup über index.db kopiert. In all diesen Fällen soll
//        die App entweder sauber weiterlaufen oder verständlich sagen, was los
//        ist, statt eine rohe SqliteException durchzureichen.
//
// WAS SQLITE SELBST ERLEDIGT (nachgemessen, nicht vermutet):
//   Ein beschädigtes oder abgeschnittenes -wal / -shm bringt das Öffnen NICHT
//   zum Scheitern — SQLite verwirft es und öffnet die Hauptdatei.
//   Gefährlich ist der umgekehrte Fall: ein GÜLTIGES WAL, das nicht mehr zur
//   Hauptdatei gehört (jemand kopiert ein Backup von Hand über index.db und
//   lässt index.db-wal liegen). Das wird eingespielt und mischt zwei Stände.
//   Erkennen lässt sich das nicht zuverlässig — begrenzen schon: nach einem
//   unsauberen Ende wird die Datei geprüft, bevor die App auf ihr weiterarbeitet.
//
// ABHÄNGIGKEITEN: dart:io, sqlite3, path
// PHASE: 0 – Robustheit beim Öffnen.

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'vault_manager.dart';

abstract class VaultRecovery {
  /// Bringt die Datenbankdatei in einen Zustand, in dem Drift sie öffnen kann.
  ///
  /// Gibt einen Hinweis für die UI zurück (oder null, wenn alles glatt war) und
  /// wirft [VaultDatabaseUnreadableException], wenn die Datei nicht zu retten
  /// ist — dann wird der Vault nicht geöffnet.
  static Future<String?> prepare(String vaultPath) async {
    final dbPath = VaultManager.dbPath(vaultPath);
    if (!File(dbPath).existsSync()) return null; // frischer Vault

    // Ein liegengebliebenes WAL heißt: beim letzten Mal wurde nicht sauber
    // geschlossen (Absturz, Stick abgezogen, Prozess getötet).
    final wal = File('$dbPath-wal');
    final uncleanShutdown = wal.existsSync() && wal.lengthSync() > 0;

    final Database db;
    try {
      db = sqlite3.open(dbPath);
    } catch (e) {
      throw VaultDatabaseUnreadableException(
          vaultPath, 'Datei lässt sich nicht öffnen: $e');
    }

    try {
      if (uncleanShutdown) {
        // Nur nach einem unsauberen Ende prüfen — bei jedem Start wäre das ein
        // vollständiger Datei-Scan für nichts.
        final check = db.select('PRAGMA quick_check(1)').first.values.first;
        if (check != 'ok') {
          throw VaultDatabaseUnreadableException(
              vaultPath, 'Integritätsprüfung fehlgeschlagen: $check');
        }
      }

      // WAL in die Hauptdatei falten. Danach ist der Ordner portabel: wer ihn
      // jetzt kopiert, bekommt den vollständigen Stand.
      db.execute('PRAGMA wal_checkpoint(TRUNCATE)');
    } on VaultDatabaseUnreadableException {
      rethrow;
    } catch (e) {
      throw VaultDatabaseUnreadableException(
          vaultPath, 'Datenbank nicht lesbar: $e');
    } finally {
      db.dispose();
    }

    if (!uncleanShutdown) return null;
    return 'Der Vault wurde beim letzten Mal nicht sauber geschlossen. '
        'Ausstehende Änderungen wurden übernommen, die Daten sind in Ordnung.';
  }
}

/// Die index.db ist vorhanden, aber unbrauchbar — der Vault wurde NICHT
/// geöffnet. Die Meldung nennt den Weg zurück: den Backups-Ordner.
class VaultDatabaseUnreadableException implements Exception {
  final String vaultPath;
  final String reason;

  VaultDatabaseUnreadableException(this.vaultPath, this.reason);

  /// Vorhandene Sicherungen, neueste zuerst — als konkreter nächster Schritt
  /// in der Fehlermeldung.
  List<String> get availableBackups {
    final dir = Directory(VaultManager.backupsDir(vaultPath));
    if (!dir.existsSync()) return const [];
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.db'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    return files.map((f) => p.basename(f.path)).toList();
  }

  @override
  String toString() {
    final backups = availableBackups;
    final hint = backups.isEmpty
        ? 'Im Backups-Ordner (.oraclevault/backups/) liegt keine Sicherung.'
        : 'Im Backups-Ordner (.oraclevault/backups/) liegen ${backups.length} '
            'Sicherungen, die neueste ist "${backups.first}". Kopiere sie über '
            '.oraclevault/index.db — lösche dabei auch index.db-wal und '
            'index.db-shm, sonst wird die Sicherung wieder überschrieben.';
    return 'Die Datenbank dieses Vaults ist beschädigt ($reason). $hint';
  }
}
