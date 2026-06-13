// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vault_database.dart';

// ignore_for_file: type=lint
class $SourcesTable extends Sources with TableInfo<$SourcesTable, Source> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _licenseMeta = const VerificationMeta(
    'license',
  );
  @override
  late final GeneratedColumn<String> license = GeneratedColumn<String>(
    'license',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aiProviderJsonMeta = const VerificationMeta(
    'aiProviderJson',
  );
  @override
  late final GeneratedColumn<String> aiProviderJson = GeneratedColumn<String>(
    'ai_provider_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    title,
    author,
    url,
    license,
    aiProviderJson,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<Source> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('license')) {
      context.handle(
        _licenseMeta,
        license.isAcceptableOrUnknown(data['license']!, _licenseMeta),
      );
    }
    if (data.containsKey('ai_provider_json')) {
      context.handle(
        _aiProviderJsonMeta,
        aiProviderJson.isAcceptableOrUnknown(
          data['ai_provider_json']!,
          _aiProviderJsonMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Source map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Source(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      license: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license'],
      ),
      aiProviderJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_provider_json'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SourcesTable createAlias(String alias) {
    return $SourcesTable(attachedDatabase, alias);
  }
}

class Source extends DataClass implements Insertable<Source> {
  final String id;

  /// Typ der Quelle.
  /// Erlaubte Werte: 'book' | 'url' | 'pdf' | 'file' | 'manual' |
  ///                 'ai_generation' | 'reddit' | 'rss'
  final String type;
  final String? title;
  final String? author;
  final String? url;
  final String? license;

  /// JSON-Objekt bei type='ai_generation':
  /// {provider, model, model_version_seen_at, system_prompt, user_prompt, params, seed}
  final String? aiProviderJson;
  final String? notes;
  final DateTime createdAt;
  const Source({
    required this.id,
    required this.type,
    this.title,
    this.author,
    this.url,
    this.license,
    this.aiProviderJson,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || license != null) {
      map['license'] = Variable<String>(license);
    }
    if (!nullToAbsent || aiProviderJson != null) {
      map['ai_provider_json'] = Variable<String>(aiProviderJson);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SourcesCompanion toCompanion(bool nullToAbsent) {
    return SourcesCompanion(
      id: Value(id),
      type: Value(type),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      license: license == null && nullToAbsent
          ? const Value.absent()
          : Value(license),
      aiProviderJson: aiProviderJson == null && nullToAbsent
          ? const Value.absent()
          : Value(aiProviderJson),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory Source.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Source(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String?>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      url: serializer.fromJson<String?>(json['url']),
      license: serializer.fromJson<String?>(json['license']),
      aiProviderJson: serializer.fromJson<String?>(json['aiProviderJson']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String?>(title),
      'author': serializer.toJson<String?>(author),
      'url': serializer.toJson<String?>(url),
      'license': serializer.toJson<String?>(license),
      'aiProviderJson': serializer.toJson<String?>(aiProviderJson),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Source copyWith({
    String? id,
    String? type,
    Value<String?> title = const Value.absent(),
    Value<String?> author = const Value.absent(),
    Value<String?> url = const Value.absent(),
    Value<String?> license = const Value.absent(),
    Value<String?> aiProviderJson = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => Source(
    id: id ?? this.id,
    type: type ?? this.type,
    title: title.present ? title.value : this.title,
    author: author.present ? author.value : this.author,
    url: url.present ? url.value : this.url,
    license: license.present ? license.value : this.license,
    aiProviderJson: aiProviderJson.present
        ? aiProviderJson.value
        : this.aiProviderJson,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  Source copyWithCompanion(SourcesCompanion data) {
    return Source(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      url: data.url.present ? data.url.value : this.url,
      license: data.license.present ? data.license.value : this.license,
      aiProviderJson: data.aiProviderJson.present
          ? data.aiProviderJson.value
          : this.aiProviderJson,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Source(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('url: $url, ')
          ..write('license: $license, ')
          ..write('aiProviderJson: $aiProviderJson, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    title,
    author,
    url,
    license,
    aiProviderJson,
    notes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Source &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.author == this.author &&
          other.url == this.url &&
          other.license == this.license &&
          other.aiProviderJson == this.aiProviderJson &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class SourcesCompanion extends UpdateCompanion<Source> {
  final Value<String> id;
  final Value<String> type;
  final Value<String?> title;
  final Value<String?> author;
  final Value<String?> url;
  final Value<String?> license;
  final Value<String?> aiProviderJson;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SourcesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.url = const Value.absent(),
    this.license = const Value.absent(),
    this.aiProviderJson = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SourcesCompanion.insert({
    required String id,
    required String type,
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.url = const Value.absent(),
    this.license = const Value.absent(),
    this.aiProviderJson = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<Source> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? url,
    Expression<String>? license,
    Expression<String>? aiProviderJson,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (url != null) 'url': url,
      if (license != null) 'license': license,
      if (aiProviderJson != null) 'ai_provider_json': aiProviderJson,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String?>? title,
    Value<String?>? author,
    Value<String?>? url,
    Value<String?>? license,
    Value<String?>? aiProviderJson,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SourcesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      author: author ?? this.author,
      url: url ?? this.url,
      license: license ?? this.license,
      aiProviderJson: aiProviderJson ?? this.aiProviderJson,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (license.present) {
      map['license'] = Variable<String>(license.value);
    }
    if (aiProviderJson.present) {
      map['ai_provider_json'] = Variable<String>(aiProviderJson.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourcesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('url: $url, ')
          ..write('license: $license, ')
          ..write('aiProviderJson: $aiProviderJson, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, parentId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final String id;
  final String name;

  /// Eltern-Kategorie. Null = Top-Level.
  final String? parentId;
  const Category({required this.id, required this.name, this.parentId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
    };
  }

  Category copyWith({
    String? id,
    String? name,
    Value<String?> parentId = const Value.absent(),
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
  );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, parentId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.parentId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Category> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? parentId,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OracleTablesTable extends OracleTables
    with TableInfo<$OracleTablesTable, OracleTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OracleTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oracleTypeMeta = const VerificationMeta(
    'oracleType',
  );
  @override
  late final GeneratedColumn<String> oracleType = GeneratedColumn<String>(
    'oracle_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('uniform'),
  );
  static const VerificationMeta _diceExprMeta = const VerificationMeta(
    'diceExpr',
  );
  @override
  late final GeneratedColumn<String> diceExpr = GeneratedColumn<String>(
    'dice_expr',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeMeta = const VerificationMeta('theme');
  @override
  late final GeneratedColumn<String> theme = GeneratedColumn<String>(
    'theme',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sources (id)',
    ),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('de'),
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    oracleType,
    diceExpr,
    genre,
    theme,
    categoryId,
    sourceId,
    language,
    metadataJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'oracle_tables';
  @override
  VerificationContext validateIntegrity(
    Insertable<OracleTable> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('oracle_type')) {
      context.handle(
        _oracleTypeMeta,
        oracleType.isAcceptableOrUnknown(data['oracle_type']!, _oracleTypeMeta),
      );
    }
    if (data.containsKey('dice_expr')) {
      context.handle(
        _diceExprMeta,
        diceExpr.isAcceptableOrUnknown(data['dice_expr']!, _diceExprMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('theme')) {
      context.handle(
        _themeMeta,
        theme.isAcceptableOrUnknown(data['theme']!, _themeMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OracleTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OracleTable(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      oracleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}oracle_type'],
      )!,
      diceExpr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dice_expr'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      theme: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OracleTablesTable createAlias(String alias) {
    return $OracleTablesTable(attachedDatabase, alias);
  }
}

class OracleTable extends DataClass implements Insertable<OracleTable> {
  final String id;
  final String name;
  final String? description;

  /// Zieh-Mechanik: 'uniform' | 'weighted' | 'dice' | 'deck'
  final String oracleType;

  /// Würfelausdruck für oracleType='dice', z. B. '1d20', '2d6+3'.
  final String? diceExpr;
  final String? genre;
  final String? theme;
  final String? categoryId;
  final String? sourceId;

  /// ISO 639-1 Sprachcode der Einträge.
  final String language;

  /// Flexibles JSON-Feld für zukünftige Metadaten ohne Schema-Änderung.
  final String? metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const OracleTable({
    required this.id,
    required this.name,
    this.description,
    required this.oracleType,
    this.diceExpr,
    this.genre,
    this.theme,
    this.categoryId,
    this.sourceId,
    required this.language,
    this.metadataJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['oracle_type'] = Variable<String>(oracleType);
    if (!nullToAbsent || diceExpr != null) {
      map['dice_expr'] = Variable<String>(diceExpr);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || theme != null) {
      map['theme'] = Variable<String>(theme);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<String>(sourceId);
    }
    map['language'] = Variable<String>(language);
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OracleTablesCompanion toCompanion(bool nullToAbsent) {
    return OracleTablesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      oracleType: Value(oracleType),
      diceExpr: diceExpr == null && nullToAbsent
          ? const Value.absent()
          : Value(diceExpr),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      theme: theme == null && nullToAbsent
          ? const Value.absent()
          : Value(theme),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      language: Value(language),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory OracleTable.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OracleTable(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      oracleType: serializer.fromJson<String>(json['oracleType']),
      diceExpr: serializer.fromJson<String?>(json['diceExpr']),
      genre: serializer.fromJson<String?>(json['genre']),
      theme: serializer.fromJson<String?>(json['theme']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      sourceId: serializer.fromJson<String?>(json['sourceId']),
      language: serializer.fromJson<String>(json['language']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'oracleType': serializer.toJson<String>(oracleType),
      'diceExpr': serializer.toJson<String?>(diceExpr),
      'genre': serializer.toJson<String?>(genre),
      'theme': serializer.toJson<String?>(theme),
      'categoryId': serializer.toJson<String?>(categoryId),
      'sourceId': serializer.toJson<String?>(sourceId),
      'language': serializer.toJson<String>(language),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OracleTable copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? oracleType,
    Value<String?> diceExpr = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<String?> theme = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
    Value<String?> sourceId = const Value.absent(),
    String? language,
    Value<String?> metadataJson = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => OracleTable(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    oracleType: oracleType ?? this.oracleType,
    diceExpr: diceExpr.present ? diceExpr.value : this.diceExpr,
    genre: genre.present ? genre.value : this.genre,
    theme: theme.present ? theme.value : this.theme,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    sourceId: sourceId.present ? sourceId.value : this.sourceId,
    language: language ?? this.language,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OracleTable copyWithCompanion(OracleTablesCompanion data) {
    return OracleTable(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      oracleType: data.oracleType.present
          ? data.oracleType.value
          : this.oracleType,
      diceExpr: data.diceExpr.present ? data.diceExpr.value : this.diceExpr,
      genre: data.genre.present ? data.genre.value : this.genre,
      theme: data.theme.present ? data.theme.value : this.theme,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      language: data.language.present ? data.language.value : this.language,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OracleTable(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('oracleType: $oracleType, ')
          ..write('diceExpr: $diceExpr, ')
          ..write('genre: $genre, ')
          ..write('theme: $theme, ')
          ..write('categoryId: $categoryId, ')
          ..write('sourceId: $sourceId, ')
          ..write('language: $language, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    oracleType,
    diceExpr,
    genre,
    theme,
    categoryId,
    sourceId,
    language,
    metadataJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OracleTable &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.oracleType == this.oracleType &&
          other.diceExpr == this.diceExpr &&
          other.genre == this.genre &&
          other.theme == this.theme &&
          other.categoryId == this.categoryId &&
          other.sourceId == this.sourceId &&
          other.language == this.language &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OracleTablesCompanion extends UpdateCompanion<OracleTable> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> oracleType;
  final Value<String?> diceExpr;
  final Value<String?> genre;
  final Value<String?> theme;
  final Value<String?> categoryId;
  final Value<String?> sourceId;
  final Value<String> language;
  final Value<String?> metadataJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const OracleTablesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.oracleType = const Value.absent(),
    this.diceExpr = const Value.absent(),
    this.genre = const Value.absent(),
    this.theme = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.language = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OracleTablesCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.oracleType = const Value.absent(),
    this.diceExpr = const Value.absent(),
    this.genre = const Value.absent(),
    this.theme = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.language = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<OracleTable> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? oracleType,
    Expression<String>? diceExpr,
    Expression<String>? genre,
    Expression<String>? theme,
    Expression<String>? categoryId,
    Expression<String>? sourceId,
    Expression<String>? language,
    Expression<String>? metadataJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (oracleType != null) 'oracle_type': oracleType,
      if (diceExpr != null) 'dice_expr': diceExpr,
      if (genre != null) 'genre': genre,
      if (theme != null) 'theme': theme,
      if (categoryId != null) 'category_id': categoryId,
      if (sourceId != null) 'source_id': sourceId,
      if (language != null) 'language': language,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OracleTablesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? oracleType,
    Value<String?>? diceExpr,
    Value<String?>? genre,
    Value<String?>? theme,
    Value<String?>? categoryId,
    Value<String?>? sourceId,
    Value<String>? language,
    Value<String?>? metadataJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return OracleTablesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      oracleType: oracleType ?? this.oracleType,
      diceExpr: diceExpr ?? this.diceExpr,
      genre: genre ?? this.genre,
      theme: theme ?? this.theme,
      categoryId: categoryId ?? this.categoryId,
      sourceId: sourceId ?? this.sourceId,
      language: language ?? this.language,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (oracleType.present) {
      map['oracle_type'] = Variable<String>(oracleType.value);
    }
    if (diceExpr.present) {
      map['dice_expr'] = Variable<String>(diceExpr.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (theme.present) {
      map['theme'] = Variable<String>(theme.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OracleTablesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('oracleType: $oracleType, ')
          ..write('diceExpr: $diceExpr, ')
          ..write('genre: $genre, ')
          ..write('theme: $theme, ')
          ..write('categoryId: $categoryId, ')
          ..write('sourceId: $sourceId, ')
          ..write('language: $language, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaFilesTable extends MediaFiles
    with TableInfo<$MediaFilesTable, MediaFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hashMeta = const VerificationMeta('hash');
  @override
  late final GeneratedColumn<String> hash = GeneratedColumn<String>(
    'hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    filePath,
    mime,
    hash,
    title,
    metadataJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    }
    if (data.containsKey('hash')) {
      context.handle(
        _hashMeta,
        hash.isAcceptableOrUnknown(data['hash']!, _hashMeta),
      );
    } else if (isInserting) {
      context.missing(_hashMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaFile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      ),
      hash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hash'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MediaFilesTable createAlias(String alias) {
    return $MediaFilesTable(attachedDatabase, alias);
  }
}

class MediaFile extends DataClass implements Insertable<MediaFile> {
  final String id;

  /// Typ des Assets: 'image' | 'audio' | 'video' | 'document'
  final String type;

  /// Pfad relativ zum Vault-Ordner, z. B. 'media/images/foo.png'.
  final String filePath;
  final String? mime;

  /// SHA-256-Hash des Dateiinhalts zur Dublettenerkennung.
  final String hash;
  final String? title;

  /// Format-spezifische Metadaten als JSON.
  final String? metadataJson;
  final DateTime createdAt;
  const MediaFile({
    required this.id,
    required this.type,
    required this.filePath,
    this.mime,
    required this.hash,
    this.title,
    this.metadataJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || mime != null) {
      map['mime'] = Variable<String>(mime);
    }
    map['hash'] = Variable<String>(hash);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MediaFilesCompanion toCompanion(bool nullToAbsent) {
    return MediaFilesCompanion(
      id: Value(id),
      type: Value(type),
      filePath: Value(filePath),
      mime: mime == null && nullToAbsent ? const Value.absent() : Value(mime),
      hash: Value(hash),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
      createdAt: Value(createdAt),
    );
  }

  factory MediaFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaFile(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      filePath: serializer.fromJson<String>(json['filePath']),
      mime: serializer.fromJson<String?>(json['mime']),
      hash: serializer.fromJson<String>(json['hash']),
      title: serializer.fromJson<String?>(json['title']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'filePath': serializer.toJson<String>(filePath),
      'mime': serializer.toJson<String?>(mime),
      'hash': serializer.toJson<String>(hash),
      'title': serializer.toJson<String?>(title),
      'metadataJson': serializer.toJson<String?>(metadataJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MediaFile copyWith({
    String? id,
    String? type,
    String? filePath,
    Value<String?> mime = const Value.absent(),
    String? hash,
    Value<String?> title = const Value.absent(),
    Value<String?> metadataJson = const Value.absent(),
    DateTime? createdAt,
  }) => MediaFile(
    id: id ?? this.id,
    type: type ?? this.type,
    filePath: filePath ?? this.filePath,
    mime: mime.present ? mime.value : this.mime,
    hash: hash ?? this.hash,
    title: title.present ? title.value : this.title,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
    createdAt: createdAt ?? this.createdAt,
  );
  MediaFile copyWithCompanion(MediaFilesCompanion data) {
    return MediaFile(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      mime: data.mime.present ? data.mime.value : this.mime,
      hash: data.hash.present ? data.hash.value : this.hash,
      title: data.title.present ? data.title.value : this.title,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaFile(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('filePath: $filePath, ')
          ..write('mime: $mime, ')
          ..write('hash: $hash, ')
          ..write('title: $title, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    filePath,
    mime,
    hash,
    title,
    metadataJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaFile &&
          other.id == this.id &&
          other.type == this.type &&
          other.filePath == this.filePath &&
          other.mime == this.mime &&
          other.hash == this.hash &&
          other.title == this.title &&
          other.metadataJson == this.metadataJson &&
          other.createdAt == this.createdAt);
}

class MediaFilesCompanion extends UpdateCompanion<MediaFile> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> filePath;
  final Value<String?> mime;
  final Value<String> hash;
  final Value<String?> title;
  final Value<String?> metadataJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MediaFilesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.filePath = const Value.absent(),
    this.mime = const Value.absent(),
    this.hash = const Value.absent(),
    this.title = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaFilesCompanion.insert({
    required String id,
    required String type,
    required String filePath,
    this.mime = const Value.absent(),
    required String hash,
    this.title = const Value.absent(),
    this.metadataJson = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       filePath = Value(filePath),
       hash = Value(hash),
       createdAt = Value(createdAt);
  static Insertable<MediaFile> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? filePath,
    Expression<String>? mime,
    Expression<String>? hash,
    Expression<String>? title,
    Expression<String>? metadataJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (filePath != null) 'file_path': filePath,
      if (mime != null) 'mime': mime,
      if (hash != null) 'hash': hash,
      if (title != null) 'title': title,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaFilesCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? filePath,
    Value<String?>? mime,
    Value<String>? hash,
    Value<String?>? title,
    Value<String?>? metadataJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MediaFilesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      mime: mime ?? this.mime,
      hash: hash ?? this.hash,
      title: title ?? this.title,
      metadataJson: metadataJson ?? this.metadataJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (hash.present) {
      map['hash'] = Variable<String>(hash.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaFilesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('filePath: $filePath, ')
          ..write('mime: $mime, ')
          ..write('hash: $hash, ')
          ..write('title: $title, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tableIdMeta = const VerificationMeta(
    'tableId',
  );
  @override
  late final GeneratedColumn<String> tableId = GeneratedColumn<String>(
    'table_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES oracle_tables (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMdMeta = const VerificationMeta('bodyMd');
  @override
  late final GeneratedColumn<String> bodyMd = GeneratedColumn<String>(
    'body_md',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _rollMinMeta = const VerificationMeta(
    'rollMin',
  );
  @override
  late final GeneratedColumn<int> rollMin = GeneratedColumn<int>(
    'roll_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rollMaxMeta = const VerificationMeta(
    'rollMax',
  );
  @override
  late final GeneratedColumn<int> rollMax = GeneratedColumn<int>(
    'roll_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
    'media_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_files (id)',
    ),
  );
  static const VerificationMeta _subtableIdMeta = const VerificationMeta(
    'subtableId',
  );
  @override
  late final GeneratedColumn<String> subtableId = GeneratedColumn<String>(
    'subtable_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES oracle_tables (id)',
    ),
  );
  static const VerificationMeta _confidenceLowMeta = const VerificationMeta(
    'confidenceLow',
  );
  @override
  late final GeneratedColumn<bool> confidenceLow = GeneratedColumn<bool>(
    'confidence_low',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("confidence_low" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _modifierJsonMeta = const VerificationMeta(
    'modifierJson',
  );
  @override
  late final GeneratedColumn<String> modifierJson = GeneratedColumn<String>(
    'modifier_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tableId,
    position,
    content,
    bodyMd,
    weight,
    rollMin,
    rollMax,
    mediaId,
    subtableId,
    confidenceLow,
    modifierJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('table_id')) {
      context.handle(
        _tableIdMeta,
        tableId.isAcceptableOrUnknown(data['table_id']!, _tableIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tableIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('body_md')) {
      context.handle(
        _bodyMdMeta,
        bodyMd.isAcceptableOrUnknown(data['body_md']!, _bodyMdMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('roll_min')) {
      context.handle(
        _rollMinMeta,
        rollMin.isAcceptableOrUnknown(data['roll_min']!, _rollMinMeta),
      );
    }
    if (data.containsKey('roll_max')) {
      context.handle(
        _rollMaxMeta,
        rollMax.isAcceptableOrUnknown(data['roll_max']!, _rollMaxMeta),
      );
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    }
    if (data.containsKey('subtable_id')) {
      context.handle(
        _subtableIdMeta,
        subtableId.isAcceptableOrUnknown(data['subtable_id']!, _subtableIdMeta),
      );
    }
    if (data.containsKey('confidence_low')) {
      context.handle(
        _confidenceLowMeta,
        confidenceLow.isAcceptableOrUnknown(
          data['confidence_low']!,
          _confidenceLowMeta,
        ),
      );
    }
    if (data.containsKey('modifier_json')) {
      context.handle(
        _modifierJsonMeta,
        modifierJson.isAcceptableOrUnknown(
          data['modifier_json']!,
          _modifierJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      bodyMd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_md'],
      ),
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      rollMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}roll_min'],
      ),
      rollMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}roll_max'],
      ),
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      ),
      subtableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtable_id'],
      ),
      confidenceLow: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}confidence_low'],
      )!,
      modifierJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modifier_json'],
      ),
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class Entry extends DataClass implements Insertable<Entry> {
  final String id;
  final String tableId;

  /// Anzeigereihenfolge innerhalb der Tabelle.
  final int position;

  /// Kurztext / Hauptinhalt des Eintrags.
  final String content;

  /// Optionaler Langtext in Markdown für reichhaltige Einträge (NSCs, Locations).
  final String? bodyMd;

  /// Relatives Gewicht für oracleType='weighted'. Default = 1.
  final double weight;

  /// Inklusiver Mindestwert für dice-Mapping. Null wenn kein dice-Typ.
  final int? rollMin;

  /// Inklusiver Maximalwert für dice-Mapping. Null wenn kein dice-Typ.
  final int? rollMax;

  /// Verweis auf ein Media-Asset (Bild, Audio, ...).
  final String? mediaId;

  /// Verweis auf eine Unter-Tabelle, die bei Ziehen automatisch aufgelöst wird.
  /// Zyklus-Erkennung erfolgt in der Roll-Engine.
  final String? subtableId;

  /// KI-Import-Marker: true = niedriger Konfidenz-Score, gelbe Hervorhebung.
  final bool confidenceLow;

  /// Entry-spezifische Zusatzdaten als JSON.
  final String? modifierJson;
  const Entry({
    required this.id,
    required this.tableId,
    required this.position,
    required this.content,
    this.bodyMd,
    required this.weight,
    this.rollMin,
    this.rollMax,
    this.mediaId,
    this.subtableId,
    required this.confidenceLow,
    this.modifierJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['table_id'] = Variable<String>(tableId);
    map['position'] = Variable<int>(position);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || bodyMd != null) {
      map['body_md'] = Variable<String>(bodyMd);
    }
    map['weight'] = Variable<double>(weight);
    if (!nullToAbsent || rollMin != null) {
      map['roll_min'] = Variable<int>(rollMin);
    }
    if (!nullToAbsent || rollMax != null) {
      map['roll_max'] = Variable<int>(rollMax);
    }
    if (!nullToAbsent || mediaId != null) {
      map['media_id'] = Variable<String>(mediaId);
    }
    if (!nullToAbsent || subtableId != null) {
      map['subtable_id'] = Variable<String>(subtableId);
    }
    map['confidence_low'] = Variable<bool>(confidenceLow);
    if (!nullToAbsent || modifierJson != null) {
      map['modifier_json'] = Variable<String>(modifierJson);
    }
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      tableId: Value(tableId),
      position: Value(position),
      content: Value(content),
      bodyMd: bodyMd == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyMd),
      weight: Value(weight),
      rollMin: rollMin == null && nullToAbsent
          ? const Value.absent()
          : Value(rollMin),
      rollMax: rollMax == null && nullToAbsent
          ? const Value.absent()
          : Value(rollMax),
      mediaId: mediaId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaId),
      subtableId: subtableId == null && nullToAbsent
          ? const Value.absent()
          : Value(subtableId),
      confidenceLow: Value(confidenceLow),
      modifierJson: modifierJson == null && nullToAbsent
          ? const Value.absent()
          : Value(modifierJson),
    );
  }

  factory Entry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      id: serializer.fromJson<String>(json['id']),
      tableId: serializer.fromJson<String>(json['tableId']),
      position: serializer.fromJson<int>(json['position']),
      content: serializer.fromJson<String>(json['content']),
      bodyMd: serializer.fromJson<String?>(json['bodyMd']),
      weight: serializer.fromJson<double>(json['weight']),
      rollMin: serializer.fromJson<int?>(json['rollMin']),
      rollMax: serializer.fromJson<int?>(json['rollMax']),
      mediaId: serializer.fromJson<String?>(json['mediaId']),
      subtableId: serializer.fromJson<String?>(json['subtableId']),
      confidenceLow: serializer.fromJson<bool>(json['confidenceLow']),
      modifierJson: serializer.fromJson<String?>(json['modifierJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tableId': serializer.toJson<String>(tableId),
      'position': serializer.toJson<int>(position),
      'content': serializer.toJson<String>(content),
      'bodyMd': serializer.toJson<String?>(bodyMd),
      'weight': serializer.toJson<double>(weight),
      'rollMin': serializer.toJson<int?>(rollMin),
      'rollMax': serializer.toJson<int?>(rollMax),
      'mediaId': serializer.toJson<String?>(mediaId),
      'subtableId': serializer.toJson<String?>(subtableId),
      'confidenceLow': serializer.toJson<bool>(confidenceLow),
      'modifierJson': serializer.toJson<String?>(modifierJson),
    };
  }

  Entry copyWith({
    String? id,
    String? tableId,
    int? position,
    String? content,
    Value<String?> bodyMd = const Value.absent(),
    double? weight,
    Value<int?> rollMin = const Value.absent(),
    Value<int?> rollMax = const Value.absent(),
    Value<String?> mediaId = const Value.absent(),
    Value<String?> subtableId = const Value.absent(),
    bool? confidenceLow,
    Value<String?> modifierJson = const Value.absent(),
  }) => Entry(
    id: id ?? this.id,
    tableId: tableId ?? this.tableId,
    position: position ?? this.position,
    content: content ?? this.content,
    bodyMd: bodyMd.present ? bodyMd.value : this.bodyMd,
    weight: weight ?? this.weight,
    rollMin: rollMin.present ? rollMin.value : this.rollMin,
    rollMax: rollMax.present ? rollMax.value : this.rollMax,
    mediaId: mediaId.present ? mediaId.value : this.mediaId,
    subtableId: subtableId.present ? subtableId.value : this.subtableId,
    confidenceLow: confidenceLow ?? this.confidenceLow,
    modifierJson: modifierJson.present ? modifierJson.value : this.modifierJson,
  );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      id: data.id.present ? data.id.value : this.id,
      tableId: data.tableId.present ? data.tableId.value : this.tableId,
      position: data.position.present ? data.position.value : this.position,
      content: data.content.present ? data.content.value : this.content,
      bodyMd: data.bodyMd.present ? data.bodyMd.value : this.bodyMd,
      weight: data.weight.present ? data.weight.value : this.weight,
      rollMin: data.rollMin.present ? data.rollMin.value : this.rollMin,
      rollMax: data.rollMax.present ? data.rollMax.value : this.rollMax,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
      subtableId: data.subtableId.present
          ? data.subtableId.value
          : this.subtableId,
      confidenceLow: data.confidenceLow.present
          ? data.confidenceLow.value
          : this.confidenceLow,
      modifierJson: data.modifierJson.present
          ? data.modifierJson.value
          : this.modifierJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('id: $id, ')
          ..write('tableId: $tableId, ')
          ..write('position: $position, ')
          ..write('content: $content, ')
          ..write('bodyMd: $bodyMd, ')
          ..write('weight: $weight, ')
          ..write('rollMin: $rollMin, ')
          ..write('rollMax: $rollMax, ')
          ..write('mediaId: $mediaId, ')
          ..write('subtableId: $subtableId, ')
          ..write('confidenceLow: $confidenceLow, ')
          ..write('modifierJson: $modifierJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tableId,
    position,
    content,
    bodyMd,
    weight,
    rollMin,
    rollMax,
    mediaId,
    subtableId,
    confidenceLow,
    modifierJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.id == this.id &&
          other.tableId == this.tableId &&
          other.position == this.position &&
          other.content == this.content &&
          other.bodyMd == this.bodyMd &&
          other.weight == this.weight &&
          other.rollMin == this.rollMin &&
          other.rollMax == this.rollMax &&
          other.mediaId == this.mediaId &&
          other.subtableId == this.subtableId &&
          other.confidenceLow == this.confidenceLow &&
          other.modifierJson == this.modifierJson);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<String> id;
  final Value<String> tableId;
  final Value<int> position;
  final Value<String> content;
  final Value<String?> bodyMd;
  final Value<double> weight;
  final Value<int?> rollMin;
  final Value<int?> rollMax;
  final Value<String?> mediaId;
  final Value<String?> subtableId;
  final Value<bool> confidenceLow;
  final Value<String?> modifierJson;
  final Value<int> rowid;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.tableId = const Value.absent(),
    this.position = const Value.absent(),
    this.content = const Value.absent(),
    this.bodyMd = const Value.absent(),
    this.weight = const Value.absent(),
    this.rollMin = const Value.absent(),
    this.rollMax = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.subtableId = const Value.absent(),
    this.confidenceLow = const Value.absent(),
    this.modifierJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesCompanion.insert({
    required String id,
    required String tableId,
    required int position,
    required String content,
    this.bodyMd = const Value.absent(),
    this.weight = const Value.absent(),
    this.rollMin = const Value.absent(),
    this.rollMax = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.subtableId = const Value.absent(),
    this.confidenceLow = const Value.absent(),
    this.modifierJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tableId = Value(tableId),
       position = Value(position),
       content = Value(content);
  static Insertable<Entry> custom({
    Expression<String>? id,
    Expression<String>? tableId,
    Expression<int>? position,
    Expression<String>? content,
    Expression<String>? bodyMd,
    Expression<double>? weight,
    Expression<int>? rollMin,
    Expression<int>? rollMax,
    Expression<String>? mediaId,
    Expression<String>? subtableId,
    Expression<bool>? confidenceLow,
    Expression<String>? modifierJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tableId != null) 'table_id': tableId,
      if (position != null) 'position': position,
      if (content != null) 'content': content,
      if (bodyMd != null) 'body_md': bodyMd,
      if (weight != null) 'weight': weight,
      if (rollMin != null) 'roll_min': rollMin,
      if (rollMax != null) 'roll_max': rollMax,
      if (mediaId != null) 'media_id': mediaId,
      if (subtableId != null) 'subtable_id': subtableId,
      if (confidenceLow != null) 'confidence_low': confidenceLow,
      if (modifierJson != null) 'modifier_json': modifierJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? tableId,
    Value<int>? position,
    Value<String>? content,
    Value<String?>? bodyMd,
    Value<double>? weight,
    Value<int?>? rollMin,
    Value<int?>? rollMax,
    Value<String?>? mediaId,
    Value<String?>? subtableId,
    Value<bool>? confidenceLow,
    Value<String?>? modifierJson,
    Value<int>? rowid,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      position: position ?? this.position,
      content: content ?? this.content,
      bodyMd: bodyMd ?? this.bodyMd,
      weight: weight ?? this.weight,
      rollMin: rollMin ?? this.rollMin,
      rollMax: rollMax ?? this.rollMax,
      mediaId: mediaId ?? this.mediaId,
      subtableId: subtableId ?? this.subtableId,
      confidenceLow: confidenceLow ?? this.confidenceLow,
      modifierJson: modifierJson ?? this.modifierJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tableId.present) {
      map['table_id'] = Variable<String>(tableId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (bodyMd.present) {
      map['body_md'] = Variable<String>(bodyMd.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (rollMin.present) {
      map['roll_min'] = Variable<int>(rollMin.value);
    }
    if (rollMax.present) {
      map['roll_max'] = Variable<int>(rollMax.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (subtableId.present) {
      map['subtable_id'] = Variable<String>(subtableId.value);
    }
    if (confidenceLow.present) {
      map['confidence_low'] = Variable<bool>(confidenceLow.value);
    }
    if (modifierJson.present) {
      map['modifier_json'] = Variable<String>(modifierJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('tableId: $tableId, ')
          ..write('position: $position, ')
          ..write('content: $content, ')
          ..write('bodyMd: $bodyMd, ')
          ..write('weight: $weight, ')
          ..write('rollMin: $rollMin, ')
          ..write('rollMax: $rollMax, ')
          ..write('mediaId: $mediaId, ')
          ..write('subtableId: $subtableId, ')
          ..write('confidenceLow: $confidenceLow, ')
          ..write('modifierJson: $modifierJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  const Tag({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(id: Value(id), name: Value(name));
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Tag copyWith({String? id, String? name}) =>
      Tag(id: id ?? this.id, name: name ?? this.name);
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag && other.id == this.id && other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TableTagsTable extends TableTags
    with TableInfo<$TableTagsTable, TableTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TableTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tableIdMeta = const VerificationMeta(
    'tableId',
  );
  @override
  late final GeneratedColumn<String> tableId = GeneratedColumn<String>(
    'table_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES oracle_tables (id)',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [tableId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'table_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TableTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('table_id')) {
      context.handle(
        _tableIdMeta,
        tableId.isAcceptableOrUnknown(data['table_id']!, _tableIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tableIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tableId, tagId};
  @override
  TableTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TableTag(
      tableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $TableTagsTable createAlias(String alias) {
    return $TableTagsTable(attachedDatabase, alias);
  }
}

class TableTag extends DataClass implements Insertable<TableTag> {
  final String tableId;
  final String tagId;
  const TableTag({required this.tableId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['table_id'] = Variable<String>(tableId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  TableTagsCompanion toCompanion(bool nullToAbsent) {
    return TableTagsCompanion(tableId: Value(tableId), tagId: Value(tagId));
  }

  factory TableTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TableTag(
      tableId: serializer.fromJson<String>(json['tableId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tableId': serializer.toJson<String>(tableId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  TableTag copyWith({String? tableId, String? tagId}) =>
      TableTag(tableId: tableId ?? this.tableId, tagId: tagId ?? this.tagId);
  TableTag copyWithCompanion(TableTagsCompanion data) {
    return TableTag(
      tableId: data.tableId.present ? data.tableId.value : this.tableId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TableTag(')
          ..write('tableId: $tableId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tableId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TableTag &&
          other.tableId == this.tableId &&
          other.tagId == this.tagId);
}

class TableTagsCompanion extends UpdateCompanion<TableTag> {
  final Value<String> tableId;
  final Value<String> tagId;
  final Value<int> rowid;
  const TableTagsCompanion({
    this.tableId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TableTagsCompanion.insert({
    required String tableId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : tableId = Value(tableId),
       tagId = Value(tagId);
  static Insertable<TableTag> custom({
    Expression<String>? tableId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tableId != null) 'table_id': tableId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TableTagsCompanion copyWith({
    Value<String>? tableId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return TableTagsCompanion(
      tableId: tableId ?? this.tableId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tableId.present) {
      map['table_id'] = Variable<String>(tableId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TableTagsCompanion(')
          ..write('tableId: $tableId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('generic'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, description, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Collection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final String id;
  final String name;
  final String? description;

  /// Art der Sammlung: 'deck' | 'supplement' | 'generic'
  final String type;
  const Collection({
    required this.id,
    required this.name,
    this.description,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['type'] = Variable<String>(type);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      type: Value(type),
    );
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'type': serializer.toJson<String>(type),
    };
  }

  Collection copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    String? type,
  }) => Collection(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    type: type ?? this.type,
  );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.type == this.type);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> type;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Collection> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? type,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (type != null) 'type': type,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? type,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('type: $type, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionTablesTable extends CollectionTables
    with TableInfo<$CollectionTablesTable, CollectionTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionTablesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id)',
    ),
  );
  static const VerificationMeta _tableIdMeta = const VerificationMeta(
    'tableId',
  );
  @override
  late final GeneratedColumn<String> tableId = GeneratedColumn<String>(
    'table_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES oracle_tables (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [collectionId, tableId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_tables';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionTable> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('table_id')) {
      context.handle(
        _tableIdMeta,
        tableId.isAcceptableOrUnknown(data['table_id']!, _tableIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tableIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectionId, tableId};
  @override
  CollectionTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionTable(
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      tableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $CollectionTablesTable createAlias(String alias) {
    return $CollectionTablesTable(attachedDatabase, alias);
  }
}

class CollectionTable extends DataClass implements Insertable<CollectionTable> {
  final String collectionId;
  final String tableId;

  /// Reihenfolge der Tabelle innerhalb der Sammlung.
  final int position;
  const CollectionTable({
    required this.collectionId,
    required this.tableId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection_id'] = Variable<String>(collectionId);
    map['table_id'] = Variable<String>(tableId);
    map['position'] = Variable<int>(position);
    return map;
  }

  CollectionTablesCompanion toCompanion(bool nullToAbsent) {
    return CollectionTablesCompanion(
      collectionId: Value(collectionId),
      tableId: Value(tableId),
      position: Value(position),
    );
  }

  factory CollectionTable.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionTable(
      collectionId: serializer.fromJson<String>(json['collectionId']),
      tableId: serializer.fromJson<String>(json['tableId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collectionId': serializer.toJson<String>(collectionId),
      'tableId': serializer.toJson<String>(tableId),
      'position': serializer.toJson<int>(position),
    };
  }

  CollectionTable copyWith({
    String? collectionId,
    String? tableId,
    int? position,
  }) => CollectionTable(
    collectionId: collectionId ?? this.collectionId,
    tableId: tableId ?? this.tableId,
    position: position ?? this.position,
  );
  CollectionTable copyWithCompanion(CollectionTablesCompanion data) {
    return CollectionTable(
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      tableId: data.tableId.present ? data.tableId.value : this.tableId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionTable(')
          ..write('collectionId: $collectionId, ')
          ..write('tableId: $tableId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(collectionId, tableId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionTable &&
          other.collectionId == this.collectionId &&
          other.tableId == this.tableId &&
          other.position == this.position);
}

class CollectionTablesCompanion extends UpdateCompanion<CollectionTable> {
  final Value<String> collectionId;
  final Value<String> tableId;
  final Value<int> position;
  final Value<int> rowid;
  const CollectionTablesCompanion({
    this.collectionId = const Value.absent(),
    this.tableId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionTablesCompanion.insert({
    required String collectionId,
    required String tableId,
    required int position,
    this.rowid = const Value.absent(),
  }) : collectionId = Value(collectionId),
       tableId = Value(tableId),
       position = Value(position);
  static Insertable<CollectionTable> custom({
    Expression<String>? collectionId,
    Expression<String>? tableId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collectionId != null) 'collection_id': collectionId,
      if (tableId != null) 'table_id': tableId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionTablesCompanion copyWith({
    Value<String>? collectionId,
    Value<String>? tableId,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return CollectionTablesCompanion(
      collectionId: collectionId ?? this.collectionId,
      tableId: tableId ?? this.tableId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (tableId.present) {
      map['table_id'] = Variable<String>(tableId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionTablesCompanion(')
          ..write('collectionId: $collectionId, ')
          ..write('tableId: $tableId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EdgesTable extends Edges with TableInfo<$EdgesTable, Edge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EdgesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromTypeMeta = const VerificationMeta(
    'fromType',
  );
  @override
  late final GeneratedColumn<String> fromType = GeneratedColumn<String>(
    'from_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromIdMeta = const VerificationMeta('fromId');
  @override
  late final GeneratedColumn<String> fromId = GeneratedColumn<String>(
    'from_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toTypeMeta = const VerificationMeta('toType');
  @override
  late final GeneratedColumn<String> toType = GeneratedColumn<String>(
    'to_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toIdMeta = const VerificationMeta('toId');
  @override
  late final GeneratedColumn<String> toId = GeneratedColumn<String>(
    'to_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationMeta = const VerificationMeta(
    'relation',
  );
  @override
  late final GeneratedColumn<String> relation = GeneratedColumn<String>(
    'relation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataJsonMeta = const VerificationMeta(
    'metadataJson',
  );
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
    'metadata_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fromType,
    fromId,
    toType,
    toId,
    relation,
    metadataJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'edges';
  @override
  VerificationContext validateIntegrity(
    Insertable<Edge> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_type')) {
      context.handle(
        _fromTypeMeta,
        fromType.isAcceptableOrUnknown(data['from_type']!, _fromTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fromTypeMeta);
    }
    if (data.containsKey('from_id')) {
      context.handle(
        _fromIdMeta,
        fromId.isAcceptableOrUnknown(data['from_id']!, _fromIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fromIdMeta);
    }
    if (data.containsKey('to_type')) {
      context.handle(
        _toTypeMeta,
        toType.isAcceptableOrUnknown(data['to_type']!, _toTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_toTypeMeta);
    }
    if (data.containsKey('to_id')) {
      context.handle(
        _toIdMeta,
        toId.isAcceptableOrUnknown(data['to_id']!, _toIdMeta),
      );
    } else if (isInserting) {
      context.missing(_toIdMeta);
    }
    if (data.containsKey('relation')) {
      context.handle(
        _relationMeta,
        relation.isAcceptableOrUnknown(data['relation']!, _relationMeta),
      );
    } else if (isInserting) {
      context.missing(_relationMeta);
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
        _metadataJsonMeta,
        metadataJson.isAcceptableOrUnknown(
          data['metadata_json']!,
          _metadataJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Edge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Edge(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fromType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_type'],
      )!,
      fromId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_id'],
      )!,
      toType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_type'],
      )!,
      toId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_id'],
      )!,
      relation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation'],
      )!,
      metadataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata_json'],
      ),
    );
  }

  @override
  $EdgesTable createAlias(String alias) {
    return $EdgesTable(attachedDatabase, alias);
  }
}

class Edge extends DataClass implements Insertable<Edge> {
  final String id;
  final String fromType;
  final String fromId;
  final String toType;
  final String toId;

  /// Typ der Relation.
  final String relation;

  /// Optionale Zusatzdaten als JSON.
  final String? metadataJson;
  const Edge({
    required this.id,
    required this.fromType,
    required this.fromId,
    required this.toType,
    required this.toId,
    required this.relation,
    this.metadataJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_type'] = Variable<String>(fromType);
    map['from_id'] = Variable<String>(fromId);
    map['to_type'] = Variable<String>(toType);
    map['to_id'] = Variable<String>(toId);
    map['relation'] = Variable<String>(relation);
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    return map;
  }

  EdgesCompanion toCompanion(bool nullToAbsent) {
    return EdgesCompanion(
      id: Value(id),
      fromType: Value(fromType),
      fromId: Value(fromId),
      toType: Value(toType),
      toId: Value(toId),
      relation: Value(relation),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
    );
  }

  factory Edge.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Edge(
      id: serializer.fromJson<String>(json['id']),
      fromType: serializer.fromJson<String>(json['fromType']),
      fromId: serializer.fromJson<String>(json['fromId']),
      toType: serializer.fromJson<String>(json['toType']),
      toId: serializer.fromJson<String>(json['toId']),
      relation: serializer.fromJson<String>(json['relation']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromType': serializer.toJson<String>(fromType),
      'fromId': serializer.toJson<String>(fromId),
      'toType': serializer.toJson<String>(toType),
      'toId': serializer.toJson<String>(toId),
      'relation': serializer.toJson<String>(relation),
      'metadataJson': serializer.toJson<String?>(metadataJson),
    };
  }

  Edge copyWith({
    String? id,
    String? fromType,
    String? fromId,
    String? toType,
    String? toId,
    String? relation,
    Value<String?> metadataJson = const Value.absent(),
  }) => Edge(
    id: id ?? this.id,
    fromType: fromType ?? this.fromType,
    fromId: fromId ?? this.fromId,
    toType: toType ?? this.toType,
    toId: toId ?? this.toId,
    relation: relation ?? this.relation,
    metadataJson: metadataJson.present ? metadataJson.value : this.metadataJson,
  );
  Edge copyWithCompanion(EdgesCompanion data) {
    return Edge(
      id: data.id.present ? data.id.value : this.id,
      fromType: data.fromType.present ? data.fromType.value : this.fromType,
      fromId: data.fromId.present ? data.fromId.value : this.fromId,
      toType: data.toType.present ? data.toType.value : this.toType,
      toId: data.toId.present ? data.toId.value : this.toId,
      relation: data.relation.present ? data.relation.value : this.relation,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Edge(')
          ..write('id: $id, ')
          ..write('fromType: $fromType, ')
          ..write('fromId: $fromId, ')
          ..write('toType: $toType, ')
          ..write('toId: $toId, ')
          ..write('relation: $relation, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fromType, fromId, toType, toId, relation, metadataJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Edge &&
          other.id == this.id &&
          other.fromType == this.fromType &&
          other.fromId == this.fromId &&
          other.toType == this.toType &&
          other.toId == this.toId &&
          other.relation == this.relation &&
          other.metadataJson == this.metadataJson);
}

class EdgesCompanion extends UpdateCompanion<Edge> {
  final Value<String> id;
  final Value<String> fromType;
  final Value<String> fromId;
  final Value<String> toType;
  final Value<String> toId;
  final Value<String> relation;
  final Value<String?> metadataJson;
  final Value<int> rowid;
  const EdgesCompanion({
    this.id = const Value.absent(),
    this.fromType = const Value.absent(),
    this.fromId = const Value.absent(),
    this.toType = const Value.absent(),
    this.toId = const Value.absent(),
    this.relation = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EdgesCompanion.insert({
    required String id,
    required String fromType,
    required String fromId,
    required String toType,
    required String toId,
    required String relation,
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fromType = Value(fromType),
       fromId = Value(fromId),
       toType = Value(toType),
       toId = Value(toId),
       relation = Value(relation);
  static Insertable<Edge> custom({
    Expression<String>? id,
    Expression<String>? fromType,
    Expression<String>? fromId,
    Expression<String>? toType,
    Expression<String>? toId,
    Expression<String>? relation,
    Expression<String>? metadataJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromType != null) 'from_type': fromType,
      if (fromId != null) 'from_id': fromId,
      if (toType != null) 'to_type': toType,
      if (toId != null) 'to_id': toId,
      if (relation != null) 'relation': relation,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EdgesCompanion copyWith({
    Value<String>? id,
    Value<String>? fromType,
    Value<String>? fromId,
    Value<String>? toType,
    Value<String>? toId,
    Value<String>? relation,
    Value<String?>? metadataJson,
    Value<int>? rowid,
  }) {
    return EdgesCompanion(
      id: id ?? this.id,
      fromType: fromType ?? this.fromType,
      fromId: fromId ?? this.fromId,
      toType: toType ?? this.toType,
      toId: toId ?? this.toId,
      relation: relation ?? this.relation,
      metadataJson: metadataJson ?? this.metadataJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromType.present) {
      map['from_type'] = Variable<String>(fromType.value);
    }
    if (fromId.present) {
      map['from_id'] = Variable<String>(fromId.value);
    }
    if (toType.present) {
      map['to_type'] = Variable<String>(toType.value);
    }
    if (toId.present) {
      map['to_id'] = Variable<String>(toId.value);
    }
    if (relation.present) {
      map['relation'] = Variable<String>(relation.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EdgesCompanion(')
          ..write('id: $id, ')
          ..write('fromType: $fromType, ')
          ..write('fromId: $fromId, ')
          ..write('toType: $toType, ')
          ..write('toId: $toId, ')
          ..write('relation: $relation, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SmartFiltersTable extends SmartFilters
    with TableInfo<$SmartFiltersTable, SmartFilter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SmartFiltersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filterJsonMeta = const VerificationMeta(
    'filterJson',
  );
  @override
  late final GeneratedColumn<String> filterJson = GeneratedColumn<String>(
    'filter_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, filterJson, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'smart_filters';
  @override
  VerificationContext validateIntegrity(
    Insertable<SmartFilter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('filter_json')) {
      context.handle(
        _filterJsonMeta,
        filterJson.isAcceptableOrUnknown(data['filter_json']!, _filterJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_filterJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SmartFilter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SmartFilter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      filterJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SmartFiltersTable createAlias(String alias) {
    return $SmartFiltersTable(attachedDatabase, alias);
  }
}

class SmartFilter extends DataClass implements Insertable<SmartFilter> {
  final String id;
  final String name;

  /// Filter-Definition als JSON. Kompatibel mit MediaShelf-SmartFilters.
  final String filterJson;
  final DateTime createdAt;
  const SmartFilter({
    required this.id,
    required this.name,
    required this.filterJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['filter_json'] = Variable<String>(filterJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SmartFiltersCompanion toCompanion(bool nullToAbsent) {
    return SmartFiltersCompanion(
      id: Value(id),
      name: Value(name),
      filterJson: Value(filterJson),
      createdAt: Value(createdAt),
    );
  }

  factory SmartFilter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SmartFilter(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      filterJson: serializer.fromJson<String>(json['filterJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'filterJson': serializer.toJson<String>(filterJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SmartFilter copyWith({
    String? id,
    String? name,
    String? filterJson,
    DateTime? createdAt,
  }) => SmartFilter(
    id: id ?? this.id,
    name: name ?? this.name,
    filterJson: filterJson ?? this.filterJson,
    createdAt: createdAt ?? this.createdAt,
  );
  SmartFilter copyWithCompanion(SmartFiltersCompanion data) {
    return SmartFilter(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      filterJson: data.filterJson.present
          ? data.filterJson.value
          : this.filterJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmartFilter(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('filterJson: $filterJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, filterJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SmartFilter &&
          other.id == this.id &&
          other.name == this.name &&
          other.filterJson == this.filterJson &&
          other.createdAt == this.createdAt);
}

class SmartFiltersCompanion extends UpdateCompanion<SmartFilter> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> filterJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SmartFiltersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.filterJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SmartFiltersCompanion.insert({
    required String id,
    required String name,
    required String filterJson,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       filterJson = Value(filterJson),
       createdAt = Value(createdAt);
  static Insertable<SmartFilter> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? filterJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (filterJson != null) 'filter_json': filterJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SmartFiltersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? filterJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SmartFiltersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      filterJson: filterJson ?? this.filterJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (filterJson.present) {
      map['filter_json'] = Variable<String>(filterJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmartFiltersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('filterJson: $filterJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WatchSourcesTable extends WatchSources
    with TableInfo<$WatchSourcesTable, WatchSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchSourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configMeta = const VerificationMeta('config');
  @override
  late final GeneratedColumn<String> config = GeneratedColumn<String>(
    'config',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _autoApproveMeta = const VerificationMeta(
    'autoApprove',
  );
  @override
  late final GeneratedColumn<bool> autoApprove = GeneratedColumn<bool>(
    'auto_approve',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_approve" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastCheckedMeta = const VerificationMeta(
    'lastChecked',
  );
  @override
  late final GeneratedColumn<DateTime> lastChecked = GeneratedColumn<DateTime>(
    'last_checked',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    config,
    autoApprove,
    lastChecked,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watch_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchSource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('config')) {
      context.handle(
        _configMeta,
        config.isAcceptableOrUnknown(data['config']!, _configMeta),
      );
    } else if (isInserting) {
      context.missing(_configMeta);
    }
    if (data.containsKey('auto_approve')) {
      context.handle(
        _autoApproveMeta,
        autoApprove.isAcceptableOrUnknown(
          data['auto_approve']!,
          _autoApproveMeta,
        ),
      );
    }
    if (data.containsKey('last_checked')) {
      context.handle(
        _lastCheckedMeta,
        lastChecked.isAcceptableOrUnknown(
          data['last_checked']!,
          _lastCheckedMeta,
        ),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WatchSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchSource(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      config: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config'],
      )!,
      autoApprove: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_approve'],
      )!,
      lastChecked: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_checked'],
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $WatchSourcesTable createAlias(String alias) {
    return $WatchSourcesTable(attachedDatabase, alias);
  }
}

class WatchSource extends DataClass implements Insertable<WatchSource> {
  final String id;

  /// Art der Quelle: 'reddit' | 'rss' | 'folder'
  final String type;

  /// Quellenspezifische Konfiguration als JSON.
  final String config;

  /// Neue Funde direkt importieren ohne Inbox-Review.
  final bool autoApprove;
  final DateTime? lastChecked;
  final bool enabled;
  const WatchSource({
    required this.id,
    required this.type,
    required this.config,
    required this.autoApprove,
    this.lastChecked,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['config'] = Variable<String>(config);
    map['auto_approve'] = Variable<bool>(autoApprove);
    if (!nullToAbsent || lastChecked != null) {
      map['last_checked'] = Variable<DateTime>(lastChecked);
    }
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  WatchSourcesCompanion toCompanion(bool nullToAbsent) {
    return WatchSourcesCompanion(
      id: Value(id),
      type: Value(type),
      config: Value(config),
      autoApprove: Value(autoApprove),
      lastChecked: lastChecked == null && nullToAbsent
          ? const Value.absent()
          : Value(lastChecked),
      enabled: Value(enabled),
    );
  }

  factory WatchSource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchSource(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      config: serializer.fromJson<String>(json['config']),
      autoApprove: serializer.fromJson<bool>(json['autoApprove']),
      lastChecked: serializer.fromJson<DateTime?>(json['lastChecked']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'config': serializer.toJson<String>(config),
      'autoApprove': serializer.toJson<bool>(autoApprove),
      'lastChecked': serializer.toJson<DateTime?>(lastChecked),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  WatchSource copyWith({
    String? id,
    String? type,
    String? config,
    bool? autoApprove,
    Value<DateTime?> lastChecked = const Value.absent(),
    bool? enabled,
  }) => WatchSource(
    id: id ?? this.id,
    type: type ?? this.type,
    config: config ?? this.config,
    autoApprove: autoApprove ?? this.autoApprove,
    lastChecked: lastChecked.present ? lastChecked.value : this.lastChecked,
    enabled: enabled ?? this.enabled,
  );
  WatchSource copyWithCompanion(WatchSourcesCompanion data) {
    return WatchSource(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      config: data.config.present ? data.config.value : this.config,
      autoApprove: data.autoApprove.present
          ? data.autoApprove.value
          : this.autoApprove,
      lastChecked: data.lastChecked.present
          ? data.lastChecked.value
          : this.lastChecked,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchSource(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('config: $config, ')
          ..write('autoApprove: $autoApprove, ')
          ..write('lastChecked: $lastChecked, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, config, autoApprove, lastChecked, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchSource &&
          other.id == this.id &&
          other.type == this.type &&
          other.config == this.config &&
          other.autoApprove == this.autoApprove &&
          other.lastChecked == this.lastChecked &&
          other.enabled == this.enabled);
}

class WatchSourcesCompanion extends UpdateCompanion<WatchSource> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> config;
  final Value<bool> autoApprove;
  final Value<DateTime?> lastChecked;
  final Value<bool> enabled;
  final Value<int> rowid;
  const WatchSourcesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.config = const Value.absent(),
    this.autoApprove = const Value.absent(),
    this.lastChecked = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchSourcesCompanion.insert({
    required String id,
    required String type,
    required String config,
    this.autoApprove = const Value.absent(),
    this.lastChecked = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       config = Value(config);
  static Insertable<WatchSource> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? config,
    Expression<bool>? autoApprove,
    Expression<DateTime>? lastChecked,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (config != null) 'config': config,
      if (autoApprove != null) 'auto_approve': autoApprove,
      if (lastChecked != null) 'last_checked': lastChecked,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchSourcesCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? config,
    Value<bool>? autoApprove,
    Value<DateTime?>? lastChecked,
    Value<bool>? enabled,
    Value<int>? rowid,
  }) {
    return WatchSourcesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      config: config ?? this.config,
      autoApprove: autoApprove ?? this.autoApprove,
      lastChecked: lastChecked ?? this.lastChecked,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (config.present) {
      map['config'] = Variable<String>(config.value);
    }
    if (autoApprove.present) {
      map['auto_approve'] = Variable<bool>(autoApprove.value);
    }
    if (lastChecked.present) {
      map['last_checked'] = Variable<DateTime>(lastChecked.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchSourcesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('config: $config, ')
          ..write('autoApprove: $autoApprove, ')
          ..write('lastChecked: $lastChecked, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InboxItemsTable extends InboxItems
    with TableInfo<$InboxItemsTable, InboxItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InboxItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _watchSourceIdMeta = const VerificationMeta(
    'watchSourceId',
  );
  @override
  late final GeneratedColumn<String> watchSourceId = GeneratedColumn<String>(
    'watch_source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES watch_sources (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _rawDataJsonMeta = const VerificationMeta(
    'rawDataJson',
  );
  @override
  late final GeneratedColumn<String> rawDataJson = GeneratedColumn<String>(
    'raw_data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedTableIdMeta = const VerificationMeta(
    'importedTableId',
  );
  @override
  late final GeneratedColumn<String> importedTableId = GeneratedColumn<String>(
    'imported_table_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES oracle_tables (id)',
    ),
  );
  static const VerificationMeta _foundAtMeta = const VerificationMeta(
    'foundAt',
  );
  @override
  late final GeneratedColumn<DateTime> foundAt = GeneratedColumn<DateTime>(
    'found_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    watchSourceId,
    status,
    rawDataJson,
    importedTableId,
    foundAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inbox_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<InboxItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('watch_source_id')) {
      context.handle(
        _watchSourceIdMeta,
        watchSourceId.isAcceptableOrUnknown(
          data['watch_source_id']!,
          _watchSourceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_watchSourceIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('raw_data_json')) {
      context.handle(
        _rawDataJsonMeta,
        rawDataJson.isAcceptableOrUnknown(
          data['raw_data_json']!,
          _rawDataJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawDataJsonMeta);
    }
    if (data.containsKey('imported_table_id')) {
      context.handle(
        _importedTableIdMeta,
        importedTableId.isAcceptableOrUnknown(
          data['imported_table_id']!,
          _importedTableIdMeta,
        ),
      );
    }
    if (data.containsKey('found_at')) {
      context.handle(
        _foundAtMeta,
        foundAt.isAcceptableOrUnknown(data['found_at']!, _foundAtMeta),
      );
    } else if (isInserting) {
      context.missing(_foundAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InboxItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InboxItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      watchSourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}watch_source_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      rawDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_data_json'],
      )!,
      importedTableId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}imported_table_id'],
      ),
      foundAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}found_at'],
      )!,
    );
  }

  @override
  $InboxItemsTable createAlias(String alias) {
    return $InboxItemsTable(attachedDatabase, alias);
  }
}

class InboxItem extends DataClass implements Insertable<InboxItem> {
  final String id;
  final String watchSourceId;

  /// Verarbeitungsstatus: 'pending' | 'accepted' | 'dismissed' | 'auto_imported'
  final String status;

  /// Vollständige Roh-Daten als JSON für nachträgliche Verarbeitung.
  final String rawDataJson;

  /// Verknüpfte OracleTable nach erfolgtem Import. Null solange pending.
  final String? importedTableId;
  final DateTime foundAt;
  const InboxItem({
    required this.id,
    required this.watchSourceId,
    required this.status,
    required this.rawDataJson,
    this.importedTableId,
    required this.foundAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['watch_source_id'] = Variable<String>(watchSourceId);
    map['status'] = Variable<String>(status);
    map['raw_data_json'] = Variable<String>(rawDataJson);
    if (!nullToAbsent || importedTableId != null) {
      map['imported_table_id'] = Variable<String>(importedTableId);
    }
    map['found_at'] = Variable<DateTime>(foundAt);
    return map;
  }

  InboxItemsCompanion toCompanion(bool nullToAbsent) {
    return InboxItemsCompanion(
      id: Value(id),
      watchSourceId: Value(watchSourceId),
      status: Value(status),
      rawDataJson: Value(rawDataJson),
      importedTableId: importedTableId == null && nullToAbsent
          ? const Value.absent()
          : Value(importedTableId),
      foundAt: Value(foundAt),
    );
  }

  factory InboxItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InboxItem(
      id: serializer.fromJson<String>(json['id']),
      watchSourceId: serializer.fromJson<String>(json['watchSourceId']),
      status: serializer.fromJson<String>(json['status']),
      rawDataJson: serializer.fromJson<String>(json['rawDataJson']),
      importedTableId: serializer.fromJson<String?>(json['importedTableId']),
      foundAt: serializer.fromJson<DateTime>(json['foundAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'watchSourceId': serializer.toJson<String>(watchSourceId),
      'status': serializer.toJson<String>(status),
      'rawDataJson': serializer.toJson<String>(rawDataJson),
      'importedTableId': serializer.toJson<String?>(importedTableId),
      'foundAt': serializer.toJson<DateTime>(foundAt),
    };
  }

  InboxItem copyWith({
    String? id,
    String? watchSourceId,
    String? status,
    String? rawDataJson,
    Value<String?> importedTableId = const Value.absent(),
    DateTime? foundAt,
  }) => InboxItem(
    id: id ?? this.id,
    watchSourceId: watchSourceId ?? this.watchSourceId,
    status: status ?? this.status,
    rawDataJson: rawDataJson ?? this.rawDataJson,
    importedTableId: importedTableId.present
        ? importedTableId.value
        : this.importedTableId,
    foundAt: foundAt ?? this.foundAt,
  );
  InboxItem copyWithCompanion(InboxItemsCompanion data) {
    return InboxItem(
      id: data.id.present ? data.id.value : this.id,
      watchSourceId: data.watchSourceId.present
          ? data.watchSourceId.value
          : this.watchSourceId,
      status: data.status.present ? data.status.value : this.status,
      rawDataJson: data.rawDataJson.present
          ? data.rawDataJson.value
          : this.rawDataJson,
      importedTableId: data.importedTableId.present
          ? data.importedTableId.value
          : this.importedTableId,
      foundAt: data.foundAt.present ? data.foundAt.value : this.foundAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InboxItem(')
          ..write('id: $id, ')
          ..write('watchSourceId: $watchSourceId, ')
          ..write('status: $status, ')
          ..write('rawDataJson: $rawDataJson, ')
          ..write('importedTableId: $importedTableId, ')
          ..write('foundAt: $foundAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    watchSourceId,
    status,
    rawDataJson,
    importedTableId,
    foundAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InboxItem &&
          other.id == this.id &&
          other.watchSourceId == this.watchSourceId &&
          other.status == this.status &&
          other.rawDataJson == this.rawDataJson &&
          other.importedTableId == this.importedTableId &&
          other.foundAt == this.foundAt);
}

class InboxItemsCompanion extends UpdateCompanion<InboxItem> {
  final Value<String> id;
  final Value<String> watchSourceId;
  final Value<String> status;
  final Value<String> rawDataJson;
  final Value<String?> importedTableId;
  final Value<DateTime> foundAt;
  final Value<int> rowid;
  const InboxItemsCompanion({
    this.id = const Value.absent(),
    this.watchSourceId = const Value.absent(),
    this.status = const Value.absent(),
    this.rawDataJson = const Value.absent(),
    this.importedTableId = const Value.absent(),
    this.foundAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InboxItemsCompanion.insert({
    required String id,
    required String watchSourceId,
    this.status = const Value.absent(),
    required String rawDataJson,
    this.importedTableId = const Value.absent(),
    required DateTime foundAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       watchSourceId = Value(watchSourceId),
       rawDataJson = Value(rawDataJson),
       foundAt = Value(foundAt);
  static Insertable<InboxItem> custom({
    Expression<String>? id,
    Expression<String>? watchSourceId,
    Expression<String>? status,
    Expression<String>? rawDataJson,
    Expression<String>? importedTableId,
    Expression<DateTime>? foundAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (watchSourceId != null) 'watch_source_id': watchSourceId,
      if (status != null) 'status': status,
      if (rawDataJson != null) 'raw_data_json': rawDataJson,
      if (importedTableId != null) 'imported_table_id': importedTableId,
      if (foundAt != null) 'found_at': foundAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InboxItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? watchSourceId,
    Value<String>? status,
    Value<String>? rawDataJson,
    Value<String?>? importedTableId,
    Value<DateTime>? foundAt,
    Value<int>? rowid,
  }) {
    return InboxItemsCompanion(
      id: id ?? this.id,
      watchSourceId: watchSourceId ?? this.watchSourceId,
      status: status ?? this.status,
      rawDataJson: rawDataJson ?? this.rawDataJson,
      importedTableId: importedTableId ?? this.importedTableId,
      foundAt: foundAt ?? this.foundAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (watchSourceId.present) {
      map['watch_source_id'] = Variable<String>(watchSourceId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rawDataJson.present) {
      map['raw_data_json'] = Variable<String>(rawDataJson.value);
    }
    if (importedTableId.present) {
      map['imported_table_id'] = Variable<String>(importedTableId.value);
    }
    if (foundAt.present) {
      map['found_at'] = Variable<DateTime>(foundAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InboxItemsCompanion(')
          ..write('id: $id, ')
          ..write('watchSourceId: $watchSourceId, ')
          ..write('status: $status, ')
          ..write('rawDataJson: $rawDataJson, ')
          ..write('importedTableId: $importedTableId, ')
          ..write('foundAt: $foundAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$VaultDatabase extends GeneratedDatabase {
  _$VaultDatabase(QueryExecutor e) : super(e);
  $VaultDatabaseManager get managers => $VaultDatabaseManager(this);
  late final $SourcesTable sources = $SourcesTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $OracleTablesTable oracleTables = $OracleTablesTable(this);
  late final $MediaFilesTable mediaFiles = $MediaFilesTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $TableTagsTable tableTags = $TableTagsTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $CollectionTablesTable collectionTables = $CollectionTablesTable(
    this,
  );
  late final $EdgesTable edges = $EdgesTable(this);
  late final $SmartFiltersTable smartFilters = $SmartFiltersTable(this);
  late final $WatchSourcesTable watchSources = $WatchSourcesTable(this);
  late final $InboxItemsTable inboxItems = $InboxItemsTable(this);
  late final CollectionDao collectionDao = CollectionDao(this as VaultDatabase);
  late final EdgeDao edgeDao = EdgeDao(this as VaultDatabase);
  late final TableDao tableDao = TableDao(this as VaultDatabase);
  late final EntryDao entryDao = EntryDao(this as VaultDatabase);
  late final TagDao tagDao = TagDao(this as VaultDatabase);
  late final CategoryDao categoryDao = CategoryDao(this as VaultDatabase);
  late final SourceDao sourceDao = SourceDao(this as VaultDatabase);
  late final MediaDao mediaDao = MediaDao(this as VaultDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sources,
    categories,
    oracleTables,
    mediaFiles,
    entries,
    tags,
    tableTags,
    collections,
    collectionTables,
    edges,
    smartFilters,
    watchSources,
    inboxItems,
  ];
}

typedef $$SourcesTableCreateCompanionBuilder =
    SourcesCompanion Function({
      required String id,
      required String type,
      Value<String?> title,
      Value<String?> author,
      Value<String?> url,
      Value<String?> license,
      Value<String?> aiProviderJson,
      Value<String?> notes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SourcesTableUpdateCompanionBuilder =
    SourcesCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String?> title,
      Value<String?> author,
      Value<String?> url,
      Value<String?> license,
      Value<String?> aiProviderJson,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SourcesTableReferences
    extends BaseReferences<_$VaultDatabase, $SourcesTable, Source> {
  $$SourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OracleTablesTable, List<OracleTable>>
  _oracleTablesRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.oracleTables,
    aliasName: $_aliasNameGenerator(db.sources.id, db.oracleTables.sourceId),
  );

  $$OracleTablesTableProcessedTableManager get oracleTablesRefs {
    final manager = $$OracleTablesTableTableManager(
      $_db,
      $_db.oracleTables,
    ).filter((f) => f.sourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_oracleTablesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SourcesTableFilterComposer
    extends Composer<_$VaultDatabase, $SourcesTable> {
  $$SourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiProviderJson => $composableBuilder(
    column: $table.aiProviderJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> oracleTablesRefs(
    Expression<bool> Function($$OracleTablesTableFilterComposer f) f,
  ) {
    final $$OracleTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableFilterComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourcesTableOrderingComposer
    extends Composer<_$VaultDatabase, $SourcesTable> {
  $$SourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get license => $composableBuilder(
    column: $table.license,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiProviderJson => $composableBuilder(
    column: $table.aiProviderJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SourcesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $SourcesTable> {
  $$SourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get license =>
      $composableBuilder(column: $table.license, builder: (column) => column);

  GeneratedColumn<String> get aiProviderJson => $composableBuilder(
    column: $table.aiProviderJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> oracleTablesRefs<T extends Object>(
    Expression<T> Function($$OracleTablesTableAnnotationComposer a) f,
  ) {
    final $$OracleTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.sourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SourcesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $SourcesTable,
          Source,
          $$SourcesTableFilterComposer,
          $$SourcesTableOrderingComposer,
          $$SourcesTableAnnotationComposer,
          $$SourcesTableCreateCompanionBuilder,
          $$SourcesTableUpdateCompanionBuilder,
          (Source, $$SourcesTableReferences),
          Source,
          PrefetchHooks Function({bool oracleTablesRefs})
        > {
  $$SourcesTableTableManager(_$VaultDatabase db, $SourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> license = const Value.absent(),
                Value<String?> aiProviderJson = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SourcesCompanion(
                id: id,
                type: type,
                title: title,
                author: author,
                url: url,
                license: license,
                aiProviderJson: aiProviderJson,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                Value<String?> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String?> license = const Value.absent(),
                Value<String?> aiProviderJson = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SourcesCompanion.insert(
                id: id,
                type: type,
                title: title,
                author: author,
                url: url,
                license: license,
                aiProviderJson: aiProviderJson,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({oracleTablesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (oracleTablesRefs) db.oracleTables],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (oracleTablesRefs)
                    await $_getPrefetchedData<
                      Source,
                      $SourcesTable,
                      OracleTable
                    >(
                      currentTable: table,
                      referencedTable: $$SourcesTableReferences
                          ._oracleTablesRefsTable(db),
                      managerFromTypedResult: (p0) => $$SourcesTableReferences(
                        db,
                        table,
                        p0,
                      ).oracleTablesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sourceId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $SourcesTable,
      Source,
      $$SourcesTableFilterComposer,
      $$SourcesTableOrderingComposer,
      $$SourcesTableAnnotationComposer,
      $$SourcesTableCreateCompanionBuilder,
      $$SourcesTableUpdateCompanionBuilder,
      (Source, $$SourcesTableReferences),
      Source,
      PrefetchHooks Function({bool oracleTablesRefs})
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      Value<String?> parentId,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> parentId,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$VaultDatabase, $CategoriesTable, Category> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _parentIdTable(_$VaultDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.categories.parentId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OracleTablesTable, List<OracleTable>>
  _oracleTablesRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.oracleTables,
    aliasName: $_aliasNameGenerator(
      db.categories.id,
      db.oracleTables.categoryId,
    ),
  );

  $$OracleTablesTableProcessedTableManager get oracleTablesRefs {
    final manager = $$OracleTablesTableTableManager(
      $_db,
      $_db.oracleTables,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_oracleTablesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$VaultDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get parentId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> oracleTablesRefs(
    Expression<bool> Function($$OracleTablesTableFilterComposer f) f,
  ) {
    final $$OracleTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableFilterComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$VaultDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get parentId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get parentId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> oracleTablesRefs<T extends Object>(
    Expression<T> Function($$OracleTablesTableAnnotationComposer a) f,
  ) {
    final $$OracleTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, $$CategoriesTableReferences),
          Category,
          PrefetchHooks Function({bool parentId, bool oracleTablesRefs})
        > {
  $$CategoriesTableTableManager(_$VaultDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                parentId: parentId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> parentId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                parentId: parentId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({parentId = false, oracleTablesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (oracleTablesRefs) db.oracleTables,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (parentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentId,
                                    referencedTable: $$CategoriesTableReferences
                                        ._parentIdTable(db),
                                    referencedColumn:
                                        $$CategoriesTableReferences
                                            ._parentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (oracleTablesRefs)
                        await $_getPrefetchedData<
                          Category,
                          $CategoriesTable,
                          OracleTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._oracleTablesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).oracleTablesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, $$CategoriesTableReferences),
      Category,
      PrefetchHooks Function({bool parentId, bool oracleTablesRefs})
    >;
typedef $$OracleTablesTableCreateCompanionBuilder =
    OracleTablesCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<String> oracleType,
      Value<String?> diceExpr,
      Value<String?> genre,
      Value<String?> theme,
      Value<String?> categoryId,
      Value<String?> sourceId,
      Value<String> language,
      Value<String?> metadataJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$OracleTablesTableUpdateCompanionBuilder =
    OracleTablesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String> oracleType,
      Value<String?> diceExpr,
      Value<String?> genre,
      Value<String?> theme,
      Value<String?> categoryId,
      Value<String?> sourceId,
      Value<String> language,
      Value<String?> metadataJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$OracleTablesTableReferences
    extends BaseReferences<_$VaultDatabase, $OracleTablesTable, OracleTable> {
  $$OracleTablesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$VaultDatabase db) =>
      db.categories.createAlias(
        $_aliasNameGenerator(db.oracleTables.categoryId, db.categories.id),
      );

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SourcesTable _sourceIdTable(_$VaultDatabase db) =>
      db.sources.createAlias(
        $_aliasNameGenerator(db.oracleTables.sourceId, db.sources.id),
      );

  $$SourcesTableProcessedTableManager? get sourceId {
    final $_column = $_itemColumn<String>('source_id');
    if ($_column == null) return null;
    final manager = $$SourcesTableTableManager(
      $_db,
      $_db.sources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EntriesTable, List<Entry>> _entriesTable(
    _$VaultDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: $_aliasNameGenerator(db.oracleTables.id, db.entries.tableId),
  );

  $$EntriesTableProcessedTableManager get entries {
    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.tableId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EntriesTable, List<Entry>> _subtableEntriesTable(
    _$VaultDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: $_aliasNameGenerator(db.oracleTables.id, db.entries.subtableId),
  );

  $$EntriesTableProcessedTableManager get subtableEntries {
    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.subtableId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_subtableEntriesTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TableTagsTable, List<TableTag>>
  _tableTagsRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.tableTags,
    aliasName: $_aliasNameGenerator(db.oracleTables.id, db.tableTags.tableId),
  );

  $$TableTagsTableProcessedTableManager get tableTagsRefs {
    final manager = $$TableTagsTableTableManager(
      $_db,
      $_db.tableTags,
    ).filter((f) => f.tableId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tableTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CollectionTablesTable, List<CollectionTable>>
  _collectionTablesRefsTable(_$VaultDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.collectionTables,
        aliasName: $_aliasNameGenerator(
          db.oracleTables.id,
          db.collectionTables.tableId,
        ),
      );

  $$CollectionTablesTableProcessedTableManager get collectionTablesRefs {
    final manager = $$CollectionTablesTableTableManager(
      $_db,
      $_db.collectionTables,
    ).filter((f) => f.tableId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionTablesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InboxItemsTable, List<InboxItem>>
  _inboxItemsRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.inboxItems,
    aliasName: $_aliasNameGenerator(
      db.oracleTables.id,
      db.inboxItems.importedTableId,
    ),
  );

  $$InboxItemsTableProcessedTableManager get inboxItemsRefs {
    final manager = $$InboxItemsTableTableManager($_db, $_db.inboxItems).filter(
      (f) => f.importedTableId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_inboxItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OracleTablesTableFilterComposer
    extends Composer<_$VaultDatabase, $OracleTablesTable> {
  $$OracleTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oracleType => $composableBuilder(
    column: $table.oracleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get diceExpr => $composableBuilder(
    column: $table.diceExpr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourcesTableFilterComposer get sourceId {
    final $$SourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableFilterComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> entries(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.tableId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> subtableEntries(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.subtableId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tableTagsRefs(
    Expression<bool> Function($$TableTagsTableFilterComposer f) f,
  ) {
    final $$TableTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tableTags,
      getReferencedColumn: (t) => t.tableId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TableTagsTableFilterComposer(
            $db: $db,
            $table: $db.tableTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> collectionTablesRefs(
    Expression<bool> Function($$CollectionTablesTableFilterComposer f) f,
  ) {
    final $$CollectionTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionTables,
      getReferencedColumn: (t) => t.tableId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionTablesTableFilterComposer(
            $db: $db,
            $table: $db.collectionTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> inboxItemsRefs(
    Expression<bool> Function($$InboxItemsTableFilterComposer f) f,
  ) {
    final $$InboxItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inboxItems,
      getReferencedColumn: (t) => t.importedTableId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InboxItemsTableFilterComposer(
            $db: $db,
            $table: $db.inboxItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OracleTablesTableOrderingComposer
    extends Composer<_$VaultDatabase, $OracleTablesTable> {
  $$OracleTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oracleType => $composableBuilder(
    column: $table.oracleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get diceExpr => $composableBuilder(
    column: $table.diceExpr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get theme => $composableBuilder(
    column: $table.theme,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourcesTableOrderingComposer get sourceId {
    final $$SourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableOrderingComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OracleTablesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $OracleTablesTable> {
  $$OracleTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oracleType => $composableBuilder(
    column: $table.oracleType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get diceExpr =>
      $composableBuilder(column: $table.diceExpr, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<String> get theme =>
      $composableBuilder(column: $table.theme, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SourcesTableAnnotationComposer get sourceId {
    final $$SourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceId,
      referencedTable: $db.sources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.sources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> entries<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.tableId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> subtableEntries<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.subtableId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tableTagsRefs<T extends Object>(
    Expression<T> Function($$TableTagsTableAnnotationComposer a) f,
  ) {
    final $$TableTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tableTags,
      getReferencedColumn: (t) => t.tableId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TableTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tableTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> collectionTablesRefs<T extends Object>(
    Expression<T> Function($$CollectionTablesTableAnnotationComposer a) f,
  ) {
    final $$CollectionTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionTables,
      getReferencedColumn: (t) => t.tableId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.collectionTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> inboxItemsRefs<T extends Object>(
    Expression<T> Function($$InboxItemsTableAnnotationComposer a) f,
  ) {
    final $$InboxItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inboxItems,
      getReferencedColumn: (t) => t.importedTableId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InboxItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.inboxItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OracleTablesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $OracleTablesTable,
          OracleTable,
          $$OracleTablesTableFilterComposer,
          $$OracleTablesTableOrderingComposer,
          $$OracleTablesTableAnnotationComposer,
          $$OracleTablesTableCreateCompanionBuilder,
          $$OracleTablesTableUpdateCompanionBuilder,
          (OracleTable, $$OracleTablesTableReferences),
          OracleTable,
          PrefetchHooks Function({
            bool categoryId,
            bool sourceId,
            bool entries,
            bool subtableEntries,
            bool tableTagsRefs,
            bool collectionTablesRefs,
            bool inboxItemsRefs,
          })
        > {
  $$OracleTablesTableTableManager(_$VaultDatabase db, $OracleTablesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OracleTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OracleTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OracleTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> oracleType = const Value.absent(),
                Value<String?> diceExpr = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String?> theme = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OracleTablesCompanion(
                id: id,
                name: name,
                description: description,
                oracleType: oracleType,
                diceExpr: diceExpr,
                genre: genre,
                theme: theme,
                categoryId: categoryId,
                sourceId: sourceId,
                language: language,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String> oracleType = const Value.absent(),
                Value<String?> diceExpr = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String?> theme = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> sourceId = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => OracleTablesCompanion.insert(
                id: id,
                name: name,
                description: description,
                oracleType: oracleType,
                diceExpr: diceExpr,
                genre: genre,
                theme: theme,
                categoryId: categoryId,
                sourceId: sourceId,
                language: language,
                metadataJson: metadataJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OracleTablesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                sourceId = false,
                entries = false,
                subtableEntries = false,
                tableTagsRefs = false,
                collectionTablesRefs = false,
                inboxItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (entries) db.entries,
                    if (subtableEntries) db.entries,
                    if (tableTagsRefs) db.tableTags,
                    if (collectionTablesRefs) db.collectionTables,
                    if (inboxItemsRefs) db.inboxItems,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$OracleTablesTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$OracleTablesTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceId,
                                    referencedTable:
                                        $$OracleTablesTableReferences
                                            ._sourceIdTable(db),
                                    referencedColumn:
                                        $$OracleTablesTableReferences
                                            ._sourceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (entries)
                        await $_getPrefetchedData<
                          OracleTable,
                          $OracleTablesTable,
                          Entry
                        >(
                          currentTable: table,
                          referencedTable: $$OracleTablesTableReferences
                              ._entriesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OracleTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).entries,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tableId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (subtableEntries)
                        await $_getPrefetchedData<
                          OracleTable,
                          $OracleTablesTable,
                          Entry
                        >(
                          currentTable: table,
                          referencedTable: $$OracleTablesTableReferences
                              ._subtableEntriesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OracleTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).subtableEntries,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.subtableId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tableTagsRefs)
                        await $_getPrefetchedData<
                          OracleTable,
                          $OracleTablesTable,
                          TableTag
                        >(
                          currentTable: table,
                          referencedTable: $$OracleTablesTableReferences
                              ._tableTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OracleTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).tableTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tableId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (collectionTablesRefs)
                        await $_getPrefetchedData<
                          OracleTable,
                          $OracleTablesTable,
                          CollectionTable
                        >(
                          currentTable: table,
                          referencedTable: $$OracleTablesTableReferences
                              ._collectionTablesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OracleTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).collectionTablesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tableId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (inboxItemsRefs)
                        await $_getPrefetchedData<
                          OracleTable,
                          $OracleTablesTable,
                          InboxItem
                        >(
                          currentTable: table,
                          referencedTable: $$OracleTablesTableReferences
                              ._inboxItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OracleTablesTableReferences(
                                db,
                                table,
                                p0,
                              ).inboxItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importedTableId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OracleTablesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $OracleTablesTable,
      OracleTable,
      $$OracleTablesTableFilterComposer,
      $$OracleTablesTableOrderingComposer,
      $$OracleTablesTableAnnotationComposer,
      $$OracleTablesTableCreateCompanionBuilder,
      $$OracleTablesTableUpdateCompanionBuilder,
      (OracleTable, $$OracleTablesTableReferences),
      OracleTable,
      PrefetchHooks Function({
        bool categoryId,
        bool sourceId,
        bool entries,
        bool subtableEntries,
        bool tableTagsRefs,
        bool collectionTablesRefs,
        bool inboxItemsRefs,
      })
    >;
typedef $$MediaFilesTableCreateCompanionBuilder =
    MediaFilesCompanion Function({
      required String id,
      required String type,
      required String filePath,
      Value<String?> mime,
      required String hash,
      Value<String?> title,
      Value<String?> metadataJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MediaFilesTableUpdateCompanionBuilder =
    MediaFilesCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> filePath,
      Value<String?> mime,
      Value<String> hash,
      Value<String?> title,
      Value<String?> metadataJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MediaFilesTableReferences
    extends BaseReferences<_$VaultDatabase, $MediaFilesTable, MediaFile> {
  $$MediaFilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EntriesTable, List<Entry>> _entriesRefsTable(
    _$VaultDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: $_aliasNameGenerator(db.mediaFiles.id, db.entries.mediaId),
  );

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.mediaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MediaFilesTableFilterComposer
    extends Composer<_$VaultDatabase, $MediaFilesTable> {
  $$MediaFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> entriesRefs(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.mediaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MediaFilesTableOrderingComposer
    extends Composer<_$VaultDatabase, $MediaFilesTable> {
  $$MediaFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hash => $composableBuilder(
    column: $table.hash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaFilesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $MediaFilesTable> {
  $$MediaFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<String> get hash =>
      $composableBuilder(column: $table.hash, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> entriesRefs<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.mediaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MediaFilesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $MediaFilesTable,
          MediaFile,
          $$MediaFilesTableFilterComposer,
          $$MediaFilesTableOrderingComposer,
          $$MediaFilesTableAnnotationComposer,
          $$MediaFilesTableCreateCompanionBuilder,
          $$MediaFilesTableUpdateCompanionBuilder,
          (MediaFile, $$MediaFilesTableReferences),
          MediaFile,
          PrefetchHooks Function({bool entriesRefs})
        > {
  $$MediaFilesTableTableManager(_$VaultDatabase db, $MediaFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> mime = const Value.absent(),
                Value<String> hash = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaFilesCompanion(
                id: id,
                type: type,
                filePath: filePath,
                mime: mime,
                hash: hash,
                title: title,
                metadataJson: metadataJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String filePath,
                Value<String?> mime = const Value.absent(),
                required String hash,
                Value<String?> title = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MediaFilesCompanion.insert(
                id: id,
                type: type,
                filePath: filePath,
                mime: mime,
                hash: hash,
                title: title,
                metadataJson: metadataJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MediaFilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (entriesRefs) db.entries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (entriesRefs)
                    await $_getPrefetchedData<
                      MediaFile,
                      $MediaFilesTable,
                      Entry
                    >(
                      currentTable: table,
                      referencedTable: $$MediaFilesTableReferences
                          ._entriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MediaFilesTableReferences(
                            db,
                            table,
                            p0,
                          ).entriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.mediaId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MediaFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $MediaFilesTable,
      MediaFile,
      $$MediaFilesTableFilterComposer,
      $$MediaFilesTableOrderingComposer,
      $$MediaFilesTableAnnotationComposer,
      $$MediaFilesTableCreateCompanionBuilder,
      $$MediaFilesTableUpdateCompanionBuilder,
      (MediaFile, $$MediaFilesTableReferences),
      MediaFile,
      PrefetchHooks Function({bool entriesRefs})
    >;
typedef $$EntriesTableCreateCompanionBuilder =
    EntriesCompanion Function({
      required String id,
      required String tableId,
      required int position,
      required String content,
      Value<String?> bodyMd,
      Value<double> weight,
      Value<int?> rollMin,
      Value<int?> rollMax,
      Value<String?> mediaId,
      Value<String?> subtableId,
      Value<bool> confidenceLow,
      Value<String?> modifierJson,
      Value<int> rowid,
    });
typedef $$EntriesTableUpdateCompanionBuilder =
    EntriesCompanion Function({
      Value<String> id,
      Value<String> tableId,
      Value<int> position,
      Value<String> content,
      Value<String?> bodyMd,
      Value<double> weight,
      Value<int?> rollMin,
      Value<int?> rollMax,
      Value<String?> mediaId,
      Value<String?> subtableId,
      Value<bool> confidenceLow,
      Value<String?> modifierJson,
      Value<int> rowid,
    });

final class $$EntriesTableReferences
    extends BaseReferences<_$VaultDatabase, $EntriesTable, Entry> {
  $$EntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OracleTablesTable _tableIdTable(_$VaultDatabase db) =>
      db.oracleTables.createAlias(
        $_aliasNameGenerator(db.entries.tableId, db.oracleTables.id),
      );

  $$OracleTablesTableProcessedTableManager get tableId {
    final $_column = $_itemColumn<String>('table_id')!;

    final manager = $$OracleTablesTableTableManager(
      $_db,
      $_db.oracleTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tableIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MediaFilesTable _mediaIdTable(_$VaultDatabase db) => db.mediaFiles
      .createAlias($_aliasNameGenerator(db.entries.mediaId, db.mediaFiles.id));

  $$MediaFilesTableProcessedTableManager? get mediaId {
    final $_column = $_itemColumn<String>('media_id');
    if ($_column == null) return null;
    final manager = $$MediaFilesTableTableManager(
      $_db,
      $_db.mediaFiles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OracleTablesTable _subtableIdTable(_$VaultDatabase db) =>
      db.oracleTables.createAlias(
        $_aliasNameGenerator(db.entries.subtableId, db.oracleTables.id),
      );

  $$OracleTablesTableProcessedTableManager? get subtableId {
    final $_column = $_itemColumn<String>('subtable_id');
    if ($_column == null) return null;
    final manager = $$OracleTablesTableTableManager(
      $_db,
      $_db.oracleTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subtableIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntriesTableFilterComposer
    extends Composer<_$VaultDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyMd => $composableBuilder(
    column: $table.bodyMd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rollMin => $composableBuilder(
    column: $table.rollMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rollMax => $composableBuilder(
    column: $table.rollMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get confidenceLow => $composableBuilder(
    column: $table.confidenceLow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modifierJson => $composableBuilder(
    column: $table.modifierJson,
    builder: (column) => ColumnFilters(column),
  );

  $$OracleTablesTableFilterComposer get tableId {
    final $$OracleTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tableId,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableFilterComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MediaFilesTableFilterComposer get mediaId {
    final $$MediaFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaId,
      referencedTable: $db.mediaFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaFilesTableFilterComposer(
            $db: $db,
            $table: $db.mediaFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OracleTablesTableFilterComposer get subtableId {
    final $$OracleTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subtableId,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableFilterComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableOrderingComposer
    extends Composer<_$VaultDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyMd => $composableBuilder(
    column: $table.bodyMd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rollMin => $composableBuilder(
    column: $table.rollMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rollMax => $composableBuilder(
    column: $table.rollMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get confidenceLow => $composableBuilder(
    column: $table.confidenceLow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modifierJson => $composableBuilder(
    column: $table.modifierJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$OracleTablesTableOrderingComposer get tableId {
    final $$OracleTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tableId,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableOrderingComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MediaFilesTableOrderingComposer get mediaId {
    final $$MediaFilesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaId,
      referencedTable: $db.mediaFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaFilesTableOrderingComposer(
            $db: $db,
            $table: $db.mediaFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OracleTablesTableOrderingComposer get subtableId {
    final $$OracleTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subtableId,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableOrderingComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get bodyMd =>
      $composableBuilder(column: $table.bodyMd, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get rollMin =>
      $composableBuilder(column: $table.rollMin, builder: (column) => column);

  GeneratedColumn<int> get rollMax =>
      $composableBuilder(column: $table.rollMax, builder: (column) => column);

  GeneratedColumn<bool> get confidenceLow => $composableBuilder(
    column: $table.confidenceLow,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modifierJson => $composableBuilder(
    column: $table.modifierJson,
    builder: (column) => column,
  );

  $$OracleTablesTableAnnotationComposer get tableId {
    final $$OracleTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tableId,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MediaFilesTableAnnotationComposer get mediaId {
    final $$MediaFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaId,
      referencedTable: $db.mediaFiles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OracleTablesTableAnnotationComposer get subtableId {
    final $$OracleTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subtableId,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $EntriesTable,
          Entry,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (Entry, $$EntriesTableReferences),
          Entry,
          PrefetchHooks Function({bool tableId, bool mediaId, bool subtableId})
        > {
  $$EntriesTableTableManager(_$VaultDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tableId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> bodyMd = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int?> rollMin = const Value.absent(),
                Value<int?> rollMax = const Value.absent(),
                Value<String?> mediaId = const Value.absent(),
                Value<String?> subtableId = const Value.absent(),
                Value<bool> confidenceLow = const Value.absent(),
                Value<String?> modifierJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                tableId: tableId,
                position: position,
                content: content,
                bodyMd: bodyMd,
                weight: weight,
                rollMin: rollMin,
                rollMax: rollMax,
                mediaId: mediaId,
                subtableId: subtableId,
                confidenceLow: confidenceLow,
                modifierJson: modifierJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tableId,
                required int position,
                required String content,
                Value<String?> bodyMd = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<int?> rollMin = const Value.absent(),
                Value<int?> rollMax = const Value.absent(),
                Value<String?> mediaId = const Value.absent(),
                Value<String?> subtableId = const Value.absent(),
                Value<bool> confidenceLow = const Value.absent(),
                Value<String?> modifierJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                tableId: tableId,
                position: position,
                content: content,
                bodyMd: bodyMd,
                weight: weight,
                rollMin: rollMin,
                rollMax: rollMax,
                mediaId: mediaId,
                subtableId: subtableId,
                confidenceLow: confidenceLow,
                modifierJson: modifierJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({tableId = false, mediaId = false, subtableId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tableId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tableId,
                                    referencedTable: $$EntriesTableReferences
                                        ._tableIdTable(db),
                                    referencedColumn: $$EntriesTableReferences
                                        ._tableIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (mediaId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.mediaId,
                                    referencedTable: $$EntriesTableReferences
                                        ._mediaIdTable(db),
                                    referencedColumn: $$EntriesTableReferences
                                        ._mediaIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (subtableId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.subtableId,
                                    referencedTable: $$EntriesTableReferences
                                        ._subtableIdTable(db),
                                    referencedColumn: $$EntriesTableReferences
                                        ._subtableIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $EntriesTable,
      Entry,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (Entry, $$EntriesTableReferences),
      Entry,
      PrefetchHooks Function({bool tableId, bool mediaId, bool subtableId})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String name,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$VaultDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TableTagsTable, List<TableTag>>
  _tableTagsRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.tableTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.tableTags.tagId),
  );

  $$TableTagsTableProcessedTableManager get tableTagsRefs {
    final manager = $$TableTagsTableTableManager(
      $_db,
      $_db.tableTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tableTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$VaultDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tableTagsRefs(
    Expression<bool> Function($$TableTagsTableFilterComposer f) f,
  ) {
    final $$TableTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tableTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TableTagsTableFilterComposer(
            $db: $db,
            $table: $db.tableTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer
    extends Composer<_$VaultDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> tableTagsRefs<T extends Object>(
    Expression<T> Function($$TableTagsTableAnnotationComposer a) f,
  ) {
    final $$TableTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tableTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TableTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tableTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool tableTagsRefs})
        > {
  $$TagsTableTableManager(_$VaultDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(id: id, name: name, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(id: id, name: name, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({tableTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tableTagsRefs) db.tableTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tableTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, TableTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._tableTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).tableTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool tableTagsRefs})
    >;
typedef $$TableTagsTableCreateCompanionBuilder =
    TableTagsCompanion Function({
      required String tableId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$TableTagsTableUpdateCompanionBuilder =
    TableTagsCompanion Function({
      Value<String> tableId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$TableTagsTableReferences
    extends BaseReferences<_$VaultDatabase, $TableTagsTable, TableTag> {
  $$TableTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OracleTablesTable _tableIdTable(_$VaultDatabase db) =>
      db.oracleTables.createAlias(
        $_aliasNameGenerator(db.tableTags.tableId, db.oracleTables.id),
      );

  $$OracleTablesTableProcessedTableManager get tableId {
    final $_column = $_itemColumn<String>('table_id')!;

    final manager = $$OracleTablesTableTableManager(
      $_db,
      $_db.oracleTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tableIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$VaultDatabase db) =>
      db.tags.createAlias($_aliasNameGenerator(db.tableTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TableTagsTableFilterComposer
    extends Composer<_$VaultDatabase, $TableTagsTable> {
  $$TableTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$OracleTablesTableFilterComposer get tableId {
    final $$OracleTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tableId,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableFilterComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TableTagsTableOrderingComposer
    extends Composer<_$VaultDatabase, $TableTagsTable> {
  $$TableTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$OracleTablesTableOrderingComposer get tableId {
    final $$OracleTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tableId,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableOrderingComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TableTagsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $TableTagsTable> {
  $$TableTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$OracleTablesTableAnnotationComposer get tableId {
    final $$OracleTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tableId,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TableTagsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $TableTagsTable,
          TableTag,
          $$TableTagsTableFilterComposer,
          $$TableTagsTableOrderingComposer,
          $$TableTagsTableAnnotationComposer,
          $$TableTagsTableCreateCompanionBuilder,
          $$TableTagsTableUpdateCompanionBuilder,
          (TableTag, $$TableTagsTableReferences),
          TableTag,
          PrefetchHooks Function({bool tableId, bool tagId})
        > {
  $$TableTagsTableTableManager(_$VaultDatabase db, $TableTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TableTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TableTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TableTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tableId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TableTagsCompanion(
                tableId: tableId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tableId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => TableTagsCompanion.insert(
                tableId: tableId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TableTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tableId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tableId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tableId,
                                referencedTable: $$TableTagsTableReferences
                                    ._tableIdTable(db),
                                referencedColumn: $$TableTagsTableReferences
                                    ._tableIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$TableTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$TableTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TableTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $TableTagsTable,
      TableTag,
      $$TableTagsTableFilterComposer,
      $$TableTagsTableOrderingComposer,
      $$TableTagsTableAnnotationComposer,
      $$TableTagsTableCreateCompanionBuilder,
      $$TableTagsTableUpdateCompanionBuilder,
      (TableTag, $$TableTagsTableReferences),
      TableTag,
      PrefetchHooks Function({bool tableId, bool tagId})
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<String> type,
      Value<int> rowid,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String> type,
      Value<int> rowid,
    });

final class $$CollectionsTableReferences
    extends BaseReferences<_$VaultDatabase, $CollectionsTable, Collection> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CollectionTablesTable, List<CollectionTable>>
  _collectionTablesRefsTable(_$VaultDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.collectionTables,
        aliasName: $_aliasNameGenerator(
          db.collections.id,
          db.collectionTables.collectionId,
        ),
      );

  $$CollectionTablesTableProcessedTableManager get collectionTablesRefs {
    final manager = $$CollectionTablesTableTableManager(
      $_db,
      $_db.collectionTables,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionTablesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$VaultDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> collectionTablesRefs(
    Expression<bool> Function($$CollectionTablesTableFilterComposer f) f,
  ) {
    final $$CollectionTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionTables,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionTablesTableFilterComposer(
            $db: $db,
            $table: $db.collectionTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$VaultDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  Expression<T> collectionTablesRefs<T extends Object>(
    Expression<T> Function($$CollectionTablesTableAnnotationComposer a) f,
  ) {
    final $$CollectionTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionTables,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.collectionTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $CollectionsTable,
          Collection,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (Collection, $$CollectionsTableReferences),
          Collection,
          PrefetchHooks Function({bool collectionTablesRefs})
        > {
  $$CollectionsTableTableManager(_$VaultDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                name: name,
                description: description,
                type: type,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                name: name,
                description: description,
                type: type,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CollectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionTablesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (collectionTablesRefs) db.collectionTables,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (collectionTablesRefs)
                    await $_getPrefetchedData<
                      Collection,
                      $CollectionsTable,
                      CollectionTable
                    >(
                      currentTable: table,
                      referencedTable: $$CollectionsTableReferences
                          ._collectionTablesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CollectionsTableReferences(
                            db,
                            table,
                            p0,
                          ).collectionTablesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.collectionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $CollectionsTable,
      Collection,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (Collection, $$CollectionsTableReferences),
      Collection,
      PrefetchHooks Function({bool collectionTablesRefs})
    >;
typedef $$CollectionTablesTableCreateCompanionBuilder =
    CollectionTablesCompanion Function({
      required String collectionId,
      required String tableId,
      required int position,
      Value<int> rowid,
    });
typedef $$CollectionTablesTableUpdateCompanionBuilder =
    CollectionTablesCompanion Function({
      Value<String> collectionId,
      Value<String> tableId,
      Value<int> position,
      Value<int> rowid,
    });

final class $$CollectionTablesTableReferences
    extends
        BaseReferences<
          _$VaultDatabase,
          $CollectionTablesTable,
          CollectionTable
        > {
  $$CollectionTablesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CollectionsTable _collectionIdTable(_$VaultDatabase db) =>
      db.collections.createAlias(
        $_aliasNameGenerator(
          db.collectionTables.collectionId,
          db.collections.id,
        ),
      );

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<String>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OracleTablesTable _tableIdTable(_$VaultDatabase db) =>
      db.oracleTables.createAlias(
        $_aliasNameGenerator(db.collectionTables.tableId, db.oracleTables.id),
      );

  $$OracleTablesTableProcessedTableManager get tableId {
    final $_column = $_itemColumn<String>('table_id')!;

    final manager = $$OracleTablesTableTableManager(
      $_db,
      $_db.oracleTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tableIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CollectionTablesTableFilterComposer
    extends Composer<_$VaultDatabase, $CollectionTablesTable> {
  $$CollectionTablesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OracleTablesTableFilterComposer get tableId {
    final $$OracleTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tableId,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableFilterComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionTablesTableOrderingComposer
    extends Composer<_$VaultDatabase, $CollectionTablesTable> {
  $$CollectionTablesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OracleTablesTableOrderingComposer get tableId {
    final $$OracleTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tableId,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableOrderingComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionTablesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $CollectionTablesTable> {
  $$CollectionTablesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OracleTablesTableAnnotationComposer get tableId {
    final $$OracleTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tableId,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionTablesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $CollectionTablesTable,
          CollectionTable,
          $$CollectionTablesTableFilterComposer,
          $$CollectionTablesTableOrderingComposer,
          $$CollectionTablesTableAnnotationComposer,
          $$CollectionTablesTableCreateCompanionBuilder,
          $$CollectionTablesTableUpdateCompanionBuilder,
          (CollectionTable, $$CollectionTablesTableReferences),
          CollectionTable,
          PrefetchHooks Function({bool collectionId, bool tableId})
        > {
  $$CollectionTablesTableTableManager(
    _$VaultDatabase db,
    $CollectionTablesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionTablesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionTablesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionTablesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> collectionId = const Value.absent(),
                Value<String> tableId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionTablesCompanion(
                collectionId: collectionId,
                tableId: tableId,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String collectionId,
                required String tableId,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => CollectionTablesCompanion.insert(
                collectionId: collectionId,
                tableId: tableId,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CollectionTablesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionId = false, tableId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (collectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.collectionId,
                                referencedTable:
                                    $$CollectionTablesTableReferences
                                        ._collectionIdTable(db),
                                referencedColumn:
                                    $$CollectionTablesTableReferences
                                        ._collectionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (tableId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tableId,
                                referencedTable:
                                    $$CollectionTablesTableReferences
                                        ._tableIdTable(db),
                                referencedColumn:
                                    $$CollectionTablesTableReferences
                                        ._tableIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CollectionTablesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $CollectionTablesTable,
      CollectionTable,
      $$CollectionTablesTableFilterComposer,
      $$CollectionTablesTableOrderingComposer,
      $$CollectionTablesTableAnnotationComposer,
      $$CollectionTablesTableCreateCompanionBuilder,
      $$CollectionTablesTableUpdateCompanionBuilder,
      (CollectionTable, $$CollectionTablesTableReferences),
      CollectionTable,
      PrefetchHooks Function({bool collectionId, bool tableId})
    >;
typedef $$EdgesTableCreateCompanionBuilder =
    EdgesCompanion Function({
      required String id,
      required String fromType,
      required String fromId,
      required String toType,
      required String toId,
      required String relation,
      Value<String?> metadataJson,
      Value<int> rowid,
    });
typedef $$EdgesTableUpdateCompanionBuilder =
    EdgesCompanion Function({
      Value<String> id,
      Value<String> fromType,
      Value<String> fromId,
      Value<String> toType,
      Value<String> toId,
      Value<String> relation,
      Value<String?> metadataJson,
      Value<int> rowid,
    });

class $$EdgesTableFilterComposer
    extends Composer<_$VaultDatabase, $EdgesTable> {
  $$EdgesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromType => $composableBuilder(
    column: $table.fromType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromId => $composableBuilder(
    column: $table.fromId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toType => $composableBuilder(
    column: $table.toType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toId => $composableBuilder(
    column: $table.toId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EdgesTableOrderingComposer
    extends Composer<_$VaultDatabase, $EdgesTable> {
  $$EdgesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromType => $composableBuilder(
    column: $table.fromType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromId => $composableBuilder(
    column: $table.fromId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toType => $composableBuilder(
    column: $table.toType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toId => $composableBuilder(
    column: $table.toId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EdgesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $EdgesTable> {
  $$EdgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromType =>
      $composableBuilder(column: $table.fromType, builder: (column) => column);

  GeneratedColumn<String> get fromId =>
      $composableBuilder(column: $table.fromId, builder: (column) => column);

  GeneratedColumn<String> get toType =>
      $composableBuilder(column: $table.toType, builder: (column) => column);

  GeneratedColumn<String> get toId =>
      $composableBuilder(column: $table.toId, builder: (column) => column);

  GeneratedColumn<String> get relation =>
      $composableBuilder(column: $table.relation, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
    column: $table.metadataJson,
    builder: (column) => column,
  );
}

class $$EdgesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $EdgesTable,
          Edge,
          $$EdgesTableFilterComposer,
          $$EdgesTableOrderingComposer,
          $$EdgesTableAnnotationComposer,
          $$EdgesTableCreateCompanionBuilder,
          $$EdgesTableUpdateCompanionBuilder,
          (Edge, BaseReferences<_$VaultDatabase, $EdgesTable, Edge>),
          Edge,
          PrefetchHooks Function()
        > {
  $$EdgesTableTableManager(_$VaultDatabase db, $EdgesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EdgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EdgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EdgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fromType = const Value.absent(),
                Value<String> fromId = const Value.absent(),
                Value<String> toType = const Value.absent(),
                Value<String> toId = const Value.absent(),
                Value<String> relation = const Value.absent(),
                Value<String?> metadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EdgesCompanion(
                id: id,
                fromType: fromType,
                fromId: fromId,
                toType: toType,
                toId: toId,
                relation: relation,
                metadataJson: metadataJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fromType,
                required String fromId,
                required String toType,
                required String toId,
                required String relation,
                Value<String?> metadataJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EdgesCompanion.insert(
                id: id,
                fromType: fromType,
                fromId: fromId,
                toType: toType,
                toId: toId,
                relation: relation,
                metadataJson: metadataJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EdgesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $EdgesTable,
      Edge,
      $$EdgesTableFilterComposer,
      $$EdgesTableOrderingComposer,
      $$EdgesTableAnnotationComposer,
      $$EdgesTableCreateCompanionBuilder,
      $$EdgesTableUpdateCompanionBuilder,
      (Edge, BaseReferences<_$VaultDatabase, $EdgesTable, Edge>),
      Edge,
      PrefetchHooks Function()
    >;
typedef $$SmartFiltersTableCreateCompanionBuilder =
    SmartFiltersCompanion Function({
      required String id,
      required String name,
      required String filterJson,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SmartFiltersTableUpdateCompanionBuilder =
    SmartFiltersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> filterJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SmartFiltersTableFilterComposer
    extends Composer<_$VaultDatabase, $SmartFiltersTable> {
  $$SmartFiltersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterJson => $composableBuilder(
    column: $table.filterJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SmartFiltersTableOrderingComposer
    extends Composer<_$VaultDatabase, $SmartFiltersTable> {
  $$SmartFiltersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterJson => $composableBuilder(
    column: $table.filterJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SmartFiltersTableAnnotationComposer
    extends Composer<_$VaultDatabase, $SmartFiltersTable> {
  $$SmartFiltersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get filterJson => $composableBuilder(
    column: $table.filterJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SmartFiltersTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $SmartFiltersTable,
          SmartFilter,
          $$SmartFiltersTableFilterComposer,
          $$SmartFiltersTableOrderingComposer,
          $$SmartFiltersTableAnnotationComposer,
          $$SmartFiltersTableCreateCompanionBuilder,
          $$SmartFiltersTableUpdateCompanionBuilder,
          (
            SmartFilter,
            BaseReferences<_$VaultDatabase, $SmartFiltersTable, SmartFilter>,
          ),
          SmartFilter,
          PrefetchHooks Function()
        > {
  $$SmartFiltersTableTableManager(_$VaultDatabase db, $SmartFiltersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SmartFiltersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SmartFiltersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SmartFiltersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> filterJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SmartFiltersCompanion(
                id: id,
                name: name,
                filterJson: filterJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String filterJson,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SmartFiltersCompanion.insert(
                id: id,
                name: name,
                filterJson: filterJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SmartFiltersTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $SmartFiltersTable,
      SmartFilter,
      $$SmartFiltersTableFilterComposer,
      $$SmartFiltersTableOrderingComposer,
      $$SmartFiltersTableAnnotationComposer,
      $$SmartFiltersTableCreateCompanionBuilder,
      $$SmartFiltersTableUpdateCompanionBuilder,
      (
        SmartFilter,
        BaseReferences<_$VaultDatabase, $SmartFiltersTable, SmartFilter>,
      ),
      SmartFilter,
      PrefetchHooks Function()
    >;
typedef $$WatchSourcesTableCreateCompanionBuilder =
    WatchSourcesCompanion Function({
      required String id,
      required String type,
      required String config,
      Value<bool> autoApprove,
      Value<DateTime?> lastChecked,
      Value<bool> enabled,
      Value<int> rowid,
    });
typedef $$WatchSourcesTableUpdateCompanionBuilder =
    WatchSourcesCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> config,
      Value<bool> autoApprove,
      Value<DateTime?> lastChecked,
      Value<bool> enabled,
      Value<int> rowid,
    });

final class $$WatchSourcesTableReferences
    extends BaseReferences<_$VaultDatabase, $WatchSourcesTable, WatchSource> {
  $$WatchSourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$InboxItemsTable, List<InboxItem>>
  _inboxItemsRefsTable(_$VaultDatabase db) => MultiTypedResultKey.fromTable(
    db.inboxItems,
    aliasName: $_aliasNameGenerator(
      db.watchSources.id,
      db.inboxItems.watchSourceId,
    ),
  );

  $$InboxItemsTableProcessedTableManager get inboxItemsRefs {
    final manager = $$InboxItemsTableTableManager(
      $_db,
      $_db.inboxItems,
    ).filter((f) => f.watchSourceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_inboxItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WatchSourcesTableFilterComposer
    extends Composer<_$VaultDatabase, $WatchSourcesTable> {
  $$WatchSourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get config => $composableBuilder(
    column: $table.config,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoApprove => $composableBuilder(
    column: $table.autoApprove,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastChecked => $composableBuilder(
    column: $table.lastChecked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> inboxItemsRefs(
    Expression<bool> Function($$InboxItemsTableFilterComposer f) f,
  ) {
    final $$InboxItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inboxItems,
      getReferencedColumn: (t) => t.watchSourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InboxItemsTableFilterComposer(
            $db: $db,
            $table: $db.inboxItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WatchSourcesTableOrderingComposer
    extends Composer<_$VaultDatabase, $WatchSourcesTable> {
  $$WatchSourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get config => $composableBuilder(
    column: $table.config,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoApprove => $composableBuilder(
    column: $table.autoApprove,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastChecked => $composableBuilder(
    column: $table.lastChecked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WatchSourcesTableAnnotationComposer
    extends Composer<_$VaultDatabase, $WatchSourcesTable> {
  $$WatchSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get config =>
      $composableBuilder(column: $table.config, builder: (column) => column);

  GeneratedColumn<bool> get autoApprove => $composableBuilder(
    column: $table.autoApprove,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastChecked => $composableBuilder(
    column: $table.lastChecked,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  Expression<T> inboxItemsRefs<T extends Object>(
    Expression<T> Function($$InboxItemsTableAnnotationComposer a) f,
  ) {
    final $$InboxItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inboxItems,
      getReferencedColumn: (t) => t.watchSourceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InboxItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.inboxItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WatchSourcesTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $WatchSourcesTable,
          WatchSource,
          $$WatchSourcesTableFilterComposer,
          $$WatchSourcesTableOrderingComposer,
          $$WatchSourcesTableAnnotationComposer,
          $$WatchSourcesTableCreateCompanionBuilder,
          $$WatchSourcesTableUpdateCompanionBuilder,
          (WatchSource, $$WatchSourcesTableReferences),
          WatchSource,
          PrefetchHooks Function({bool inboxItemsRefs})
        > {
  $$WatchSourcesTableTableManager(_$VaultDatabase db, $WatchSourcesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> config = const Value.absent(),
                Value<bool> autoApprove = const Value.absent(),
                Value<DateTime?> lastChecked = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchSourcesCompanion(
                id: id,
                type: type,
                config: config,
                autoApprove: autoApprove,
                lastChecked: lastChecked,
                enabled: enabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String config,
                Value<bool> autoApprove = const Value.absent(),
                Value<DateTime?> lastChecked = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchSourcesCompanion.insert(
                id: id,
                type: type,
                config: config,
                autoApprove: autoApprove,
                lastChecked: lastChecked,
                enabled: enabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WatchSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({inboxItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (inboxItemsRefs) db.inboxItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (inboxItemsRefs)
                    await $_getPrefetchedData<
                      WatchSource,
                      $WatchSourcesTable,
                      InboxItem
                    >(
                      currentTable: table,
                      referencedTable: $$WatchSourcesTableReferences
                          ._inboxItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WatchSourcesTableReferences(
                            db,
                            table,
                            p0,
                          ).inboxItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.watchSourceId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WatchSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $WatchSourcesTable,
      WatchSource,
      $$WatchSourcesTableFilterComposer,
      $$WatchSourcesTableOrderingComposer,
      $$WatchSourcesTableAnnotationComposer,
      $$WatchSourcesTableCreateCompanionBuilder,
      $$WatchSourcesTableUpdateCompanionBuilder,
      (WatchSource, $$WatchSourcesTableReferences),
      WatchSource,
      PrefetchHooks Function({bool inboxItemsRefs})
    >;
typedef $$InboxItemsTableCreateCompanionBuilder =
    InboxItemsCompanion Function({
      required String id,
      required String watchSourceId,
      Value<String> status,
      required String rawDataJson,
      Value<String?> importedTableId,
      required DateTime foundAt,
      Value<int> rowid,
    });
typedef $$InboxItemsTableUpdateCompanionBuilder =
    InboxItemsCompanion Function({
      Value<String> id,
      Value<String> watchSourceId,
      Value<String> status,
      Value<String> rawDataJson,
      Value<String?> importedTableId,
      Value<DateTime> foundAt,
      Value<int> rowid,
    });

final class $$InboxItemsTableReferences
    extends BaseReferences<_$VaultDatabase, $InboxItemsTable, InboxItem> {
  $$InboxItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WatchSourcesTable _watchSourceIdTable(_$VaultDatabase db) =>
      db.watchSources.createAlias(
        $_aliasNameGenerator(db.inboxItems.watchSourceId, db.watchSources.id),
      );

  $$WatchSourcesTableProcessedTableManager get watchSourceId {
    final $_column = $_itemColumn<String>('watch_source_id')!;

    final manager = $$WatchSourcesTableTableManager(
      $_db,
      $_db.watchSources,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_watchSourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OracleTablesTable _importedTableIdTable(_$VaultDatabase db) =>
      db.oracleTables.createAlias(
        $_aliasNameGenerator(db.inboxItems.importedTableId, db.oracleTables.id),
      );

  $$OracleTablesTableProcessedTableManager? get importedTableId {
    final $_column = $_itemColumn<String>('imported_table_id');
    if ($_column == null) return null;
    final manager = $$OracleTablesTableTableManager(
      $_db,
      $_db.oracleTables,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importedTableIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InboxItemsTableFilterComposer
    extends Composer<_$VaultDatabase, $InboxItemsTable> {
  $$InboxItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawDataJson => $composableBuilder(
    column: $table.rawDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get foundAt => $composableBuilder(
    column: $table.foundAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WatchSourcesTableFilterComposer get watchSourceId {
    final $$WatchSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.watchSourceId,
      referencedTable: $db.watchSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchSourcesTableFilterComposer(
            $db: $db,
            $table: $db.watchSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OracleTablesTableFilterComposer get importedTableId {
    final $$OracleTablesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importedTableId,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableFilterComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InboxItemsTableOrderingComposer
    extends Composer<_$VaultDatabase, $InboxItemsTable> {
  $$InboxItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawDataJson => $composableBuilder(
    column: $table.rawDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get foundAt => $composableBuilder(
    column: $table.foundAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WatchSourcesTableOrderingComposer get watchSourceId {
    final $$WatchSourcesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.watchSourceId,
      referencedTable: $db.watchSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchSourcesTableOrderingComposer(
            $db: $db,
            $table: $db.watchSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OracleTablesTableOrderingComposer get importedTableId {
    final $$OracleTablesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importedTableId,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableOrderingComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InboxItemsTableAnnotationComposer
    extends Composer<_$VaultDatabase, $InboxItemsTable> {
  $$InboxItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get rawDataJson => $composableBuilder(
    column: $table.rawDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get foundAt =>
      $composableBuilder(column: $table.foundAt, builder: (column) => column);

  $$WatchSourcesTableAnnotationComposer get watchSourceId {
    final $$WatchSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.watchSourceId,
      referencedTable: $db.watchSources,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WatchSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.watchSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OracleTablesTableAnnotationComposer get importedTableId {
    final $$OracleTablesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importedTableId,
      referencedTable: $db.oracleTables,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OracleTablesTableAnnotationComposer(
            $db: $db,
            $table: $db.oracleTables,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InboxItemsTableTableManager
    extends
        RootTableManager<
          _$VaultDatabase,
          $InboxItemsTable,
          InboxItem,
          $$InboxItemsTableFilterComposer,
          $$InboxItemsTableOrderingComposer,
          $$InboxItemsTableAnnotationComposer,
          $$InboxItemsTableCreateCompanionBuilder,
          $$InboxItemsTableUpdateCompanionBuilder,
          (InboxItem, $$InboxItemsTableReferences),
          InboxItem,
          PrefetchHooks Function({bool watchSourceId, bool importedTableId})
        > {
  $$InboxItemsTableTableManager(_$VaultDatabase db, $InboxItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InboxItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InboxItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InboxItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> watchSourceId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> rawDataJson = const Value.absent(),
                Value<String?> importedTableId = const Value.absent(),
                Value<DateTime> foundAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InboxItemsCompanion(
                id: id,
                watchSourceId: watchSourceId,
                status: status,
                rawDataJson: rawDataJson,
                importedTableId: importedTableId,
                foundAt: foundAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String watchSourceId,
                Value<String> status = const Value.absent(),
                required String rawDataJson,
                Value<String?> importedTableId = const Value.absent(),
                required DateTime foundAt,
                Value<int> rowid = const Value.absent(),
              }) => InboxItemsCompanion.insert(
                id: id,
                watchSourceId: watchSourceId,
                status: status,
                rawDataJson: rawDataJson,
                importedTableId: importedTableId,
                foundAt: foundAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InboxItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({watchSourceId = false, importedTableId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (watchSourceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.watchSourceId,
                                    referencedTable: $$InboxItemsTableReferences
                                        ._watchSourceIdTable(db),
                                    referencedColumn:
                                        $$InboxItemsTableReferences
                                            ._watchSourceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (importedTableId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.importedTableId,
                                    referencedTable: $$InboxItemsTableReferences
                                        ._importedTableIdTable(db),
                                    referencedColumn:
                                        $$InboxItemsTableReferences
                                            ._importedTableIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$InboxItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$VaultDatabase,
      $InboxItemsTable,
      InboxItem,
      $$InboxItemsTableFilterComposer,
      $$InboxItemsTableOrderingComposer,
      $$InboxItemsTableAnnotationComposer,
      $$InboxItemsTableCreateCompanionBuilder,
      $$InboxItemsTableUpdateCompanionBuilder,
      (InboxItem, $$InboxItemsTableReferences),
      InboxItem,
      PrefetchHooks Function({bool watchSourceId, bool importedTableId})
    >;

class $VaultDatabaseManager {
  final _$VaultDatabase _db;
  $VaultDatabaseManager(this._db);
  $$SourcesTableTableManager get sources =>
      $$SourcesTableTableManager(_db, _db.sources);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$OracleTablesTableTableManager get oracleTables =>
      $$OracleTablesTableTableManager(_db, _db.oracleTables);
  $$MediaFilesTableTableManager get mediaFiles =>
      $$MediaFilesTableTableManager(_db, _db.mediaFiles);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$TableTagsTableTableManager get tableTags =>
      $$TableTagsTableTableManager(_db, _db.tableTags);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$CollectionTablesTableTableManager get collectionTables =>
      $$CollectionTablesTableTableManager(_db, _db.collectionTables);
  $$EdgesTableTableManager get edges =>
      $$EdgesTableTableManager(_db, _db.edges);
  $$SmartFiltersTableTableManager get smartFilters =>
      $$SmartFiltersTableTableManager(_db, _db.smartFilters);
  $$WatchSourcesTableTableManager get watchSources =>
      $$WatchSourcesTableTableManager(_db, _db.watchSources);
  $$InboxItemsTableTableManager get inboxItems =>
      $$InboxItemsTableTableManager(_db, _db.inboxItems);
}
