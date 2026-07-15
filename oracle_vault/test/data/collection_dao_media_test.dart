// Tests für CollectionDao.watchMediaEntriesFor — liefert alle Einträge mit
// angehängtem Medium über die Tabellen einer Collection, korrekt sortiert.

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oracle_vault/data/db/vault_database.dart';

void main() {
  late VaultDatabase db;

  setUp(() => db = VaultDatabase.inMemory());
  tearDown(() => db.close());

  Future<void> insertTable(String id, String name) async {
    final now = DateTime.now();
    await db.into(db.oracleTables).insert(OracleTablesCompanion.insert(
          id: id,
          name: name,
          createdAt: now,
          updatedAt: now,
        ));
  }

  Future<String> insertMedia(String id) async {
    await db.into(db.mediaFiles).insert(MediaFilesCompanion.insert(
          id: id,
          type: 'image',
          filePath: 'media/images/$id.png',
          hash: 'hash-$id',
          createdAt: DateTime.now(),
        ));
    return id;
  }

  Future<void> insertEntry(
    String id,
    String tableId,
    int position,
    String content, {
    String? mediaId,
  }) async {
    await db.into(db.entries).insert(EntriesCompanion.insert(
          id: id,
          tableId: tableId,
          position: position,
          content: content,
          mediaId: Value(mediaId),
        ));
  }

  test('liefert nur Einträge mit Medium, sortiert nach Tabellen-/Eintragspos.',
      () async {
    // Zwei Tabellen in einer Collection, plus eine Tabelle außerhalb.
    await insertTable('t1', 'Battlemaps A');
    await insertTable('t2', 'Battlemaps B');
    await insertTable('t3', 'Fremd');

    final col = await db.collectionDao
        .createCollection(name: 'Maps', type: 'battlemap');
    await db.collectionDao.addTable(col, 't1', position: 0);
    await db.collectionDao.addTable(col, 't2', position: 1);

    await insertMedia('m1');
    await insertMedia('m2');
    await insertMedia('m3');

    // t2 hat ein Medium (soll NACH t1 kommen wegen position).
    await insertEntry('e-t2', 't2', 0, 'Karte B1', mediaId: 'm3');
    // t1: zwei Einträge, einer mit, einer ohne Medium.
    await insertEntry('e-t1b', 't1', 1, 'Karte A2', mediaId: 'm2');
    await insertEntry('e-t1a', 't1', 0, 'Karte A1', mediaId: 'm1');
    await insertEntry('e-t1c', 't1', 2, 'Ohne Bild'); // kein Medium
    // Fremde Tabelle mit Medium — darf NICHT erscheinen.
    await insertMedia('m4');
    await insertEntry('e-t3', 't3', 0, 'Fremdkarte', mediaId: 'm4');

    final result = await db.collectionDao.watchMediaEntriesFor(col).first;

    expect(result.map((e) => e.id).toList(),
        ['e-t1a', 'e-t1b', 'e-t2']); // t1(pos0,1) dann t2(pos0)
    expect(result.every((e) => e.mediaId != null), isTrue);
  });

  test('leere Collection ⇒ leere Liste', () async {
    final col =
        await db.collectionDao.createCollection(name: 'Leer', type: 'deck');
    final result = await db.collectionDao.watchMediaEntriesFor(col).first;
    expect(result, isEmpty);
  });
}
