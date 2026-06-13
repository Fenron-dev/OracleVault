// Datei: lib/features/tables/ai_generate_screen.dart
//
// ZWECK: KI-gestützte Tabellen-Generierung — Nutzer gibt einen Prompt ein,
//        KI erzeugt eine vollständige Tabelle mit Einträgen.
//        Nach der Generierung wird der Import-Screen mit dem Ergebnis befüllt
//        (gleicher Review-Flow wie beim URL-Import).
// ABHÄNGIGKEITEN: llm_profiles_store, llm_tasks, import_controller
// PHASE: 3

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../features/import/import_controller.dart';
import '../../features/import/import_state.dart';
import '../../services/llm/llm_profiles_store.dart';
import '../../services/llm/llm_service.dart';
import '../../services/llm/llm_tasks.dart';

class AiGenerateScreen extends ConsumerStatefulWidget {
  const AiGenerateScreen({super.key});

  @override
  ConsumerState<AiGenerateScreen> createState() =>
      _AiGenerateScreenState();
}

class _AiGenerateScreenState extends ConsumerState<AiGenerateScreen> {
  final _promptCtrl = TextEditingController();
  int _count = 20;
  String _oracleType = 'uniform';
  String _language = 'de';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    if (_promptCtrl.text.trim().isEmpty) return;

