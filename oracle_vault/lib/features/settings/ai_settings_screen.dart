// Datei: lib/features/settings/ai_settings_screen.dart
//
// ZWECK: KI-Einstellungen — Provider-Profile anlegen/bearbeiten/löschen,
//        Verbindung testen, OpenRouter-Modell-Picker.
// ABHÄNGIGKEITEN: llm_profiles_store, llm_service
// PHASE: 3

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme.dart';
import '../../services/llm/llm_profile.dart';
import '../../services/llm/llm_profiles_store.dart';
import '../../services/llm/llm_service.dart';

const _uuid = Uuid();

class AiSettingsScreen extends ConsumerWidget {
  const AiSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(llmProfilesProvider);
    final cs = Theme.of(context).colorScheme;
    final borderColor = AppTheme.border(context);

    return Scaffold(
      appBar: AppBar(title: const Text('KI-Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.sp16),
        children: [
          // ── KI global ein/aus ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KI-Features',
                        style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      'Tag-Vorschläge, Generierung, Import-Normalisierung',
                      style: TextStyle(
                          fontSize: 11, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Switch(
                value: state.aiEnabled,
                onChanged: (v) => ref
                    .read(llmProfilesProvider.notifier)
                    .setAiEnabled(v),
              ),
            ],
          ),

          const Gap(AppTheme.sp16),
          Divider(color: borderColor),
          const Gap(AppTheme.sp8),

          // ── Profile ───────────────────────────────────────────────────
          Row(
            children: [
              Text('Provider-Profile',
                  style: Theme.of(context).textTheme.titleSmall),
              const Spacer(),
              _AddProfileMenu(),
            ],
          ),
          const Gap(AppTheme.sp8),

          if (state.profiles.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppTheme.sp24),
              child: Center(
                child: Text(
                  'Noch kein Profil. Klicke „+ Profil" um Ollama, '
                  'LM Studio oder OpenRouter einzurichten.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, color: cs.onSurfaceVariant),
                ),
              ),
            ),

          ...state.profiles.map((p) => _ProfileTile(
                profile: p,
                isDefault: p.id == state.defaultProfileId,
              )),
        ],
      ),
    );
  }
}

// ── "+ Profil"-Menü ───────────────────────────────────────────────────────────

class _AddProfileMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentBg = AppTheme.accentBg(context);
    final accentText = AppTheme.accentText(context);
    final accentBorder = AppTheme.accentBorder(context);

    return PopupMenuButton<String>(
      onSelected: (value) async {
        final notifier = ref.read(llmProfilesProvider.notifier);
        LlmProfile profile;
        switch (value) {
          case 'ollama':
            profile = await notifier.addOllamaTemplate();
          case 'lmstudio':
            profile = await notifier.addLmStudioTemplate();
          case 'openrouter':
            profile = await notifier.addOpenRouterTemplate();
          default:
            profile = LlmProfile(
              id: _uuid.v4(),
              name: 'Custom',
              baseUrl: 'http://localhost:8080/v1',
              kind: ProviderKind.custom,
              defaultModel: 'model',
            );
            await notifier.addProfile(profile);
        }
        if (context.mounted) {
          _showProfileEditor(context, ref, profile);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'ollama', child: Text('Ollama (lokal)')),
        PopupMenuItem(
            value: 'lmstudio', child: Text('LM Studio (lokal)')),
        PopupMenuItem(value: 'openrouter', child: Text('OpenRouter')),
        PopupMenuItem(value: 'custom', child: Text('Custom Endpoint')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.sp12, vertical: 5),
        decoration: BoxDecoration(
          color: accentBg,
          border: Border.all(color: accentBorder),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 14, color: accentText),
            const SizedBox(width: 4),
            Text('Profil',
                style:
                    TextStyle(fontSize: 12, color: accentText)),
          ],
        ),
      ),
    );
  }

  void _showProfileEditor(
      BuildContext context, WidgetRef ref, LlmProfile profile) {
    showDialog<void>(
      context: context,
      builder: (_) => _ProfileEditorDialog(profile: profile),
    );
  }
}

