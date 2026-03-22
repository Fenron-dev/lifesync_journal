// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'properties.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPropertiesCollection on Isar {
  IsarCollection<Properties> get properties => this.collection();
}

const PropertiesSchema = CollectionSchema(
  name: r'Properties',
  id: -9155848749205695476,
  properties: {
    r'colorHex': PropertySchema(
      id: 0,
      name: r'colorHex',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'defaultValue': PropertySchema(
      id: 2,
      name: r'defaultValue',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 3,
      name: r'description',
      type: IsarType.string,
    ),
    r'displayName': PropertySchema(
      id: 4,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'iconName': PropertySchema(
      id: 5,
      name: r'iconName',
      type: IsarType.string,
    ),
    r'isActive': PropertySchema(
      id: 6,
      name: r'isActive',
      type: IsarType.bool,
    ),
    r'isBuiltin': PropertySchema(
      id: 7,
      name: r'isBuiltin',
      type: IsarType.bool,
    ),
    r'isRequired': PropertySchema(
      id: 8,
      name: r'isRequired',
      type: IsarType.bool,
    ),
    r'maxValue': PropertySchema(
      id: 9,
      name: r'maxValue',
      type: IsarType.double,
    ),
    r'minValue': PropertySchema(
      id: 10,
      name: r'minValue',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 11,
      name: r'name',
      type: IsarType.string,
    ),
    r'optionList': PropertySchema(
      id: 12,
      name: r'optionList',
      type: IsarType.stringList,
    ),
    r'options': PropertySchema(
      id: 13,
      name: r'options',
      type: IsarType.string,
    ),
    r'propertyType': PropertySchema(
      id: 14,
      name: r'propertyType',
      type: IsarType.string,
    ),
    r'showInDashboard': PropertySchema(
      id: 15,
      name: r'showInDashboard',
      type: IsarType.bool,
    ),
    r'showInQuickAdd': PropertySchema(
      id: 16,
      name: r'showInQuickAdd',
      type: IsarType.bool,
    ),
    r'sortOrder': PropertySchema(
      id: 17,
      name: r'sortOrder',
      type: IsarType.long,
    ),
    r'stepValue': PropertySchema(
      id: 18,
      name: r'stepValue',
      type: IsarType.double,
    ),
    r'unit': PropertySchema(
      id: 19,
      name: r'unit',
      type: IsarType.string,
    ),
    r'vaultIdList': PropertySchema(
      id: 20,
      name: r'vaultIdList',
      type: IsarType.longList,
    ),
    r'vaultIds': PropertySchema(
      id: 21,
      name: r'vaultIds',
      type: IsarType.string,
    )
  },
  estimateSize: _propertiesEstimateSize,
  serialize: _propertiesSerialize,
  deserialize: _propertiesDeserialize,
  deserializeProp: _propertiesDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isBuiltin': IndexSchema(
      id: -120736834514636676,
      name: r'isBuiltin',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isBuiltin',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isActive': IndexSchema(
      id: 8092228061260947457,
      name: r'isActive',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isActive',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'vaultIds': IndexSchema(
      id: -1756707151285460393,
      name: r'vaultIds',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'vaultIds',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _propertiesGetId,
  getLinks: _propertiesGetLinks,
  attach: _propertiesAttach,
  version: '3.1.0+1',
);

int _propertiesEstimateSize(
  Properties object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.colorHex.length * 3;
  bytesCount += 3 + object.defaultValue.length * 3;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.displayName.length * 3;
  bytesCount += 3 + object.iconName.length * 3;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.optionList.length * 3;
  {
    for (var i = 0; i < object.optionList.length; i++) {
      final value = object.optionList[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.options.length * 3;
  bytesCount += 3 + object.propertyType.length * 3;
  {
    final value = object.unit;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.vaultIdList.length * 8;
  bytesCount += 3 + object.vaultIds.length * 3;
  return bytesCount;
}

void _propertiesSerialize(
  Properties object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.colorHex);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeString(offsets[2], object.defaultValue);
  writer.writeString(offsets[3], object.description);
  writer.writeString(offsets[4], object.displayName);
  writer.writeString(offsets[5], object.iconName);
  writer.writeBool(offsets[6], object.isActive);
  writer.writeBool(offsets[7], object.isBuiltin);
  writer.writeBool(offsets[8], object.isRequired);
  writer.writeDouble(offsets[9], object.maxValue);
  writer.writeDouble(offsets[10], object.minValue);
  writer.writeString(offsets[11], object.name);
  writer.writeStringList(offsets[12], object.optionList);
  writer.writeString(offsets[13], object.options);
  writer.writeString(offsets[14], object.propertyType);
  writer.writeBool(offsets[15], object.showInDashboard);
  writer.writeBool(offsets[16], object.showInQuickAdd);
  writer.writeLong(offsets[17], object.sortOrder);
  writer.writeDouble(offsets[18], object.stepValue);
  writer.writeString(offsets[19], object.unit);
  writer.writeLongList(offsets[20], object.vaultIdList);
  writer.writeString(offsets[21], object.vaultIds);
}

Properties _propertiesDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Properties();
  object.colorHex = reader.readString(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.defaultValue = reader.readString(offsets[2]);
  object.description = reader.readString(offsets[3]);
  object.displayName = reader.readString(offsets[4]);
  object.iconName = reader.readString(offsets[5]);
  object.id = id;
  object.isActive = reader.readBool(offsets[6]);
  object.isBuiltin = reader.readBool(offsets[7]);
  object.isRequired = reader.readBool(offsets[8]);
  object.maxValue = reader.readDoubleOrNull(offsets[9]);
  object.minValue = reader.readDoubleOrNull(offsets[10]);
  object.name = reader.readString(offsets[11]);
  object.options = reader.readString(offsets[13]);
  object.propertyType = reader.readString(offsets[14]);
  object.showInDashboard = reader.readBool(offsets[15]);
  object.showInQuickAdd = reader.readBool(offsets[16]);
  object.sortOrder = reader.readLong(offsets[17]);
  object.stepValue = reader.readDoubleOrNull(offsets[18]);
  object.unit = reader.readStringOrNull(offsets[19]);
  object.vaultIds = reader.readString(offsets[21]);
  return object;
}

P _propertiesDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringList(offset) ?? []) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readLong(offset)) as P;
    case 18:
      return (reader.readDoubleOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readLongList(offset) ?? []) as P;
    case 21:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _propertiesGetId(Properties object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _propertiesGetLinks(Properties object) {
  return [];
}

void _propertiesAttach(IsarCollection<dynamic> col, Id id, Properties object) {
  object.id = id;
}

extension PropertiesByIndex on IsarCollection<Properties> {
  Future<Properties?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  Properties? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<Properties?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<Properties?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(Properties object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(Properties object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<Properties> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<Properties> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension PropertiesQueryWhereSort
    on QueryBuilder<Properties, Properties, QWhere> {
  QueryBuilder<Properties, Properties, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Properties, Properties, QAfterWhere> anyIsBuiltin() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isBuiltin'),
      );
    });
  }

  QueryBuilder<Properties, Properties, QAfterWhere> anyIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isActive'),
      );
    });
  }
}

