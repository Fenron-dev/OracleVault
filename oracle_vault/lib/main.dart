// Datei: lib/main.dart
//
// ZWECK: App-Einstiegspunkt. Bewusst minimal — alle Initialisierungslogik
//        übernehmen Riverpod-Provider lazy beim ersten Zugriff.
// ABHÄNGIGKEITEN: flutter_riverpod, intl, app.dart
// PHASE: 0 – Grundgerüst.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized() muss vor allen Plugin-
  // oder FFI-Aufrufen beim Start stehen. Drift/SQLite nutzt FFI.
  WidgetsFlutterBinding.ensureInitialized();

  // Lokalisierungsdaten für DateFormat('de_DE') laden.
  await initializeDateFormatting('de_DE');

  runApp(
    const ProviderScope(
      child: OracleVaultApp(),
    ),
  );
}
