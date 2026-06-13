// Datei: lib/features/library/widgets/table_detail_panel.dart
//
// ZWECK: Rechtes Panel nach wireframe_01_library (Preview-Modus).
//        Hintergrund: bg-secondary.
//        Inhalt: Titel + Meta-Zeile + Tags + Würfel-Button + Einträge-Preview +
//                Verlinkt-Sektion.
//        Der vollständige Detail-Screen (wireframe_03) kommt in Phase 5
//        mit Wiki-Links und Backlinks.
// PHASE: 1 – redesigned nach Mockup.

import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../data/db/vault_database.dart';
import '../../../domain/roll_engine/roll_engine.dart';
import '../../../services/llm/llm_profiles_store.dart';
import '../../../services/llm/llm_service.dart';
import '../../../services/llm/llm_tasks.dart';
import '../library_providers.dart';
import '../library_state.dart';
import 'media_thumbnail.dart';

const _kLangLabels = {
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

const _uuid = Uuid();

class TableDetailPanel extends ConsumerStatefulWidget {
  const TableDetailPanel({super.key});

  @override
  ConsumerState<TableDetailPanel> createState() =>
      _TableDetailPanelState();
}

class _TableDetailPanelState extends ConsumerState<TableDetailPanel> {
  final _rollEngine = RollEngine();
  TestRollResult? _lastRoll;
  bool _rolling = false;

  Future<void> _doRoll(
      OracleTable table, List<Entry> entries) async {
    if (entries.isEmpty) return;
    setState(() => _rolling = true);

    final rollTable = RollTable(
      id: table.id,
      name: table.name,
      oracleType: table.oracleType,
      diceExpr: table.diceExpr,
      entries: entries
          .map((e) => RollEntry(
                id: e.id,
                content: e.content,
                bodyMd: e.bodyMd,
                weight: e.weight,
                rollMin: e.rollMin,
                rollMax: e.rollMax,
                subtableId: e.subtableId,
                modifierJson: e.modifierJson,
              ))
          .toList(),
    );

    final result = await _rollEngine.rollOnce(rollTable);

    Map<String, dynamic> modifiers = {};
    if (result.entry.modifierJson != null) {
      try {
        modifiers = jsonDecode(result.entry.modifierJson!)
            as Map<String, dynamic>;
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _rolling = false;
        _lastRoll = TestRollResult(
          content: result.entry.content,
          bodyMd: result.entry.bodyMd,
          path: result.path.map((s) => s.tableName).toList(),
          modifiers: modifiers,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedTableIdProvider);
    if (selectedId == null) return _EmptyDetail();

    final tableAsync = ref.watch(selectedTableProvider);
    final entriesAsync = ref.watch(entriesForSelectedTableProvider);
    final tagsAsync = ref.watch(tagsForSelectedTableProvider);

    return tableAsync.when(
      loading: () =>
          const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Fehler: $e')),
      data: (table) {
        if (table == null) return _EmptyDetail();
        return _DetailContent(
          table: table,
          entriesAsync: entriesAsync,
          tagsAsync: tagsAsync,
          lastRoll: _lastRoll,
          rolling: _rolling,
          onRoll: () => entriesAsync
              .whenData((entries) => _doRoll(table, entries)),
        );
      },
    );
  }
}

// ── Detail-Inhalt ─────────────────────────────────────────────────────────────

class _DetailContent extends ConsumerWidget {
  final OracleTable table;
  final AsyncValue entriesAsync;
  final AsyncValue tagsAsync;
  final TestRollResult? lastRoll;
  final bool rolling;
  final VoidCallback onRoll;

  const _DetailContent({
    required this.table,
    required this.entriesAsync,
    required this.tagsAsync,
    required this.lastRoll,
    required this.rolling,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgSec = AppTheme.bgSecondary(context);
    final cs = Theme.of(context).colorScheme;
    final accentText = AppTheme.accentText(context);
    final accentBorder = AppTheme.accentBorder(context);
    final borderColor = AppTheme.border(context);
    final tertiary = AppTheme.textTertiary(context);

    return Container(
      color: bgSec,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.sp16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Titelzeile + Edit-Button ─────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    table.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Übersetzen
                InkWell(
                  onTap: () => context
                      .push('${AppRoutes.tableTranslate}/${table.id}'),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.translate,
                        size: 14, color: cs.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 2),
                // KI-Erweitern
                _ExtendAiButton(table: table, entriesAsync: entriesAsync),
                const SizedBox(width: 2),
                InkWell(
                  onTap: () =>
                      context.push('${AppRoutes.tableEdit}/${table.id}'),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.edit_outlined,
                        size: 14, color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),

            // ── Meta-Zeile ───────────────────────────────────────────
            const SizedBox(height: 3),
            Text(
              _metaLine(table),
              style: TextStyle(fontSize: 11, color: tertiary),
            ),

            // ── Sprachvarianten-Switcher ─────────────────────────────
            _TranslationChips(tableId: table.id),

            // ── Tags ─────────────────────────────────────────────────
            tagsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (tags) {
                final tagList = tags as List;
                if (tagList.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: AppTheme.sp8),
                  child: Wrap(
                    spacing: AppTheme.sp4,
                    runSpacing: AppTheme.sp4,
                    children: tagList
                        .map<Widget>((t) => _OutlineChip(label: '#${t.name}'))
                        .toList(),
                  ),
                );
              },
            ),

            // ── Collection-Zuordnung ─────────────────────────────────
            _CollectionRow(tableId: table.id),

            const SizedBox(height: AppTheme.sp12),

            // ── Würfel-Button ────────────────────────────────────────
            GestureDetector(
              onTap: rolling ? null : onRoll,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: bgSec,
                  border: Border.all(color: accentBorder),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    rolling
                        ? SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: accentText))
                        : Icon(Icons.casino_outlined,
                            size: 14, color: accentText),
                    const SizedBox(width: 6),
                    Text(
                      'Würfeln (${table.diceExpr ?? table.oracleType})',
                      style: TextStyle(
                        fontSize: 12,
                        color: accentText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Würfel-Ergebnis ──────────────────────────────────────
            if (lastRoll != null) ...[
              const SizedBox(height: AppTheme.sp8),
              _RollResultCard(result: lastRoll!),
            ],

            const SizedBox(height: AppTheme.sp12),
            Divider(height: 1, color: borderColor),
            const SizedBox(height: AppTheme.sp8),

            // ── Einträge-Vorschau ────────────────────────────────────
            Text('Vorschau',
                style:
                    TextStyle(fontSize: 10, color: tertiary)),
            const SizedBox(height: AppTheme.sp4),

            entriesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Fehler: $e'),
              data: (entries) {
                final list = entries as List;
                if (list.isEmpty) {
                  return Text('Keine Einträge',
                      style:
                          TextStyle(fontSize: 11, color: tertiary));
                }
                final preview = list.take(4).toList();
                return Column(
                  children: [
                    ...preview
                        .asMap()
                        .entries
                        .map((e) => _PreviewEntry(
                              num: e.key + 1,
                              entry: e.value,
                            )),
                    if (list.length > 4)
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 4, left: 24),
                        child: Text(
                          '… ${list.length - 4} weitere',
                          style: TextStyle(
                              fontSize: 11, color: tertiary),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _metaLine(OracleTable t) {
    final parts = <String>[];
    if (t.genre != null) parts.add(t.genre!);
    parts.add(t.language.toUpperCase());
    return parts.join(' · ');
  }
}

// ── Würfel-Ergebnis-Karte ──────────────────────────────────────────────────────

class _RollResultCard extends StatelessWidget {
  final TestRollResult result;
  const _RollResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final borderColor = AppTheme.border(context);
    final bgPrimary = Theme.of(context).colorScheme.surface;
    final tertiary = AppTheme.textTertiary(context);
    final accentText = AppTheme.accentText(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.sp12),
      decoration: BoxDecoration(
        color: bgPrimary,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            result.content,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500),
          ),
          if (result.bodyMd != null) ...[
            const SizedBox(height: 4),
            Text(result.bodyMd!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: tertiary)),
          ],
          if (result.path.length > 1) ...[
            const SizedBox(height: 4),
            Text(
              'via: ${result.path.join(' → ')}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: accentText),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Eintrags-Zeile in der Vorschau ────────────────────────────────────────────

class _PreviewEntry extends StatelessWidget {
  final int num;
  final Entry entry;
  const _PreviewEntry({required this.num, required this.entry});

  @override
  Widget build(BuildContext context) {
    final warnBg = AppTheme.warnBg(context);
    final warnBorder = AppTheme.warnBorder(context);
    final warnText = AppTheme.warnText(context);
    final tertiary = AppTheme.textTertiary(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: entry.confidenceLow
          ? BoxDecoration(
              color: warnBg,
              border:
                  Border(left: BorderSide(color: warnBorder, width: 3)),
            )
          : null,
      padding: EdgeInsets.fromLTRB(
          entry.confidenceLow ? 9 : 12, 5, 12, 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              num.toString().padLeft(2, '0'),
              style: TextStyle(
                fontSize: 11,
                color: entry.confidenceLow ? warnText : tertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              entry.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          if (entry.mediaId != null) ...[
            const SizedBox(width: 8),
            MediaThumbnail(mediaId: entry.mediaId!, size: 28),
          ],
          if (entry.confidenceLow)
            Icon(Icons.warning_amber_rounded,
                size: 12, color: warnText),
        ],
      ),
    );
  }
}

// ── OutlineChip ────────────────────────────────────────────────────────────────

class _OutlineChip extends StatelessWidget {
  final String label;
  const _OutlineChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final borderColor = AppTheme.border(context);
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, color: cs.onSurface)),
    );
  }
}

// ── KI-Erweitern-Button ───────────────────────────────────────────────────────

class _ExtendAiButton extends ConsumerStatefulWidget {
  final OracleTable table;
  final AsyncValue entriesAsync;
  const _ExtendAiButton({required this.table, required this.entriesAsync});

  @override
  ConsumerState<_ExtendAiButton> createState() => _ExtendAiButtonState();
}

class _ExtendAiButtonState extends ConsumerState<_ExtendAiButton> {
  bool _loading = false;

  Future<void> _extend() async {
    final profiles = ref.read(llmProfilesProvider);
    if (!profiles.aiEnabled || profiles.profiles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('KI-Profil einrichten (Einstellungen → KI)')));
      }
      return;
    }

    // Anzahl per Dialog abfragen.
    final count = await showDialog<int>(
      context: context,
      builder: (ctx) => _ExtendCountDialog(table: widget.table),
    );
    if (count == null || !mounted) return;

    setState(() => _loading = true);

    try {
      final profile = profiles.profileForTask(LlmTask.generation);
      if (profile == null) throw LlmException.noProfile();

      final apiKey =
          await ref.read(llmProfilesProvider.notifier).loadApiKey(profile.id);
      final service = LlmService(profile: profile, apiKey: apiKey);
      final tasks = LlmTasks(service);

      final existingEntries = (widget.entriesAsync.valueOrNull as List? ?? [])
          .map<String>((e) => (e as Entry).content)
          .toList();

      final newEntries = await tasks.extendTable(
        tableName: widget.table.name,
        existingEntries: existingEntries,
        addCount: count,
        language: widget.table.language,
      );

      if (newEntries.isEmpty) throw const LlmException('KI hat keine Einträge zurückgegeben.');

      final db = ref.read(vaultDbProvider);
      if (db == null) return;

      final startPos = existingEntries.length;
      final companions = newEntries.asMap().entries.map((e) => EntriesCompanion(
            id: Value(_uuid.v4()),
            tableId: Value(widget.table.id),
            position: Value(startPos + e.key),
            content: Value(e.value.content.trim()),
          )).toList();

      await db.entryDao.insertAll(companions);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                '${newEntries.length} Einträge hinzugefügt')));
      }
    } on LlmException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Fehler: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: _loading ? null : _extend,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: _loading
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: cs.onSurfaceVariant))
            : Icon(Icons.auto_awesome_outlined,
                size: 14, color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _ExtendCountDialog extends StatefulWidget {
  final OracleTable table;
  const _ExtendCountDialog({required this.table});

  @override
  State<_ExtendCountDialog> createState() => _ExtendCountDialogState();
}

class _ExtendCountDialogState extends State<_ExtendCountDialog> {
  int _count = 10;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Erweitern: ${widget.table.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Wie viele neue Einträge soll die KI generieren?'),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Anzahl'),
            child: DropdownButton<int>(
              value: _count,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              items: [5, 10, 20, 30, 50]
                  .map((n) =>
                      DropdownMenuItem(value: n, child: Text('$n Einträge')))
                  .toList(),
              onChanged: (v) => setState(() => _count = v ?? 10),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen')),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, _count),
          icon: const Icon(Icons.auto_awesome_outlined, size: 16),
          label: const Text('Generieren'),
        ),
      ],
    );
  }
}