extension PropertiesQueryWhere
    on QueryBuilder<Properties, Properties, QWhereClause> {
  QueryBuilder<Properties, Properties, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Properties, Properties, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Properties, Properties, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Properties, Properties, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterWhereClause> nameEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Properties, Properties, QAfterWhereClause> isBuiltinEqualTo(
      bool isBuiltin) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isBuiltin',
        value: [isBuiltin],
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterWhereClause> isBuiltinNotEqualTo(
      bool isBuiltin) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isBuiltin',
              lower: [],
              upper: [isBuiltin],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isBuiltin',
              lower: [isBuiltin],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isBuiltin',
              lower: [isBuiltin],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isBuiltin',
              lower: [],
              upper: [isBuiltin],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Properties, Properties, QAfterWhereClause> isActiveEqualTo(
      bool isActive) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isActive',
        value: [isActive],
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterWhereClause> isActiveNotEqualTo(
      bool isActive) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [],
              upper: [isActive],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [isActive],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [isActive],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isActive',
              lower: [],
              upper: [isActive],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Properties, Properties, QAfterWhereClause> vaultIdsEqualTo(
      String vaultIds) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'vaultIds',
        value: [vaultIds],
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterWhereClause> vaultIdsNotEqualTo(
      String vaultIds) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vaultIds',
              lower: [],
              upper: [vaultIds],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vaultIds',
              lower: [vaultIds],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vaultIds',
              lower: [vaultIds],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'vaultIds',
              lower: [],
              upper: [vaultIds],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PropertiesQueryFilter
    on QueryBuilder<Properties, Properties, QFilterCondition> {
  QueryBuilder<Properties, Properties, QAfterFilterCondition> colorHexEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      colorHexGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> colorHexLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> colorHexBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorHex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      colorHexStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> colorHexEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> colorHexContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'colorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> colorHexMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'colorHex',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      colorHexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorHex',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      colorHexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'colorHex',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      defaultValueEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      defaultValueGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      defaultValueLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      defaultValueBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      defaultValueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'defaultValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      defaultValueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'defaultValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      defaultValueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'defaultValue',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      defaultValueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'defaultValue',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      defaultValueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultValue',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      defaultValueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'defaultValue',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      displayNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      displayNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      displayNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      displayNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      displayNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      displayNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      displayNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      displayNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> iconNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      iconNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> iconNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> iconNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      iconNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'iconName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> iconNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'iconName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> iconNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'iconName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> iconNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'iconName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      iconNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconName',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      iconNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iconName',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> isActiveEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isActive',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> isBuiltinEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBuiltin',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> isRequiredEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isRequired',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> maxValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'maxValue',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      maxValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'maxValue',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> maxValueEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      maxValueGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> maxValueLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> maxValueBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> minValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'minValue',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      minValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'minValue',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> minValueEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'minValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      minValueGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'minValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> minValueLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'minValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> minValueBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'minValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'optionList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'optionList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'optionList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'optionList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'optionList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'optionList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'optionList',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'optionList',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'optionList',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'optionList',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'optionList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'optionList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'optionList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'optionList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'optionList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'optionList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> optionsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'options',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'options',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> optionsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'options',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> optionsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'options',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> optionsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'options',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> optionsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'options',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> optionsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'options',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> optionsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'options',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> optionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'options',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      optionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'options',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      propertyTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'propertyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      propertyTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'propertyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      propertyTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'propertyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      propertyTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'propertyType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      propertyTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'propertyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      propertyTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'propertyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      propertyTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'propertyType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      propertyTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'propertyType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      propertyTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'propertyType',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      propertyTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'propertyType',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      showInDashboardEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showInDashboard',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      showInQuickAddEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showInQuickAdd',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> sortOrderEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      sortOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> sortOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sortOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> sortOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sortOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      stepValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stepValue',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      stepValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stepValue',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> stepValueEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stepValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      stepValueGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stepValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> stepValueLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stepValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> stepValueBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stepValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> unitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unit',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> unitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unit',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> unitEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> unitGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> unitLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> unitBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> unitStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> unitEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> unitContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unit',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> unitMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unit',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> unitIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> unitIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unit',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      vaultIdListElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vaultIdList',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      vaultIdListElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vaultIdList',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      vaultIdListElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vaultIdList',
        value: value,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      vaultIdListElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vaultIdList',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      vaultIdListLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vaultIdList',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      vaultIdListIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vaultIdList',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      vaultIdListIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vaultIdList',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      vaultIdListLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vaultIdList',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      vaultIdListLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vaultIdList',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      vaultIdListLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'vaultIdList',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> vaultIdsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vaultIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      vaultIdsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'vaultIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> vaultIdsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'vaultIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> vaultIdsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'vaultIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      vaultIdsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'vaultIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> vaultIdsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'vaultIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> vaultIdsContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'vaultIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition> vaultIdsMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'vaultIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      vaultIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vaultIds',
        value: '',
      ));
    });
  }

  QueryBuilder<Properties, Properties, QAfterFilterCondition>
      vaultIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'vaultIds',
        value: '',
      ));
    });
  }
}

