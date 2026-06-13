// Datei: lib/features/import/import_screen.dart
//
// ZWECK: Import-Screen nach wireframe_02_import.
//        Single-Pane (kein Wizard):
//          TopBar:      ← Zurück | Titel | Status-Pill | Verwerfen | Speichern ⌘↵
//          Quell-Zeile: Icon + URL/Dateiname + "Erneut" + Konfidenz-Info
//          Haupt-Split: Quellansicht (links) | Editor (rechts)
//          Source-Block: Metadaten (Quelle, Datum, Autor, Lizenz)
//          Bottom-Bar:  "Nach dem Speichern" Optionen
//
//        Phase 3 ergänzt: KI-Vorschläge-Block zwischen Haupt-Split und Source-Block.
// PHASE: 2

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../services/llm/llm_profiles_store.dart';
import 'import_controller.dart';
import 'import_state.dart';

class ImportScreen extends ConsumerStatefulWidget {
  /// Optionale Vorausfüllung (z. B. aus Share-Intent oder Topbar-URL-Paste).
  final String? initialUrl;

  const ImportScreen({super.key, this.initialUrl});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadUrl(widget.initialUrl!);
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  // ── Lade-Aktionen ──────────────────────────────────────────────────────────

  Future<void> _loadUrl(String url) async {
    if (url.trim().isEmpty) return;
    await ref
        .read(importControllerProvider.notifier)
        .loadSource(ImportSource(
          type: ImportSourceType.url,
          raw: url.trim(),
        ));
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'csv', 'tsv', 'txt', 'md', 'markdown', 'xlsx', 'xls',
        'pdf', 'epub',
        'jpg', 'jpeg', 'png', 'tiff', 'tif', 'bmp', 'webp', 'gif',
      ],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;

    final mime = lookupMimeType(path);
    await ref
        .read(importControllerProvider.notifier)
        .loadSource(ImportSource(
          type: ImportSourceType.file,
          raw: path,
          mimeType: mime,
        ));
  }

  Future<void> _pasteImage() async {
    final found = await ref
        .read(importControllerProvider.notifier)
        .loadImageFromClipboard();
    if (!found && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Kein Bild in der Zwischenablage gefunden')),
      );
    }
  }

  Future<void> _paste() async {
    final text = await Clipboard.getData(Clipboard.kTextPlain);
    if (text?.text == null || text!.text!.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zwischenablage ist leer')),
        );
      }
      return;
    }
    await ref
        .read(importControllerProvider.notifier)
        .loadSource(ImportSource(
          type: ImportSourceType.paste,
          raw: text.text!,
        ));
  }

  Future<void> _save() async {
    final ctrl = ref.read(importControllerProvider.notifier);
    final savedId = await ctrl.save();
    if (savedId == null) return;
    if (!mounted) return;

    final continueImport =
        ref.read(importControllerProvider).saveAndContinue;
    final openAfter = ref.read(importControllerProvider).saveAndOpen;

    if (continueImport) {
      // Reset + im Screen bleiben (neue Quelle eingeben)
      ctrl.reset();
      _urlController.clear();
    } else if (openAfter) {
      context.go(AppRoutes.library);
    } else {
      context.go(AppRoutes.library);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importControllerProvider);
    final borderColor = AppTheme.border(context);

    return Scaffold(
      body: Column(
        children: [
          // ── TopBar ──────────────────────────────────────────────────
          _ImportTopBar(
            state: state,
            onBack: () {
              ref.read(importControllerProvider.notifier).reset();
              context.go(AppRoutes.library);
            },
            onSave: _save,
            onDiscard: () {
              ref.read(importControllerProvider.notifier).reset();
              context.go(AppRoutes.library);
            },
          ),
          Divider(height: 1, color: borderColor),

          // ── Quell-Eingabe ─────────────────────────────────────────────
          _SourceInputRow(
            urlController: _urlController,
            state: state,
            onLoadUrl: _loadUrl,
            onPickFile: _pickFile,
            onPaste: _paste,
            onPasteImage: _pasteImage,
            onReanalyze: () {
              final src = state.source;
              if (src != null) {
                ref
                    .read(importControllerProvider.notifier)
                    .loadSource(src);
              }
            },
          ),
          Divider(height: 1, color: borderColor),

          // ── Haupt-Content ────────────────────────────────────────────
          Expanded(
            child: state.status == ImportStatus.idle
                ? _IdleHint()
                : state.status == ImportStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.status == ImportStatus.error
                        ? _ErrorView(message: state.errorMessage ?? '')
                        : _ImportBody(state: state),
          ),

          // ── KI-Vorschläge-Block (Phase 3) ───────────────────────────
          if (state.draft != null) ...[
            Divider(height: 1, color: borderColor),
            _AiSuggestionsBlock(state: state),
          ],

          // ── Source-Block + Bottom-Bar ────────────────────────────────
          if (state.draft != null) ...[
            Divider(height: 1, color: borderColor),
            _SourceMetaBlock(state: state),
            Divider(height: 1, color: borderColor),
            _BottomBar(state: state),
          ],
        ],
      ),
    );
  }
}