    final profilesState = ref.read(llmProfilesProvider);
    if (!profilesState.aiEnabled) {
      setState(() => _error = 'KI ist in den Einstellungen deaktiviert.');
      return;
    }
    final profile =
        profilesState.profileForTask(LlmTask.generation);
    if (profile == null) {
      setState(() =>
          _error = 'Kein KI-Profil konfiguriert.\n'
              'Einstellungen → KI → Profil anlegen.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final apiKey = await ref
          .read(llmProfilesProvider.notifier)
          .loadApiKey(profile.id);
      final service = LlmService(profile: profile, apiKey: apiKey);
      final tasks = LlmTasks(service);

      final result = await tasks.generateTable(
        prompt: _promptCtrl.text.trim(),
        count: _count,
        language: _language,
        oracleType: _oracleType,
      );

      // Ergebnis in ImportController schreiben → Import-Review-Screen öffnen.
      final draft = ImportDraft(
        name: result.name,
        oracleType: result.oracleType,
        diceExpr: result.diceExpr,
        language: result.language ?? _language,
        entries: result.entries
            .map((e) => RawEntry(
                  content: e.content,
                  rollMin: e.rollMin,
                  rollMax: e.rollMax,
                  confidence: e.confidence,
                ))
            .toList(),
        tags: result.suggestedTags,
        genre: result.genre,
        sourceTitle: 'KI-Generierung',
      );

      // AI-Source-Tracking: wird beim Speichern im ImportController ergänzt.
      final candidate = RawCandidate(
        name: result.name,
        oracleType: result.oracleType,
        diceExpr: result.diceExpr,
        entries: result.entries
            .map((e) => RawEntry(content: e.content))
            .toList(),
        language: result.language ?? _language,
        sourceText:
            'Generiert von ${profile.name} · ${profile.defaultModel}\n\nPrompt: ${_promptCtrl.text}',
        sourceTitle: 'KI: ${result.name}',
      );

      ref.read(importControllerProvider.notifier).setFromAiGeneration(
        candidate: candidate,
        draft: draft,
        source: ImportSource(
            type: ImportSourceType.paste,
            raw: 'ai:${profile.id}'),
      );

      if (mounted) context.go(AppRoutes.importScreen);
    } on LlmException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Fehler: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final profilesState = ref.watch(llmProfilesProvider);
    final hasProfile =
        profilesState.profileForTask(LlmTask.generation) != null;
    final borderColor = AppTheme.border(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tabelle generieren')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.sp24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Kein Profil ────────────────────────────────────────
                if (!hasProfile || !profilesState.aiEnabled)
                  Container(
                    padding: const EdgeInsets.all(AppTheme.sp12),
                    decoration: BoxDecoration(
                      color: AppTheme.warnBg(context),
                      border: Border.all(
                          color: AppTheme.warnBorder(context)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          !profilesState.aiEnabled
                              ? 'KI ist deaktiviert.'
                              : 'Kein KI-Profil konfiguriert.',
                          style: TextStyle(
                              color: AppTheme.warnText(context)),
                        ),
                        TextButton(
                          onPressed: () =>
                              context.push(AppRoutes.aiSettings),
                          child: const Text('Jetzt einrichten'),
                        ),
                      ],
                    ),
                  )
                else ...[
                  // ── Prompt ────────────────────────────────────────────
                  Text('Beschreibe die Tabelle',
                      style: Theme.of(context).textTheme.titleSmall),
                  const Gap(AppTheme.sp8),
                  TextField(
                    controller: _promptCtrl,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'z. B. „30 verlassene Orte für ein düsteres Fantasy-Setting"\n'
                          'oder „D20 seltsame Geräusche in einem alten Wald"',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: borderColor)),
                    ),
                  ),
                  const Gap(AppTheme.sp16),

                  // ── Einstellungen ─────────────────────────────────────
                  Row(
                    children: [
                      // Anzahl
                      Expanded(
                        child: _SettingField(
                          label: 'Anzahl Einträge',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _count,
                              isDense: true,
                              items: [10, 20, 30, 50, 100]
                                  .map((n) => DropdownMenuItem(
                                      value: n,
                                      child: Text('$n')))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _count = v ?? 20),
                            ),
                          ),
                        ),
                      ),
                      const Gap(AppTheme.sp8),
                      // Typ
                      Expanded(
                        child: _SettingField(
                          label: 'Typ',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _oracleType,
                              isDense: true,
                              items: const [
                                DropdownMenuItem(
                                    value: 'uniform',
                                    child: Text('Gleichverteilt')),
                                DropdownMenuItem(
                                    value: 'dice',
                                    child: Text('Würfeltabelle')),
                              ],
                              onChanged: (v) => setState(
                                  () => _oracleType = v ?? 'uniform'),
                            ),
                          ),
                        ),
                      ),
                      const Gap(AppTheme.sp8),
                      // Sprache
                      Expanded(
                        child: _SettingField(
                          label: 'Sprache',
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _language,
                              isDense: true,
                              items: const [
                                DropdownMenuItem(
                                    value: 'de',
                                    child: Text('Deutsch')),
                                DropdownMenuItem(
                                    value: 'en',
                                    child: Text('Englisch')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _language = v ?? 'de'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppTheme.sp8),

                  // Aktives Profil anzeigen
                  Builder(builder: (ctx) {
                    final p = profilesState
                        .profileForTask(LlmTask.generation)!;
                    return Text(
                      'Modell: ${p.name} · ${p.defaultModel}',
                      style: TextStyle(
                          fontSize: 11, color: cs.onSurfaceVariant),
                    );
                  }),
                ],

                const Gap(AppTheme.sp16),

                // ── Fehler ────────────────────────────────────────────
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppTheme.sp12),
                    decoration: BoxDecoration(
                      color: AppTheme.warnBg(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_error!,
                        style: TextStyle(
                            color: AppTheme.warnText(context))),
                  ),
                  const Gap(AppTheme.sp12),
                ],

                // ── Generieren-Button ─────────────────────────────────
                FilledButton.icon(
                  onPressed:
                      (_loading || !hasProfile || !profilesState.aiEnabled)
                          ? null
                          : _generate,
                  icon: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome_outlined),
                  label: Text(_loading
                      ? 'Generiere…'
                      : 'Tabelle generieren'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingField extends StatelessWidget {
  final String label;
  final Widget child;
  const _SettingField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final borderColor = AppTheme.border(context);
    final tertiary = AppTheme.textTertiary(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 10, color: tertiary)),
        const SizedBox(height: 3),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.sp8, vertical: 5),
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