extension PropertiesQueryObject
    on QueryBuilder<Properties, Properties, QFilterCondition> {}

extension PropertiesQueryLinks
    on QueryBuilder<Properties, Properties, QFilterCondition> {}

extension PropertiesQuerySortBy
    on QueryBuilder<Properties, Properties, QSortBy> {
  QueryBuilder<Properties, Properties, QAfterSortBy> sortByColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByDefaultValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultValue', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByDefaultValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultValue', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByIconName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconName', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByIconNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconName', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByIsBuiltin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBuiltin', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByIsBuiltinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBuiltin', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByIsRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRequired', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByIsRequiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRequired', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByMaxValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxValue', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByMaxValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxValue', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByMinValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minValue', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByMinValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minValue', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByOptions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'options', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByOptionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'options', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByPropertyType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propertyType', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByPropertyTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propertyType', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByShowInDashboard() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showInDashboard', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy>
      sortByShowInDashboardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showInDashboard', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByShowInQuickAdd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showInQuickAdd', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy>
      sortByShowInQuickAddDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showInQuickAdd', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByStepValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepValue', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByStepValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepValue', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByVaultIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultIds', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> sortByVaultIdsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultIds', Sort.desc);
    });
  }
}

