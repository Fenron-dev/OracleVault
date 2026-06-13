// Datei: lib/features/settings/backup_settings_screen.dart
//
// ZWECK: Backup- und Restore-UI für den aktiven Vault.
//        Zeigt vorhandene Backups, ermöglicht manuelle Backups,
//        JSON-Export und Wiederherstellung.
// ABHÄNGIGKEITEN: flutter_riverpod, path_provider, backup_service.dart, di.dart
// PHASE: 0 – Pflichtfeature.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/di.dart';
import '../../core/theme.dart';
import '../../data/vault/vault_manager.dart';
import '../../services/backup_service.dart';

/// Backup-Einträge als Riverpod-Provider.
final backupListProvider =
    FutureProvider<List<BackupEntry>>((ref) async {
  final vault = ref.watch(activeVaultProvider);
  if (vault == null) return [];
  return BackupService.listBackups(vault.vaultPath);
});

/// Backup- und Restore-Screen.
class BackupSettingsScreen extends ConsumerStatefulWidget {
  const BackupSettingsScreen({super.key});

  @override
  ConsumerState<BackupSettingsScreen> createState() =>
      _BackupSettingsScreenState();
}

class _BackupSettingsScreenState
    extends ConsumerState<BackupSettingsScreen> {
  bool _working = false;
  String? _message;

  Future<void> _runAction(Future<BackupResult> Function() action) async {
    setState(() {
      _working = true;
      _message = null;
    });
    try {
      final result = await action();
      if (mounted) {
        setState(() => _message = result.success
            ? '✓ ${result.path != null ? "Gespeichert unter: ${result.path}" : "Erfolgreich"}'
            : '✗ ${result.error}');
      }
    } catch (e) {
      if (mounted) setState(() => _message = '✗ Fehler: $e');
    } finally {
      if (mounted) {
        setState(() => _working = false);
        ref.invalidate(backupListProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vault = ref.watch(activeVaultProvider);
    final backupsAsync = ref.watch(backupListProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (vault == null) {
      return const Scaffold(
        body: Center(child: Text('Kein Vault geöffnet')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Daten')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.sp16),
        children: [
          // ── Status-Nachricht ─────────────────────────────────────────
          if (_message != null) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.sp12),
              decoration: BoxDecoration(
                color: _message!.startsWith('✓')
                    ? cs.primaryContainer
                    : cs.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _message!,
                style: TextStyle(
                  color: _message!.startsWith('✓')
                      ? cs.onPrimaryContainer
                      : cs.onErrorContainer,
                ),
              ),
            ),
            const Gap(AppTheme.sp16),
          ],

          // ── Aktionen ─────────────────────────────────────────────────
          const _SectionHeader('Backup erstellen'),
          ListTile(
            leading: const Icon(Icons.save_outlined),
            title: const Text('Auto-Backup jetzt ausführen'),
            subtitle: const Text('Speichert index.db im Backups-Ordner'),
            onTap: _working
                ? null
                : () => _runAction(
                    () => BackupService.createAutoBackup(vault.vaultPath)),
          ),
          ListTile(
            leading: const Icon(Icons.archive_outlined),
            title: const Text('JSON-Voll-Export'),
            subtitle:
                const Text('Schema-unabhängiges JSON aller Entitäten'),
            onTap: _working
                ? null
                : () async {
                    final dir =
                        await getApplicationDocumentsDirectory();
                    await _runAction(() => BackupService.createJsonExport(
                        vault.database, vault.vaultPath, dir.path));
                  },
          ),
          ListTile(
            leading: const Icon(Icons.folder_zip_outlined),
            title: const Text('ZIP-Backup des gesamten Vaults'),
            subtitle: const Text('Inkl. Medien-Ordner, ohne Thumbnails'),
            onTap: _working
                ? null
                : () async {
                    final dir =
                        await getApplicationDocumentsDirectory();
                    await _runAction(() =>
                        BackupService.createZipBackup(
                            vault.vaultPath, dir.path));
                  },
          ),

          if (_working) ...[
            const Gap(AppTheme.sp16),
            const Center(child: CircularProgressIndicator()),
          ],

          const Gap(AppTheme.sp16),
          const Divider(),
          const Gap(AppTheme.sp8),

          // ── Vorhandene Backups ────────────────────────────────────────
          const _SectionHeader('Vorhandene Backups'),
          backupsAsync.when(
            loading: () => const Center(
                child: Padding(
              padding: EdgeInsets.all(AppTheme.sp16),
              child: CircularProgressIndicator(),
            )),
            error: (e, _) => Text('Fehler: $e'),
            data: (backups) {
              if (backups.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppTheme.sp16),
                  child: Text(
                    'Noch keine Backups vorhanden.',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                );
              }
              return Column(
                children: backups
                    .map((b) => _BackupTile(
                          entry: b,
                          onRestore: () => _confirmRestore(context, vault, b),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRestore(
      BuildContext context, OpenedVault vault, BackupEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vault wiederherstellen?'),
        content: Text(
          'Alle aktuellen Daten werden durch das Backup\n'
          '"${entry.filename}" ersetzt.\n\n'
          'Diese Aktion kann nicht rückgängig gemacht werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Wiederherstellen'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _runAction(() =>
        BackupService.restoreFromDbSnapshot(vault.vaultPath, entry.path));
  }
}

// ── Hilfsmethoden ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _BackupTile extends StatelessWidget {
  final BackupEntry entry;
  final VoidCallback onRestore;

  const _BackupTile({required this.entry, required this.onRestore});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dateStr =
        DateFormat('dd.MM.yyyy HH:mm').format(entry.createdAt);
    final sizeKb = (entry.sizeBytes / 1024).toStringAsFixed(1);

    return ListTile(
      leading: Icon(_typeIcon(entry.type), color: cs.primary),
      title: Text(entry.filename,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('$dateStr · $sizeKb KB'),
      trailing: TextButton(
        onPressed: onRestore,
        child: const Text('Wiederherstellen'),
      ),
    );
  }

  IconData _typeIcon(BackupType type) => switch (type) {
        BackupType.preMigration => Icons.update,
        BackupType.auto => Icons.schedule,
        BackupType.manual => Icons.save,
        BackupType.jsonExport => Icons.data_object,
      };
}
