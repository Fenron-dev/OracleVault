// Datei: lib/features/tables/translation_screen.dart
//
// ZWECK: Side-by-Side Übersetzungsmaske für eine Oracle-Tabelle.
//
// LAYOUT:
//   AppBar:  Tabellenname | Zielsprache-Picker | KI-Übersetzen | Speichern
//   Body:    Row(
//              Left:  Original-Einträge (read-only, scrollt synchron)
//              │
//              Right: Übersetzungs-Felder (editierbar)
//            )
//
// SPEICHERN: Erstellt eine neue Tabelle mit den übersetzten Einträgen und
//            verknüpft sie mit der Original-Tabelle via
//            Edge(relation='translation_of').
// PHASE: 3

import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme.dart';
import '../../data/db/vault_database.dart';
import '../../services/llm/llm_profiles_store.dart';
import '../../services/llm/llm_service.dart';
import '../../services/llm/llm_tasks.dart';
import '../library/library_providers.dart';

const _uuid = Uuid();

// ── Labels ────────────────────────────────────────────────────────────────────

const _kLanguages = {
  'de': 'Deutsch',
  'en': 'Englisch',
  'fr': 'Französisch',
  'es': 'Spanisch',
  'it': 'Italienisch',
  'pt': 'Portugiesisch',
  'nl': 'Niederländisch',
  'pl': 'Polnisch',
  'ja': 'Japanisch',
};

String _langLabel(String code) => _kLanguages[code] ?? code.toUpperCase();

// ── Screen ────────────────────────────────────────────────────────────────────

class TranslationScreen extends ConsumerStatefulWidget {
  final String tableId;
  const TranslationScreen({super.key, required this.tableId});

