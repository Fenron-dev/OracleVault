// Datei: lib/features/import/import_controller.dart
//
// ZWECK: Riverpod-Notifier der den gesamten Import-Ablauf steuert.
//        Orchestriert Adapter-Auswahl, State-Übergänge und DB-Commit.
//
// ABLAUF:
//   loadSource(source) → wählt Adapter → parse() → draft befüllen → status=ready
//   updateDraft(fn)    → Nutzer bearbeitet Felder/Einträge
//   save()             → Tabelle + Einträge in DB schreiben, Source anlegen
// PHASE: 2

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:uuid/uuid.dart';

import '../../data/db/vault_database.dart';
import '../../features/library/library_providers.dart';
import '../../services/llm/llm_profiles_store.dart';
import '../../services/llm/llm_service.dart';
import '../../services/llm/llm_tasks.dart';
import 'adapters/csv_adapter.dart';
import 'adapters/epub_adapter.dart';
import 'adapters/image_adapter.dart';
import 'adapters/import_adapter.dart';
import 'adapters/pdf_adapter.dart';
import 'adapters/text_adapter.dart';
import 'adapters/url_adapter.dart';
import 'import_state.dart';

const _uuid = Uuid();

// ── Provider ──────────────────────────────────────────────────────────────────

final importControllerProvider =
    NotifierProvider<ImportController, ImportScreenState>(
        ImportController.new);

// ── Controller ────────────────────────────────────────────────────────────────

class ImportController extends Notifier<ImportScreenState> {
  @override
  ImportScreenState build() => const ImportScreenState();

  final List<ImportAdapter> _adapters = [
    CsvAdapter(),
    PdfAdapter(),   // vor TextAdapter: PDF hat eigene Textextraktion
    EpubAdapter(),  // vor TextAdapter: ePub hat eigenes HTML-Parsing
    ImageAdapter(), // vor TextAdapter: Bilder → OCR
    UrlAdapter(),
    TextAdapter(), // TextAdapter ist der allgemeine Fallback
  ];

  // ── Quelle laden + parsen ──────────────────────────────────────────────────

  Future<void> loadSource(ImportSource source) async {
    state = state.copyWith(
      status: ImportStatus.loading,
      source: source,
      errorMessage: null,
    );

    try {
      final adapter = _adapters.firstWhere(
        (a) => a.canHandle(source),
        orElse: () => TextAdapter(),
      );

      final candidate = await adapter.parse(source);
      final draft = ImportDraft.fromCandidate(candidate);

      state = state.copyWith(
        status: ImportStatus.ready,
        candidate: candidate,
        draft: draft,
      );
    } on ImportParseException catch (e) {
      state = state.copyWith(
        status: ImportStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: ImportStatus.error,
        errorMessage: 'Unbekannter Fehler: $e',
      );
    }
  }

  // ── Draft aktualisieren ────────────────────────────────────────────────────

  void updateDraft(ImportDraft Function(ImportDraft) fn) {
    final current = state.draft;
    if (current == null) return;
    state = state.copyWith(draft: fn(current));
  }

  void updateEntry(int index, RawEntry updated) {
    final draft = state.draft;
    if (draft == null) return;
    final entries = List<RawEntry>.from(draft.entries);
    if (index < 0 || index >= entries.length) return;
    entries[index] = updated;
    state = state.copyWith(draft: draft.copyWith(entries: entries));
  }

  void deleteEntry(int index) {
    final draft = state.draft;
    if (draft == null) return;
    final entries = List<RawEntry>.from(draft.entries)..removeAt(index);
    state = state.copyWith(draft: draft.copyWith(entries: entries));
  }

  void addEntry(RawEntry entry) {
    final draft = state.draft;
    if (draft == null) return;
    state = state.copyWith(
        draft: draft.copyWith(entries: [...draft.entries, entry]));
  }

  void toggleSaveAndContinue(bool v) =>
      state = state.copyWith(saveAndContinue: v);
  void toggleSaveAndOpen(bool v) =>
      state = state.copyWith(saveAndOpen: v);

  // ── Speichern ──────────────────────────────────────────────────────────────

