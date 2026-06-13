// Datei: lib/data/vault/recent_vaults_store.dart
//
// ZWECK: Persistiert die Liste der zuletzt geöffneten Vaults in SharedPreferences.
//        Diese Daten gehören zur App, nicht zum Vault – deshalb SharedPreferences
//        und nicht config.json im Vault-Ordner.
// ABHÄNGIGKEITEN: shared_preferences
// PHASE: 0 – Grundgerüst.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Eintrag in der Recent-Vaults-Liste.
class RecentVault {
  final String path;
  final String name;
  final DateTime lastOpened;

  const RecentVault({
    required this.path,
    required this.name,
    required this.lastOpened,
  });

  Map<String, dynamic> toJson() => {
        'path': path,
        'name': name,
        'lastOpened': lastOpened.toIso8601String(),
      };

  factory RecentVault.fromJson(Map<String, dynamic> json) => RecentVault(
        path: json['path'] as String,
        name: json['name'] as String,
        lastOpened: DateTime.parse(json['lastOpened'] as String),
      );
}

/// Liest und schreibt die Liste der zuletzt geöffneten Vaults.
///
/// Die Liste ist nach [RecentVault.lastOpened] absteigend sortiert.
/// Maximal [maxEntries] Einträge werden gespeichert.
class RecentVaultsStore {
  static const String _key = 'recent_vaults';
  static const int maxEntries = 10;

  /// Gibt die gespeicherte Liste zurück, neueste zuerst.
  static Future<List<RecentVault>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final vaults = <RecentVault>[];
    for (final item in raw) {
      try {
        vaults.add(RecentVault.fromJson(
            jsonDecode(item) as Map<String, dynamic>));
      } catch (_) {
        // Korrupter Eintrag wird übersprungen.
      }
    }
    return vaults;
  }

  /// Fügt [path] zur Liste hinzu oder aktualisiert [lastOpened] falls vorhanden.
  /// Entfernt den ältesten Eintrag wenn die Liste [maxEntries] überschreitet.
  static Future<void> touch(String path, String name) async {
    final current = await load();
    // Vorhandenen Eintrag entfernen (wird aktualisiert nach vorne gestellt).
    current.removeWhere((v) => v.path == path);
    current.insert(
        0,
        RecentVault(
          path: path,
          name: name,
          lastOpened: DateTime.now(),
        ));
    final trimmed = current.take(maxEntries).toList();
    await _save(trimmed);
  }

  /// Entfernt [path] aus der Liste (z. B. nach Löschen des Vaults).
  static Future<void> remove(String path) async {
    final current = await load();
    current.removeWhere((v) => v.path == path);
    await _save(current);
  }

  static Future<void> _save(List<RecentVault> vaults) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = vaults
        .map((v) => jsonEncode(v.toJson()))
        .toList();
    await prefs.setStringList(_key, raw);
  }
}
