// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $FloorsTable extends Floors with TableInfo<$FloorsTable, Floor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FloorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  List<GeneratedColumn> get $columns => [id, number, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'floors';
  @override
  VerificationContext validateIntegrity(
    Insertable<Floor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
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
  Floor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Floor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $FloorsTable createAlias(String alias) {
    return $FloorsTable(attachedDatabase, alias);
  }
}

class Floor extends DataClass implements Insertable<Floor> {
  final int id;
  final int number;
  final String name;
  const Floor({required this.id, required this.number, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['number'] = Variable<int>(number);
    map['name'] = Variable<String>(name);
    return map;
  }

  FloorsCompanion toCompanion(bool nullToAbsent) {
    return FloorsCompanion(
      id: Value(id),
      number: Value(number),
      name: Value(name),
    );
  }

  factory Floor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Floor(
      id: serializer.fromJson<int>(json['id']),
      number: serializer.fromJson<int>(json['number']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'number': serializer.toJson<int>(number),
      'name': serializer.toJson<String>(name),
    };
  }

  Floor copyWith({int? id, int? number, String? name}) => Floor(
    id: id ?? this.id,
    number: number ?? this.number,
    name: name ?? this.name,
  );
  Floor copyWithCompanion(FloorsCompanion data) {
    return Floor(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Floor(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, number, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Floor &&
          other.id == this.id &&
          other.number == this.number &&
          other.name == this.name);
}

class FloorsCompanion extends UpdateCompanion<Floor> {
  final Value<int> id;
  final Value<int> number;
  final Value<String> name;
  const FloorsCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.name = const Value.absent(),
  });
  FloorsCompanion.insert({
    this.id = const Value.absent(),
    required int number,
    required String name,
  }) : number = Value(number),
       name = Value(name);
  static Insertable<Floor> custom({
    Expression<int>? id,
    Expression<int>? number,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (name != null) 'name': name,
    });
  }

  FloorsCompanion copyWith({
    Value<int>? id,
    Value<int>? number,
    Value<String>? name,
  }) {
    return FloorsCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FloorsCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $StoresTable extends Stores with TableInfo<$StoresTable, Store> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoresTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _floorIdMeta = const VerificationMeta(
    'floorId',
  );
  @override
  late final GeneratedColumn<int> floorId = GeneratedColumn<int>(
    'floor_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<int> x = GeneratedColumn<int>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<int> y = GeneratedColumn<int>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<String> image = GeneratedColumn<String>(
    'image',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taglineMeta = const VerificationMeta(
    'tagline',
  );
  @override
  late final GeneratedColumn<String> tagline = GeneratedColumn<String>(
    'tagline',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _badgeMeta = const VerificationMeta('badge');
  @override
  late final GeneratedColumn<String> badge = GeneratedColumn<String>(
    'badge',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    floorId,
    x,
    y,
    image,
    tagline,
    badge,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stores';
  @override
  VerificationContext validateIntegrity(
    Insertable<Store> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('floor_id')) {
      context.handle(
        _floorIdMeta,
        floorId.isAcceptableOrUnknown(data['floor_id']!, _floorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_floorIdMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
        _imageMeta,
        image.isAcceptableOrUnknown(data['image']!, _imageMeta),
      );
    }
    if (data.containsKey('tagline')) {
      context.handle(
        _taglineMeta,
        tagline.isAcceptableOrUnknown(data['tagline']!, _taglineMeta),
      );
    }
    if (data.containsKey('badge')) {
      context.handle(
        _badgeMeta,
        badge.isAcceptableOrUnknown(data['badge']!, _badgeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Store map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Store(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      floorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}floor_id'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}y'],
      )!,
      image: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image'],
      ),
      tagline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tagline'],
      )!,
      badge: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}badge'],
      )!,
    );
  }

  @override
  $StoresTable createAlias(String alias) {
    return $StoresTable(attachedDatabase, alias);
  }
}

class Store extends DataClass implements Insertable<Store> {
  final int id;
  final String name;
  final String category;
  final int floorId;
  final int x;
  final int y;
  final String? image;
  final String tagline;
  final String badge;
  const Store({
    required this.id,
    required this.name,
    required this.category,
    required this.floorId,
    required this.x,
    required this.y,
    this.image,
    required this.tagline,
    required this.badge,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['floor_id'] = Variable<int>(floorId);
    map['x'] = Variable<int>(x);
    map['y'] = Variable<int>(y);
    if (!nullToAbsent || image != null) {
      map['image'] = Variable<String>(image);
    }
    map['tagline'] = Variable<String>(tagline);
    map['badge'] = Variable<String>(badge);
    return map;
  }

  StoresCompanion toCompanion(bool nullToAbsent) {
    return StoresCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      floorId: Value(floorId),
      x: Value(x),
      y: Value(y),
      image: image == null && nullToAbsent
          ? const Value.absent()
          : Value(image),
      tagline: Value(tagline),
      badge: Value(badge),
    );
  }

  factory Store.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Store(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      floorId: serializer.fromJson<int>(json['floorId']),
      x: serializer.fromJson<int>(json['x']),
      y: serializer.fromJson<int>(json['y']),
      image: serializer.fromJson<String?>(json['image']),
      tagline: serializer.fromJson<String>(json['tagline']),
      badge: serializer.fromJson<String>(json['badge']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'floorId': serializer.toJson<int>(floorId),
      'x': serializer.toJson<int>(x),
      'y': serializer.toJson<int>(y),
      'image': serializer.toJson<String?>(image),
      'tagline': serializer.toJson<String>(tagline),
      'badge': serializer.toJson<String>(badge),
    };
  }

  Store copyWith({
    int? id,
    String? name,
    String? category,
    int? floorId,
    int? x,
    int? y,
    Value<String?> image = const Value.absent(),
    String? tagline,
    String? badge,
  }) => Store(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    floorId: floorId ?? this.floorId,
    x: x ?? this.x,
    y: y ?? this.y,
    image: image.present ? image.value : this.image,
    tagline: tagline ?? this.tagline,
    badge: badge ?? this.badge,
  );
  Store copyWithCompanion(StoresCompanion data) {
    return Store(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      floorId: data.floorId.present ? data.floorId.value : this.floorId,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
      image: data.image.present ? data.image.value : this.image,
      tagline: data.tagline.present ? data.tagline.value : this.tagline,
      badge: data.badge.present ? data.badge.value : this.badge,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Store(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('floorId: $floorId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('image: $image, ')
          ..write('tagline: $tagline, ')
          ..write('badge: $badge')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, category, floorId, x, y, image, tagline, badge);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Store &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.floorId == this.floorId &&
          other.x == this.x &&
          other.y == this.y &&
          other.image == this.image &&
          other.tagline == this.tagline &&
          other.badge == this.badge);
}

class StoresCompanion extends UpdateCompanion<Store> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> category;
  final Value<int> floorId;
  final Value<int> x;
  final Value<int> y;
  final Value<String?> image;
  final Value<String> tagline;
  final Value<String> badge;
  const StoresCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.floorId = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.image = const Value.absent(),
    this.tagline = const Value.absent(),
    this.badge = const Value.absent(),
  });
  StoresCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String category,
    required int floorId,
    required int x,
    required int y,
    this.image = const Value.absent(),
    this.tagline = const Value.absent(),
    this.badge = const Value.absent(),
  }) : name = Value(name),
       category = Value(category),
       floorId = Value(floorId),
       x = Value(x),
       y = Value(y);
  static Insertable<Store> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<int>? floorId,
    Expression<int>? x,
    Expression<int>? y,
    Expression<String>? image,
    Expression<String>? tagline,
    Expression<String>? badge,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (floorId != null) 'floor_id': floorId,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (image != null) 'image': image,
      if (tagline != null) 'tagline': tagline,
      if (badge != null) 'badge': badge,
    });
  }

  StoresCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? category,
    Value<int>? floorId,
    Value<int>? x,
    Value<int>? y,
    Value<String?>? image,
    Value<String>? tagline,
    Value<String>? badge,
  }) {
    return StoresCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      floorId: floorId ?? this.floorId,
      x: x ?? this.x,
      y: y ?? this.y,
      image: image ?? this.image,
      tagline: tagline ?? this.tagline,
      badge: badge ?? this.badge,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (floorId.present) {
      map['floor_id'] = Variable<int>(floorId.value);
    }
    if (x.present) {
      map['x'] = Variable<int>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<int>(y.value);
    }
    if (image.present) {
      map['image'] = Variable<String>(image.value);
    }
    if (tagline.present) {
      map['tagline'] = Variable<String>(tagline.value);
    }
    if (badge.present) {
      map['badge'] = Variable<String>(badge.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoresCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('floorId: $floorId, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('image: $image, ')
          ..write('tagline: $tagline, ')
          ..write('badge: $badge')
          ..write(')'))
        .toString();
  }
}

class $BeaconsTable extends Beacons with TableInfo<$BeaconsTable, Beacon> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BeaconsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _advIdMeta = const VerificationMeta('advId');
  @override
  late final GeneratedColumn<String> advId = GeneratedColumn<String>(
    'adv_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<int> storeId = GeneratedColumn<int>(
    'store_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mallIdMeta = const VerificationMeta('mallId');
  @override
  late final GeneratedColumn<int> mallId = GeneratedColumn<int>(
    'mall_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _floorIdMeta = const VerificationMeta(
    'floorId',
  );
  @override
  late final GeneratedColumn<int> floorId = GeneratedColumn<int>(
    'floor_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _txMeta = const VerificationMeta('tx');
  @override
  late final GeneratedColumn<int> tx = GeneratedColumn<int>(
    'tx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _xMeta = const VerificationMeta('x');
  @override
  late final GeneratedColumn<int> x = GeneratedColumn<int>(
    'x',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yMeta = const VerificationMeta('y');
  @override
  late final GeneratedColumn<int> y = GeneratedColumn<int>(
    'y',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    advId,
    storeId,
    mallId,
    floorId,
    tx,
    x,
    y,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'beacons';
  @override
  VerificationContext validateIntegrity(
    Insertable<Beacon> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('adv_id')) {
      context.handle(
        _advIdMeta,
        advId.isAcceptableOrUnknown(data['adv_id']!, _advIdMeta),
      );
    } else if (isInserting) {
      context.missing(_advIdMeta);
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    }
    if (data.containsKey('mall_id')) {
      context.handle(
        _mallIdMeta,
        mallId.isAcceptableOrUnknown(data['mall_id']!, _mallIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mallIdMeta);
    }
    if (data.containsKey('floor_id')) {
      context.handle(
        _floorIdMeta,
        floorId.isAcceptableOrUnknown(data['floor_id']!, _floorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_floorIdMeta);
    }
    if (data.containsKey('tx')) {
      context.handle(_txMeta, tx.isAcceptableOrUnknown(data['tx']!, _txMeta));
    } else if (isInserting) {
      context.missing(_txMeta);
    }
    if (data.containsKey('x')) {
      context.handle(_xMeta, x.isAcceptableOrUnknown(data['x']!, _xMeta));
    } else if (isInserting) {
      context.missing(_xMeta);
    }
    if (data.containsKey('y')) {
      context.handle(_yMeta, y.isAcceptableOrUnknown(data['y']!, _yMeta));
    } else if (isInserting) {
      context.missing(_yMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {advId};
  @override
  Beacon map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Beacon(
      advId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adv_id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}store_id'],
      ),
      mallId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mall_id'],
      )!,
      floorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}floor_id'],
      )!,
      tx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tx'],
      )!,
      x: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}x'],
      )!,
      y: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}y'],
      )!,
    );
  }

  @override
  $BeaconsTable createAlias(String alias) {
    return $BeaconsTable(attachedDatabase, alias);
  }
}