  /// Schreibt Tabelle + Einträge in die DB.
  /// Gibt die neue TableId zurück.
  Future<String?> save() async {
    final draft = state.draft;
    if (draft == null) return null;
    final db = ref.read(vaultDbProvider);
    if (db == null) return null;

    state = state.copyWith(status: ImportStatus.saving);

    try {
      final now = DateTime.now();
      final tableId = _uuid.v4();

      // ── Source anlegen ─────────────────────────────────────────────
      String? sourceId;
      final rawSource = state.source?.raw ?? '';
      final isAiGenerated = rawSource.startsWith('ai:');

      if (isAiGenerated) {
        // KI-generierte Tabelle → Source mit ai_generation-Typ + Profil-Info.
        final profileId = rawSource.substring(3);
        final profile = ref
            .read(llmProfilesProvider)
            .profiles
            .where((p) => p.id == profileId)
            .firstOrNull;
        sourceId = _uuid.v4();
        await db.sourceDao.insertSource(SourcesCompanion(
          id: Value(sourceId),
          type: const Value('ai_generation'),
          title: Value(draft.sourceTitle.isEmpty ? null : draft.sourceTitle),
          aiProviderJson: Value(profile != null
              ? jsonEncode({
                  'provider': profile.kind.name,
                  'model': profile.defaultModel,
                  'base_url': profile.baseUrl,
                  'generated_at': now.toIso8601String(),
                })
              : null),
          createdAt: Value(now),
        ));
      } else if (draft.sourceUrl.isNotEmpty || draft.sourceTitle.isNotEmpty) {
        sourceId = _uuid.v4();
        await db.sourceDao.insertSource(SourcesCompanion(
          id: Value(sourceId),
          type: Value(_detectSourceType(draft.sourceUrl)),
          title: Value(
              draft.sourceTitle.isEmpty ? null : draft.sourceTitle),
          author: Value(
              draft.sourceAuthor.isEmpty ? null : draft.sourceAuthor),
          url: Value(draft.sourceUrl.isEmpty ? null : draft.sourceUrl),
          license: Value(draft.license),
          createdAt: Value(now),
        ));
      }

      // ── Tabelle anlegen ─────────────────────────────────────────────
      await db.tableDao.insertTable(OracleTablesCompanion(
        id: Value(tableId),
        name: Value(draft.name.trim()),
        description: Value(draft.description?.trim().isEmpty == true
            ? null
            : draft.description?.trim()),
        oracleType: Value(draft.oracleType),
        diceExpr: Value(draft.diceExpr),
        language: Value(draft.language),
        genre: Value(draft.genre),
        theme: Value(draft.theme),
        sourceId: Value(sourceId),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      // ── Einträge anlegen ────────────────────────────────────────────
      final validEntries = draft.entries
          .where((e) => e.content.trim().isNotEmpty)
          .toList();

      final entryCompanions = validEntries
          .asMap()
          .entries
          .map((e) => EntriesCompanion(
                id: Value(_uuid.v4()),
                tableId: Value(tableId),
                position: Value(e.key),
                content: Value(e.value.content.trim()),
                weight: Value(e.value.weight),
                rollMin: Value(e.value.rollMin),
                rollMax: Value(e.value.rollMax),
                confidenceLow: Value(e.value.confidenceLow),
              ))
          .toList();

      await db.entryDao.replaceAll(tableId, entryCompanions);

      // ── Tags anlegen ────────────────────────────────────────────────
      if (draft.tags.isNotEmpty) {
        final tagIds = <String>[];
        for (final tagName in draft.tags) {
          final tag = await db.tagDao.findOrCreate(tagName, _uuid.v4());
          tagIds.add(tag.id);
        }
        await db.tableDao.setTagsFor(tableId, tagIds);
      }

      // Selektion auf neue Tabelle setzen.
      ref.read(selectedTableIdProvider.notifier).state = tableId;

      state = const ImportScreenState(); // zurücksetzen
      return tableId;
    } catch (e) {
      state = state.copyWith(
        status: ImportStatus.error,
        errorMessage: 'Fehler beim Speichern: $e',
      );
      return null;
    }
  }

  // ── Multi-Tabellen-Extraktion ─────────────────────────────────────────────

  /// Erkennt mehrere Tabellen im aktuellen Quelltext:
  ///   1. Muster-Erkennung via TextAdapter.splitByHeaders (kein LLM)
  ///   2. LLM-Fallback wenn Muster < 2 Tabellen liefert
  /// Gibt eine leere Liste zurück wenn keine Tabellen erkannt werden.
  Future<List<RawCandidate>> extractMultipleTables() async {
    final sourceText = state.candidate?.sourceText ?? '';
    if (sourceText.trim().isEmpty) return [];

    // Schritt 1: Muster-Erkennung
    final patternTables = await TextAdapter.splitByHeaders(sourceText);
    if (patternTables.length >= 2) return patternTables;

    // Schritt 2: LLM-Fallback
    final profilesState = ref.read(llmProfilesProvider);
    if (!profilesState.aiEnabled || profilesState.profiles.isEmpty) return [];
    final profile = profilesState.profileForTask(LlmTask.parsing)
        ?? profilesState.profiles.first;

    state = state.copyWith(isAiProcessing: true, aiError: null as Object?);
    try {
      final apiKey = await ref
          .read(llmProfilesProvider.notifier)
          .loadApiKey(profile.id);
      final service = LlmService(profile: profile, apiKey: apiKey);
      final tasks = LlmTasks(service);
      final aiTables = await tasks.extractMultipleTables(text: sourceText);

      final language = detectLanguage(sourceText);
      return aiTables
          .map((t) => RawCandidate(
                name: t.name,
                entries: t.entries
                    .map((e) => RawEntry(content: e))
                    .toList(),
                language: language,
                oracleType: 'uniform',
                overallConfidence: 0.75,
                sourceText: t.entries.join('\n'),
              ))
          .toList();
    } on LlmException catch (e) {
      state = state.copyWith(aiError: e.message);
      return [];
    } catch (e) {
      state = state.copyWith(aiError: 'Fehler: $e');
      return [];
    } finally {
      state = state.copyWith(isAiProcessing: false);
    }
  }

  /// Speichert mehrere Tabellen auf einmal (aus Multi-Tabellen-Erkennung).
  /// Gibt die Anzahl erfolgreich gespeicherter Tabellen zurück.
  Future<int> saveMultiple(List<RawCandidate> candidates) async {
    final db = ref.read(vaultDbProvider);
    if (db == null || candidates.isEmpty) return 0;

    final draft = state.draft;
    final now = DateTime.now();
    int saved = 0;

    // Gemeinsame Source für alle Tabellen (aus aktuellem Draft)
    String? sourceId;
    if (draft != null &&
        (draft.sourceUrl.isNotEmpty || draft.sourceTitle.isNotEmpty)) {
      sourceId = _uuid.v4();
      await db.sourceDao.insertSource(SourcesCompanion(
        id: Value(sourceId),
        type: Value(_detectSourceType(draft.sourceUrl)),
        title: Value(draft.sourceTitle.isEmpty ? null : draft.sourceTitle),
        author: Value(draft.sourceAuthor.isEmpty ? null : draft.sourceAuthor),
        url: Value(draft.sourceUrl.isEmpty ? null : draft.sourceUrl),
        createdAt: Value(now),
      ));
    }

    final tableIds = <String>[];

    for (final candidate in candidates) {
      try {
        final tableId = _uuid.v4();
        await db.tableDao.insertTable(OracleTablesCompanion(
          id: Value(tableId),
          name: Value(candidate.name.trim()),
          oracleType: Value(candidate.oracleType),
          language: Value(candidate.language),
          sourceId: Value(sourceId),
          createdAt: Value(now),
          updatedAt: Value(now),
        ));

        final companions = candidate.entries
            .where((e) => e.content.trim().isNotEmpty)
            .toList()
            .asMap()
            .entries
            .map((e) => EntriesCompanion(
                  id: Value(_uuid.v4()),
                  tableId: Value(tableId),
                  position: Value(e.key),
                  content: Value(e.value.content.trim()),
                  weight: Value(e.value.weight),
                  rollMin: Value(e.value.rollMin),
                  rollMax: Value(e.value.rollMax),
                ))
            .toList();
        await db.entryDao.replaceAll(tableId, companions);
        tableIds.add(tableId);
        saved++;
      } catch (_) {}
    }

    // Alle importierten Tabellen als Collection verknüpfen.
    if (tableIds.length >= 2) {
      final collectionName = draft?.sourceTitle.isNotEmpty == true
          ? draft!.sourceTitle
          : 'Import ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final collectionId = await db.collectionDao.createCollection(
        name: collectionName,
        type: 'supplement',
      );
      await db.collectionDao.addTables(collectionId, tableIds);
    }

    return saved;
  }

  // ── KI-Normalisierung ─────────────────────────────────────────────────────

  /// Bereinigt Einträge mit KI (Tippfehler, Nummerierungen, Konfidenz-Score).
  /// Verarbeitet in 30er-Batches damit der Kontext des Modells nicht überläuft.
  Future<void> normalizeWithAi() async {
    final draft = state.draft;
    if (draft == null || state.isAiProcessing) return;

    final profilesState = ref.read(llmProfilesProvider);
    if (!profilesState.aiEnabled) {
      state = state.copyWith(aiError: 'KI ist in den Einstellungen deaktiviert.');
      return;
    }
    final profile = profilesState.profileForTask(LlmTask.parsing);
    if (profile == null) {
      state = state.copyWith(
          aiError: 'Kein KI-Profil konfiguriert (Einstellungen → KI).');
      return;
    }

    state = state.copyWith(
        isAiProcessing: true, aiError: null as Object?);

    try {
      final apiKey = await ref
          .read(llmProfilesProvider.notifier)
          .loadApiKey(profile.id);
      final service = LlmService(profile: profile, apiKey: apiKey);
      final tasks = LlmTasks(service);

      const batchSize = 30;
      final entries = draft.entries.toList();
      final normalized = <RawEntry>[];

      for (int i = 0; i < entries.length; i += batchSize) {
        final batch = entries.sublist(
            i, (i + batchSize).clamp(0, entries.length));
        final rawTexts = batch.map((e) => e.content).toList();

        final result = await tasks.normalizeEntries(
          rawEntries: rawTexts,
          language: draft.language,
        );

        for (int j = 0; j < batch.length; j++) {
          final original = batch[j];
          if (j < result.length && result[j].content.isNotEmpty) {
            normalized.add(RawEntry(
              content: result[j].content,
              rollMin: original.rollMin,
              rollMax: original.rollMax,
              weight: original.weight,
              confidence: result[j].confidence,
            ));
          } else {
            normalized.add(original);
          }
        }
      }

      state = state.copyWith(
        draft: draft.copyWith(entries: normalized),
        isAiProcessing: false,
        aiNormalizationDone: true,
      );
    } on LlmException catch (e) {
      state = state.copyWith(isAiProcessing: false, aiError: e.message);
    } catch (e) {
      state = state.copyWith(
          isAiProcessing: false, aiError: 'Fehler: $e');
    }
  }

  // ── KI-Tag-Vorschlag ──────────────────────────────────────────────────────

  /// Schlägt Tags, Genre und Thema via KI vor und schreibt sie in den Draft.
  Future<void> suggestTagsWithAi() async {
    final draft = state.draft;
    if (draft == null || state.isAiProcessing) return;

    final profilesState = ref.read(llmProfilesProvider);
    if (!profilesState.aiEnabled) {
      state = state.copyWith(aiError: 'KI ist in den Einstellungen deaktiviert.');
      return;
    }
    final profile = profilesState.profileForTask(LlmTask.tagging);
    if (profile == null) {
      state = state.copyWith(
          aiError: 'Kein KI-Profil konfiguriert (Einstellungen → KI).');
      return;
    }

    state = state.copyWith(
        isAiProcessing: true, aiError: null as Object?);

    try {
      final apiKey = await ref
          .read(llmProfilesProvider.notifier)
          .loadApiKey(profile.id);
      final service = LlmService(profile: profile, apiKey: apiKey);
      final tasks = LlmTasks(service);

      final suggestions = await tasks.suggestTagsAndGenre(
        tableName: draft.name,
        sampleEntries: draft.entries.take(15).map((e) => e.content).toList(),
        language: draft.language,
      );

      state = state.copyWith(
        draft: draft.copyWith(
          tags: suggestions.tags.isNotEmpty ? suggestions.tags : draft.tags,
          genre: suggestions.genre?.isNotEmpty == true
              ? suggestions.genre
              : draft.genre,
          theme: suggestions.theme?.isNotEmpty == true
              ? suggestions.theme
              : draft.theme,
        ),
        isAiProcessing: false,
      );
    } on LlmException catch (e) {
      state = state.copyWith(isAiProcessing: false, aiError: e.message);
    } catch (e) {
      state = state.copyWith(
          isAiProcessing: false, aiError: 'Fehler: $e');
    }
  }

  // ── KI-Übersetzung ────────────────────────────────────────────────────────

  /// Übersetzt alle Einträge in [targetLanguage] und aktualisiert den Draft.
  Future<void> translateWithAi(String targetLanguage) async {
    final draft = state.draft;
    if (draft == null || state.isAiProcessing) return;

    final profilesState = ref.read(llmProfilesProvider);
    if (!profilesState.aiEnabled) {
      state = state.copyWith(aiError: 'KI ist deaktiviert.');
      return;
    }
    final profile = profilesState.profileForTask(LlmTask.translation);
    if (profile == null) {
      state = state.copyWith(aiError: 'Kein KI-Profil (Einstellungen → KI).');
      return;
    }

    state = state.copyWith(isAiProcessing: true, aiError: null as Object?);

    try {
      final apiKey = await ref
          .read(llmProfilesProvider.notifier)
          .loadApiKey(profile.id);
      final service = LlmService(profile: profile, apiKey: apiKey);
      final tasks = LlmTasks(service);

      const batchSize = 50;
      final entries = draft.entries.toList();
      final translated = <RawEntry>[];

      for (int i = 0; i < entries.length; i += batchSize) {
        final batch =
            entries.sublist(i, (i + batchSize).clamp(0, entries.length));
        final texts = await tasks.translateEntries(
          entries: batch.map((e) => e.content).toList(),
          targetLanguage: targetLanguage,
          tableContext: draft.name,
        );
        for (int j = 0; j < batch.length; j++) {
          final original = batch[j];
          translated.add(RawEntry(
            content: j < texts.length && texts[j].isNotEmpty
                ? texts[j]
                : original.content,
            rollMin: original.rollMin,
            rollMax: original.rollMax,
            weight: original.weight,
            confidence: original.confidence,
          ));
        }
      }

      state = state.copyWith(
        draft: draft.copyWith(entries: translated, language: targetLanguage),
        isAiProcessing: false,
      );
    } on LlmException catch (e) {
      state = state.copyWith(isAiProcessing: false, aiError: e.message);
    } catch (e) {
      state = state.copyWith(isAiProcessing: false, aiError: 'Fehler: $e');
    }
  }

  // ── KI-Tabellen-Anreicherung ──────────────────────────────────────────────

  /// Füllt Titel, Beschreibung, Genre und Thema via KI.
  Future<void> enrichWithAi() async {
    final draft = state.draft;
    if (draft == null || state.isAiProcessing) return;

    final profilesState = ref.read(llmProfilesProvider);
    if (!profilesState.aiEnabled) {
      state = state.copyWith(aiError: 'KI ist deaktiviert.');
      return;
    }
    final profile = profilesState.profileForTask(LlmTask.tagging);
    if (profile == null) {
      state = state.copyWith(aiError: 'Kein KI-Profil (Einstellungen → KI).');
      return;
    }

    state = state.copyWith(isAiProcessing: true, aiError: null as Object?);

    try {
      final apiKey = await ref
          .read(llmProfilesProvider.notifier)
          .loadApiKey(profile.id);
      final service = LlmService(profile: profile, apiKey: apiKey);
      final tasks = LlmTasks(service);

      final enrichment = await tasks.enrichTable(
        currentName: draft.name,
        sampleEntries:
            draft.entries.take(15).map((e) => e.content).toList(),
        language: draft.language,
      );

      state = state.copyWith(
        draft: draft.copyWith(
          name: enrichment.name?.isNotEmpty == true
              ? enrichment.name
              : draft.name,
          description: enrichment.description?.isNotEmpty == true
              ? enrichment.description
              : draft.description,
          tags: enrichment.tags.isNotEmpty ? enrichment.tags : draft.tags,
          genre: enrichment.genre?.isNotEmpty == true
              ? enrichment.genre
              : draft.genre,
          theme: enrichment.theme?.isNotEmpty == true
              ? enrichment.theme
              : draft.theme,
        ),
        isAiProcessing: false,
      );
    } on LlmException catch (e) {
      state = state.copyWith(isAiProcessing: false, aiError: e.message);
    } catch (e) {
      state = state.copyWith(isAiProcessing: false, aiError: 'Fehler: $e');
    }
  }

  // ── Zwischenablage-Bild laden ─────────────────────────────────────────────

  /// Prüft ob die Zwischenablage ein Bild enthält und startet den Import.
  /// Gibt [true] zurück wenn ein Bild gefunden wurde, [false] sonst.
  Future<bool> loadImageFromClipboard() async {
    final bytes = await Pasteboard.image;
    if (bytes == null || bytes.isEmpty) return false;

    // Bild als temporäre Datei ablegen → ImageAdapter aufrufen.
    final tmp = await getTemporaryDirectory();
    final tempPath =
        '${tmp.path}/oracle_clipboard_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(tempPath).writeAsBytes(bytes);

    await loadSource(ImportSource(
      type: ImportSourceType.file,
      raw: tempPath,
      mimeType: 'image/png',
    ));
    return true;
  }

  // ── Vom AI-Generator befüllen ─────────────────────────────────────────────

  void setFromAiGeneration({
    required RawCandidate candidate,
    required ImportDraft draft,
    required ImportSource source,
  }) {
    state = ImportScreenState(
      status: ImportStatus.ready,
      source: source,
      candidate: candidate,
      draft: draft,
    );
  }

  // ── Reset ──────────────────────────────────────────────────────────────────

  void reset() => state = const ImportScreenState();

  // ── Hilfsmethoden ─────────────────────────────────────────────────────────

  String _detectSourceType(String url) {
    if (url.contains('reddit.com')) return 'reddit';
    if (url.contains('rss') || url.endsWith('.xml')) return 'rss';
    if (url.startsWith('http')) return 'url';
    return 'manual';
  }
}
