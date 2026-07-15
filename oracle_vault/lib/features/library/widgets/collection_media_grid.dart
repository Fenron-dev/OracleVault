// Datei: lib/features/library/widgets/collection_media_grid.dart
//
// ZWECK: Medien-Grid für eine aktive Collection (Battlemaps/Token/Deck).
//        Zeigt alle Einträge mit angehängtem Medium als Thumbnail-Kacheln.
//        Tap auf eine Kachel öffnet die Vollansicht (über MediaThumbnail).
// PHASE: 4

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../library_providers.dart';
import 'media_thumbnail.dart';

class CollectionMediaGrid extends ConsumerWidget {
  const CollectionMediaGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(collectionMediaEntriesProvider);

    return entriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) =>
          const Center(child: Text('Fehler beim Laden der Medien')),
      data: (entries) {
        if (entries.isEmpty) {
          return _EmptyState();
        }
        return GridView.builder(
          padding: const EdgeInsets.all(AppTheme.sp16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 160,
            mainAxisSpacing: AppTheme.sp12,
            crossAxisSpacing: AppTheme.sp12,
            childAspectRatio: 0.85,
          ),
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final entry = entries[i];
            return _MediaTile(
              mediaId: entry.mediaId!,
              caption: entry.content,
            );
          },
        );
      },
    );
  }
}

class _MediaTile extends StatelessWidget {
  final String mediaId;
  final String caption;
  const _MediaTile({required this.mediaId, required this.caption});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) => Center(
              child: MediaThumbnail(
                mediaId: mediaId,
                size: c.maxWidth,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.sp4),
        Text(
          caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_outlined, size: 32, color: cs.onSurfaceVariant),
          const SizedBox(height: AppTheme.sp8),
          Text(
            'Keine Medien in dieser Collection',
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppTheme.sp4),
          Text(
            'Hänge Einträgen Bilder an, um sie hier zu sehen.',
            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