// ── TopBar ────────────────────────────────────────────────────────────────────

class _ImportTopBar extends StatelessWidget {
  final ImportScreenState state;
  final VoidCallback onBack;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  const _ImportTopBar({
    required this.state,
    required this.onBack,
    required this.onSave,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.sp12),
        child: Row(
          children: [
            // ← Zurück
            _TinyBtn(
              icon: Icons.arrow_back,
              label: 'Zurück',
              onTap: onBack,
            ),
            const SizedBox(width: AppTheme.sp12),
            Icon(Icons.file_upload_outlined, size: 15, color: cs.onSurfaceVariant),
            const SizedBox(width: AppTheme.sp8),
            Text('Importieren',
                style: Theme.of(context).textTheme.titleSmall),
            if (state.source != null) ...[
              const SizedBox(width: AppTheme.sp4),
              Text(
                _sourceLabel(state.source!),
                style: TextStyle(
                    fontSize: 11, color: cs.onSurfaceVariant),
              ),
            ],
            const Spacer(),
            // Status-Pill
            _StatusPill(status: state.status,
                uncertainCount: state.candidate?.uncertainCount ?? 0,
                entryCount: state.draft?.entries.length ?? 0),
            const SizedBox(width: AppTheme.sp8),
            // Verwerfen
            if (state.status != ImportStatus.idle)
              _TinyBtn(label: 'Verwerfen', onTap: onDiscard),
            const SizedBox(width: AppTheme.sp4),
            // Speichern
            if (state.draft != null)
              _SaveBtn(onTap: state.status == ImportStatus.saving
                  ? null
                  : onSave),
          ],
        ),
      ),
    );
  }

  String _sourceLabel(ImportSource src) => switch (src.type) {
        ImportSourceType.url => 'aus URL',
        ImportSourceType.file => 'aus Datei',
        ImportSourceType.paste => 'aus Zwischenablage',
      };
}

class _StatusPill extends StatelessWidget {
  final ImportStatus status;
  final int uncertainCount;
  final int entryCount;

  const _StatusPill(
      {required this.status,
      required this.uncertainCount,
      required this.entryCount});

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = switch (status) {
      ImportStatus.ready => (
          AppTheme.accentBg(context),
          Icons.check_circle_outline,
          entryCount > 0
              ? '$entryCount Einträge${uncertainCount > 0 ? ' · $uncertainCount unsicher' : ''}'
              : 'Bereit',
        ),
      ImportStatus.loading => (
          AppTheme.bgSecondary(context),
          Icons.hourglass_empty,
          'Analysiere…',
        ),
      ImportStatus.saving => (
          AppTheme.bgSecondary(context),
          Icons.save_outlined,
          'Speichere…',
        ),
      ImportStatus.error => (
          AppTheme.warnBg(context),
          Icons.warning_amber_outlined,
          'Fehler',
        ),
      _ => (AppTheme.bgSecondary(context), Icons.circle_outlined, ''),
    };

    if (label.isEmpty) return const SizedBox.shrink();

    final textColor = status == ImportStatus.ready
        ? AppTheme.accentText(context)
        : status == ImportStatus.error
            ? AppTheme.warnText(context)
            : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp12, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: textColor)),
        ],
      ),
    );
  }
}

class _TinyBtn extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;

  const _TinyBtn({this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.sp12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border(context)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: cs.onSurface),
              const SizedBox(width: 4),
            ],
            Text(label,
                style: TextStyle(fontSize: 12, color: cs.onSurface)),
          ],
        ),
      ),
    );
  }
}

class _SaveBtn extends StatelessWidget {
  final VoidCallback? onTap;
  const _SaveBtn({this.onTap});

