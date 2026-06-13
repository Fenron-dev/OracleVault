// Datei: lib/features/library/widgets/media_thumbnail.dart
//
// ZWECK: Zeigt das Thumbnail eines Media-Assets (per mediaId) an.
//        - Bilder: gecachtes Thumbnail (ThumbnailService), Tap → Vollansicht
//        - Andere Typen: Typ-Icon (Audio/Video/Dokument)
// ABHÄNGIGKEITEN: flutter, flutter_riverpod, di.dart, vault_database.dart
// PHASE: 4

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di.dart';
import '../../../data/db/vault_database.dart';

/// Kleines Vorschaubild für ein Media-Asset, referenziert über [mediaId].
class MediaThumbnail extends ConsumerWidget {
  final String mediaId;
  final double size;

  const MediaThumbnail({super.key, required this.mediaId, this.size = 40});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vault = ref.watch(activeVaultProvider);
    final mediaSvc = ref.watch(mediaServiceProvider);
    final thumbSvc = ref.watch(thumbnailServiceProvider);

    if (vault == null || mediaSvc == null) {
      return _IconBox(size: size, icon: Icons.broken_image_outlined);
    }

    return FutureBuilder<MediaFile?>(
      future: vault.database.mediaDao.fetchById(mediaId),
      builder: (context, snap) {
        final media = snap.data;
        if (media == null) {
          return _IconBox(size: size, icon: Icons.broken_image_outlined);
        }
        if (media.type != 'image') {
          return _IconBox(size: size, icon: _iconForType(media.type));
        }
        return FutureBuilder<File?>(
          future: thumbSvc?.thumbnailFor(media, size: (size * 2).round()),
          builder: (context, ts) {
            final file = ts.data;
            final image = file != null
                ? Image.file(file,
                    width: size, height: size, fit: BoxFit.cover)
                : _IconBox(size: size, icon: Icons.image_outlined);
            return GestureDetector(
              onTap: () =>
                  _showFull(context, mediaSvc.absolutePath(media), media.title),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: image,
              ),
            );
          },
        );
      },
    );
  }

  static IconData _iconForType(String type) => switch (type) {
        'audio' => Icons.audiotrack,
        'video' => Icons.movie_outlined,
        _ => Icons.description_outlined,
      };

  void _showFull(BuildContext context, String absolutePath, String? title) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null && title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(title,
                    style: Theme.of(context).textTheme.titleSmall),
              ),
            Flexible(
              child: InteractiveViewer(
                child: Image.file(File(absolutePath)),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Schließen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final double size;
  final IconData icon;
  const _IconBox({required this.size, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: size * 0.5, color: cs.onSurfaceVariant),
    );
  }
}
