// Datei: lib/features/tables/widgets/entries_editor.dart
//
// ZWECK: Inline-Editor für Einträge einer Oracle-Tabelle.
//        Zeigt alle Einträge als editierbare Liste.
//        Drag-to-reorder, Hinzufügen, Löschen.
//        Zusatzfelder (weight, rollMin/Max) je nach oracleType.
// ABHÄNGIGKEITEN: flutter, uuid
// PHASE: 1

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di.dart';
import '../../../core/theme.dart';
import '../../library/widgets/media_thumbnail.dart';

const _uuid = Uuid();

/// Entwurfsobjekt für einen Tabellen-Eintrag (noch nicht persistiert).
class EntryDraft {
  final String id;
  String content;
  String? bodyMd;
  double weight;
  int? rollMin;
  int? rollMax;
  String? subtableId;
  String? mediaId;

  EntryDraft({
    String? id,
    this.content = '',
    this.bodyMd,
    this.weight = 1.0,
    this.rollMin,
    this.rollMax,
    this.subtableId,
    this.mediaId,
  }) : id = id ?? _uuid.v4();

  factory EntryDraft.empty() => EntryDraft();

  EntryDraft copyWith({
    String? content,
    String? bodyMd,
    double? weight,
    int? rollMin,
    int? rollMax,
  }) =>
      EntryDraft(
        id: id,
        content: content ?? this.content,
        bodyMd: bodyMd ?? this.bodyMd,
        weight: weight ?? this.weight,
        rollMin: rollMin ?? this.rollMin,
        rollMax: rollMax ?? this.rollMax,
        subtableId: subtableId,
        mediaId: mediaId,
      );
}

/// Bearbeitbarer Einträge-Editor.
///
/// [onChanged] wird nach jeder Änderung mit der aktuellen Liste aufgerufen.
class EntriesEditor extends StatefulWidget {
  final List<EntryDraft> entries;
  final String oracleType;
  final ValueChanged<List<EntryDraft>> onChanged;

  const EntriesEditor({
    super.key,
    required this.entries,
    required this.oracleType,
    required this.onChanged,
  });

  @override
  State<EntriesEditor> createState() => _EntriesEditorState();
}

class _EntriesEditorState extends State<EntriesEditor> {
  late List<EntryDraft> _entries;

  @override
  void initState() {
    super.initState();
    _entries = List.from(widget.entries);
  }

  @override
  void didUpdateWidget(EntriesEditor old) {
    super.didUpdateWidget(old);
    if (old.entries != widget.entries) {
      _entries = List.from(widget.entries);
    }
  }

  void _notify() => widget.onChanged(_entries);

  void _addEntry() {
    setState(() => _entries.add(EntryDraft.empty()));
    _notify();
  }

  void _removeEntry(int index) {
    setState(() => _entries.removeAt(index));
    _notify();
  }