// ── Sprachvarianten-Chips ─────────────────────────────────────────────────────

/// Zeigt Sprachvarianten-Chips für eine Tabelle.
/// Merkt sich die zuletzt bekannte Varianten-Liste, damit Chips beim
/// Wechsel zwischen Tabellen nicht kurz verschwinden.
class _TranslationChips extends ConsumerStatefulWidget {
  final String tableId;
  const _TranslationChips({required this.tableId});

  @override
  ConsumerState<_TranslationChips> createState() => _TranslationChipsState();
}

class _TranslationChipsState extends ConsumerState<_TranslationChips> {
  List<OracleTable> _variants = [];

  @override
  Widget build(BuildContext context) {
    // Hört auf neue Daten und cached sie — beim Laden wird die letzte
    // bekannte Liste weiter angezeigt statt die Chips verschwinden zu lassen.
    ref.listen(translationVariantsProvider, (_, next) {
      next.whenData((v) {
        if (mounted) setState(() => _variants = v);
      });
    });

    // Sofort aus Provider lesen falls bereits Daten vorhanden.
    final fresh = ref.watch(translationVariantsProvider).valueOrNull;
    final variants = fresh ?? _variants;

    if (variants.length < 2) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: variants.map((v) {
          final label = _kLangLabels[v.language] ?? v.language.toUpperCase();
          return _LangChip(
            label: label,
            selected: v.id == widget.tableId,
            onTap: () =>
                ref.read(selectedTableIdProvider.notifier).state = v.id,
          );
        }).toList(),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentBg = AppTheme.accentBg(context);
    final accentText = AppTheme.accentText(context);
    final accentBorder = AppTheme.accentBorder(context);
    final borderColor = AppTheme.border(context);

    return GestureDetector(
      onTap: selected ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: selected ? accentBg : null,
          border: Border.all(
              color: selected ? accentBorder : borderColor, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? accentText : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ── Collection-Zuordnung ──────────────────────────────────────────────────────

/// Zeigt die Collection der Tabelle als Chip (mit × zum Entfernen) oder
/// einen "+ Collection"-Button wenn die Tabelle noch nicht zugeordnet ist.
class _CollectionRow extends ConsumerWidget {
  final String tableId;
  const _CollectionRow({required this.tableId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionAsync = ref.watch(collectionOfSelectedTableProvider);

    return collectionAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (collection) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: collection != null
            ? _CollectionChip(tableId: tableId, collection: collection)
            : _AddCollectionPill(tableId: tableId),
      ),
    );
  }
}

/// Teal-Chip: Tabelle ist dieser Collection zugeordnet.
/// Tippen auf den Namen → Picker zum Wechseln.
/// Tippen auf × → Zuordnung entfernen.
class _CollectionChip extends ConsumerWidget {
  final String tableId;
  final Collection collection;
  const _CollectionChip(
      {required this.tableId, required this.collection});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentBg = AppTheme.accentBg(context);
    final accentText = AppTheme.accentText(context);
    final accentBorder = AppTheme.accentBorder(context);

    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => _CollectionPickerDialog(
          tableId: tableId,
          currentCollectionId: collection.id,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(7, 3, 4, 3),
        decoration: BoxDecoration(
          color: accentBg,
          border: Border.all(color: accentBorder),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_special_outlined,
                size: 11, color: accentText),
            const SizedBox(width: 4),
            Text(collection.name,
                style: TextStyle(fontSize: 11, color: accentText)),
            const SizedBox(width: 4),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                final db = ref.read(vaultDbProvider);
                if (db == null) return;
                await db.collectionDao
                    .removeTable(collection.id, tableId);
                ref.invalidate(collectionOfSelectedTableProvider);
              },
              child: Icon(Icons.close, size: 11, color: accentText),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill-Button für Tabellen ohne Collection-Zuordnung.
class _AddCollectionPill extends StatelessWidget {
  final String tableId;
  const _AddCollectionPill({required this.tableId});

  @override
  Widget build(BuildContext context) {
    final borderColor = AppTheme.border(context);
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => _CollectionPickerDialog(tableId: tableId),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_special_outlined,
                size: 11, color: cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text('+ Collection',
                style:
                    TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

/// Dialog: wählt eine bestehende Collection oder legt eine neue an.
/// Wenn [currentCollectionId] gesetzt ist, wird diese Zuordnung
/// zuerst aufgelöst bevor die neue gespeichert wird (= "verschieben").
class _CollectionPickerDialog extends ConsumerStatefulWidget {
  final String tableId;
  final String? currentCollectionId;

  const _CollectionPickerDialog({
    required this.tableId,
    this.currentCollectionId,
  });

  @override
  ConsumerState<_CollectionPickerDialog> createState() =>
      _CollectionPickerDialogState();
}

class _CollectionPickerDialogState
    extends ConsumerState<_CollectionPickerDialog> {
  bool _creatingNew = false;
  bool _saving = false;
  final _newNameCtrl = TextEditingController();

  @override
  void dispose() {
    _newNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _addToCollection(String newId) async {
    if (newId == widget.currentCollectionId) {
      Navigator.pop(context);
      return;
    }
    setState(() => _saving = true);
    final db = ref.read(vaultDbProvider);
    if (db == null) return;
    if (widget.currentCollectionId != null) {
      await db.collectionDao
          .removeTable(widget.currentCollectionId!, widget.tableId);
    }
    await db.collectionDao.addTable(newId, widget.tableId);
    ref.invalidate(collectionOfSelectedTableProvider);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _createAndAdd() async {
    final name = _newNameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    final db = ref.read(vaultDbProvider);
    if (db == null) return;
    if (widget.currentCollectionId != null) {
      await db.collectionDao
          .removeTable(widget.currentCollectionId!, widget.tableId);
    }
    final newId = await db.collectionDao
        .createCollection(name: name, type: 'supplement');
    await db.collectionDao.addTable(newId, widget.tableId);
    ref.invalidate(collectionOfSelectedTableProvider);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final collectionsAsync = ref.watch(allCollectionsProvider);
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(widget.currentCollectionId != null
          ? 'Collection ändern'
          : 'Zu Collection hinzufügen'),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SizedBox(
        width: 300,
        child: _saving
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            : collectionsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) =>
                    const Text('Fehler beim Laden der Collections'),
                data: (collections) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...collections.map(
                      (c) => ListTile(
                        leading: Icon(_icon(c.type), size: 16),
                        title: Text(c.name,
                            style: const TextStyle(fontSize: 13)),
                        trailing: c.id == widget.currentCollectionId
                            ? Icon(Icons.check,
                                size: 14, color: cs.primary)
                            : null,
                        dense: true,
                        onTap: _saving
                            ? null
                            : () => _addToCollection(c.id),
                      ),
                    ),
                    const Divider(height: 8),
                    if (_creatingNew)
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 8, 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _newNameCtrl,
                                autofocus: true,
                                style:
                                    const TextStyle(fontSize: 13),
                                decoration: const InputDecoration(
                                  hintText: 'Name der Collection …',
                                  isDense: true,
                                  contentPadding:
                                      EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8),
                                ),
                                onSubmitted: (_) => _createAndAdd(),
                              ),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.check, size: 16),
                              onPressed:
                                  _saving ? null : _createAndAdd,
                            ),
                          ],
                        ),
                      )
                    else
                      ListTile(
                        leading: const Icon(Icons.add, size: 16),
                        title: const Text('Neue Collection …',
                            style: TextStyle(fontSize: 13)),
                        dense: true,
                        onTap: () =>
                            setState(() => _creatingNew = true),
                      ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
      ],
    );
  }

  IconData _icon(String type) => switch (type) {
        'deck' => Icons.style_outlined,
        'supplement' => Icons.menu_book_outlined,
        _ => Icons.folder_special_outlined,
      };
}

// ── Leer-Zustand ──────────────────────────────────────────────────────────────

class _EmptyDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bgSec = AppTheme.bgSecondary(context);
    final tertiary = AppTheme.textTertiary(context);
    return Container(
      color: bgSec,
      child: Center(
        child: Text('Tabelle auswählen',
            style: TextStyle(fontSize: 12, color: tertiary)),
      ),
    );
  }
}
