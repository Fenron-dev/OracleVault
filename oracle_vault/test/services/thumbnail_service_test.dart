// Tests für ThumbnailService: Generierung, Caching, kein Hochskalieren,
// Eviction, Nicht-Bild-Assets.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:oracle_vault/data/db/vault_database.dart';
import 'package:oracle_vault/services/media/media_service.dart';
import 'package:oracle_vault/services/media/thumbnail_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory vaultDir;
  late VaultDatabase db;
  late MediaService media;
  late ThumbnailService thumbs;

  setUp(() async {
    vaultDir = await Directory.systemTemp.createTemp('ov_thumb_test');
    db = VaultDatabase.inMemory();
    thumbs = ThumbnailService(vaultPath: vaultDir.path);
    media = MediaService(
        db: db, vaultPath: vaultDir.path, thumbnails: thumbs);
  });

  tearDown(() async {
    await db.close();
    if (await vaultDir.exists()) await vaultDir.delete(recursive: true);
  });

  // Erzeugt ein echtes PNG der angegebenen Größe und importiert es als Asset.
  Future<MediaFile> importImage(String name, int w, int h) async {
    final image = img.Image(w, h);
    img.fill(image, img.getColor(120, 90, 200));
    final src = File(p.join(vaultDir.path, '_src', name));
    await src.create(recursive: true);
    await src.writeAsBytes(img.encodePng(image));
    return media.importFile(src);
  }

  test('erzeugt Thumbnail und skaliert auf längere Kante', () async {
    final m = await importImage('big.png', 800, 600);
    final thumb = await thumbs.thumbnailFor(m, size: 256);

    expect(thumb, isNotNull);
    expect(await thumb!.exists(), isTrue);
    expect(thumb.path, thumbs.cachePathFor(m.hash, 256));

    final decoded = img.decodeImage(await thumb.readAsBytes())!;
    expect(decoded.width, 256); // breiter als hoch → Breite = size
    expect(decoded.height, 192); // Seitenverhältnis erhalten
  });

  test('skaliert kleine Bilder nicht hoch', () async {
    final m = await importImage('small.png', 100, 80);
    final thumb = await thumbs.thumbnailFor(m, size: 256);

    final decoded = img.decodeImage(await thumb!.readAsBytes())!;
    expect(decoded.width, 100);
    expect(decoded.height, 80);
  });

  test('zweiter Aufruf nutzt den Cache (gleiche Datei)', () async {
    final m = await importImage('c.png', 400, 400);
    final first = await thumbs.thumbnailFor(m, size: 128);
    final firstModified = await first!.lastModified();

    final second = await thumbs.thumbnailFor(m, size: 128);
    expect(second!.path, first.path);
    expect(await second.lastModified(), firstModified); // nicht neu erzeugt
  });

  test('evict entfernt gecachte Thumbnails', () async {
    final m = await importImage('e.png', 300, 300);
    await thumbs.thumbnailFor(m, size: 64);
    await thumbs.thumbnailFor(m, size: 128);
    expect(File(thumbs.cachePathFor(m.hash, 64)).existsSync(), isTrue);

    await thumbs.evict(m);

    expect(File(thumbs.cachePathFor(m.hash, 64)).existsSync(), isFalse);
    expect(File(thumbs.cachePathFor(m.hash, 128)).existsSync(), isFalse);
  });

  test('gibt null für Nicht-Bild-Assets zurück', () async {
    final src = File(p.join(vaultDir.path, '_src', 'doc.pdf'));
    await src.create(recursive: true);
    await src.writeAsString('not an image');
    final m = await media.importFile(src);
    expect(m.type, 'document');

    expect(await thumbs.thumbnailFor(m), isNull);
  });

  test('begrenzte Parallelität: viele Anfragen liefern alle Thumbnails',
      () async {
    final pool = ThumbnailService(vaultPath: vaultDir.path, maxConcurrent: 2);
    final items = <MediaFile>[];
    for (var i = 0; i < 6; i++) {
      items.add(await importImage('p$i.png', 200 + i, 150));
    }
    final results =
        await Future.wait(items.map((m) => pool.thumbnailFor(m, size: 64)));
    expect(results.every((f) => f != null), isTrue);
  });

  // ── Aufräumen (Issue #23) ───────────────────────────────────────────────

  test('deleteMedia räumt den Thumbnail-Cache mit weg', () async {
    final asset = await importImage('karte.png', 400, 300);
    final thumb = await thumbs.thumbnailFor(asset);
    expect(await thumb!.exists(), isTrue);

    await media.deleteMedia(asset);

    expect(await thumb.exists(), isFalse,
        reason: 'der Cache liegt unter dem Hash — ein neues Asset mit '
            'demselben Inhalt bekäme sonst das alte Bild');
  });

  test('deleteMedia behält den Cache, solange ein zweiter Record ihn teilt',
      () async {
    final asset = await importImage('karte.png', 400, 300);
    final thumb = await thumbs.thumbnailFor(asset);

    // Zweiter Record auf denselben Hash (Deduplizierung teilt sich Datei
    // und Cache).
    await db.mediaDao.insertMedia(MediaFilesCompanion.insert(
      id: 'zwilling',
      filePath: asset.filePath,
      type: asset.type,
      hash: asset.hash,
      createdAt: DateTime.now(),
    ));

    await media.deleteMedia(asset);
    expect(await thumb!.exists(), isTrue);
  });

  test('clearCache leert den gesamten Cache', () async {
    final a = await importImage('a.png', 400, 300);
    final b = await importImage('b.png', 300, 400);
    await thumbs.thumbnailFor(a);
    await thumbs.thumbnailFor(b);

    expect(await thumbs.clearCache(), 2);
    expect(Directory(thumbs.cacheDir()).listSync(), isEmpty);
  });
}