  @override
  Widget build(BuildContext context) {
    final accentBg = AppTheme.accentBg(context);
    final accentText = AppTheme.accentText(context);
    final accentBorder = AppTheme.accentBorder(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.sp12, vertical: 4),
        decoration: BoxDecoration(
          color: accentBg,
          border: Border.all(color: accentBorder),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.save_outlined, size: 13, color: accentText),
            const SizedBox(width: 4),
            Text('Speichern',
                style: TextStyle(
                    fontSize: 12,
                    color: accentText,
                    fontWeight: FontWeight.w500)),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                border: Border.all(color: accentBorder),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('⌘↵',
                  style: TextStyle(fontSize: 10, color: accentText)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quell-Eingabe-Zeile ───────────────────────────────────────────────────────

class _SourceInputRow extends ConsumerWidget {
  final TextEditingController urlController;
  final ImportScreenState state;
  final ValueChanged<String> onLoadUrl;
  final VoidCallback onPickFile;
  final VoidCallback onPaste;
  final VoidCallback onPasteImage;
  final VoidCallback onReanalyze;

  const _SourceInputRow({
    required this.urlController,
    required this.state,
    required this.onLoadUrl,
    required this.onPickFile,
    required this.onPaste,
    required this.onPasteImage,
    required this.onReanalyze,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final bgSec = AppTheme.bgSecondary(context);
    final borderColor = AppTheme.border(context);
    final tertiary = AppTheme.textTertiary(context);

    // Wenn eine Quelle geladen ist: URL-Zeile im Read-Only-Stil anzeigen.
    if (state.source != null && state.status != ImportStatus.idle) {
      return Container(
        color: bgSec,
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.sp16, vertical: 8),
        child: Row(
          children: [
            Icon(Icons.link, size: 14, color: tertiary),
            const SizedBox(width: AppTheme.sp8),
            Expanded(
              child: Text(
                state.source!.displayName,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppTheme.sp8),
            _TinyBtn(
              icon: Icons.refresh,
              label: 'Erneut analysieren',
              onTap: state.status == ImportStatus.loading
                  ? null
                  : onReanalyze,
            ),
          ],
        ),
      );
    }

    // Idle: Eingabe-Interface
    return Padding(
      padding: const EdgeInsets.all(AppTheme.sp12),
      child: Row(
        children: [
          // URL-Eingabe
          Expanded(
            child: SizedBox(
              height: 34,
              child: TextField(
                controller: urlController,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'URL eingeben (Reddit, Blog, …)',
                  hintStyle: TextStyle(
                      fontSize: 12, color: cs.onSurfaceVariant),
                  prefixIcon: Icon(Icons.link,
                      size: 14, color: cs.onSurfaceVariant),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.sp12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  filled: false,
                ),
                onSubmitted: onLoadUrl,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.sp8),
          _TinyBtn(
            label: 'Laden',
            onTap: () => onLoadUrl(urlController.text),
          ),
          const SizedBox(width: AppTheme.sp4),
          _TinyBtn(
            icon: Icons.folder_open_outlined,
            label: 'Datei',
            onTap: onPickFile,
          ),
          const SizedBox(width: AppTheme.sp4),
          _TinyBtn(
            icon: Icons.content_paste,
            label: 'Text',
            onTap: onPaste,
          ),
          const SizedBox(width: AppTheme.sp4),
          _TinyBtn(
            icon: Icons.image_outlined,
            label: 'Bild',
            onTap: onPasteImage,
          ),
        ],
      ),
    );
  }
}

// ── Haupt-Split ───────────────────────────────────────────────────────────────

class _ImportBody extends ConsumerWidget {
  final ImportScreenState state;
  const _ImportBody({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderColor = AppTheme.border(context);
    final bgSec = AppTheme.bgSecondary(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Linke Pane: Quellansicht
        SizedBox(
          width: 340,
          child: Container(
            color: bgSec,
            child: _SourcePane(candidate: state.candidate!),
          ),
        ),
        VerticalDivider(width: 1, color: borderColor),
        // Rechte Pane: Editor
        Expanded(
          child: _EditPane(
            state: state,
            onDraftChange: (fn) =>
                ref.read(importControllerProvider.notifier).updateDraft(fn),
            onEntryChange: (i, e) => ref
                .read(importControllerProvider.notifier)
                .updateEntry(i, e),
            onEntryDelete: (i) =>
                ref.read(importControllerProvider.notifier).deleteEntry(i),
            onEntryAdd: () => ref
                .read(importControllerProvider.notifier)
                .addEntry(const RawEntry(content: '')),
          ),
        ),
      ],
    );
  }
}

// ── Quellansicht (links) ──────────────────────────────────────────────────────

class _SourcePane extends StatelessWidget {
  final RawCandidate candidate;
  const _SourcePane({required this.candidate});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentText = AppTheme.accentText(context);
    final accentBg = AppTheme.accentBg(context);
    final tertiary = AppTheme.textTertiary(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quellansicht',
              style: TextStyle(fontSize: 10, color: tertiary)),
          const SizedBox(height: AppTheme.sp8),
          Container(
            padding: const EdgeInsets.all(AppTheme.sp12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: AppTheme.border(context)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (candidate.sourceTitle != null &&
                    candidate.sourceTitle!.isNotEmpty) ...[
                  Text(
                    candidate.sourceTitle!,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                ],
                if (candidate.sourceAuthor != null) ...[
                  Text(
                    candidate.sourceAuthor!,
                    style: TextStyle(fontSize: 10, color: tertiary),
                  ),
                  const SizedBox(height: 6),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'extrahiert',
                    style: TextStyle(fontSize: 10, color: accentText),
                  ),
                ),
                const SizedBox(height: AppTheme.sp8),
                // Bild-Vorschau wenn ein Bild importiert wurde.
                if (candidate.sourceImagePath != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      File(candidate.sourceImagePath!),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          size: 48),
                    ),
                  ),
                  if (candidate.sourceText.isNotEmpty)
                    const SizedBox(height: AppTheme.sp8),
                ],
                if (candidate.sourceText.isNotEmpty)
                  Text(
                    candidate.sourceText.length > 1200
                        ? '${candidate.sourceText.substring(0, 1200)}…'
                        : candidate.sourceText,
                    style: TextStyle(fontSize: 12, color: cs.onSurface),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.sp8),
          Text(
            'Klick auf Eintrag rechts → Quelle hebt hervor',
            style: TextStyle(fontSize: 11, color: tertiary),
          ),
        ],
      ),
    );
  }
}

