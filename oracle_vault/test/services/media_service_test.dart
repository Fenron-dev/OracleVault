// Tests für MediaService: Import, Deduplizierung (SHA-256), Pfadauflösung,
// sicheres Löschen.

import 'dart:io';

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:oracle_vault/data/db/vault_database.dart';
import 'package:oracle_vault/services/media/media_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory vaultDir;
  late VaultDatabase db;
  late MediaService service;

  setUp(() async {
    vaultDir = await Directory.systemTemp.createTemp('ov_media_test');
    db = VaultDatabase.inMemory();
    service = MediaService(db: db, vaultPath: vaultDir.path);
  });

  tearDown(() async {
    await db.close();
    if (await vaultDir.exists()) await vaultDir.delete(recursive: true);
  });

  Future<File> makeSource(String name, String content) async {
    final f = File(p.join(vaultDir.path, '_src', name));
    await f.create(recursive: true);
    await f.writeAsString(content);
    return f;
  }

  test('importFile kopiert Bild nach media/images und füllt Felder', () async {
    final src = await makeSource('map.png', 'fake-png-bytes');
    final media = await service.importFile(src);

    expect(media.type, 'image');
    expect(media.filePath, startsWith('media/images/'));
    expect(media.hash, isNotEmpty);
    expect(media.mime, 'image/png');
    expect(media.title, 'map');

    // physische Datei liegt im Vault und ist auflösbar
    final abs = service.absolutePath(media);
    expect(abs, p.join(vaultDir.path, media.filePath));
    expect(await File(abs).exists(), isTrue);
  });

  test('identischer Inhalt wird dedupliziert (gleicher Record)', () async {
    final a = await makeSource('a.png', 'same-content');
    final b = await makeSource('b.png', 'same-content');

    final first = await service.importFile(a);
    final second = await service.importFile(b);

    expect(second.id, first.id);
    expect(second.hash, first.hash);
    expect((await db.mediaDao.fetchAll()).length, 1);
  });

  test('unterschiedlicher Inhalt erzeugt zwei Records', () async {
    final a = await makeSource('a.png', 'content-1');
    final b = await makeSource('b.png', 'content-2');

    await service.importFile(a);
    await service.importFile(b);

    expect((await db.mediaDao.fetchAll()).length, 2);
  });

  test('deleteMedia entfernt Record und Datei (letzte Referenz)', () async {
    final src = await makeSource('snd.mp3', 'audio-bytes');
    final media = await service.importFile(src);
    expect(media.type, 'audio');
    final abs = service.absolutePath(media);
    expect(await File(abs).exists(), isTrue);

    await service.deleteMedia(media);

    expect(await service.db.mediaDao.fetchById(media.id), isNull);
    expect(await File(abs).exists(), isFalse);
  });

  test('mediaTypeFor leitet Typ aus MIME bzw. Endung ab', () {
    expect(MediaService.mediaTypeFor('image/png', 'x.png'), 'image');
    expect(MediaService.mediaTypeFor('audio/mpeg', 'x.mp3'), 'audio');
    expect(MediaService.mediaTypeFor('video/mp4', 'x.mp4'), 'video');
    expect(MediaService.mediaTypeFor('application/pdf', 'x.pdf'), 'document');
    // Fallback nur über Endung
    expect(MediaService.mediaTypeFor(null, 'clip.mov'), 'video');
    expect(MediaService.mediaTypeFor(null, 'note.unknownext'), 'document');
  });

  test('Bild-Import speichert Breite/Höhe in metadataJson', () async {
    final image = img.Image(640, 480);
    img.fill(image, img.getColor(10, 20, 30));
    final src = File(p.join(vaultDir.path, '_src', 'sized.png'));
    await src.create(recursive: true);
    await src.writeAsBytes(img.encodePng(image));

    final media = await service.importFile(src);
    final meta = jsonDecode(media.metadataJson!) as Map<String, dynamic>;
    expect(meta['width'], 640);
    expect(meta['height'], 480);
    expect(meta['bytes'], isPositive);
  });

  test('importFile wirft bei fehlender Quelldatei', () async {
    final missing = File(p.join(vaultDir.path, 'does_not_exist.png'));
    expect(
      () => service.importFile(missing),
      throwsA(isA<MediaImportException>()),
    );
  });
}
