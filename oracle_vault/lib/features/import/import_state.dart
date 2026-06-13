// Datei: lib/features/import/import_state.dart
//
// ZWECK: Datenmodelle für die Import-Pipeline.
//        RawCandidate = Roh-Ergebnis eines Adapters, noch nicht persistiert.
//        ImportDraft = bearbeitbarer Entwurf im Import-Screen.
//        ImportSource = Herkunftsinformation (URL, Datei, Paste).
// PHASE: 2

import 'package:flutter/foundation.dart';

// ── Herkunft ──────────────────────────────────────────────────────────────────

enum ImportSourceType { url, file, paste }

/// Herkunft des zu importierenden Inhalts.
class ImportSource {
  final ImportSourceType type;
  final String raw;        // URL-String, Dateipfad oder Paste-Text
  final String? mimeType;  // Datei-Import: z. B. 'text/csv', 'application/vnd.ms-excel'

  const ImportSource({required this.type, required this.raw, this.mimeType});

  String get displayName => switch (type) {
        ImportSourceType.url => raw,
        ImportSourceType.file => raw.split(RegExp(r'[/\\]')).last,
        ImportSourceType.paste => 'Eingefügter Text',
      };
}

// ── Roh-Eintrag aus dem Adapter ───────────────────────────────────────────────

class RawEntry {
  final String content;
  final int? rollMin;
  final int? rollMax;
  final double weight;
  final double confidence; // 0.0–1.0; < 0.7 → confidenceLow

  const RawEntry({
    required this.content,
    this.rollMin,
    this.rollMax,
    this.weight = 1.0,
    this.confidence = 1.0,
  });

  bool get confidenceLow => confidence < 0.7;
}

// ── Roh-Kandidat aus dem Adapter ─────────────────────────────────────────────

/// Ergebnis eines Adapters — noch nicht validiert oder persistiert.
class RawCandidate {
  final String name;
  final String oracleType;   // 'uniform' | 'weighted' | 'dice' | 'deck'
  final String? diceExpr;
  final List<RawEntry> entries;
  final String language;
  final double overallConfidence;
  final String sourceText;   // Quelltext für die linke Pane im Import-Screen

  // Source-Metadaten (auto-erkannt):
  final String? sourceTitle;
  final String? sourceAuthor;
  final String? sourceUrl;
  final String? sourceDate;

  /// Optionaler Pfad zu einem Bild das in der Quellpane angezeigt wird
  /// (Bild-Import via Datei oder Zwischenablage; Temp-Datei für Clipboard).
  final String? sourceImagePath;

  const RawCandidate({
    required this.name,
    this.oracleType = 'uniform',
    this.diceExpr,
    required this.entries,
    this.language = 'de',
    this.overallConfidence = 1.0,
    this.sourceText = '',
    this.sourceTitle,
    this.sourceAuthor,
    this.sourceUrl,
    this.sourceDate,
    this.sourceImagePath,
  });

  int get uncertainCount =>
      entries.where((e) => e.confidenceLow).length;
}

// ── Bearbeitbarer Import-Entwurf ──────────────────────────────────────────────

/// Mutabler Entwurf im Import-Screen (wird nach dem Parsen befüllt und
/// kann vom Nutzer bearbeitet werden).
class ImportDraft {
  String name;
  String? description;
  String oracleType;
  String? diceExpr;
  String language;
  List<RawEntry> entries;
  String sourceTitle;
  String sourceAuthor;
  String sourceUrl;
  String? sourceDate;
  String? license;
  String? genre;
  String? theme;
  String? category;
  List<String> tags;

  ImportDraft({
    required this.name,
    this.description,
    required this.oracleType,
    this.diceExpr,
    required this.language,
    required this.entries,
    this.sourceTitle = '',
    this.sourceAuthor = '',
    this.sourceUrl = '',
    this.sourceDate,
    this.license,
    this.genre,
    this.theme,
    this.category,
    List<String>? tags,
  }) : tags = tags ?? [];