// ── Editor-Pane (rechts) ──────────────────────────────────────────────────────

class _EditPane extends ConsumerWidget {
  final ImportScreenState state;
  final void Function(ImportDraft Function(ImportDraft)) onDraftChange;
  final void Function(int, RawEntry) onEntryChange;
  final void Function(int) onEntryDelete;
  final VoidCallback onEntryAdd;

  const _EditPane({
    required this.state,
    required this.onDraftChange,
    required this.onEntryChange,
    required this.onEntryDelete,
    required this.onEntryAdd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = state.draft!;
    final cs = Theme.of(context).colorScheme;
    final tertiary = AppTheme.textTertiary(context);
    final borderColor = AppTheme.border(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.sp16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Metadaten-Zeile ──────────────────────────────────────────
          Row(
            children: [
              // Name
              Expanded(
                child: _FieldBox(
                  label: 'Name',
                  child: TextFormField(
                    initialValue: draft.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero),
                    onChanged: (v) =>
                        onDraftChange((d) => d.copyWith(name: v)),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.sp8),
              // Typ
              SizedBox(
                width: 90,
                child: _FieldBox(
                  label: 'Typ',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: draft.oracleType,
                      isDense: true,
                      style: TextStyle(
                          fontSize: 12, color: cs.onSurface),
                      items: const [
                        DropdownMenuItem(
                            value: 'uniform', child: Text('Gleich')),
                        DropdownMenuItem(
                            value: 'dice', child: Text('Würfel')),
                        DropdownMenuItem(
                            value: 'weighted',
                            child: Text('Gewichtet')),
                        DropdownMenuItem(
                            value: 'deck', child: Text('Deck')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          onDraftChange((d) => d.copyWith(oracleType: v));
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.sp8),
              // Sprache
              SizedBox(
                width: 80,
                child: _FieldBox(
                  label: 'Sprache',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: draft.language,
                      isDense: true,
                      style: TextStyle(
                          fontSize: 12, color: cs.onSurface),
                      items: const [
                        DropdownMenuItem(value: 'de', child: Text('DE')),
                        DropdownMenuItem(value: 'en', child: Text('EN')),
                        DropdownMenuItem(
                            value: 'fr', child: Text('FR')),
                        DropdownMenuItem(
                            value: 'es', child: Text('ES')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          onDraftChange((d) => d.copyWith(language: v));
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp8),

          // ── Beschreibung ─────────────────────────────────────────────
          _FieldBox(
            label: 'Beschreibung',
            child: TextFormField(
              initialValue: draft.description ?? '',
              style: const TextStyle(fontSize: 12),
              maxLines: 3,
              minLines: 1,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                  hintText: 'Optional — KI kann sie automatisch erstellen'),
              onChanged: (v) =>
                  onDraftChange((d) => d.copyWith(description: v.isEmpty ? null as Object? : v)),
            ),
          ),

          const SizedBox(height: AppTheme.sp12),

          // ── Einträge-Liste ───────────────────────────────────────────
          Row(
            children: [
              Text('Einträge',
                  style: TextStyle(fontSize: 10, color: tertiary)),
              Text(' · ',
                  style: TextStyle(fontSize: 10, color: tertiary)),
              Text('klick zum Bearbeiten',
                  style: TextStyle(fontSize: 10, color: tertiary)),
              const Spacer(),
              InkWell(
                onTap: onEntryAdd,
                child: Row(
                  children: [
                    Icon(Icons.add, size: 12, color: cs.onSurfaceVariant),
                    Text(' Eintrag',
                        style: TextStyle(
                            fontSize: 11, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.sp4),

          // Alle Einträge scrollbar anzeigen — kein Limit, da der Nutzer
          // vor dem Speichern jeden Eintrag prüfen können muss.
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 600),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: draft.entries.length,
                  itemBuilder: (context, i) => _EntryRow(
                    index: i,
                    entry: draft.entries[i],
                    showRange: draft.oracleType == 'dice',
                    showWeight: draft.oracleType == 'weighted',
                    onChange: (updated) => onEntryChange(i, updated),
                    onDelete: () => onEntryDelete(i),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  final String label;
  final Widget child;
  const _FieldBox({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final borderColor = AppTheme.border(context);
    final tertiary = AppTheme.textTertiary(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: tertiary)),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.sp8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(5),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _EntryRow extends StatefulWidget {
  final int index;
  final RawEntry entry;
  final bool showRange;
  final bool showWeight;
  final ValueChanged<RawEntry> onChange;
  final VoidCallback onDelete;

  const _EntryRow({
    required this.index,
    required this.entry,
    required this.showRange,
    required this.showWeight,
    required this.onChange,
    required this.onDelete,
  });

  @override
  State<_EntryRow> createState() => _EntryRowState();
}

class _EntryRowState extends State<_EntryRow> {
  late TextEditingController _contentCtrl;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _contentCtrl = TextEditingController(text: widget.entry.content);
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warnBg = AppTheme.warnBg(context);
    final warnBorder = AppTheme.warnBorder(context);
    final warnText = AppTheme.warnText(context);
    final borderColor = AppTheme.border(context);
    final tertiary = AppTheme.textTertiary(context);
    final cs = Theme.of(context).colorScheme;
    final e = widget.entry;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        decoration: BoxDecoration(
          color: e.confidenceLow ? warnBg : null,
          border: Border(
            left: e.confidenceLow
                ? BorderSide(color: warnBorder, width: 3)
                : BorderSide.none,
            bottom: BorderSide(color: borderColor, width: 1),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
            e.confidenceLow ? 7 : 10, 7, 10, 7),
        child: Row(
          children: [
            // Nummer
            SizedBox(
              width: 24,
              child: Text(
                (widget.index + 1).toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 11,
                  color: e.confidenceLow ? warnText : tertiary,
                ),
              ),
            ),
            // Min-Max (dice)
            if (widget.showRange) ...[
              SizedBox(
                width: 36,
                child: Text(
                  e.rollMin != null
                      ? '${e.rollMin}-${e.rollMax}'
                      : '',
                  style: TextStyle(
                      fontSize: 11, color: cs.onSurfaceVariant),
                ),
              ),
            ],
            // Content
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (v) =>
                    widget.onChange(RawEntry(
                      content: v,
                      rollMin: e.rollMin,
                      rollMax: e.rollMax,
                      weight: e.weight,
                      confidence: e.confidence,
                    )),
              ),
            ),
            // Warn-Icon
            if (e.confidenceLow) ...[
              Icon(Icons.warning_amber_rounded,
                  size: 12, color: warnText),
              const SizedBox(width: 4),
            ],
            // Löschen (bei Hover)
            if (_hovered)
              InkWell(
                onTap: widget.onDelete,
                child: Icon(Icons.close, size: 12, color: cs.error),
              )
            else
              const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

// ── KI-Vorschläge-Block ───────────────────────────────────────────────────────

class _AiSuggestionsBlock extends ConsumerWidget {
  final ImportScreenState state;
  const _AiSuggestionsBlock({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tertiary = AppTheme.textTertiary(context);
    final draft = state.draft;
    if (draft == null) return const SizedBox.shrink();

    final profilesState = ref.watch(llmProfilesProvider);
    final aiAvailable = profilesState.aiEnabled &&
        profilesState.profiles.isNotEmpty;

    final uncertainCount =
        draft.entries.where((e) => e.confidence < 0.7).length;
    final isDone = state.aiNormalizationDone;
    final isLoading = state.isAiProcessing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Haupt-Zeile ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                isDone
                    ? Icons.check_circle_outline
                    : uncertainCount > 0
                        ? Icons.warning_amber_rounded
                        : Icons.auto_awesome_outlined,
                size: 16,
                color: isDone
                    ? cs.primary
                    : uncertainCount > 0
                        ? cs.tertiary
                        : tertiary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isDone
                      ? 'KI-Normalisierung abgeschlossen'
                      : uncertainCount > 0
                          ? '$uncertainCount Eintrag${uncertainCount == 1 ? '' : 'träge'} mit niedriger Konfidenz'
                          : 'Alle Einträge mit hoher Konfidenz erkannt',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurface),
                ),
              ),
              // Normalisierung
              if (!isDone)
                TextButton.icon(
                  onPressed: (aiAvailable && !isLoading)
                      ? () => ref
                          .read(importControllerProvider.notifier)
                          .normalizeWithAi()
                      : null,
                  icon: isLoading
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_fix_high, size: 14),
                  label: Text(
                      isLoading ? 'Normalisiere…' : 'KI-Normalisierung'),
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                ),
              const SizedBox(width: 4),
              // Tag + Metadaten-Vorschlag
              TextButton.icon(
                onPressed: (aiAvailable && !isLoading)
                    ? () => ref
                        .read(importControllerProvider.notifier)
                        .suggestTagsWithAi()
                    : null,
                icon: const Icon(Icons.sell_outlined, size: 14),
                label: const Text('Tags'),
                style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact),
              ),
              const SizedBox(width: 4),
              // Anreichern: Titel, Beschreibung, Tags, Genre, Thema
              TextButton.icon(
                onPressed: (aiAvailable && !isLoading)
                    ? () => ref
                        .read(importControllerProvider.notifier)
                        .enrichWithAi()
                    : null,
                icon: const Icon(Icons.auto_fix_normal, size: 14),
                label: const Text('Anreichern'),
                style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact),
              ),
              const SizedBox(width: 4),
              // Übersetzen
              _TranslateButton(
                  enabled: aiAvailable && !isLoading, state: state),
            ],
          ),
        ),
        // ── Zweite Zeile: Mehrere Tabellen ────────────────────────────
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
          child: Row(
            children: [
              const Icon(Icons.table_chart_outlined, size: 14,
                  color: Colors.transparent), // Ausrichtungs-Spacer
              const SizedBox(width: 8),
              _MultiTablesButton(enabled: !isLoading, state: state),
            ],
          ),
        ),
        // ── KI-Fehler ─────────────────────────────────────────────────
        if (state.aiError != null)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              state.aiError!,
              style: TextStyle(fontSize: 11, color: cs.error),
            ),
          ),
        // ── Kein Profil-Hinweis ───────────────────────────────────────
        if (!aiAvailable)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'KI-Profil einrichten um Normalisierung und Tag-Vorschläge zu nutzen',
              style: TextStyle(fontSize: 11, color: tertiary),
            ),
          ),
      ],
    );
  }
}

// ── Übersetzen-Button mit Sprach-Picker ──────────────────────────────────────

class _TranslateButton extends ConsumerWidget {
  final bool enabled;
  final ImportScreenState state;
  const _TranslateButton({required this.enabled, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = state.draft?.language ?? 'de';
    return PopupMenuButton<String>(
      enabled: enabled,
      tooltip: 'Übersetzen',
      offset: const Offset(0, 28),
      onSelected: (lang) =>
          ref.read(importControllerProvider.notifier).translateWithAi(lang),
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'de', child: Text('→ Deutsch')),
        const PopupMenuItem(value: 'en', child: Text('→ Englisch')),
        const PopupMenuItem(value: 'fr', child: Text('→ Französisch')),
        const PopupMenuItem(value: 'es', child: Text('→ Spanisch')),
        const PopupMenuItem(value: 'it', child: Text('→ Italienisch')),
      ].where((m) => m.value != currentLang).toList(),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate, size: 14),
            const SizedBox(width: 4),
            Text('Übersetzen',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(fontSize: 12)),
            const Icon(Icons.arrow_drop_down, size: 14),
          ],
        ),
      ),
    );
  }
}

