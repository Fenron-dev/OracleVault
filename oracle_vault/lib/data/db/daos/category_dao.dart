// Datei: lib/data/db/daos/category_dao.dart
//
// ZWECK: Datenbankzugriff für Kategorien (hierarchischer Baum).
// ABHÄNGIGKEITEN: drift, vault_database.dart
// PHASE: 1

import 'package:drift/drift.dart';

import '../vault_database.dart';
import '../tables/categories.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<VaultDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Stream<List<Category>> watchAll() =>
      (select(categories)..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .watch();

  Future<List<Category>> fetchAll() =>
      (select(categories)..orderBy([(c) => OrderingTerm.asc(c.name)])).get();

  /// Top-Level-Kategorien (parentId == null).
  Future<List<Category>> fetchRoots() =>
      (select(categories)
            ..where((c) => c.parentId.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .get();

  /// Direkte Kinder einer Kategorie.
  Future<List<Category>> fetchChildren(String parentId) =>
      (select(categories)
            ..where((c) => c.parentId.equals(parentId))
            ..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .get();

  Future<void> insertCategory(CategoriesCompanion cat) =>
      into(categories).insert(cat);

  Future<bool> updateCategory(CategoriesCompanion cat) =>
      update(categories).replace(cat);

  Future<int> deleteCategory(String id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();
}
