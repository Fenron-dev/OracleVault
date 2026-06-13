// Datei: lib/data/db/tables/media_files.dart
//
// ZWECK: Datei-Assets (Bilder, Audio, Video, Dokumente).
//        Dateiname 'media_files' statt 'media', weil 'Media' im Dart-Kern
//        als Bezeichner reserviert ist.
// ABHÄNGIGKEITEN: drift
// PHASE: 0 – Grundschema (Tabelle angelegt, Nutzung ab Phase 4).

import 'package:drift/drift.dart';

/// Ein Datei-Asset im Vault.
///
/// [filePath] ist relativ zum Vault-Wurzelordner, z. B. 'media/images/map01.png'.
/// [hash] (SHA-256) dient der Dublettenerkennung beim Import.
/// [metadataJson] speichert format-spezifische Felder, z. B.:
///   Bild: {width, height}
///   Audio/Video: {duration_ms}
///   Battlemap: {grid_size, scale, setting}
class MediaFiles extends Table {
  TextColumn get id => text()();

  /// Typ des Assets: 'image' | 'audio' | 'video' | 'document'
  TextColumn get type => text()();

  /// Pfad relativ zum Vault-Ordner, z. B. 'media/images/foo.png'.
  TextColumn get filePath => text()();

  TextColumn get mime => text().nullable()();

  /// SHA-256-Hash des Dateiinhalts zur Dublettenerkennung.
  TextColumn get hash => text()();

  TextColumn get title => text().nullable()();

  /// Format-spezifische Metadaten als JSON.
  TextColumn get metadataJson => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