// ── Profil-Kachel ─────────────────────────────────────────────────────────────

class _ProfileTile extends ConsumerStatefulWidget {
  final LlmProfile profile;
  final bool isDefault;

  const _ProfileTile({required this.profile, required this.isDefault});

  @override
  ConsumerState<_ProfileTile> createState() => _ProfileTileState();
}

class _ProfileTileState extends ConsumerState<_ProfileTile> {
  bool _testing = false;
  bool? _testResult;
  String? _testError;

  Future<void> _test() async {
    setState(() {
      _testing = true;
      _testResult = null;
      _testError = null;
    });
    try {
      final apiKey = await ref
          .read(llmProfilesProvider.notifier)
          .loadApiKey(widget.profile.id);
      final service = LlmService(profile: widget.profile, apiKey: apiKey);
      final ok = await service.testConnection();
      if (mounted) {
        setState(() {
          _testing = false;
          _testResult = ok;
          if (!ok) _testError = 'Verbindung fehlgeschlagen (kein Fehlerdetail)';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _testing = false;
          _testResult = false;
          _testError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = AppTheme.border(context);
    final bgSec = AppTheme.bgSecondary(context);
    final accentText = AppTheme.accentText(context);
    final notifier = ref.read(llmProfilesProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.sp8),
      decoration: BoxDecoration(
        color: widget.isDefault ? AppTheme.accentBg(context) : bgSec,
        border: Border.all(
          color: widget.isDefault
              ? AppTheme.accentBorder(context)
              : borderColor,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(AppTheme.sp12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_kindIcon(widget.profile.kind),
                  size: 16, color: cs.onSurfaceVariant),
              const Gap(AppTheme.sp8),
              Expanded(
                child: Text(
                  widget.profile.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (widget.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBg(context),
                    border: Border.all(
                        color: AppTheme.accentBorder(context)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Standard',
                      style: TextStyle(
                          fontSize: 10, color: accentText)),
                ),
            ],
          ),
          const Gap(AppTheme.sp4),
          Text(
            '${widget.profile.baseUrl}  ·  ${widget.profile.defaultModel}',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
          if (widget.profile.hasApiKey)
            Text('API-Key: ••••••••',
                style: TextStyle(
                    fontSize: 11, color: cs.onSurfaceVariant)),
          const Gap(AppTheme.sp8),
          if (_testError != null) ...[
            Text(
              _testError!,
              style: TextStyle(fontSize: 10, color: cs.error),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(AppTheme.sp4),
          ],
          Row(
            children: [
              // Test-Verbindung
              _SmallBtn(
                label: _testing
                    ? 'Teste…'
                    : _testResult == null
                        ? 'Verbindung testen'
                        : _testResult!
                            ? '✓ Verbunden'
                            : '✗ Fehler',
                color: _testResult == true
                    ? Colors.green
                    : _testResult == false
                        ? cs.error
                        : null,
                onTap: _testing ? null : _test,
              ),
              const Gap(AppTheme.sp8),
              // Bearbeiten
              _SmallBtn(
                label: 'Bearbeiten',
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (_) =>
                      _ProfileEditorDialog(profile: widget.profile),
                ),
              ),
              const Gap(AppTheme.sp8),
              // Als Standard
              if (!widget.isDefault)
                _SmallBtn(
                  label: 'Standard',
                  onTap: () => notifier.setDefault(widget.profile.id),
                ),
              const Spacer(),
              // Löschen
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 16, color: cs.error),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Profil löschen?'),
                      content:
                          Text('„${widget.profile.name}" entfernen?'),
                      actions: [
                        TextButton(
                            onPressed: () =>
                                Navigator.of(ctx).pop(false),
                            child: const Text('Abbrechen')),
                        FilledButton(
                            onPressed: () =>
                                Navigator.of(ctx).pop(true),
                            child: const Text('Löschen')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    notifier.deleteProfile(widget.profile.id);
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _kindIcon(ProviderKind kind) => switch (kind) {
        ProviderKind.ollama => Icons.computer,
        ProviderKind.lmstudio => Icons.laptop,
        ProviderKind.openrouter => Icons.cloud_outlined,
        ProviderKind.custom => Icons.settings_ethernet,
      };
}

class _SmallBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  const _SmallBtn({required this.label, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border(context)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                color: color ?? cs.onSurface)),
      ),
    );
  }
}

// ── Profil-Editor Dialog ──────────────────────────────────────────────────────

class _ProfileEditorDialog extends ConsumerStatefulWidget {
  final LlmProfile profile;
  const _ProfileEditorDialog({required this.profile});

  @override
  ConsumerState<_ProfileEditorDialog> createState() =>
      _ProfileEditorDialogState();
}

class _ProfileEditorDialogState
    extends ConsumerState<_ProfileEditorDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _urlCtrl;
  late TextEditingController _modelCtrl;
  late TextEditingController _apiKeyCtrl;
  late TextEditingController _maxTokensCtrl;
  late ProviderKind _kind;
  late double _temperature;
  bool _keyVisible = false;
  bool _loadingModels = false;
  List<OpenRouterModel> _openRouterModels = [];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _urlCtrl = TextEditingController(text: widget.profile.baseUrl);
    _modelCtrl = TextEditingController(text: widget.profile.defaultModel);
    _apiKeyCtrl = TextEditingController();
    _maxTokensCtrl = TextEditingController(
        text: widget.profile.maxTokens.toString());
    _kind = widget.profile.kind;
    _temperature = widget.profile.temperature;
    _loadApiKey();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    _modelCtrl.dispose();
    _apiKeyCtrl.dispose();
    _maxTokensCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadApiKey() async {
    final key = await ref
        .read(llmProfilesProvider.notifier)
        .loadApiKey(widget.profile.id);
    if (key != null && mounted) {
      setState(() => _apiKeyCtrl.text = key);
    }
  }

  Future<void> _save() async {
    try {
      final notifier = ref.read(llmProfilesProvider.notifier);
      final updated = widget.profile.copyWith(
        name: _nameCtrl.text.trim(),
        baseUrl: _urlCtrl.text.trim(),
        defaultModel: _modelCtrl.text.trim(),
        kind: _kind,
        maxTokens:
            int.tryParse(_maxTokensCtrl.text.trim()) ??
            widget.profile.maxTokens,
        temperature: _temperature,
      );
      await notifier.updateProfile(updated);
      final key = _apiKeyCtrl.text.trim();
      if (key.isNotEmpty) {
        await notifier.saveApiKey(widget.profile.id, key);
      } else {
        await notifier.deleteApiKey(widget.profile.id);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Speichern: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _loadOpenRouterModels() async {
    if (_apiKeyCtrl.text.trim().isEmpty) return;
    setState(() => _loadingModels = true);
    final models = await LlmService.fetchOpenRouterModels(
        _apiKeyCtrl.text.trim());
    if (mounted) {
      setState(() {
        _openRouterModels = models;
        _loadingModels = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOpenRouter = _kind == ProviderKind.openrouter;

    return AlertDialog(
      title: Text('Profil: ${widget.profile.name}'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Name'),
              ),
              const Gap(AppTheme.sp8),
              InputDecorator(
                decoration:
                    const InputDecoration(labelText: 'Provider-Typ'),
                child: DropdownButton<ProviderKind>(
                  value: _kind,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: ProviderKind.values
                      .map((k) => DropdownMenuItem(
                          value: k, child: Text(_kindLabel(k))))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _kind = v);
                    // URL-Vorausfüllung
                    if (_urlCtrl.text.isEmpty ||
                        _urlCtrl.text == widget.profile.baseUrl) {
                      _urlCtrl.text = switch (v) {
                        ProviderKind.ollama =>
                          'http://localhost:11434/v1',
                        ProviderKind.lmstudio =>
                          'http://localhost:1234/v1',
                        ProviderKind.openrouter =>
                          'https://openrouter.ai/api/v1',
                        _ => _urlCtrl.text,
                      };
                    }
                  },
                ),
              ),
              const Gap(AppTheme.sp8),
              TextField(
                controller: _urlCtrl,
                decoration:
                    const InputDecoration(labelText: 'Base-URL'),
              ),
              const Gap(AppTheme.sp8),
              // Modell-Feld
              if (isOpenRouter && _openRouterModels.isNotEmpty)
                _OpenRouterModelPicker(
                  models: _openRouterModels,
                  selectedId: _modelCtrl.text,
                  onSelected: (id) =>
                      setState(() => _modelCtrl.text = id),
                )
              else
                TextField(
                  controller: _modelCtrl,
                  decoration: InputDecoration(
                    labelText: 'Modell-ID',
                    suffixIcon: isOpenRouter
                        ? IconButton(
                            icon: _loadingModels
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.list, size: 16),
                            tooltip: 'Modelle laden',
                            onPressed: _loadOpenRouterModels,
                          )
                        : null,
                  ),
                ),
              const Gap(AppTheme.sp8),
              TextField(
                controller: _apiKeyCtrl,
                obscureText: !_keyVisible,
                decoration: InputDecoration(
                  labelText: 'API-Key (optional für lokal)',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _keyVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 16,
                    ),
                    onPressed: () =>
                        setState(() => _keyVisible = !_keyVisible),
                  ),
                ),
              ),
              const Gap(AppTheme.sp12),
              // ── Max Output-Tokens ──────────────────────────────────
              TextField(
                controller: _maxTokensCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Output-Tokens',
                  helperText:
                      'Erhöhen wenn Übersetzungen/Generierungen abgeschnitten werden (z. B. 4096)',
                ),
              ),
              const Gap(AppTheme.sp12),
              // ── Temperature ────────────────────────────────────────
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Temperature',
                          style: TextStyle(fontSize: 12)),
                      Text(
                        _temperature.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Slider(
                    value: _temperature,
                    min: 0.0,
                    max: 2.0,
                    divisions: 40,
                    onChanged: (v) =>
                        setState(() => _temperature = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Präzise (0.0)',
                          style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                      Text('Kreativ (2.0)',
                          style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(onPressed: _save, child: const Text('Speichern')),
      ],
    );
  }

  String _kindLabel(ProviderKind k) => switch (k) {
        ProviderKind.ollama => 'Ollama',
        ProviderKind.lmstudio => 'LM Studio',
        ProviderKind.openrouter => 'OpenRouter',
        ProviderKind.custom => 'Custom',
      };
}

// ── OpenRouter Modell-Picker ──────────────────────────────────────────────────

class _OpenRouterModelPicker extends StatefulWidget {
  final List<OpenRouterModel> models;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const _OpenRouterModelPicker({
    required this.models,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  State<_OpenRouterModelPicker> createState() =>
      _OpenRouterModelPickerState();
}

class _OpenRouterModelPickerState
    extends State<_OpenRouterModelPicker> {
  bool _freeOnly = true;
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = widget.models
        .where((m) => !_freeOnly || m.isFree)
        .where((m) =>
            _filter.isEmpty ||
            m.id.toLowerCase().contains(_filter.toLowerCase()) ||
            m.name.toLowerCase().contains(_filter.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Modell', style: TextStyle(fontSize: 11)),
            const Spacer(),
            Row(
              children: [
                Checkbox(
                  value: _freeOnly,
                  onChanged: (v) =>
                      setState(() => _freeOnly = v ?? true),
                  visualDensity: VisualDensity.compact,
                ),
                const Text('Nur Free', style: TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
        TextField(
          decoration:
              const InputDecoration(hintText: 'Filter…'),
          onChanged: (v) => setState(() => _filter = v),
        ),
        const Gap(AppTheme.sp4),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.border(context)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final m = filtered[i];
              final selected = m.id == widget.selectedId;
              return ListTile(
                dense: true,
                title: Text(m.name,
                    style: const TextStyle(fontSize: 12)),
                subtitle: Text(m.id,
                    style: const TextStyle(fontSize: 10)),
                trailing: Text(
                  m.priceLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        m.isFree ? Colors.green : cs.onSurfaceVariant,
                  ),
                ),
                selected: selected,
                selectedTileColor: AppTheme.accentBg(context),
                onTap: () => widget.onSelected(m.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
