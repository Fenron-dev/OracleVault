// Datei: lib/features/vault_picker/vault_picker_screen.dart
//
// ZWECK: Startbildschirm — zeigt zuletzt geöffnete Vaults und ermöglicht
//        das Öffnen eines bestehenden oder Anlegen eines neuen Vaults.
//        Pattern: Obsidian-Vault-Picker.
//
// ABLAUF:
//   Vault öffnen: file_picker → Ordner wählen → VaultManager.open() →
//                 activeVaultProvider setzen → Router leitet auf /library
//   Vault anlegen: file_picker → Ordner wählen → VaultManager.create() →
//                  activeVaultProvider setzen
//
// ABHÄNGIGKEITEN: flutter_riverpod, file_picker, go_router, di.dart,
//                 vault_manager.dart, recent_vaults_store.dart
// PHASE: 0 – Grundgerüst.

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../core/di.dart';
import '../../core/theme.dart';
import '../../data/vault/recent_vaults_store.dart';
import '../../data/vault/vault_manager.dart';

/// Riverpod-Provider für die Recent-Vaults-Liste.
///
/// FutureProvider: lädt einmal beim Start, wird nach jedem Öffnen/Anlegen
/// via ref.invalidate() neu geladen.
final recentVaultsProvider =
    FutureProvider<List<RecentVault>>((ref) => RecentVaultsStore.load());

/// Startbildschirm der App.
class VaultPickerScreen extends ConsumerStatefulWidget {
  const VaultPickerScreen({super.key});

  @override
  ConsumerState<VaultPickerScreen> createState() => _VaultPickerScreenState();
}

class _VaultPickerScreenState extends ConsumerState<VaultPickerScreen> {
  bool _loading = false;
  String? _error;

  // ── Vault öffnen ────────────────────────────────────────────────────────

  Future<void> _openVault({String? preselectedPath}) async {
    String? path = preselectedPath;

    if (path == null) {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Vault-Ordner öffnen',
      );
      if (result == null) return; // Abgebrochen
      path = result;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final opened = await VaultManager.open(path);
      final config = await VaultManager.readConfig(path);
      final name = config['name'] as String? ?? 'Vault';
      await RecentVaultsStore.touch(path, name);
      ref.read(activeVaultProvider.notifier).state = opened;
      ref.invalidate(recentVaultsProvider);
    } on VaultNotFoundException {
      // Kein Vault — anbieten einen neuen anzulegen.
      if (mounted) {
        final create = await _showNotAVaultDialog(path);
        if (create == true) {
          await _createVaultAt(path);
          return;
        }
      }
      setState(() => _error = 'Kein Vault gefunden unter: $path');
    } catch (e) {
      setState(() => _error = 'Fehler beim Öffnen: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Vault anlegen ────────────────────────────────────────────────────────

  Future<void> _createVault() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Ordner für neuen Vault wählen',
    );
    if (result == null) return;
    await _createVaultAt(result);
  }

  Future<void> _createVaultAt(String path) async {
    // Vault-Namen vom Nutzer abfragen.
    if (!mounted) return;
    final name = await _showNameDialog(defaultName: _folderName(path));
    if (name == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final opened =
          await VaultManager.create(path, name: name, language: 'de');
      await RecentVaultsStore.touch(path, name);
      ref.read(activeVaultProvider.notifier).state = opened;
      ref.invalidate(recentVaultsProvider);
    } on VaultAlreadyExistsException {
      // Bereits ein Vault — direkt öffnen.
      await _openVault(preselectedPath: path);
    } catch (e) {
      setState(() => _error = 'Fehler beim Anlegen: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Dialoge ─────────────────────────────────────────────────────────────

  Future<bool?> _showNotAVaultDialog(String path) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Kein Vault gefunden'),
          content: Text(
            '„${_folderName(path)}" enthält noch keinen OracleVault.\n'
            'Soll ein neuer Vault in diesem Ordner angelegt werden?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Vault anlegen'),
            ),
          ],
        ),
      );

  Future<String?> _showNameDialog({required String defaultName}) async {
    final controller = TextEditingController(text: defaultName);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vault-Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Mein Vault'),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );
  }

  // ── Hilfsmethoden ────────────────────────────────────────────────────────

  String _folderName(String path) => path.split(RegExp(r'[/\\]')).last;

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final recentsAsync = ref.watch(recentVaultsProvider);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.sp32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Logo / Titel ───────────────────────────────────────
                Icon(Icons.auto_stories_outlined,
                    size: 64, color: cs.primary),
                const Gap(AppTheme.sp16),
                Text(
                  'OracleVault',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Lokal-first Random-Tabellen-Verwaltung',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const Gap(AppTheme.sp32),

                // ── Fehler-Anzeige ─────────────────────────────────────
                if (_error != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.all(AppTheme.sp12),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: cs.onErrorContainer),
                    ),
                  ),
                  const Gap(AppTheme.sp16),
                ],

                // ── Aktions-Buttons ────────────────────────────────────
                FilledButton.icon(
                  onPressed: _loading ? null : _openVault,
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Vault öffnen …'),
                ),
                const Gap(AppTheme.sp8),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _createVault,
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: const Text('Neuen Vault anlegen …'),
                ),

                // ── Recent-Vaults-Liste ────────────────────────────────
                recentsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (recents) {
                    if (recents.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(AppTheme.sp32),
                        Text(
                          'Zuletzt geöffnet',
                          style: theme.textTheme.labelMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const Gap(AppTheme.sp8),
                        ...recents.map((vault) =>
                            _RecentVaultTile(
                              vault: vault,
                              onTap: () => _openVault(
                                  preselectedPath: vault.path),
                              onRemove: () async {
                                await RecentVaultsStore.remove(
                                    vault.path);
                                ref.invalidate(recentVaultsProvider);
                              },
                            )),
                      ],
                    );
                  },
                ),

                if (_loading) ...[
                  const Gap(AppTheme.sp24),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Recent-Vault-Kachel ───────────────────────────────────────────────────────

class _RecentVaultTile extends StatelessWidget {
  final RecentVault vault;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentVaultTile({
    required this.vault,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dateStr = DateFormat('dd.MM.yyyy HH:mm').format(vault.lastOpened);

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: AppTheme.sp8),
      leading: Icon(Icons.book_outlined, color: cs.primary),
      title: Text(vault.name,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        vault.path,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall
            ?.copyWith(color: cs.onSurfaceVariant),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateStr,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const Gap(AppTheme.sp4),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            tooltip: 'Aus Liste entfernen',
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