class Beacon extends DataClass implements Insertable<Beacon> {
  final String advId;
  final int? storeId;
  final int mallId;
  final int floorId;
  final int tx;
  final int x;
  final int y;
  const Beacon({
    required this.advId,
    this.storeId,
    required this.mallId,
    required this.floorId,
    required this.tx,
    required this.x,
    required this.y,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['adv_id'] = Variable<String>(advId);
    if (!nullToAbsent || storeId != null) {
      map['store_id'] = Variable<int>(storeId);
    }
    map['mall_id'] = Variable<int>(mallId);
    map['floor_id'] = Variable<int>(floorId);
    map['tx'] = Variable<int>(tx);
    map['x'] = Variable<int>(x);
    map['y'] = Variable<int>(y);
    return map;
  }

  BeaconsCompanion toCompanion(bool nullToAbsent) {
    return BeaconsCompanion(
      advId: Value(advId),
      storeId: storeId == null && nullToAbsent
          ? const Value.absent()
          : Value(storeId),
      mallId: Value(mallId),
      floorId: Value(floorId),
      tx: Value(tx),
      x: Value(x),
      y: Value(y),
    );
  }

  factory Beacon.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Beacon(
      advId: serializer.fromJson<String>(json['advId']),
      storeId: serializer.fromJson<int?>(json['storeId']),
      mallId: serializer.fromJson<int>(json['mallId']),
      floorId: serializer.fromJson<int>(json['floorId']),
      tx: serializer.fromJson<int>(json['tx']),
      x: serializer.fromJson<int>(json['x']),
      y: serializer.fromJson<int>(json['y']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'advId': serializer.toJson<String>(advId),
      'storeId': serializer.toJson<int?>(storeId),
      'mallId': serializer.toJson<int>(mallId),
      'floorId': serializer.toJson<int>(floorId),
      'tx': serializer.toJson<int>(tx),
      'x': serializer.toJson<int>(x),
      'y': serializer.toJson<int>(y),
    };
  }

  Beacon copyWith({
    String? advId,
    Value<int?> storeId = const Value.absent(),
    int? mallId,
    int? floorId,
    int? tx,
    int? x,
    int? y,
  }) => Beacon(
    advId: advId ?? this.advId,
    storeId: storeId.present ? storeId.value : this.storeId,
    mallId: mallId ?? this.mallId,
    floorId: floorId ?? this.floorId,
    tx: tx ?? this.tx,
    x: x ?? this.x,
    y: y ?? this.y,
  );
  Beacon copyWithCompanion(BeaconsCompanion data) {
    return Beacon(
      advId: data.advId.present ? data.advId.value : this.advId,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      mallId: data.mallId.present ? data.mallId.value : this.mallId,
      floorId: data.floorId.present ? data.floorId.value : this.floorId,
      tx: data.tx.present ? data.tx.value : this.tx,
      x: data.x.present ? data.x.value : this.x,
      y: data.y.present ? data.y.value : this.y,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Beacon(')
          ..write('advId: $advId, ')
          ..write('storeId: $storeId, ')
          ..write('mallId: $mallId, ')
          ..write('floorId: $floorId, ')
          ..write('tx: $tx, ')
          ..write('x: $x, ')
          ..write('y: $y')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(advId, storeId, mallId, floorId, tx, x, y);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Beacon &&
          other.advId == this.advId &&
          other.storeId == this.storeId &&
          other.mallId == this.mallId &&
          other.floorId == this.floorId &&
          other.tx == this.tx &&
          other.x == this.x &&
          other.y == this.y);
}

class BeaconsCompanion extends UpdateCompanion<Beacon> {
  final Value<String> advId;
  final Value<int?> storeId;
  final Value<int> mallId;
  final Value<int> floorId;
  final Value<int> tx;
  final Value<int> x;
  final Value<int> y;
  final Value<int> rowid;
  const BeaconsCompanion({
    this.advId = const Value.absent(),
    this.storeId = const Value.absent(),
    this.mallId = const Value.absent(),
    this.floorId = const Value.absent(),
    this.tx = const Value.absent(),
    this.x = const Value.absent(),
    this.y = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BeaconsCompanion.insert({
    required String advId,
    this.storeId = const Value.absent(),
    required int mallId,
    required int floorId,
    required int tx,
    required int x,
    required int y,
    this.rowid = const Value.absent(),
  }) : advId = Value(advId),
       mallId = Value(mallId),
       floorId = Value(floorId),
       tx = Value(tx),
       x = Value(x),
       y = Value(y);
  static Insertable<Beacon> custom({
    Expression<String>? advId,
    Expression<int>? storeId,
    Expression<int>? mallId,
    Expression<int>? floorId,
    Expression<int>? tx,
    Expression<int>? x,
    Expression<int>? y,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (advId != null) 'adv_id': advId,
      if (storeId != null) 'store_id': storeId,
      if (mallId != null) 'mall_id': mallId,
      if (floorId != null) 'floor_id': floorId,
      if (tx != null) 'tx': tx,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BeaconsCompanion copyWith({
    Value<String>? advId,
    Value<int?>? storeId,
    Value<int>? mallId,
    Value<int>? floorId,
    Value<int>? tx,
    Value<int>? x,
    Value<int>? y,
    Value<int>? rowid,
  }) {
    return BeaconsCompanion(
      advId: advId ?? this.advId,
      storeId: storeId ?? this.storeId,
      mallId: mallId ?? this.mallId,
      floorId: floorId ?? this.floorId,
      tx: tx ?? this.tx,
      x: x ?? this.x,
      y: y ?? this.y,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (advId.present) {
      map['adv_id'] = Variable<String>(advId.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<int>(storeId.value);
    }
    if (mallId.present) {
      map['mall_id'] = Variable<int>(mallId.value);
    }
    if (floorId.present) {
      map['floor_id'] = Variable<int>(floorId.value);
    }
    if (tx.present) {
      map['tx'] = Variable<int>(tx.value);
    }
    if (x.present) {
      map['x'] = Variable<int>(x.value);
    }
    if (y.present) {
      map['y'] = Variable<int>(y.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BeaconsCompanion(')
          ..write('advId: $advId, ')
          ..write('storeId: $storeId, ')
          ..write('mallId: $mallId, ')
          ..write('floorId: $floorId, ')
          ..write('tx: $tx, ')
          ..write('x: $x, ')
          ..write('y: $y, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CampaignsTable extends Campaigns
    with TableInfo<$CampaignsTable, Campaign> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampaignsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<int> storeId = GeneratedColumn<int>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _couponMeta = const VerificationMeta('coupon');
  @override
  late final GeneratedColumn<String> coupon = GeneratedColumn<String>(
    'coupon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startsMeta = const VerificationMeta('starts');
  @override
  late final GeneratedColumn<String> starts = GeneratedColumn<String>(
    'starts',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsMeta = const VerificationMeta('ends');
  @override
  late final GeneratedColumn<String> ends = GeneratedColumn<String>(
    'ends',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    title,
    body,
    coupon,
    starts,
    ends,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'campaigns';
  @override
  VerificationContext validateIntegrity(
    Insertable<Campaign> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storeIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('coupon')) {
      context.handle(
        _couponMeta,
        coupon.isAcceptableOrUnknown(data['coupon']!, _couponMeta),
      );
    }
    if (data.containsKey('starts')) {
      context.handle(
        _startsMeta,
        starts.isAcceptableOrUnknown(data['starts']!, _startsMeta),
      );
    } else if (isInserting) {
      context.missing(_startsMeta);
    }
    if (data.containsKey('ends')) {
      context.handle(
        _endsMeta,
        ends.isAcceptableOrUnknown(data['ends']!, _endsMeta),
      );
    } else if (isInserting) {
      context.missing(_endsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Campaign map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Campaign(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}store_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      coupon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coupon'],
      )!,
      starts: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}starts'],
      )!,
      ends: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ends'],
      )!,
    );
  }

  @override
  $CampaignsTable createAlias(String alias) {
    return $CampaignsTable(attachedDatabase, alias);
  }
}

class Campaign extends DataClass implements Insertable<Campaign> {
  final int id;
  final int storeId;
  final String title;
  final String body;
  final String coupon;
  final String starts;
  final String ends;
  const Campaign({
    required this.id,
    required this.storeId,
    required this.title,
    required this.body,
    required this.coupon,
    required this.starts,
    required this.ends,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['store_id'] = Variable<int>(storeId);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['coupon'] = Variable<String>(coupon);
    map['starts'] = Variable<String>(starts);
    map['ends'] = Variable<String>(ends);
    return map;
  }

  CampaignsCompanion toCompanion(bool nullToAbsent) {
    return CampaignsCompanion(
      id: Value(id),
      storeId: Value(storeId),
      title: Value(title),
      body: Value(body),
      coupon: Value(coupon),
      starts: Value(starts),
      ends: Value(ends),
    );
  }

  factory Campaign.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Campaign(
      id: serializer.fromJson<int>(json['id']),
      storeId: serializer.fromJson<int>(json['storeId']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      coupon: serializer.fromJson<String>(json['coupon']),
      starts: serializer.fromJson<String>(json['starts']),
      ends: serializer.fromJson<String>(json['ends']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'storeId': serializer.toJson<int>(storeId),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'coupon': serializer.toJson<String>(coupon),
      'starts': serializer.toJson<String>(starts),
      'ends': serializer.toJson<String>(ends),
    };
  }

  Campaign copyWith({
    int? id,
    int? storeId,
    String? title,
    String? body,
    String? coupon,
    String? starts,
    String? ends,
  }) => Campaign(
    id: id ?? this.id,
    storeId: storeId ?? this.storeId,
    title: title ?? this.title,
    body: body ?? this.body,
    coupon: coupon ?? this.coupon,
    starts: starts ?? this.starts,
    ends: ends ?? this.ends,
  );
  Campaign copyWithCompanion(CampaignsCompanion data) {
    return Campaign(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      coupon: data.coupon.present ? data.coupon.value : this.coupon,
      starts: data.starts.present ? data.starts.value : this.starts,
      ends: data.ends.present ? data.ends.value : this.ends,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Campaign(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('coupon: $coupon, ')
          ..write('starts: $starts, ')
          ..write('ends: $ends')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, storeId, title, body, coupon, starts, ends);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Campaign &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.title == this.title &&
          other.body == this.body &&
          other.coupon == this.coupon &&
          other.starts == this.starts &&
          other.ends == this.ends);
}

class CampaignsCompanion extends UpdateCompanion<Campaign> {
  final Value<int> id;
  final Value<int> storeId;
  final Value<String> title;
  final Value<String> body;
  final Value<String> coupon;
  final Value<String> starts;
  final Value<String> ends;
  const CampaignsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.coupon = const Value.absent(),
    this.starts = const Value.absent(),
    this.ends = const Value.absent(),
  });
  CampaignsCompanion.insert({
    this.id = const Value.absent(),
    required int storeId,
    required String title,
    required String body,
    this.coupon = const Value.absent(),
    required String starts,
    required String ends,
  }) : storeId = Value(storeId),
       title = Value(title),
       body = Value(body),
       starts = Value(starts),
       ends = Value(ends);
  static Insertable<Campaign> custom({
    Expression<int>? id,
    Expression<int>? storeId,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? coupon,
    Expression<String>? starts,
    Expression<String>? ends,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (coupon != null) 'coupon': coupon,
      if (starts != null) 'starts': starts,
      if (ends != null) 'ends': ends,
    });
  }

  CampaignsCompanion copyWith({
    Value<int>? id,
    Value<int>? storeId,
    Value<String>? title,
    Value<String>? body,
    Value<String>? coupon,
    Value<String>? starts,
    Value<String>? ends,
  }) {
    return CampaignsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      title: title ?? this.title,
      body: body ?? this.body,
      coupon: coupon ?? this.coupon,
      starts: starts ?? this.starts,
      ends: ends ?? this.ends,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<int>(storeId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (coupon.present) {
      map['coupon'] = Variable<String>(coupon.value);
    }
    if (starts.present) {
      map['starts'] = Variable<String>(starts.value);
    }
    if (ends.present) {
      map['ends'] = Variable<String>(ends.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CampaignsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('coupon: $coupon, ')
          ..write('starts: $starts, ')
          ..write('ends: $ends')
          ..write(')'))
        .toString();
  }
}

class $CampaignBeaconsTable extends CampaignBeacons
    with TableInfo<$CampaignBeaconsTable, CampaignBeacon> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampaignBeaconsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<int> campaignId = GeneratedColumn<int>(
    'campaign_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _advIdMeta = const VerificationMeta('advId');
  @override
  late final GeneratedColumn<String> advId = GeneratedColumn<String>(
    'adv_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [campaignId, advId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'campaign_beacons';
  @override
  VerificationContext validateIntegrity(
    Insertable<CampaignBeacon> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('campaign_id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['campaign_id']!, _campaignIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campaignIdMeta);
    }
    if (data.containsKey('adv_id')) {
      context.handle(
        _advIdMeta,
        advId.isAcceptableOrUnknown(data['adv_id']!, _advIdMeta),
      );
    } else if (isInserting) {
      context.missing(_advIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  CampaignBeacon map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CampaignBeacon(
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}campaign_id'],
      )!,
      advId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adv_id'],
      )!,
    );
  }

  @override
  $CampaignBeaconsTable createAlias(String alias) {
    return $CampaignBeaconsTable(attachedDatabase, alias);
  }
}

class CampaignBeacon extends DataClass implements Insertable<CampaignBeacon> {
  final int campaignId;
  final String advId;
  const CampaignBeacon({required this.campaignId, required this.advId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['campaign_id'] = Variable<int>(campaignId);
    map['adv_id'] = Variable<String>(advId);
    return map;
  }

  CampaignBeaconsCompanion toCompanion(bool nullToAbsent) {
    return CampaignBeaconsCompanion(
      campaignId: Value(campaignId),
      advId: Value(advId),
    );
  }

  factory CampaignBeacon.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CampaignBeacon(
      campaignId: serializer.fromJson<int>(json['campaignId']),
      advId: serializer.fromJson<String>(json['advId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'campaignId': serializer.toJson<int>(campaignId),
      'advId': serializer.toJson<String>(advId),
    };
  }

  CampaignBeacon copyWith({int? campaignId, String? advId}) => CampaignBeacon(
    campaignId: campaignId ?? this.campaignId,
    advId: advId ?? this.advId,
  );
  CampaignBeacon copyWithCompanion(CampaignBeaconsCompanion data) {
    return CampaignBeacon(
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      advId: data.advId.present ? data.advId.value : this.advId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CampaignBeacon(')
          ..write('campaignId: $campaignId, ')
          ..write('advId: $advId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(campaignId, advId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CampaignBeacon &&
          other.campaignId == this.campaignId &&
          other.advId == this.advId);
}

class CampaignBeaconsCompanion extends UpdateCompanion<CampaignBeacon> {
  final Value<int> campaignId;
  final Value<String> advId;
  final Value<int> rowid;
  const CampaignBeaconsCompanion({
    this.campaignId = const Value.absent(),
    this.advId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampaignBeaconsCompanion.insert({
    required int campaignId,
    required String advId,
    this.rowid = const Value.absent(),
  }) : campaignId = Value(campaignId),
       advId = Value(advId);
  static Insertable<CampaignBeacon> custom({
    Expression<int>? campaignId,
    Expression<String>? advId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (campaignId != null) 'campaign_id': campaignId,
      if (advId != null) 'adv_id': advId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampaignBeaconsCompanion copyWith({
    Value<int>? campaignId,
    Value<String>? advId,
    Value<int>? rowid,
  }) {
    return CampaignBeaconsCompanion(
      campaignId: campaignId ?? this.campaignId,
      advId: advId ?? this.advId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (campaignId.present) {
      map['campaign_id'] = Variable<int>(campaignId.value);
    }
    if (advId.present) {
      map['adv_id'] = Variable<String>(advId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CampaignBeaconsCompanion(')
          ..write('campaignId: $campaignId, ')
          ..write('advId: $advId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PingsTable extends Pings with TableInfo<$PingsTable, Ping> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tMeta = const VerificationMeta('t');
  @override
  late final GeneratedColumn<String> t = GeneratedColumn<String>(
    't',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _advIdMeta = const VerificationMeta('advId');
  @override
  late final GeneratedColumn<String> advId = GeneratedColumn<String>(
    'adv_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rssiMeta = const VerificationMeta('rssi');
  @override
  late final GeneratedColumn<int> rssi = GeneratedColumn<int>(
    'rssi',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, t, advId, rssi];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ping> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('t')) {
      context.handle(_tMeta, t.isAcceptableOrUnknown(data['t']!, _tMeta));
    } else if (isInserting) {
      context.missing(_tMeta);
    }
    if (data.containsKey('adv_id')) {
      context.handle(
        _advIdMeta,
        advId.isAcceptableOrUnknown(data['adv_id']!, _advIdMeta),
      );
    } else if (isInserting) {
      context.missing(_advIdMeta);
    }
    if (data.containsKey('rssi')) {
      context.handle(
        _rssiMeta,
        rssi.isAcceptableOrUnknown(data['rssi']!, _rssiMeta),
      );
    } else if (isInserting) {
      context.missing(_rssiMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ping map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ping(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      t: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}t'],
      )!,
      advId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adv_id'],
      )!,
      rssi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rssi'],
      )!,
    );
  }

  @override
  $PingsTable createAlias(String alias) {
    return $PingsTable(attachedDatabase, alias);
  }
}

class Ping extends DataClass implements Insertable<Ping> {
  final int id;
  final String t;
  final String advId;
  final int rssi;
  const Ping({
    required this.id,
    required this.t,
    required this.advId,
    required this.rssi,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['t'] = Variable<String>(t);
    map['adv_id'] = Variable<String>(advId);
    map['rssi'] = Variable<int>(rssi);
    return map;
  }

  PingsCompanion toCompanion(bool nullToAbsent) {
    return PingsCompanion(
      id: Value(id),
      t: Value(t),
      advId: Value(advId),
      rssi: Value(rssi),
    );
  }

  factory Ping.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ping(
      id: serializer.fromJson<int>(json['id']),
      t: serializer.fromJson<String>(json['t']),
      advId: serializer.fromJson<String>(json['advId']),
      rssi: serializer.fromJson<int>(json['rssi']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      't': serializer.toJson<String>(t),
      'advId': serializer.toJson<String>(advId),
      'rssi': serializer.toJson<int>(rssi),
    };
  }

  Ping copyWith({int? id, String? t, String? advId, int? rssi}) => Ping(
    id: id ?? this.id,
    t: t ?? this.t,
    advId: advId ?? this.advId,
    rssi: rssi ?? this.rssi,
  );
  Ping copyWithCompanion(PingsCompanion data) {
    return Ping(
      id: data.id.present ? data.id.value : this.id,
      t: data.t.present ? data.t.value : this.t,
      advId: data.advId.present ? data.advId.value : this.advId,
      rssi: data.rssi.present ? data.rssi.value : this.rssi,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ping(')
          ..write('id: $id, ')
          ..write('t: $t, ')
          ..write('advId: $advId, ')
          ..write('rssi: $rssi')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, t, advId, rssi);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ping &&
          other.id == this.id &&
          other.t == this.t &&
          other.advId == this.advId &&
          other.rssi == this.rssi);
}

class PingsCompanion extends UpdateCompanion<Ping> {
  final Value<int> id;
  final Value<String> t;
  final Value<String> advId;
  final Value<int> rssi;
  const PingsCompanion({
    this.id = const Value.absent(),
    this.t = const Value.absent(),
    this.advId = const Value.absent(),
    this.rssi = const Value.absent(),
  });
  PingsCompanion.insert({
    this.id = const Value.absent(),
    required String t,
    required String advId,
    required int rssi,
  }) : t = Value(t),
       advId = Value(advId),
       rssi = Value(rssi);
  static Insertable<Ping> custom({
    Expression<int>? id,
    Expression<String>? t,
    Expression<String>? advId,
    Expression<int>? rssi,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (t != null) 't': t,
      if (advId != null) 'adv_id': advId,
      if (rssi != null) 'rssi': rssi,
    });
  }

  PingsCompanion copyWith({
    Value<int>? id,
    Value<String>? t,
    Value<String>? advId,
    Value<int>? rssi,
  }) {
    return PingsCompanion(
      id: id ?? this.id,
      t: t ?? this.t,
      advId: advId ?? this.advId,
      rssi: rssi ?? this.rssi,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (t.present) {
      map['t'] = Variable<String>(t.value);
    }
    if (advId.present) {
      map['adv_id'] = Variable<String>(advId.value);
    }
    if (rssi.present) {
      map['rssi'] = Variable<int>(rssi.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PingsCompanion(')
          ..write('id: $id, ')
          ..write('t: $t, ')
          ..write('advId: $advId, ')
          ..write('rssi: $rssi')
          ..write(')'))
        .toString();
  }
}

class $ImpressionsTable extends Impressions
    with TableInfo<$ImpressionsTable, Impression> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImpressionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<int> campaignId = GeneratedColumn<int>(
    'campaign_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tMeta = const VerificationMeta('t');
  @override
  late final GeneratedColumn<String> t = GeneratedColumn<String>(
    't',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedMeta = const VerificationMeta('opened');
  @override
  late final GeneratedColumn<bool> opened = GeneratedColumn<bool>(
    'opened',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("opened" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, campaignId, t, opened];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'impressions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Impression> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['campaign_id']!, _campaignIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campaignIdMeta);
    }
    if (data.containsKey('t')) {
      context.handle(_tMeta, t.isAcceptableOrUnknown(data['t']!, _tMeta));
    } else if (isInserting) {
      context.missing(_tMeta);
    }
    if (data.containsKey('opened')) {
      context.handle(
        _openedMeta,
        opened.isAcceptableOrUnknown(data['opened']!, _openedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Impression map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Impression(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}campaign_id'],
      )!,
      t: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}t'],
      )!,
      opened: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}opened'],
      )!,
    );
  }

  @override
  $ImpressionsTable createAlias(String alias) {
    return $ImpressionsTable(attachedDatabase, alias);
  }
}

class Impression extends DataClass implements Insertable<Impression> {
  final int id;
  final int campaignId;
  final String t;
  final bool opened;
  const Impression({
    required this.id,
    required this.campaignId,
    required this.t,
    required this.opened,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['campaign_id'] = Variable<int>(campaignId);
    map['t'] = Variable<String>(t);
    map['opened'] = Variable<bool>(opened);
    return map;
  }

  ImpressionsCompanion toCompanion(bool nullToAbsent) {
    return ImpressionsCompanion(
      id: Value(id),
      campaignId: Value(campaignId),
      t: Value(t),
      opened: Value(opened),
    );
  }

  factory Impression.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Impression(
      id: serializer.fromJson<int>(json['id']),
      campaignId: serializer.fromJson<int>(json['campaignId']),
      t: serializer.fromJson<String>(json['t']),
      opened: serializer.fromJson<bool>(json['opened']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'campaignId': serializer.toJson<int>(campaignId),
      't': serializer.toJson<String>(t),
      'opened': serializer.toJson<bool>(opened),
    };
  }

  Impression copyWith({int? id, int? campaignId, String? t, bool? opened}) =>
      Impression(
        id: id ?? this.id,
        campaignId: campaignId ?? this.campaignId,
        t: t ?? this.t,
        opened: opened ?? this.opened,
      );
  Impression copyWithCompanion(ImpressionsCompanion data) {
    return Impression(
      id: data.id.present ? data.id.value : this.id,
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      t: data.t.present ? data.t.value : this.t,
      opened: data.opened.present ? data.opened.value : this.opened,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Impression(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('t: $t, ')
          ..write('opened: $opened')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, campaignId, t, opened);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Impression &&
          other.id == this.id &&
          other.campaignId == this.campaignId &&
          other.t == this.t &&
          other.opened == this.opened);
}

class ImpressionsCompanion extends UpdateCompanion<Impression> {
  final Value<int> id;
  final Value<int> campaignId;
  final Value<String> t;
  final Value<bool> opened;
  const ImpressionsCompanion({
    this.id = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.t = const Value.absent(),
    this.opened = const Value.absent(),
  });
  ImpressionsCompanion.insert({
    this.id = const Value.absent(),
    required int campaignId,
    required String t,
    this.opened = const Value.absent(),
  }) : campaignId = Value(campaignId),
       t = Value(t);
  static Insertable<Impression> custom({
    Expression<int>? id,
    Expression<int>? campaignId,
    Expression<String>? t,
    Expression<bool>? opened,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (campaignId != null) 'campaign_id': campaignId,
      if (t != null) 't': t,
      if (opened != null) 'opened': opened,
    });
  }

  ImpressionsCompanion copyWith({
    Value<int>? id,
    Value<int>? campaignId,
    Value<String>? t,
    Value<bool>? opened,
  }) {
    return ImpressionsCompanion(
      id: id ?? this.id,
      campaignId: campaignId ?? this.campaignId,
      t: t ?? this.t,
      opened: opened ?? this.opened,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<int>(campaignId.value);
    }
    if (t.present) {
      map['t'] = Variable<String>(t.value);
    }
    if (opened.present) {
      map['opened'] = Variable<bool>(opened.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImpressionsCompanion(')
          ..write('id: $id, ')
          ..write('campaignId: $campaignId, ')
          ..write('t: $t, ')
          ..write('opened: $opened')
          ..write(')'))
        .toString();
  }
}

class $DedupTable extends Dedup with TableInfo<$DedupTable, DedupData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DedupTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<int> campaignId = GeneratedColumn<int>(
    'campaign_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastFiredMeta = const VerificationMeta(
    'lastFired',
  );
  @override
  late final GeneratedColumn<String> lastFired = GeneratedColumn<String>(
    'last_fired',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [campaignId, lastFired];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dedup';
  @override
  VerificationContext validateIntegrity(
    Insertable<DedupData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('campaign_id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['campaign_id']!, _campaignIdMeta),
      );
    }
    if (data.containsKey('last_fired')) {
      context.handle(
        _lastFiredMeta,
        lastFired.isAcceptableOrUnknown(data['last_fired']!, _lastFiredMeta),
      );
    } else if (isInserting) {
      context.missing(_lastFiredMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {campaignId};
  @override
  DedupData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DedupData(
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}campaign_id'],
      )!,
      lastFired: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_fired'],
      )!,
    );
  }

  @override
  $DedupTable createAlias(String alias) {
    return $DedupTable(attachedDatabase, alias);
  }
}

class DedupData extends DataClass implements Insertable<DedupData> {
  final int campaignId;
  final String lastFired;
  const DedupData({required this.campaignId, required this.lastFired});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['campaign_id'] = Variable<int>(campaignId);
    map['last_fired'] = Variable<String>(lastFired);
    return map;
  }

  DedupCompanion toCompanion(bool nullToAbsent) {
    return DedupCompanion(
      campaignId: Value(campaignId),
      lastFired: Value(lastFired),
    );
  }

  factory DedupData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DedupData(
      campaignId: serializer.fromJson<int>(json['campaignId']),
      lastFired: serializer.fromJson<String>(json['lastFired']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'campaignId': serializer.toJson<int>(campaignId),
      'lastFired': serializer.toJson<String>(lastFired),
    };
  }

  DedupData copyWith({int? campaignId, String? lastFired}) => DedupData(
    campaignId: campaignId ?? this.campaignId,
    lastFired: lastFired ?? this.lastFired,
  );
  DedupData copyWithCompanion(DedupCompanion data) {
    return DedupData(
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      lastFired: data.lastFired.present ? data.lastFired.value : this.lastFired,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DedupData(')
          ..write('campaignId: $campaignId, ')
          ..write('lastFired: $lastFired')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(campaignId, lastFired);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DedupData &&
          other.campaignId == this.campaignId &&
          other.lastFired == this.lastFired);
}

class DedupCompanion extends UpdateCompanion<DedupData> {
  final Value<int> campaignId;
  final Value<String> lastFired;
  const DedupCompanion({
    this.campaignId = const Value.absent(),
    this.lastFired = const Value.absent(),
  });
  DedupCompanion.insert({
    this.campaignId = const Value.absent(),
    required String lastFired,
  }) : lastFired = Value(lastFired);
  static Insertable<DedupData> custom({
    Expression<int>? campaignId,
    Expression<String>? lastFired,
  }) {
    return RawValuesInsertable({
      if (campaignId != null) 'campaign_id': campaignId,
      if (lastFired != null) 'last_fired': lastFired,
    });
  }

  DedupCompanion copyWith({Value<int>? campaignId, Value<String>? lastFired}) {
    return DedupCompanion(
      campaignId: campaignId ?? this.campaignId,
      lastFired: lastFired ?? this.lastFired,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (campaignId.present) {
      map['campaign_id'] = Variable<int>(campaignId.value);
    }
    if (lastFired.present) {
      map['last_fired'] = Variable<String>(lastFired.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DedupCompanion(')
          ..write('campaignId: $campaignId, ')
          ..write('lastFired: $lastFired')
          ..write(')'))
        .toString();
  }
}

class $VisitedTable extends Visited with TableInfo<$VisitedTable, VisitedData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VisitedTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<int> storeId = GeneratedColumn<int>(
    'store_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [storeId, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'visited';
  @override
  VerificationContext validateIntegrity(
    Insertable<VisitedData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {storeId};
  @override
  VisitedData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VisitedData(
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}store_id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $VisitedTable createAlias(String alias) {
    return $VisitedTable(attachedDatabase, alias);
  }
}

class VisitedData extends DataClass implements Insertable<VisitedData> {
  final int storeId;
  final String at;
  const VisitedData({required this.storeId, required this.at});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['store_id'] = Variable<int>(storeId);
    map['at'] = Variable<String>(at);
    return map;
  }

  VisitedCompanion toCompanion(bool nullToAbsent) {
    return VisitedCompanion(storeId: Value(storeId), at: Value(at));
  }

  factory VisitedData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VisitedData(
      storeId: serializer.fromJson<int>(json['storeId']),
      at: serializer.fromJson<String>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'storeId': serializer.toJson<int>(storeId),
      'at': serializer.toJson<String>(at),
    };
  }

  VisitedData copyWith({int? storeId, String? at}) =>
      VisitedData(storeId: storeId ?? this.storeId, at: at ?? this.at);
  VisitedData copyWithCompanion(VisitedCompanion data) {
    return VisitedData(
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VisitedData(')
          ..write('storeId: $storeId, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(storeId, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VisitedData &&
          other.storeId == this.storeId &&
          other.at == this.at);
}

class VisitedCompanion extends UpdateCompanion<VisitedData> {
  final Value<int> storeId;
  final Value<String> at;
  const VisitedCompanion({
    this.storeId = const Value.absent(),
    this.at = const Value.absent(),
  });
  VisitedCompanion.insert({
    this.storeId = const Value.absent(),
    required String at,
  }) : at = Value(at);
  static Insertable<VisitedData> custom({
    Expression<int>? storeId,
    Expression<String>? at,
  }) {
    return RawValuesInsertable({
      if (storeId != null) 'store_id': storeId,
      if (at != null) 'at': at,
    });
  }

  VisitedCompanion copyWith({Value<int>? storeId, Value<String>? at}) {
    return VisitedCompanion(
      storeId: storeId ?? this.storeId,
      at: at ?? this.at,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (storeId.present) {
      map['store_id'] = Variable<int>(storeId.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VisitedCompanion(')
          ..write('storeId: $storeId, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

class $MetaTable extends Meta with TableInfo<$MetaTable, MetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _kMeta = const VerificationMeta('k');
  @override
  late final GeneratedColumn<String> k = GeneratedColumn<String>(
    'k',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vMeta = const VerificationMeta('v');
  @override
  late final GeneratedColumn<String> v = GeneratedColumn<String>(
    'v',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [k, v];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('k')) {
      context.handle(_kMeta, k.isAcceptableOrUnknown(data['k']!, _kMeta));
    } else if (isInserting) {
      context.missing(_kMeta);
    }
    if (data.containsKey('v')) {
      context.handle(_vMeta, v.isAcceptableOrUnknown(data['v']!, _vMeta));
    } else if (isInserting) {
      context.missing(_vMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {k};
  @override
  MetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaData(
      k: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}k'],
      )!,
      v: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}v'],
      )!,
    );
  }

  @override
  $MetaTable createAlias(String alias) {
    return $MetaTable(attachedDatabase, alias);
  }
}

class MetaData extends DataClass implements Insertable<MetaData> {
  final String k;
  final String v;
  const MetaData({required this.k, required this.v});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['k'] = Variable<String>(k);
    map['v'] = Variable<String>(v);
    return map;
  }

  MetaCompanion toCompanion(bool nullToAbsent) {
    return MetaCompanion(k: Value(k), v: Value(v));
  }

  factory MetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaData(
      k: serializer.fromJson<String>(json['k']),
      v: serializer.fromJson<String>(json['v']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'k': serializer.toJson<String>(k),
      'v': serializer.toJson<String>(v),
    };
  }

  MetaData copyWith({String? k, String? v}) =>
      MetaData(k: k ?? this.k, v: v ?? this.v);
  MetaData copyWithCompanion(MetaCompanion data) {
    return MetaData(
      k: data.k.present ? data.k.value : this.k,
      v: data.v.present ? data.v.value : this.v,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaData(')
          ..write('k: $k, ')
          ..write('v: $v')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(k, v);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaData && other.k == this.k && other.v == this.v);
}

class MetaCompanion extends UpdateCompanion<MetaData> {
  final Value<String> k;
  final Value<String> v;
  final Value<int> rowid;
  const MetaCompanion({
    this.k = const Value.absent(),
    this.v = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaCompanion.insert({
    required String k,
    required String v,
    this.rowid = const Value.absent(),
  }) : k = Value(k),
       v = Value(v);
  static Insertable<MetaData> custom({
    Expression<String>? k,
    Expression<String>? v,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (k != null) 'k': k,
      if (v != null) 'v': v,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaCompanion copyWith({
    Value<String>? k,
    Value<String>? v,
    Value<int>? rowid,
  }) {
    return MetaCompanion(
      k: k ?? this.k,
      v: v ?? this.v,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (k.present) {
      map['k'] = Variable<String>(k.value);
    }
    if (v.present) {
      map['v'] = Variable<String>(v.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaCompanion(')
          ..write('k: $k, ')
          ..write('v: $v, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $FloorsTable floors = $FloorsTable(this);
  late final $StoresTable stores = $StoresTable(this);
  late final $BeaconsTable beacons = $BeaconsTable(this);
  late final $CampaignsTable campaigns = $CampaignsTable(this);
  late final $CampaignBeaconsTable campaignBeacons = $CampaignBeaconsTable(
    this,
  );
  late final $PingsTable pings = $PingsTable(this);
  late final $ImpressionsTable impressions = $ImpressionsTable(this);
  late final $DedupTable dedup = $DedupTable(this);
  late final $VisitedTable visited = $VisitedTable(this);
  late final $MetaTable meta = $MetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    floors,
    stores,
    beacons,
    campaigns,
    campaignBeacons,
    pings,
    impressions,
    dedup,
    visited,
    meta,
  ];
}

typedef $$FloorsTableCreateCompanionBuilder =
    FloorsCompanion Function({
      Value<int> id,
      required int number,
      required String name,
    });
typedef $$FloorsTableUpdateCompanionBuilder =
    FloorsCompanion Function({
      Value<int> id,
      Value<int> number,
      Value<String> name,
    });

class $$FloorsTableFilterComposer extends Composer<_$AppDb, $FloorsTable> {
  $$FloorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FloorsTableOrderingComposer extends Composer<_$AppDb, $FloorsTable> {
  $$FloorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FloorsTableAnnotationComposer extends Composer<_$AppDb, $FloorsTable> {
  $$FloorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$FloorsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $FloorsTable,
          Floor,
          $$FloorsTableFilterComposer,
          $$FloorsTableOrderingComposer,
          $$FloorsTableAnnotationComposer,
          $$FloorsTableCreateCompanionBuilder,
          $$FloorsTableUpdateCompanionBuilder,
          (Floor, BaseReferences<_$AppDb, $FloorsTable, Floor>),
          Floor,
          PrefetchHooks Function()
        > {
  $$FloorsTableTableManager(_$AppDb db, $FloorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FloorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FloorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FloorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => FloorsCompanion(id: id, number: number, name: name),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int number,
                required String name,
              }) => FloorsCompanion.insert(id: id, number: number, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FloorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $FloorsTable,
      Floor,
      $$FloorsTableFilterComposer,
      $$FloorsTableOrderingComposer,
      $$FloorsTableAnnotationComposer,
      $$FloorsTableCreateCompanionBuilder,
      $$FloorsTableUpdateCompanionBuilder,
      (Floor, BaseReferences<_$AppDb, $FloorsTable, Floor>),
      Floor,
      PrefetchHooks Function()
    >;
typedef $$StoresTableCreateCompanionBuilder =
    StoresCompanion Function({
      Value<int> id,
      required String name,
      required String category,
      required int floorId,
      required int x,
      required int y,
      Value<String?> image,
      Value<String> tagline,
      Value<String> badge,
    });
typedef $$StoresTableUpdateCompanionBuilder =
    StoresCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> category,
      Value<int> floorId,
      Value<int> x,
      Value<int> y,
      Value<String?> image,
      Value<String> tagline,
      Value<String> badge,
    });

class $$StoresTableFilterComposer extends Composer<_$AppDb, $StoresTable> {
  $$StoresTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get floorId => $composableBuilder(
    column: $table.floorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagline => $composableBuilder(
    column: $table.tagline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get badge => $composableBuilder(
    column: $table.badge,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoresTableOrderingComposer extends Composer<_$AppDb, $StoresTable> {
  $$StoresTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get floorId => $composableBuilder(
    column: $table.floorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get image => $composableBuilder(
    column: $table.image,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagline => $composableBuilder(
    column: $table.tagline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get badge => $composableBuilder(
    column: $table.badge,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoresTableAnnotationComposer extends Composer<_$AppDb, $StoresTable> {
  $$StoresTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get floorId =>
      $composableBuilder(column: $table.floorId, builder: (column) => column);

  GeneratedColumn<int> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<int> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);

  GeneratedColumn<String> get image =>
      $composableBuilder(column: $table.image, builder: (column) => column);

  GeneratedColumn<String> get tagline =>
      $composableBuilder(column: $table.tagline, builder: (column) => column);

  GeneratedColumn<String> get badge =>
      $composableBuilder(column: $table.badge, builder: (column) => column);
}

class $$StoresTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $StoresTable,
          Store,
          $$StoresTableFilterComposer,
          $$StoresTableOrderingComposer,
          $$StoresTableAnnotationComposer,
          $$StoresTableCreateCompanionBuilder,
          $$StoresTableUpdateCompanionBuilder,
          (Store, BaseReferences<_$AppDb, $StoresTable, Store>),
          Store,
          PrefetchHooks Function()
        > {
  $$StoresTableTableManager(_$AppDb db, $StoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> floorId = const Value.absent(),
                Value<int> x = const Value.absent(),
                Value<int> y = const Value.absent(),
                Value<String?> image = const Value.absent(),
                Value<String> tagline = const Value.absent(),
                Value<String> badge = const Value.absent(),
              }) => StoresCompanion(
                id: id,
                name: name,
                category: category,
                floorId: floorId,
                x: x,
                y: y,
                image: image,
                tagline: tagline,
                badge: badge,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String category,
                required int floorId,
                required int x,
                required int y,
                Value<String?> image = const Value.absent(),
                Value<String> tagline = const Value.absent(),
                Value<String> badge = const Value.absent(),
              }) => StoresCompanion.insert(
                id: id,
                name: name,
                category: category,
                floorId: floorId,
                x: x,
                y: y,
                image: image,
                tagline: tagline,
                badge: badge,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $StoresTable,
      Store,
      $$StoresTableFilterComposer,
      $$StoresTableOrderingComposer,
      $$StoresTableAnnotationComposer,
      $$StoresTableCreateCompanionBuilder,
      $$StoresTableUpdateCompanionBuilder,
      (Store, BaseReferences<_$AppDb, $StoresTable, Store>),
      Store,
      PrefetchHooks Function()
    >;
typedef $$BeaconsTableCreateCompanionBuilder =
    BeaconsCompanion Function({
      required String advId,
      Value<int?> storeId,
      required int mallId,
      required int floorId,
      required int tx,
      required int x,
      required int y,
      Value<int> rowid,
    });
typedef $$BeaconsTableUpdateCompanionBuilder =
    BeaconsCompanion Function({
      Value<String> advId,
      Value<int?> storeId,
      Value<int> mallId,
      Value<int> floorId,
      Value<int> tx,
      Value<int> x,
      Value<int> y,
      Value<int> rowid,
    });

class $$BeaconsTableFilterComposer extends Composer<_$AppDb, $BeaconsTable> {
  $$BeaconsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get advId => $composableBuilder(
    column: $table.advId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mallId => $composableBuilder(
    column: $table.mallId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get floorId => $composableBuilder(
    column: $table.floorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tx => $composableBuilder(
    column: $table.tx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BeaconsTableOrderingComposer extends Composer<_$AppDb, $BeaconsTable> {
  $$BeaconsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get advId => $composableBuilder(
    column: $table.advId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mallId => $composableBuilder(
    column: $table.mallId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get floorId => $composableBuilder(
    column: $table.floorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tx => $composableBuilder(
    column: $table.tx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get x => $composableBuilder(
    column: $table.x,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get y => $composableBuilder(
    column: $table.y,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BeaconsTableAnnotationComposer
    extends Composer<_$AppDb, $BeaconsTable> {
  $$BeaconsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get advId =>
      $composableBuilder(column: $table.advId, builder: (column) => column);

  GeneratedColumn<int> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<int> get mallId =>
      $composableBuilder(column: $table.mallId, builder: (column) => column);

  GeneratedColumn<int> get floorId =>
      $composableBuilder(column: $table.floorId, builder: (column) => column);

  GeneratedColumn<int> get tx =>
      $composableBuilder(column: $table.tx, builder: (column) => column);

  GeneratedColumn<int> get x =>
      $composableBuilder(column: $table.x, builder: (column) => column);

  GeneratedColumn<int> get y =>
      $composableBuilder(column: $table.y, builder: (column) => column);
}

class $$BeaconsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $BeaconsTable,
          Beacon,
          $$BeaconsTableFilterComposer,
          $$BeaconsTableOrderingComposer,
          $$BeaconsTableAnnotationComposer,
          $$BeaconsTableCreateCompanionBuilder,
          $$BeaconsTableUpdateCompanionBuilder,
          (Beacon, BaseReferences<_$AppDb, $BeaconsTable, Beacon>),
          Beacon,
          PrefetchHooks Function()
        > {
  $$BeaconsTableTableManager(_$AppDb db, $BeaconsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BeaconsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BeaconsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BeaconsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> advId = const Value.absent(),
                Value<int?> storeId = const Value.absent(),
                Value<int> mallId = const Value.absent(),
                Value<int> floorId = const Value.absent(),
                Value<int> tx = const Value.absent(),
                Value<int> x = const Value.absent(),
                Value<int> y = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BeaconsCompanion(
                advId: advId,
                storeId: storeId,
                mallId: mallId,
                floorId: floorId,
                tx: tx,
                x: x,
                y: y,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String advId,
                Value<int?> storeId = const Value.absent(),
                required int mallId,
                required int floorId,
                required int tx,
                required int x,
                required int y,
                Value<int> rowid = const Value.absent(),
              }) => BeaconsCompanion.insert(
                advId: advId,
                storeId: storeId,
                mallId: mallId,
                floorId: floorId,
                tx: tx,
                x: x,
                y: y,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BeaconsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $BeaconsTable,
      Beacon,
      $$BeaconsTableFilterComposer,
      $$BeaconsTableOrderingComposer,
      $$BeaconsTableAnnotationComposer,
      $$BeaconsTableCreateCompanionBuilder,
      $$BeaconsTableUpdateCompanionBuilder,
      (Beacon, BaseReferences<_$AppDb, $BeaconsTable, Beacon>),
      Beacon,
      PrefetchHooks Function()
    >;
typedef $$CampaignsTableCreateCompanionBuilder =
    CampaignsCompanion Function({
      Value<int> id,
      required int storeId,
      required String title,
      required String body,
      Value<String> coupon,
      required String starts,
      required String ends,
    });
typedef $$CampaignsTableUpdateCompanionBuilder =
    CampaignsCompanion Function({
      Value<int> id,
      Value<int> storeId,
      Value<String> title,
      Value<String> body,
      Value<String> coupon,
      Value<String> starts,
      Value<String> ends,
    });

class $$CampaignsTableFilterComposer
    extends Composer<_$AppDb, $CampaignsTable> {
  $$CampaignsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coupon => $composableBuilder(
    column: $table.coupon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get starts => $composableBuilder(
    column: $table.starts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ends => $composableBuilder(
    column: $table.ends,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CampaignsTableOrderingComposer
    extends Composer<_$AppDb, $CampaignsTable> {
  $$CampaignsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coupon => $composableBuilder(
    column: $table.coupon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get starts => $composableBuilder(
    column: $table.starts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ends => $composableBuilder(
    column: $table.ends,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CampaignsTableAnnotationComposer
    extends Composer<_$AppDb, $CampaignsTable> {
  $$CampaignsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get coupon =>
      $composableBuilder(column: $table.coupon, builder: (column) => column);

  GeneratedColumn<String> get starts =>
      $composableBuilder(column: $table.starts, builder: (column) => column);

  GeneratedColumn<String> get ends =>
      $composableBuilder(column: $table.ends, builder: (column) => column);
}

class $$CampaignsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $CampaignsTable,
          Campaign,
          $$CampaignsTableFilterComposer,
          $$CampaignsTableOrderingComposer,
          $$CampaignsTableAnnotationComposer,
          $$CampaignsTableCreateCompanionBuilder,
          $$CampaignsTableUpdateCompanionBuilder,
          (Campaign, BaseReferences<_$AppDb, $CampaignsTable, Campaign>),
          Campaign,
          PrefetchHooks Function()
        > {
  $$CampaignsTableTableManager(_$AppDb db, $CampaignsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CampaignsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CampaignsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CampaignsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> storeId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> coupon = const Value.absent(),
                Value<String> starts = const Value.absent(),
                Value<String> ends = const Value.absent(),
              }) => CampaignsCompanion(
                id: id,
                storeId: storeId,
                title: title,
                body: body,
                coupon: coupon,
                starts: starts,
                ends: ends,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int storeId,
                required String title,
                required String body,
                Value<String> coupon = const Value.absent(),
                required String starts,
                required String ends,
              }) => CampaignsCompanion.insert(
                id: id,
                storeId: storeId,
                title: title,
                body: body,
                coupon: coupon,
                starts: starts,
                ends: ends,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CampaignsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $CampaignsTable,
      Campaign,
      $$CampaignsTableFilterComposer,
      $$CampaignsTableOrderingComposer,
      $$CampaignsTableAnnotationComposer,
      $$CampaignsTableCreateCompanionBuilder,
      $$CampaignsTableUpdateCompanionBuilder,
      (Campaign, BaseReferences<_$AppDb, $CampaignsTable, Campaign>),
      Campaign,
      PrefetchHooks Function()
    >;
typedef $$CampaignBeaconsTableCreateCompanionBuilder =
    CampaignBeaconsCompanion Function({
      required int campaignId,
      required String advId,
      Value<int> rowid,
    });
typedef $$CampaignBeaconsTableUpdateCompanionBuilder =
    CampaignBeaconsCompanion Function({
      Value<int> campaignId,
      Value<String> advId,
      Value<int> rowid,
    });

class $$CampaignBeaconsTableFilterComposer
    extends Composer<_$AppDb, $CampaignBeaconsTable> {
  $$CampaignBeaconsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get advId => $composableBuilder(
    column: $table.advId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CampaignBeaconsTableOrderingComposer
    extends Composer<_$AppDb, $CampaignBeaconsTable> {
  $$CampaignBeaconsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get advId => $composableBuilder(
    column: $table.advId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CampaignBeaconsTableAnnotationComposer
    extends Composer<_$AppDb, $CampaignBeaconsTable> {
  $$CampaignBeaconsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get advId =>
      $composableBuilder(column: $table.advId, builder: (column) => column);
}

class $$CampaignBeaconsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $CampaignBeaconsTable,
          CampaignBeacon,
          $$CampaignBeaconsTableFilterComposer,
          $$CampaignBeaconsTableOrderingComposer,
          $$CampaignBeaconsTableAnnotationComposer,
          $$CampaignBeaconsTableCreateCompanionBuilder,
          $$CampaignBeaconsTableUpdateCompanionBuilder,
          (
            CampaignBeacon,
            BaseReferences<_$AppDb, $CampaignBeaconsTable, CampaignBeacon>,
          ),
          CampaignBeacon,
          PrefetchHooks Function()
        > {
  $$CampaignBeaconsTableTableManager(_$AppDb db, $CampaignBeaconsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CampaignBeaconsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CampaignBeaconsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CampaignBeaconsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> campaignId = const Value.absent(),
                Value<String> advId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampaignBeaconsCompanion(
                campaignId: campaignId,
                advId: advId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int campaignId,
                required String advId,
                Value<int> rowid = const Value.absent(),
              }) => CampaignBeaconsCompanion.insert(
                campaignId: campaignId,
                advId: advId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CampaignBeaconsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $CampaignBeaconsTable,
      CampaignBeacon,
      $$CampaignBeaconsTableFilterComposer,
      $$CampaignBeaconsTableOrderingComposer,
      $$CampaignBeaconsTableAnnotationComposer,
      $$CampaignBeaconsTableCreateCompanionBuilder,
      $$CampaignBeaconsTableUpdateCompanionBuilder,
      (
        CampaignBeacon,
        BaseReferences<_$AppDb, $CampaignBeaconsTable, CampaignBeacon>,
      ),
      CampaignBeacon,
      PrefetchHooks Function()
    >;
typedef $$PingsTableCreateCompanionBuilder =
    PingsCompanion Function({
      Value<int> id,
      required String t,
      required String advId,
      required int rssi,
    });
typedef $$PingsTableUpdateCompanionBuilder =
    PingsCompanion Function({
      Value<int> id,
      Value<String> t,
      Value<String> advId,
      Value<int> rssi,
    });

class $$PingsTableFilterComposer extends Composer<_$AppDb, $PingsTable> {
  $$PingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get t => $composableBuilder(
    column: $table.t,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get advId => $composableBuilder(
    column: $table.advId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rssi => $composableBuilder(
    column: $table.rssi,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PingsTableOrderingComposer extends Composer<_$AppDb, $PingsTable> {
  $$PingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get t => $composableBuilder(
    column: $table.t,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get advId => $composableBuilder(
    column: $table.advId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rssi => $composableBuilder(
    column: $table.rssi,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PingsTableAnnotationComposer extends Composer<_$AppDb, $PingsTable> {
  $$PingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get t =>
      $composableBuilder(column: $table.t, builder: (column) => column);

  GeneratedColumn<String> get advId =>
      $composableBuilder(column: $table.advId, builder: (column) => column);

  GeneratedColumn<int> get rssi =>
      $composableBuilder(column: $table.rssi, builder: (column) => column);
}

class $$PingsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $PingsTable,
          Ping,
          $$PingsTableFilterComposer,
          $$PingsTableOrderingComposer,
          $$PingsTableAnnotationComposer,
          $$PingsTableCreateCompanionBuilder,
          $$PingsTableUpdateCompanionBuilder,
          (Ping, BaseReferences<_$AppDb, $PingsTable, Ping>),
          Ping,
          PrefetchHooks Function()
        > {
  $$PingsTableTableManager(_$AppDb db, $PingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> t = const Value.absent(),
                Value<String> advId = const Value.absent(),
                Value<int> rssi = const Value.absent(),
              }) => PingsCompanion(id: id, t: t, advId: advId, rssi: rssi),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String t,
                required String advId,
                required int rssi,
              }) =>
                  PingsCompanion.insert(id: id, t: t, advId: advId, rssi: rssi),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $PingsTable,
      Ping,
      $$PingsTableFilterComposer,
      $$PingsTableOrderingComposer,
      $$PingsTableAnnotationComposer,
      $$PingsTableCreateCompanionBuilder,
      $$PingsTableUpdateCompanionBuilder,
      (Ping, BaseReferences<_$AppDb, $PingsTable, Ping>),
      Ping,
      PrefetchHooks Function()
    >;
typedef $$ImpressionsTableCreateCompanionBuilder =
    ImpressionsCompanion Function({
      Value<int> id,
      required int campaignId,
      required String t,
      Value<bool> opened,
    });
typedef $$ImpressionsTableUpdateCompanionBuilder =
    ImpressionsCompanion Function({
      Value<int> id,
      Value<int> campaignId,
      Value<String> t,
      Value<bool> opened,
    });

class $$ImpressionsTableFilterComposer
    extends Composer<_$AppDb, $ImpressionsTable> {
  $$ImpressionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get t => $composableBuilder(
    column: $table.t,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get opened => $composableBuilder(
    column: $table.opened,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImpressionsTableOrderingComposer
    extends Composer<_$AppDb, $ImpressionsTable> {
  $$ImpressionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get t => $composableBuilder(
    column: $table.t,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get opened => $composableBuilder(
    column: $table.opened,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImpressionsTableAnnotationComposer
    extends Composer<_$AppDb, $ImpressionsTable> {
  $$ImpressionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get t =>
      $composableBuilder(column: $table.t, builder: (column) => column);

  GeneratedColumn<bool> get opened =>
      $composableBuilder(column: $table.opened, builder: (column) => column);
}

class $$ImpressionsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ImpressionsTable,
          Impression,
          $$ImpressionsTableFilterComposer,
          $$ImpressionsTableOrderingComposer,
          $$ImpressionsTableAnnotationComposer,
          $$ImpressionsTableCreateCompanionBuilder,
          $$ImpressionsTableUpdateCompanionBuilder,
          (Impression, BaseReferences<_$AppDb, $ImpressionsTable, Impression>),
          Impression,
          PrefetchHooks Function()
        > {
  $$ImpressionsTableTableManager(_$AppDb db, $ImpressionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImpressionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImpressionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImpressionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> campaignId = const Value.absent(),
                Value<String> t = const Value.absent(),
                Value<bool> opened = const Value.absent(),
              }) => ImpressionsCompanion(
                id: id,
                campaignId: campaignId,
                t: t,
                opened: opened,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int campaignId,
                required String t,
                Value<bool> opened = const Value.absent(),
              }) => ImpressionsCompanion.insert(
                id: id,
                campaignId: campaignId,
                t: t,
                opened: opened,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImpressionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ImpressionsTable,
      Impression,
      $$ImpressionsTableFilterComposer,
      $$ImpressionsTableOrderingComposer,
      $$ImpressionsTableAnnotationComposer,
      $$ImpressionsTableCreateCompanionBuilder,
      $$ImpressionsTableUpdateCompanionBuilder,
      (Impression, BaseReferences<_$AppDb, $ImpressionsTable, Impression>),
      Impression,
      PrefetchHooks Function()
    >;
typedef $$DedupTableCreateCompanionBuilder =
    DedupCompanion Function({Value<int> campaignId, required String lastFired});
typedef $$DedupTableUpdateCompanionBuilder =
    DedupCompanion Function({Value<int> campaignId, Value<String> lastFired});

class $$DedupTableFilterComposer extends Composer<_$AppDb, $DedupTable> {
  $$DedupTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastFired => $composableBuilder(
    column: $table.lastFired,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DedupTableOrderingComposer extends Composer<_$AppDb, $DedupTable> {
  $$DedupTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastFired => $composableBuilder(
    column: $table.lastFired,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DedupTableAnnotationComposer extends Composer<_$AppDb, $DedupTable> {
  $$DedupTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastFired =>
      $composableBuilder(column: $table.lastFired, builder: (column) => column);
}

class $$DedupTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $DedupTable,
          DedupData,
          $$DedupTableFilterComposer,
          $$DedupTableOrderingComposer,
          $$DedupTableAnnotationComposer,
          $$DedupTableCreateCompanionBuilder,
          $$DedupTableUpdateCompanionBuilder,
          (DedupData, BaseReferences<_$AppDb, $DedupTable, DedupData>),
          DedupData,
          PrefetchHooks Function()
        > {
  $$DedupTableTableManager(_$AppDb db, $DedupTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DedupTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DedupTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DedupTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> campaignId = const Value.absent(),
                Value<String> lastFired = const Value.absent(),
              }) =>
                  DedupCompanion(campaignId: campaignId, lastFired: lastFired),
          createCompanionCallback:
              ({
                Value<int> campaignId = const Value.absent(),
                required String lastFired,
              }) => DedupCompanion.insert(
                campaignId: campaignId,
                lastFired: lastFired,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DedupTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $DedupTable,
      DedupData,
      $$DedupTableFilterComposer,
      $$DedupTableOrderingComposer,
      $$DedupTableAnnotationComposer,
      $$DedupTableCreateCompanionBuilder,
      $$DedupTableUpdateCompanionBuilder,
      (DedupData, BaseReferences<_$AppDb, $DedupTable, DedupData>),
      DedupData,
      PrefetchHooks Function()
    >;
typedef $$VisitedTableCreateCompanionBuilder =
    VisitedCompanion Function({Value<int> storeId, required String at});
typedef $$VisitedTableUpdateCompanionBuilder =
    VisitedCompanion Function({Value<int> storeId, Value<String> at});

class $$VisitedTableFilterComposer extends Composer<_$AppDb, $VisitedTable> {
  $$VisitedTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VisitedTableOrderingComposer extends Composer<_$AppDb, $VisitedTable> {
  $$VisitedTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get storeId => $composableBuilder(
    column: $table.storeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VisitedTableAnnotationComposer
    extends Composer<_$AppDb, $VisitedTable> {
  $$VisitedTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get storeId =>
      $composableBuilder(column: $table.storeId, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$VisitedTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $VisitedTable,
          VisitedData,
          $$VisitedTableFilterComposer,
          $$VisitedTableOrderingComposer,
          $$VisitedTableAnnotationComposer,
          $$VisitedTableCreateCompanionBuilder,
          $$VisitedTableUpdateCompanionBuilder,
          (VisitedData, BaseReferences<_$AppDb, $VisitedTable, VisitedData>),
          VisitedData,
          PrefetchHooks Function()
        > {
  $$VisitedTableTableManager(_$AppDb db, $VisitedTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VisitedTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VisitedTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VisitedTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> storeId = const Value.absent(),
                Value<String> at = const Value.absent(),
              }) => VisitedCompanion(storeId: storeId, at: at),
          createCompanionCallback:
              ({
                Value<int> storeId = const Value.absent(),
                required String at,
              }) => VisitedCompanion.insert(storeId: storeId, at: at),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VisitedTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $VisitedTable,
      VisitedData,
      $$VisitedTableFilterComposer,
      $$VisitedTableOrderingComposer,
      $$VisitedTableAnnotationComposer,
      $$VisitedTableCreateCompanionBuilder,
      $$VisitedTableUpdateCompanionBuilder,
      (VisitedData, BaseReferences<_$AppDb, $VisitedTable, VisitedData>),
      VisitedData,
      PrefetchHooks Function()
    >;
typedef $$MetaTableCreateCompanionBuilder =
    MetaCompanion Function({
      required String k,
      required String v,
      Value<int> rowid,
    });
typedef $$MetaTableUpdateCompanionBuilder =
    MetaCompanion Function({
      Value<String> k,
      Value<String> v,
      Value<int> rowid,
    });

class $$MetaTableFilterComposer extends Composer<_$AppDb, $MetaTable> {
  $$MetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get k => $composableBuilder(
    column: $table.k,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get v => $composableBuilder(
    column: $table.v,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaTableOrderingComposer extends Composer<_$AppDb, $MetaTable> {
  $$MetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get k => $composableBuilder(
    column: $table.k,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get v => $composableBuilder(
    column: $table.v,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaTableAnnotationComposer extends Composer<_$AppDb, $MetaTable> {
  $$MetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get k =>
      $composableBuilder(column: $table.k, builder: (column) => column);

  GeneratedColumn<String> get v =>
      $composableBuilder(column: $table.v, builder: (column) => column);
}

class $$MetaTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $MetaTable,
          MetaData,
          $$MetaTableFilterComposer,
          $$MetaTableOrderingComposer,
          $$MetaTableAnnotationComposer,
          $$MetaTableCreateCompanionBuilder,
          $$MetaTableUpdateCompanionBuilder,
          (MetaData, BaseReferences<_$AppDb, $MetaTable, MetaData>),
          MetaData,
          PrefetchHooks Function()
        > {
  $$MetaTableTableManager(_$AppDb db, $MetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> k = const Value.absent(),
                Value<String> v = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetaCompanion(k: k, v: v, rowid: rowid),
          createCompanionCallback:
              ({
                required String k,
                required String v,
                Value<int> rowid = const Value.absent(),
              }) => MetaCompanion.insert(k: k, v: v, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $MetaTable,
      MetaData,
      $$MetaTableFilterComposer,
      $$MetaTableOrderingComposer,
      $$MetaTableAnnotationComposer,
      $$MetaTableCreateCompanionBuilder,
      $$MetaTableUpdateCompanionBuilder,
      (MetaData, BaseReferences<_$AppDb, $MetaTable, MetaData>),
      MetaData,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$FloorsTableTableManager get floors =>
      $$FloorsTableTableManager(_db, _db.floors);
  $$StoresTableTableManager get stores =>
      $$StoresTableTableManager(_db, _db.stores);
  $$BeaconsTableTableManager get beacons =>
      $$BeaconsTableTableManager(_db, _db.beacons);
  $$CampaignsTableTableManager get campaigns =>
      $$CampaignsTableTableManager(_db, _db.campaigns);
  $$CampaignBeaconsTableTableManager get campaignBeacons =>
      $$CampaignBeaconsTableTableManager(_db, _db.campaignBeacons);
  $$PingsTableTableManager get pings =>
      $$PingsTableTableManager(_db, _db.pings);
  $$ImpressionsTableTableManager get impressions =>
      $$ImpressionsTableTableManager(_db, _db.impressions);
  $$DedupTableTableManager get dedup =>
      $$DedupTableTableManager(_db, _db.dedup);
  $$VisitedTableTableManager get visited =>
      $$VisitedTableTableManager(_db, _db.visited);
  $$MetaTableTableManager get meta => $$MetaTableTableManager(_db, _db.meta);
}