extension PropertiesQuerySortThenBy
    on QueryBuilder<Properties, Properties, QSortThenBy> {
  QueryBuilder<Properties, Properties, QAfterSortBy> thenByColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorHex', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByDefaultValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultValue', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByDefaultValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultValue', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByIconName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconName', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByIconNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconName', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByIsActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isActive', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByIsBuiltin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBuiltin', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByIsBuiltinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBuiltin', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByIsRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRequired', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByIsRequiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isRequired', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByMaxValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxValue', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByMaxValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxValue', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByMinValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minValue', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByMinValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'minValue', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByOptions() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'options', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByOptionsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'options', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByPropertyType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propertyType', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByPropertyTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'propertyType', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByShowInDashboard() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showInDashboard', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy>
      thenByShowInDashboardDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showInDashboard', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByShowInQuickAdd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showInQuickAdd', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy>
      thenByShowInQuickAddDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showInQuickAdd', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenBySortOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sortOrder', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByStepValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepValue', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByStepValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stepValue', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByUnit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByUnitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unit', Sort.desc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByVaultIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultIds', Sort.asc);
    });
  }

  QueryBuilder<Properties, Properties, QAfterSortBy> thenByVaultIdsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vaultIds', Sort.desc);
    });
  }
}

extension PropertiesQueryWhereDistinct
    on QueryBuilder<Properties, Properties, QDistinct> {
  QueryBuilder<Properties, Properties, QDistinct> distinctByColorHex(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorHex', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByDefaultValue(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultValue', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByDisplayName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByIconName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByIsActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isActive');
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByIsBuiltin() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBuiltin');
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByIsRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isRequired');
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByMaxValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxValue');
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByMinValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'minValue');
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByOptionList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'optionList');
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByOptions(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'options', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByPropertyType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'propertyType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByShowInDashboard() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showInDashboard');
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByShowInQuickAdd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showInQuickAdd');
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctBySortOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortOrder');
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByStepValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stepValue');
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByUnit(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unit', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByVaultIdList() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vaultIdList');
    });
  }

  QueryBuilder<Properties, Properties, QDistinct> distinctByVaultIds(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vaultIds', caseSensitive: caseSensitive);
    });
  }
}

extension PropertiesQueryProperty
    on QueryBuilder<Properties, Properties, QQueryProperty> {
  QueryBuilder<Properties, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Properties, String, QQueryOperations> colorHexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorHex');
    });
  }

  QueryBuilder<Properties, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Properties, String, QQueryOperations> defaultValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultValue');
    });
  }

  QueryBuilder<Properties, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<Properties, String, QQueryOperations> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<Properties, String, QQueryOperations> iconNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconName');
    });
  }

  QueryBuilder<Properties, bool, QQueryOperations> isActiveProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isActive');
    });
  }

  QueryBuilder<Properties, bool, QQueryOperations> isBuiltinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBuiltin');
    });
  }

  QueryBuilder<Properties, bool, QQueryOperations> isRequiredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isRequired');
    });
  }

  QueryBuilder<Properties, double?, QQueryOperations> maxValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxValue');
    });
  }

  QueryBuilder<Properties, double?, QQueryOperations> minValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'minValue');
    });
  }

  QueryBuilder<Properties, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Properties, List<String>, QQueryOperations>
      optionListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'optionList');
    });
  }

  QueryBuilder<Properties, String, QQueryOperations> optionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'options');
    });
  }

  QueryBuilder<Properties, String, QQueryOperations> propertyTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'propertyType');
    });
  }

  QueryBuilder<Properties, bool, QQueryOperations> showInDashboardProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showInDashboard');
    });
  }

  QueryBuilder<Properties, bool, QQueryOperations> showInQuickAddProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showInQuickAdd');
    });
  }

  QueryBuilder<Properties, int, QQueryOperations> sortOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortOrder');
    });
  }

  QueryBuilder<Properties, double?, QQueryOperations> stepValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stepValue');
    });
  }

  QueryBuilder<Properties, String?, QQueryOperations> unitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unit');
    });
  }

  QueryBuilder<Properties, List<int>, QQueryOperations> vaultIdListProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vaultIdList');
    });
  }

  QueryBuilder<Properties, String, QQueryOperations> vaultIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vaultIds');
    });
  }
}