  @override
  ConsumerState<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends ConsumerState<TranslationScreen> {
  OracleTable? _table;
  List<Entry> _sourceEntries = [];

  String _targetLanguage = 'de';
  final List<TextEditingController> _controllers = [];
  // Set of indices whose controller has a REAL translation (differs from original)
  final Set<int> _translated = {};
  // Set of indices currently being processed
  final Set<int> _inProgress = {};

  final _scrollController = ScrollController();

  bool _loading = false;
  bool _aiRunning = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final db = ref.read(vaultDbProvider);
      if (db == null) return;

      final table = await db.tableDao.fetchById(widget.tableId);
      if (table == null) return;

      final entries = await db.entryDao.fetchForTable(widget.tableId);

      // Zielsprache: erste andere Sprache als die Quellsprache wählen
      final sourceLang = table.language;
      _targetLanguage = sourceLang == 'de' ? 'en' : 'de';

      _controllers.clear();
      for (final _ in entries) {
        _controllers.add(TextEditingController());
      }

      setState(() {
        _table = table;
        _sourceEntries = entries;
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; _error = 'Fehler: $e'; });
    }
  }

  // ── KI-Übersetzung ─────────────────────────────────────────────────────────

  Future<void> _translateWithAi() async {
    if (_aiRunning || _sourceEntries.isEmpty) return;

    final profiles = ref.read(llmProfilesProvider);
    if (!profiles.aiEnabled || profiles.profiles.isEmpty) {
      setState(() => _error = 'Kein KI-Profil konfiguriert (Einstellungen → KI).');
      return;
    }
    final profile = profiles.profileForTask(LlmTask.translation);
    if (profile == null) {
      setState(() => _error = 'Kein Übersetzungs-Profil konfiguriert.');
      return;
    }

    setState(() { _aiRunning = true; _error = null; });

    try {
      final apiKey = await ref
          .read(llmProfilesProvider.notifier)
          .loadApiKey(profile.id);
      final service = LlmService(profile: profile, apiKey: apiKey);
      final tasks = LlmTasks(service);

      // Kleine Batches (10): LLM-Modelle produzieren für große Batches
      // schlechtere Ergebnisse und brechen häufiger ab.
      const batchSize = 10;
      final allTexts = _sourceEntries.map((e) => e.content).toList();
      int failedBatches = 0;

      for (int i = 0; i < allTexts.length; i += batchSize) {
        if (!mounted) break;
        final batchEnd = (i + batchSize).clamp(0, allTexts.length);
        final batchIndices = List.generate(batchEnd - i, (j) => i + j);
        final batch = batchIndices.map((idx) => allTexts[idx]).toList();

        // In-Progress markieren
        if (mounted) setState(() => _inProgress.addAll(batchIndices));

        try {
          final translated = await tasks.translateEntries(
            entries: batch,
            targetLanguage: _targetLanguage,
            tableContext: _table?.name,
          );

          if (!mounted) break;
          setState(() {
            for (int j = 0; j < batch.length; j++) {
              final idx = i + j;
              if (idx >= _controllers.length) continue;
              final original = batch[j];
              final translation = j < translated.length ? translated[j] : '';
              // Nur als "übersetzt" markieren wenn Text sich tatsächlich unterscheidet
              if (translation.isNotEmpty && translation != original) {
                _controllers[idx].text = translation;
                _translated.add(idx);
              }
              // Original-Text NICHT in Controller schreiben (bleibt leer → klar sichtbar)
            }
            _inProgress.removeAll(batchIndices);
          });
        } catch (e) {
          failedBatches++;
          if (mounted) {
            setState(() {
              _inProgress.removeAll(batchIndices);
              // Ersten Batch-Fehler als Hinweis anzeigen
              if (failedBatches == 1) {
                final hint = e is LlmException ? e.message : e.toString();
                _error = 'Batch fehlgeschlagen: ${hint.substring(0, 120.clamp(0, hint.length))}…';
              }
            });
          }
        }
      }

      if (failedBatches > 0 && mounted) {
        setState(() => _error =
            '$failedBatches von ${(allTexts.length / batchSize).ceil()} '
            'Batch${failedBatches == 1 ? '' : 'es'} fehlgeschlagen '
            '(häufige Ursache: Output-Token-Limit des Modells). '
            'Fehlende Felder können manuell befüllt werden.');
      }
    } on LlmException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Fehler: $e');
    } finally {
      if (mounted) setState(() { _aiRunning = false; _inProgress.clear(); });
    }
  }

  // ── Speichern ──────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_table == null) return;
    setState(() { _loading = true; _error = null; });

    try {
      final db = ref.read(vaultDbProvider);
      if (db == null) return;

      final now = DateTime.now();
      final newTableId = _uuid.v4();
      final sourceLang = _table!.language;
      final newName =
          '${_table!.name} [${_langLabel(_targetLanguage)}]';

      // ── Neue Tabelle anlegen ─────────────────────────────────────────────
      await db.tableDao.insertTable(OracleTablesCompanion(
        id: Value(newTableId),
        name: Value(newName),
        description: Value(_table!.description),
        oracleType: Value(_table!.oracleType),
        diceExpr: Value(_table!.diceExpr),
        language: Value(_targetLanguage),
        genre: Value(_table!.genre),
        theme: Value(_table!.theme),
        createdAt: Value(now),
        updatedAt: Value(now),
      ));

      // ── Übersetzte Einträge anlegen ──────────────────────────────────────
      final companions = <EntriesCompanion>[];
      for (int i = 0; i < _sourceEntries.length; i++) {
        final src = _sourceEntries[i];
        final text = i < _controllers.length
            ? _controllers[i].text.trim()
            : src.content;
        if (text.isEmpty) continue;
        companions.add(EntriesCompanion(
          id: Value(_uuid.v4()),
          tableId: Value(newTableId),
          position: Value(i),
          content: Value(text),
          weight: Value(src.weight),
          rollMin: Value(src.rollMin),
          rollMax: Value(src.rollMax),
        ));
      }
      await db.entryDao.replaceAll(newTableId, companions);

      // ── Edge: translation_of verknüpfen ──────────────────────────────────
      await db.edgeDao.linkTranslation(
        sourceTableId: widget.tableId,
        translationTableId: newTableId,
      );

      // ── Tags übernehmen ──────────────────────────────────────────────────
      final tags = await db.tableDao.fetchTagsFor(widget.tableId);
      if (tags.isNotEmpty) {
        await db.tableDao.setTagsFor(newTableId, tags.map((t) => t.id).toList());
      }

      if (mounted) {
        // Chips im Detail-Panel sofort aktualisieren.
        ref.invalidate(translationVariantsProvider);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '„$newName" gespeichert — ${sourceLang.toUpperCase()} → ${_targetLanguage.toUpperCase()}'),
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = 'Speichern fehlgeschlagen: $e'; });
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tertiary = AppTheme.textTertiary(context);
    final borderColor = AppTheme.border(context);
    final sourceLang = _table?.language ?? '?';

    if (_loading && _table == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_table?.name ?? 'Übersetzen'),
        actions: [
          // Zielsprache
          _LanguagePicker(
            current: _targetLanguage,
            exclude: sourceLang,
            onChanged: (lang) => setState(() {
              _targetLanguage = lang;
              // Alten Inhalt verwerfen — neue Zielsprache = frischer Start.
              for (final c in _controllers) {
                c.clear();
              }
              _translated.clear();
              _error = null;
            }),
          ),
          const SizedBox(width: AppTheme.sp8),
          // KI-Übersetzen
          TextButton.icon(
            onPressed: _aiRunning ? null : _translateWithAi,
            icon: _aiRunning
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome_outlined, size: 16),
            label: Text(_aiRunning ? 'Übersetze…' : 'KI übersetzen'),
          ),
          const SizedBox(width: AppTheme.sp4),
          // Speichern
          FilledButton(
            onPressed: (_loading || _aiRunning) ? null : _save,
            child: const Text('Speichern'),
          ),
          const SizedBox(width: AppTheme.sp12),
        ],
      ),
      body: Column(
        children: [
          // ── Fehleranzeige ──────────────────────────────────────────────
          if (_error != null)
            Container(
              width: double.infinity,
              color: cs.errorContainer,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Text(_error!,
                  style: TextStyle(color: cs.onErrorContainer, fontSize: 12),
                  maxLines: 3),
            ),

          // ── Header ────────────────────────────────────────────────────
          Container(
            color: AppTheme.bgSecondary(context),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Original · ${_langLabel(sourceLang)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: tertiary),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Übersetzung · ${_langLabel(_targetLanguage)}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.primary),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),

          // ── Einträge-Liste (synchron gescrollt) ───────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _sourceEntries.length,
              itemBuilder: (ctx, i) {
                final src = _sourceEntries[i];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: borderColor, width: 0.5)),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Zeilen-Nr. ──────────────────────────────────
                        Container(
                          width: 36,
                          color: _inProgress.contains(i)
                              ? cs.primaryContainer.withValues(alpha: 0.3)
                              : AppTheme.bgSecondary(context),
                          alignment: Alignment.topCenter,
                          padding: const EdgeInsets.only(top: 10),
                          child: _inProgress.contains(i)
                              ? SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: cs.primary),
                                )
                              : Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: _translated.contains(i)
                                          ? cs.primary
                                          : tertiary),
                                ),
                        ),
                        // ── Original ────────────────────────────────────
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: SelectableText(
                              src.content,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                        VerticalDivider(width: 1, color: borderColor),
                        // ── Übersetzung ──────────────────────────────────
                        Expanded(
                          child: Container(
                            color: _inProgress.contains(i)
                                ? cs.primaryContainer.withValues(alpha: 0.08)
                                : null,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: i < _controllers.length
                                ? TextField(
                                    controller: _controllers[i],
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      isDense: true,
                                      hintText: _inProgress.contains(i)
                                          ? 'wird übersetzt…'
                                          : '— Übersetzung eingeben',
                                      hintStyle: TextStyle(
                                          color: _inProgress.contains(i)
                                              ? cs.primary
                                              : tertiary,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic),
                                    ),
                                    style: const TextStyle(fontSize: 13),
                                    onChanged: (_) {
                                      // Manuell bearbeitete Einträge tracken
                                      final idx = i;
                                      if (!_translated.contains(idx)) {
                                        setState(
                                            () => _translated.add(idx));
                                      }
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Status-Leiste ──────────────────────────────────────────────
          Container(
            color: AppTheme.bgSecondary(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Text(
                  '${_sourceEntries.length} Einträge',
                  style: TextStyle(fontSize: 11, color: tertiary),
                ),
                const SizedBox(width: 8),
                Text(
                  '·  ${_translated.length} übersetzt',
                  style: TextStyle(
                      fontSize: 11,
                      color: _translated.isEmpty ? tertiary : cs.primary),
                ),
                if (_controllers.any((c) => c.text.isNotEmpty) &&
                    _translated.length <
                        _controllers.where((c) => c.text.isNotEmpty).length)
                  Text(
                    '  ·  '
                    '${_controllers.where((c) => c.text.isNotEmpty).length - _translated.length} manuell',
                    style: TextStyle(fontSize: 11, color: tertiary),
                  ),
                if (_aiRunning) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: cs.primary),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'KI läuft… (${_inProgress.isEmpty ? '?' : _inProgress.first + 1}–'
                    '${_inProgress.isEmpty ? '?' : _inProgress.last + 1})',
                    style: TextStyle(fontSize: 11, color: cs.primary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sprach-Picker ─────────────────────────────────────────────────────────────

class _LanguagePicker extends StatelessWidget {
  final String current;
  final String exclude;
  final ValueChanged<String> onChanged;

  const _LanguagePicker({
    required this.current,
    required this.exclude,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = _kLanguages.entries
        .where((e) => e.key != exclude)
        .map((e) => PopupMenuItem<String>(
              value: e.key,
              child: Text(e.value),
            ))
        .toList();

    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder: (_) => items,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border(context)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '→ ${_langLabel(current)}',
              style: TextStyle(fontSize: 13, color: cs.onSurface),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down,
                size: 16, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