  void _reorder(int old, int newIdx) {
    setState(() {
      final item = _entries.removeAt(old);
      _entries.insert(newIdx, item);
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDice = widget.oracleType == 'dice';
    final isWeighted = widget.oracleType == 'weighted';

    return Column(
      children: [
        // ── Header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.sp16, vertical: AppTheme.sp8),
          child: Row(
            children: [
              Text('Einträge (${_entries.length})',
                  style: theme.textTheme.titleSmall),
              const Spacer(),
              TextButton.icon(
                onPressed: _addEntry,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Hinzufügen'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.sp8),
                  minimumSize: const Size(0, 32),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // ── Spalten-Header ───────────────────────────────────────────
        if (isDice || isWeighted)
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.sp16, vertical: AppTheme.sp4),
            child: Row(
              children: [
                if (isDice) ...[
                  SizedBox(
                      width: 56,
                      child: Text('Min',
                          style: theme.textTheme.labelSmall)),
                  SizedBox(
                      width: 56,
                      child: Text('Max',
                          style: theme.textTheme.labelSmall)),
                ],
                if (isWeighted)
                  SizedBox(
                      width: 60,
                      child: Text('Gewicht',
                          style: theme.textTheme.labelSmall)),
                Expanded(
                    child: Text('Inhalt',
                        style: theme.textTheme.labelSmall)),
              ],
            ),
          ),

        // ── Einträge-Liste (drag-to-reorder) ─────────────────────────
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: AppTheme.sp32),
            itemCount: _entries.length,
            onReorder: _reorder,
            buildDefaultDragHandles: false,
            itemBuilder: (ctx, i) {
              final entry = _entries[i];
              return _EntryRow(
                key: ValueKey(entry.id),
                entry: entry,
                index: i,
                isDice: isDice,
                isWeighted: isWeighted,
                onChanged: (updated) {
                  setState(() => _entries[i] = updated);
                  _notify();
                },
                onDelete: () => _removeEntry(i),
                onAddAfter: () {
                  setState(
                      () => _entries.insert(i + 1, EntryDraft.empty()));
                  _notify();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Einzelne Eintrags-Zeile ───────────────────────────────────────────────────

class _EntryRow extends ConsumerStatefulWidget {
  final EntryDraft entry;
  final int index;
  final bool isDice;
  final bool isWeighted;
  final ValueChanged<EntryDraft> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onAddAfter;

  const _EntryRow({
    super.key,
    required this.entry,
    required this.index,
    required this.isDice,
    required this.isWeighted,
    required this.onChanged,
    required this.onDelete,
    required this.onAddAfter,
  });

  @override
  ConsumerState<_EntryRow> createState() => _EntryRowState();
}

class _EntryRowState extends ConsumerState<_EntryRow> {
  late TextEditingController _contentCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;
  late TextEditingController _weightCtrl;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _contentCtrl =
        TextEditingController(text: widget.entry.content);
    _minCtrl = TextEditingController(
        text: widget.entry.rollMin?.toString() ?? '');
    _maxCtrl = TextEditingController(
        text: widget.entry.rollMax?.toString() ?? '');
    _weightCtrl = TextEditingController(
        text: widget.entry.weight == 1.0
            ? '1'
            : widget.entry.weight.toString());
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(widget.entry.copyWith(
      content: _contentCtrl.text,
      weight: double.tryParse(_weightCtrl.text) ?? 1.0,
      rollMin: int.tryParse(_minCtrl.text),
      rollMax: int.tryParse(_maxCtrl.text),
    ));
  }

  Future<void> _attachImage() async {
    final svc = ref.read(mediaServiceProvider);
    if (svc == null) return;
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path == null) return;
    try {
      final media = await svc.importFile(File(path));
      widget.entry.mediaId = media.id;
      if (mounted) setState(() {});
      _emit();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bild-Import fehlgeschlagen: $e')),
        );
      }
    }
  }

  void _removeImage() {
    widget.entry.mediaId = null;
    setState(() {});
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        color: _hovered ? cs.surfaceContainerLow : null,
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.sp8, vertical: AppTheme.sp4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag-Handle
            ReorderableDragStartListener(
              index: widget.index,
              child: Icon(Icons.drag_indicator,
                  size: 16, color: cs.onSurfaceVariant.withAlpha(128)),
            ),
            const Gap(AppTheme.sp4),

            // Dice-Felder
            if (widget.isDice) ...[
              SizedBox(
                width: 48,
                child: TextField(
                  controller: _minCtrl,
                  decoration:
                      const InputDecoration(hintText: 'Min', isDense: true),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  onChanged: (_) => _emit(),
                ),
              ),
              const Gap(AppTheme.sp4),
              SizedBox(
                width: 48,
                child: TextField(
                  controller: _maxCtrl,
                  decoration:
                      const InputDecoration(hintText: 'Max', isDense: true),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  onChanged: (_) => _emit(),
                ),
              ),
              const Gap(AppTheme.sp8),
            ],

            // Gewichts-Feld
            if (widget.isWeighted) ...[
              SizedBox(
                width: 52,
                child: TextField(
                  controller: _weightCtrl,
                  decoration:
                      const InputDecoration(hintText: '1', isDense: true),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _emit(),
                ),
              ),
              const Gap(AppTheme.sp8),
            ],

            // Inhalt
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                decoration: InputDecoration(
                  hintText: 'Eintrag ${widget.index + 1} …',
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: cs.primary, width: 1),
                  ),
                ),
                onChanged: (_) => _emit(),
                onSubmitted: (_) => widget.onAddAfter(),
              ),
            ),

            // Angehängtes Bild (Thumbnail), immer sichtbar wenn gesetzt
            if (widget.entry.mediaId != null) ...[
              const Gap(AppTheme.sp4),
              MediaThumbnail(mediaId: widget.entry.mediaId!, size: 26),
            ],

            // Aktions-Buttons (nur bei Hover)
            if (_hovered) ...[
              const Gap(AppTheme.sp4),
              InkWell(
                onTap:
                    widget.entry.mediaId == null ? _attachImage : _removeImage,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    widget.entry.mediaId == null
                        ? Icons.image_outlined
                        : Icons.hide_image_outlined,
                    size: 14,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              InkWell(
                onTap: widget.onAddAfter,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.add, size: 14,
                      color: cs.onSurfaceVariant),
                ),
              ),
              InkWell(
                onTap: widget.onDelete,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.close, size: 14,
                      color: cs.error),
                ),
              ),
            ] else
              const SizedBox(width: 36),
          ],
        ),
      ),
    );
  }
}