// ── Mehrere-Tabellen-Button ───────────────────────────────────────────────────

class _MultiTablesButton extends ConsumerWidget {
  final bool enabled;
  final ImportScreenState state;
  const _MultiTablesButton({required this.enabled, required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: enabled ? () => _run(context, ref) : null,
      icon: const Icon(Icons.table_chart_outlined, size: 14),
      label: const Text('Mehrere Tabellen'),
      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
    );
  }

  Future<void> _run(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(importControllerProvider.notifier);
    final candidates = await notifier.extractMultipleTables();

    if (!context.mounted) return;

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Keine mehreren Tabellen erkannt. '
            'Versuche es mit einem konfigurierten KI-Profil.'),
      ));
      return;
    }

    final saved = await showDialog<int>(
      context: context,
      builder: (_) => _MultiTableDialog(candidates: candidates),
    );

    if (!context.mounted || saved == null) return;
    if (saved > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$saved Tabelle${saved == 1 ? '' : 'n'} importiert.'),
      ));
    }
  }
}

// ── Mehrere-Tabellen-Dialog ───────────────────────────────────────────────────

class _MultiTableDialog extends ConsumerStatefulWidget {
  final List<RawCandidate> candidates;
  const _MultiTableDialog({required this.candidates});

  @override
  ConsumerState<_MultiTableDialog> createState() => _MultiTableDialogState();
}

