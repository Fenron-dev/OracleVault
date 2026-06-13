// Datei: lib/features/tables/table_form_screen.dart
//
// ZWECK: Formular zum Anlegen und Bearbeiten einer Oracle-Tabelle.
//        Obere Hälfte: Metadaten (Name, Typ, Beschreibung, Sprache, Tags).
//        Untere Hälfte: Einträge-Editor mit Inline-Bearbeitung.
//        Speichern schreibt Tabelle + alle Einträge in einer Transaktion.
// ABHÄNGIGKEITEN: flutter_riverpod, drift, uuid, library_providers.dart
// PHASE: 1

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../data/db/vault_database.dart';
import '../../services/llm/llm_profiles_store.dart';
import '../../services/llm/llm_service.dart';
import '../../services/llm/llm_tasks.dart';
import '../library/library_providers.dart';
import 'widgets/entries_editor.dart';

const _uuid = Uuid();

class TableFormScreen extends ConsumerStatefulWidget {
  /// Null → neues Anlegen. Gesetzt → Bearbeitung.
  final String? tableId;

  const TableFormScreen({super.key, this.tableId});

  @override
  ConsumerState<TableFormScreen> createState() => _TableFormScreenState();
}

class _TableFormScreenState extends ConsumerState<TableFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _diceExprCtrl = TextEditingController();
  final _genreCtrl = TextEditingController();
  final _themeCtrl = TextEditingController();

  String _oracleType = 'uniform';
  String _language = 'de';
  bool _loading = false;
  bool _initialized = false;
  bool _aiLoading = false;
  String? _aiError;

  // Eintrags-Liste im Bearbeitungs-Zustand.
  List<EntryDraft> _entries = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _diceExprCtrl.dispose();
    _genreCtrl.dispose();
    _themeCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    if (_initialized || widget.tableId == null) {
      _initialized = true;
      if (_entries.isEmpty) _entries = [EntryDraft.empty()];
      return;
    }
    final dao = ref.read(tableDaoProvider);
    final entryDao = ref.read(entryDaoProvider);
    if (dao == null || entryDao == null) return;

    final table = await dao.fetchById(widget.tableId!);
    if (table == null || !mounted) return;

    final existingEntries = await entryDao.fetchForTable(widget.tableId!);

    setState(() {
      _nameCtrl.text = table.name;
      _descCtrl.text = table.description ?? '';
      _oracleType = table.oracleType;
      _diceExprCtrl.text = table.diceExpr ?? '';
      _genreCtrl.text = table.genre ?? '';
      _themeCtrl.text = table.theme ?? '';
      _language = table.language;
      _entries = existingEntries
          .map((e) => EntryDraft(
                id: e.id,
                content: e.content,
                bodyMd: e.bodyMd,
                weight: e.weight,
                rollMin: e.rollMin,
                rollMax: e.rollMax,
                subtableId: e.subtableId,
                mediaId: e.mediaId,
              ))
          .toList();
      if (_entries.isEmpty) _entries = [EntryDraft.empty()];
      _initialized = true;
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final tableDao = ref.read(tableDaoProvider);
    final entryDao = ref.read(entryDaoProvider);
    if (tableDao == null || entryDao == null) return;

    setState(() => _loading = true);

    try {
      final now = DateTime.now();
      final tableId = widget.tableId ?? _uuid.v4();

      final companion = OracleTablesCompanion(
        id: Value(tableId),
        name: Value(_nameCtrl.text.trim()),
        description: Value(
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim()),
        oracleType: Value(_oracleType),
        diceExpr: Value(_diceExprCtrl.text.trim().isEmpty
            ? null
            : _diceExprCtrl.text.trim()),
        genre: Value(
            _genreCtrl.text.trim().isEmpty ? null : _genreCtrl.text.trim()),
        theme: Value(
            _themeCtrl.text.trim().isEmpty ? null : _themeCtrl.text.trim()),
        language: Value(_language),
        createdAt: widget.tableId == null ? Value(now) : const Value.absent(),
        updatedAt: Value(now),
      );

      if (widget.tableId == null) {
        await tableDao.insertTable(companion);
      } else {
        await tableDao.updateTable(companion);
      }

      // Einträge komplett ersetzen.
      final entryCompanions = _entries
          .asMap()
          .entries
          .where((e) => e.value.content.trim().isNotEmpty)
          .map((e) => EntriesCompanion(
                id: Value(e.value.id),
                tableId: Value(tableId),
                position: Value(e.key),
                content: Value(e.value.content.trim()),
                bodyMd: Value(e.value.bodyMd?.trim().isEmpty == true
                    ? null
                    : e.value.bodyMd?.trim()),
                weight: Value(e.value.weight),
                rollMin: Value(e.value.rollMin),
                rollMax: Value(e.value.rollMax),
                subtableId: Value(e.value.subtableId),
                mediaId: Value(e.value.mediaId),
              ))
          .toList();

      await entryDao.replaceAll(tableId, entryCompanions);

      // Selektion auf gespeicherte Tabelle setzen.
      ref.read(selectedTableIdProvider.notifier).state = tableId;

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Speichern: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── KI-Methoden ───────────────────────────────────────────────────────────

  Future<LlmTasks?> _buildTasks(LlmTask task) async {
    final profiles = ref.read(llmProfilesProvider);
    if (!profiles.aiEnabled) {
      setState(() => _aiError = 'KI ist deaktiviert (Einstellungen → KI).');
      return null;
    }
    final profile = profiles.profileForTask(task);
    if (profile == null) {
      setState(() => _aiError = 'Kein KI-Profil konfiguriert (Einstellungen → KI).');
      return null;
    }
    final apiKey =
        await ref.read(llmProfilesProvider.notifier).loadApiKey(profile.id);
    return LlmTasks(LlmService(profile: profile, apiKey: apiKey));
  }

  Future<void> _enrichWithAi() async {
    if (_aiLoading) return;
    setState(() { _aiLoading = true; _aiError = null; });
    try {
      final tasks = await _buildTasks(LlmTask.tagging);
      if (tasks == null) return;

      final sample = _entries.take(15).map((e) => e.content).toList();
      final result = await tasks.enrichTable(
        currentName: _nameCtrl.text.trim().isEmpty
            ? 'Unbekannte Tabelle'
            : _nameCtrl.text.trim(),
        sampleEntries: sample,
        language: _language,
      );

      setState(() {
        if (result.name?.isNotEmpty == true) _nameCtrl.text = result.name!;
        if (result.description?.isNotEmpty == true) {
          _descCtrl.text = result.description!;
        }
        if (result.genre?.isNotEmpty == true) _genreCtrl.text = result.genre!;
        if (result.theme?.isNotEmpty == true) _themeCtrl.text = result.theme!;
      });
    } on LlmException catch (e) {
      setState(() => _aiError = e.message);
    } catch (e) {
      setState(() => _aiError = 'Fehler: $e');
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }


  Future<void> _extendWithAi() async {
    if (_aiLoading) return;

    final count = await showDialog<int>(
      context: context,
      builder: (ctx) => _ExtendCountDialog(
          tableName: _nameCtrl.text.trim().isEmpty
              ? 'Tabelle'
              : _nameCtrl.text.trim()),
    );
    if (count == null || !mounted) return;

    setState(() { _aiLoading = true; _aiError = null; });
    try {
      final tasks = await _buildTasks(LlmTask.generation);
      if (tasks == null) return;

      final newEntries = await tasks.extendTable(
        tableName: _nameCtrl.text.trim(),
        existingEntries: _entries.map((e) => e.content).toList(),
        addCount: count,
        language: _language,
      );

      setState(() {
        _entries = [
          ..._entries,
          ...newEntries.map((e) => EntryDraft(content: e.content)),
        ];
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${newEntries.length} Einträge hinzugefügt')));
      }
    } on LlmException catch (e) {
      setState(() => _aiError = e.message);
    } catch (e) {
      setState(() => _aiError = 'Fehler: $e');
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _init(),
      builder: (ctx, snapshot) {
        if (!_initialized) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return _buildForm(context);
      },
    );
  }

  Widget _buildForm(BuildContext context) {
    final isNew = widget.tableId == null;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Neue Tabelle' : 'Tabelle bearbeiten'),
        actions: [
          // Übersetzen → öffnet dedizierten Übersetzungs-Screen
          if (widget.tableId != null)
            IconButton(
              icon: const Icon(Icons.translate, size: 18),
              tooltip: 'Übersetzen',
              onPressed: () =>
                  context.push('${AppRoutes.tableTranslate}/${widget.tableId}'),
            ),
          // Mit KI erweitern
          IconButton(
            icon: _aiLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.auto_awesome_outlined, size: 18),
            tooltip: 'Mit KI erweitern',
            onPressed: _aiLoading ? null : _extendWithAi,
          ),
          TextButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Speichern'),
          ),
          const SizedBox(width: AppTheme.sp8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Linke Spalte: Metadaten ──────────────────────────────
            SizedBox(
              width: 340,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.sp16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Name *'),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Name darf nicht leer sein'
                              : null,
                      autofocus: isNew,
                    ),
                    const Gap(AppTheme.sp12),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Beschreibung'),
                      maxLines: 3,
                    ),
                    const Gap(AppTheme.sp12),

                    // ── Typ-Auswahl ───────────────────────────────────
                    Text('Typ',
                        style: theme.textTheme.labelMedium
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const Gap(AppTheme.sp4),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'uniform', label: Text('Gleich')),
                        ButtonSegment(
                            value: 'weighted', label: Text('Gewichtet')),
                        ButtonSegment(value: 'dice', label: Text('Würfel')),
                        ButtonSegment(value: 'deck', label: Text('Deck')),
                      ],
                      selected: {_oracleType},
                      onSelectionChanged: (s) =>
                          setState(() => _oracleType = s.first),
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                      ),
                    ),

                    if (_oracleType == 'dice') ...[
                      const Gap(AppTheme.sp12),
                      TextFormField(
                        controller: _diceExprCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Würfelausdruck',
                          hintText: 'z. B. 1d20, 2d6+3',
                        ),
                        validator: (v) {
                          if (_oracleType != 'dice') return null;
                          if (v == null || v.trim().isEmpty) {
                            return 'Würfelausdruck erforderlich';
                          }
                          return null;
                        },
                      ),
                    ],

                    const Gap(AppTheme.sp12),

                    // ── Sprache ───────────────────────────────────────
                    DropdownButtonFormField<String>(
                      initialValue: _language,
                      decoration:
                          const InputDecoration(labelText: 'Sprache'),
                      items: const [
                        DropdownMenuItem(value: 'de', child: Text('Deutsch')),
                        DropdownMenuItem(
                            value: 'en', child: Text('Englisch')),
                        DropdownMenuItem(
                            value: 'fr', child: Text('Französisch')),
                        DropdownMenuItem(
                            value: 'es', child: Text('Spanisch')),
                        DropdownMenuItem(
                            value: 'it', child: Text('Italienisch')),
                      ],
                      onChanged: (v) =>
                          setState(() => _language = v ?? 'de'),
                    ),
                    const Gap(AppTheme.sp12),

                    TextFormField(
                      controller: _genreCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Genre'),
                    ),
                    const Gap(AppTheme.sp12),
                    TextFormField(
                      controller: _themeCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Thema'),
                    ),

                    const Gap(AppTheme.sp16),

                    // ── KI-Bereich ────────────────────────────────────
                    if (_aiError != null) ...[
                      Text(
                        _aiError!,
                        style: TextStyle(
                            fontSize: 11, color: cs.error),
                        maxLines: 4,
                      ),
                      const Gap(AppTheme.sp8),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _aiLoading ? null : _enrichWithAi,
                            icon: _aiLoading
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.auto_fix_normal,
                                    size: 16),
                            label: Text(_aiLoading
                                ? 'KI lädt…'
                                : 'Metadaten ergänzen'),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const VerticalDivider(width: 1),

            // ── Rechte Spalte: Einträge ──────────────────────────────
            Expanded(
              child: EntriesEditor(
                entries: _entries,
                oracleType: _oracleType,
                onChanged: (updated) =>
                    setState(() => _entries = updated),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Anzahl-Dialog für KI-Erweiterung ─────────────────────────────────────────

class _ExtendCountDialog extends StatefulWidget {
  final String tableName;
  const _ExtendCountDialog({required this.tableName});

  @override
  State<_ExtendCountDialog> createState() => _ExtendCountDialogState();
}

class _ExtendCountDialogState extends State<_ExtendCountDialog> {
  int _count = 10;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Erweitern: ${widget.tableName}'),
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
                  .map((n) => DropdownMenuItem(
                      value: n, child: Text('$n Einträge')))
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