  factory ImportDraft.fromCandidate(RawCandidate c) => ImportDraft(
        name: c.name,
        oracleType: c.oracleType,
        diceExpr: c.diceExpr,
        language: c.language,
        entries: List.from(c.entries),
        sourceTitle: c.sourceTitle ?? '',
        sourceAuthor: c.sourceAuthor ?? '',
        sourceUrl: c.sourceUrl ?? '',
        sourceDate: c.sourceDate,
      );

  ImportDraft copyWith({
    String? name,
    Object? description = _keep,
    String? oracleType,
    String? diceExpr,
    String? language,
    List<RawEntry>? entries,
    String? sourceTitle,
    String? sourceAuthor,
    String? sourceUrl,
    String? sourceDate,
    String? license,
    String? genre,
    String? theme,
    String? category,
    List<String>? tags,
  }) =>
      ImportDraft(
        name: name ?? this.name,
        description: identical(description, _keep)
            ? this.description
            : description as String?,
        oracleType: oracleType ?? this.oracleType,
        diceExpr: diceExpr ?? this.diceExpr,
        language: language ?? this.language,
        entries: entries ?? this.entries,
        sourceTitle: sourceTitle ?? this.sourceTitle,
        sourceAuthor: sourceAuthor ?? this.sourceAuthor,
        sourceUrl: sourceUrl ?? this.sourceUrl,
        sourceDate: sourceDate ?? this.sourceDate,
        license: license ?? this.license,
        genre: genre ?? this.genre,
        theme: theme ?? this.theme,
        category: category ?? this.category,
        tags: tags ?? this.tags,
      );
}

// ── Import-Status ─────────────────────────────────────────────────────────────

enum ImportStatus { idle, loading, ready, saving, error }

/// Gesamtzustand des Import-Screens.
@immutable
class ImportScreenState {
  final ImportStatus status;
  final ImportSource? source;
  final RawCandidate? candidate;       // Ergebnis des Adapters (unveränderlich)
  final ImportDraft? draft;            // Bearbeitbarer Entwurf
  final String? errorMessage;
  final bool saveAndContinue;          // „Weitere URL importieren" Checkbox
  final bool saveAndOpen;              // „Sofort öffnen" Checkbox

  // KI-Status
  final bool isAiProcessing;           // Normalisierung/Tagging läuft
  final bool aiNormalizationDone;      // Normalisierung abgeschlossen
  final String? aiError;               // Letzter KI-Fehler

  const ImportScreenState({
    this.status = ImportStatus.idle,
    this.source,
    this.candidate,
    this.draft,
    this.errorMessage,
    this.saveAndContinue = true,
    this.saveAndOpen = false,
    this.isAiProcessing = false,
    this.aiNormalizationDone = false,
    this.aiError,
  });

  ImportScreenState copyWith({
    ImportStatus? status,
    ImportSource? source,
    RawCandidate? candidate,
    ImportDraft? draft,
    String? errorMessage,
    bool? saveAndContinue,
    bool? saveAndOpen,
    bool? isAiProcessing,
    bool? aiNormalizationDone,
    // null = beibehalten, leerer String = löschen
    Object? aiError = _keep,
  }) =>
      ImportScreenState(
        status: status ?? this.status,
        source: source ?? this.source,
        candidate: candidate ?? this.candidate,
        draft: draft ?? this.draft,
        errorMessage: errorMessage ?? this.errorMessage,
        saveAndContinue: saveAndContinue ?? this.saveAndContinue,
        saveAndOpen: saveAndOpen ?? this.saveAndOpen,
        isAiProcessing: isAiProcessing ?? this.isAiProcessing,
        aiNormalizationDone: aiNormalizationDone ?? this.aiNormalizationDone,
        aiError: identical(aiError, _keep)
            ? this.aiError
            : aiError as String?,
      );
}

const _keep = Object();
