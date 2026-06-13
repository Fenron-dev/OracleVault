// Datei: lib/data/db/daos/tag_dao.dart
//
// ZWECK: Datenbankzugriff für Tags.
// ABHÄNGIGKEITEN: drift, vault_database.dart
// PHASE: 1

import 'package:drift/drift.dart';

import '../vault_database.dart';
import '../tables/tags.dart';

part 'tag_dao.g.dart';

@DriftAccessor(tables: [Tags])
class TagDao extends DatabaseAccessor<VaultDatabase> with _$TagDaoMixin {
  TagDao(super.db);

  Stream<List<Tag>> watchAll() =>
      (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<List<Tag>> fetchAll() =>
      (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).get();

  Future<Tag?> fetchByName(String name) =>
      (select(tags)..where((t) => t.name.equals(name))).getSingleOrNull();

  /// Findet oder legt an (für Tag-Autocomplete beim Import).
  Future<Tag> findOrCreate(String name, String id) async {
    final existing = await fetchByName(name);
    if (existing != null) return existing;
    await into(tags).insert(TagsCompanion.insert(id: id, name: name));
    return (await fetchByName(name))!;
  }

  Future<void> insertTag(TagsCompanion tag) =>
      into(tags).insert(tag, onConflict: DoNothing());

  Future<int> deleteTag(String id) =>
      (delete(tags)..where((t) => t.id.equals(id))).go();
}