class _MultiTableDialogState extends ConsumerState<_MultiTableDialog> {
  late List<bool> _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = List.filled(widget.candidates.length, true);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = AppTheme.border(context);
    final selectedCount = _selected.where((v) => v).length;

    return AlertDialog(
      title: Text('${widget.candidates.length} Tabellen erkannt'),
      content: SizedBox(
        width: 480,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wähle die Tabellen die importiert werden sollen:',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: widget.candidates.length,
                itemBuilder: (ctx, i) {
                  final c = widget.candidates[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(6),
                      color: _selected[i]
                          ? AppTheme.accentBg(context)
                          : null,
                    ),
                    child: CheckboxListTile(
                      dense: true,
                      value: _selected[i],
                      onChanged: (v) =>
                          setState(() => _selected[i] = v ?? false),
                      title: Text(c.name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        '${c.entries.length} Einträge  ·  '
                        '${c.language.toUpperCase()}  ·  '
                        '${c.entries.take(3).map((e) => e.content).join(', ')}…',
                        style: TextStyle(
                            fontSize: 11, color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      activeColor: AppTheme.accentText(context),
                      checkColor: cs.surface,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(0),
          child: const Text('Abbrechen'),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: _saving
                  ? null
                  : () => setState(
                      () => _selected = List.filled(_selected.length, true)),
              child: const Text('Alle'),
            ),
            TextButton(
              onPressed: _saving
                  ? null
                  : () => setState(
                      () => _selected = List.filled(_selected.length, false)),
              child: const Text('Keine'),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: (_saving || selectedCount == 0) ? null : _import,
          icon: _saving
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.save_alt_outlined, size: 16),
          label: Text(_saving
              ? 'Importiere…'
              : '$selectedCount importieren'),
        ),
      ],
    );
  }

  Future<void> _import() async {
    final toImport = <RawCandidate>[];
    for (int i = 0; i < widget.candidates.length; i++) {
      if (_selected[i]) toImport.add(widget.candidates[i]);
    }
    setState(() => _saving = true);
    final saved = await ref
        .read(importControllerProvider.notifier)
        .saveMultiple(toImport);
    if (mounted) Navigator.of(context).pop(saved);
  }
}

// ── Source-Metadaten-Block ────────────────────────────────────────────────────

class _SourceMetaBlock extends ConsumerWidget {
  final ImportScreenState state;
  const _SourceMetaBlock({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = state.draft!;
    final tertiary = AppTheme.textTertiary(context);
    final warnBg = AppTheme.warnBg(context);
    final warnText = AppTheme.warnText(context);
    final warnBorder = AppTheme.warnBorder(context);

    void update(ImportDraft Function(ImportDraft) fn) =>
        ref.read(importControllerProvider.notifier).updateDraft(fn);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp16, vertical: AppTheme.sp8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quelle', style: TextStyle(fontSize: 10, color: tertiary)),
          const SizedBox(height: AppTheme.sp8),
          Wrap(
            spacing: AppTheme.sp16,
            runSpacing: AppTheme.sp4,
            children: [
              _MetaField(
                label: 'Quelle:',
                value: draft.sourceTitle,
                onChanged: (v) =>
                    update((d) => d.copyWith(sourceTitle: v)),
              ),
              _MetaField(
                label: 'Datum:',
                value: draft.sourceDate ??
                    DateTime.now()
                        .toIso8601String()
                        .substring(0, 10),
                onChanged: (v) =>
                    update((d) => d.copyWith(sourceDate: v)),
              ),
              _MetaField(
                label: 'Autor:',
                value: draft.sourceAuthor,
                onChanged: (v) =>
                    update((d) => d.copyWith(sourceAuthor: v)),
              ),
              draft.license != null
                  ? _MetaField(
                      label: 'Lizenz:',
                      value: draft.license!,
                      onChanged: (v) =>
                          update((d) => d.copyWith(license: v)),
                    )
                  : GestureDetector(
                      onTap: () => update(
                          (d) => d.copyWith(license: 'unbekannt')),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.sp8, vertical: 3),
                        decoration: BoxDecoration(
                          color: warnBg,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: warnBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 11, color: warnText),
                            const SizedBox(width: 4),
                            Text(
                              'Lizenz nicht angegeben · festlegen',
                              style: TextStyle(
                                  fontSize: 11, color: warnText),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;

  const _MetaField(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tertiary = AppTheme.textTertiary(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: tertiary)),
        const SizedBox(width: 4),
        IntrinsicWidth(
          child: TextFormField(
            initialValue: value ?? '',
            style: TextStyle(fontSize: 12, color: cs.onSurface),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ── Bottom-Bar ────────────────────────────────────────────────────────────────

class _BottomBar extends ConsumerWidget {
  final ImportScreenState state;
  const _BottomBar({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tertiary = AppTheme.textTertiary(context);
    final ctrl = ref.read(importControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.sp16, vertical: 8),
      child: Row(
        children: [
          Text('Nach dem Speichern:',
              style: TextStyle(fontSize: 11, color: tertiary)),
          const SizedBox(width: AppTheme.sp12),
          Row(
            children: [
              Checkbox(
                value: state.saveAndContinue,
                onChanged: (v) =>
                    ctrl.toggleSaveAndContinue(v ?? false),
                visualDensity: VisualDensity.compact,
              ),
              Text('Weitere importieren',
                  style: TextStyle(fontSize: 12, color: cs.onSurface)),
            ],
          ),
          const SizedBox(width: AppTheme.sp12),
          Row(
            children: [
              Checkbox(
                value: state.saveAndOpen,
                onChanged: (v) => ctrl.toggleSaveAndOpen(v ?? false),
                visualDensity: VisualDensity.compact,
              ),
              Text('Sofort öffnen',
                  style: TextStyle(fontSize: 12, color: cs.onSurface)),
            ],
          ),
          const Spacer(),
          if (state.draft != null)
            Text(
              '${state.draft!.tags.length} Tags · '
              '${state.draft!.entries.length} Einträge',
              style: TextStyle(fontSize: 11, color: tertiary),
            ),
        ],
      ),
    );
  }
}

// ── Hilfszustände ─────────────────────────────────────────────────────────────

class _IdleHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.file_upload_outlined,
              size: 40, color: cs.onSurfaceVariant.withAlpha(80)),
          const SizedBox(height: AppTheme.sp16),
          Text(
            'URL eingeben, Datei wählen oder Text einfügen',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppTheme.sp8),
          Text(
            'Unterstützt: URL, Reddit, CSV, XLSX, TXT, Markdown',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final warnBg = AppTheme.warnBg(context);
    final warnText = AppTheme.warnText(context);
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppTheme.sp32),
        padding: const EdgeInsets.all(AppTheme.sp16),
        decoration: BoxDecoration(
          color: warnBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: warnText, size: 32),
            const SizedBox(height: AppTheme.sp8),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: warnText)),
          ],
        ),
      ),
    );
  }
}
