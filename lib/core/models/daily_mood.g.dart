// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_mood.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyMoodCollection on Isar {
  IsarCollection<DailyMood> get dailyMoods => this.collection();
}

const DailyMoodSchema = CollectionSchema(
  name: r'DailyMood',
  id: 7480591711839828123,
  properties: {
    r'activities': PropertySchema(
      id: 0,
      name: r'activities',
      type: IsarType.stringList,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'energyLevel': PropertySchema(
      id: 3,
      name: r'energyLevel',
      type: IsarType.long,
    ),
    r'journalEntryId': PropertySchema(
      id: 4,
      name: r'journalEntryId',
      type: IsarType.long,
    ),
    r'mood': PropertySchema(
      id: 5,
      name: r'mood',
      type: IsarType.string,
      enumMap: _DailyMoodmoodEnumValueMap,
    ),
    r'note': PropertySchema(
      id: 6,
      name: r'note',
      type: IsarType.string,
    ),
    r'productivityLevel': PropertySchema(
      id: 7,
      name: r'productivityLevel',
      type: IsarType.long,
    ),
    r'sleepQuality': PropertySchema(
      id: 8,
      name: r'sleepQuality',
      type: IsarType.long,
    ),
    r'stressLevel': PropertySchema(
      id: 9,
      name: r'stressLevel',
      type: IsarType.long,
    )
  },
  estimateSize: _dailyMoodEstimateSize,
  serialize: _dailyMoodSerialize,
  deserialize: _dailyMoodDeserialize,
  deserializeProp: _dailyMoodDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'journalEntryId': IndexSchema(
      id: 1931315215782674582,
      name: r'journalEntryId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'journalEntryId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _dailyMoodGetId,
  getLinks: _dailyMoodGetLinks,
  attach: _dailyMoodAttach,
  version: '3.1.0+1',
);

int _dailyMoodEstimateSize(
  DailyMood object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.activities.length * 3;
  {
    for (var i = 0; i < object.activities.length; i++) {
      final value = object.activities[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.mood.name.length * 3;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _dailyMoodSerialize(
  DailyMood object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.activities);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeLong(offsets[3], object.energyLevel);
  writer.writeLong(offsets[4], object.journalEntryId);
  writer.writeString(offsets[5], object.mood.name);
  writer.writeString(offsets[6], object.note);
  writer.writeLong(offsets[7], object.productivityLevel);
  writer.writeLong(offsets[8], object.sleepQuality);
  writer.writeLong(offsets[9], object.stressLevel);
}

DailyMood _dailyMoodDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyMood();
  object.activities = reader.readStringList(offsets[0]) ?? [];
  object.createdAt = reader.readDateTime(offsets[1]);
  object.date = reader.readDateTime(offsets[2]);
  object.energyLevel = reader.readLongOrNull(offsets[3]);
  object.id = id;
  object.journalEntryId = reader.readLongOrNull(offsets[4]);
  object.mood =
      _DailyMoodmoodValueEnumMap[reader.readStringOrNull(offsets[5])] ??
          MoodLevel.veryBad;
  object.note = reader.readStringOrNull(offsets[6]);
  object.productivityLevel = reader.readLongOrNull(offsets[7]);
  object.sleepQuality = reader.readLongOrNull(offsets[8]);
  object.stressLevel = reader.readLongOrNull(offsets[9]);
  return object;
}

P _dailyMoodDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? []) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (_DailyMoodmoodValueEnumMap[reader.readStringOrNull(offset)] ??
          MoodLevel.veryBad) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DailyMoodmoodEnumValueMap = {
  r'veryBad': r'veryBad',
  r'bad': r'bad',
  r'neutral': r'neutral',
  r'good': r'good',
  r'veryGood': r'veryGood',
};
const _DailyMoodmoodValueEnumMap = {
  r'veryBad': MoodLevel.veryBad,
  r'bad': MoodLevel.bad,
  r'neutral': MoodLevel.neutral,
  r'good': MoodLevel.good,
  r'veryGood': MoodLevel.veryGood,
};

Id _dailyMoodGetId(DailyMood object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyMoodGetLinks(DailyMood object) {
  return [];
}

void _dailyMoodAttach(IsarCollection<dynamic> col, Id id, DailyMood object) {
  object.id = id;
}

extension DailyMoodByIndex on IsarCollection<DailyMood> {
  Future<DailyMood?> getByDate(DateTime date) {
    return getByIndex(r'date', [date]);
  }

  DailyMood? getByDateSync(DateTime date) {
    return getByIndexSync(r'date', [date]);
  }

  Future<bool> deleteByDate(DateTime date) {
    return deleteByIndex(r'date', [date]);
  }

  bool deleteByDateSync(DateTime date) {
    return deleteByIndexSync(r'date', [date]);
  }

  Future<List<DailyMood?>> getAllByDate(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndex(r'date', values);
  }

  List<DailyMood?> getAllByDateSync(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'date', values);
  }

  Future<int> deleteAllByDate(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'date', values);
  }

  int deleteAllByDateSync(List<DateTime> dateValues) {
    final values = dateValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'date', values);
  }

  Future<Id> putByDate(DailyMood object) {
    return putByIndex(r'date', object);
  }

  Id putByDateSync(DailyMood object, {bool saveLinks = true}) {
    return putByIndexSync(r'date', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDate(List<DailyMood> objects) {
    return putAllByIndex(r'date', objects);
  }

  List<Id> putAllByDateSync(List<DailyMood> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'date', objects, saveLinks: saveLinks);
  }
}

extension DailyMoodQueryWhereSort
    on QueryBuilder<DailyMood, DailyMood, QWhere> {
  QueryBuilder<DailyMood, DailyMood, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhere> anyJournalEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'journalEntryId'),
      );
    });
  }
}

extension DailyMoodQueryWhere
    on QueryBuilder<DailyMood, DailyMood, QWhereClause> {
  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause> idBetween(
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

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause> dateNotEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause> journalEntryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'journalEntryId',
        value: [null],
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause>
      journalEntryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'journalEntryId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause> journalEntryIdEqualTo(
      int? journalEntryId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'journalEntryId',
        value: [journalEntryId],
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause>
      journalEntryIdNotEqualTo(int? journalEntryId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'journalEntryId',
              lower: [],
              upper: [journalEntryId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'journalEntryId',
              lower: [journalEntryId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'journalEntryId',
              lower: [journalEntryId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'journalEntryId',
              lower: [],
              upper: [journalEntryId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause>
      journalEntryIdGreaterThan(
    int? journalEntryId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'journalEntryId',
        lower: [journalEntryId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause> journalEntryIdLessThan(
    int? journalEntryId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'journalEntryId',
        lower: [],
        upper: [journalEntryId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterWhereClause> journalEntryIdBetween(
    int? lowerJournalEntryId,
    int? upperJournalEntryId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'journalEntryId',
        lower: [lowerJournalEntryId],
        includeLower: includeLower,
        upper: [upperJournalEntryId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyMoodQueryFilter
    on QueryBuilder<DailyMood, DailyMood, QFilterCondition> {
  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activities',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activities',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activities',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activities',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activities',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activities',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activities',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activities',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activities',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activities',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activities',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activities',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activities',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activities',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activities',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      activitiesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'activities',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
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

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      energyLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'energyLevel',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      energyLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'energyLevel',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> energyLevelEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'energyLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      energyLevelGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'energyLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> energyLevelLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'energyLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> energyLevelBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'energyLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> idBetween(
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

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      journalEntryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'journalEntryId',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      journalEntryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'journalEntryId',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      journalEntryIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'journalEntryId',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      journalEntryIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'journalEntryId',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      journalEntryIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'journalEntryId',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      journalEntryIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'journalEntryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> moodEqualTo(
    MoodLevel value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mood',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> moodGreaterThan(
    MoodLevel value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mood',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> moodLessThan(
    MoodLevel value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mood',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> moodBetween(
    MoodLevel lower,
    MoodLevel upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mood',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> moodStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mood',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> moodEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mood',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> moodContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mood',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> moodMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mood',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> moodIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mood',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> moodIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mood',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> noteContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> noteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      productivityLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'productivityLevel',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      productivityLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'productivityLevel',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      productivityLevelEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productivityLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      productivityLevelGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productivityLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      productivityLevelLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productivityLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      productivityLevelBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productivityLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      sleepQualityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sleepQuality',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      sleepQualityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sleepQuality',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> sleepQualityEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepQuality',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      sleepQualityGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sleepQuality',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      sleepQualityLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sleepQuality',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> sleepQualityBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sleepQuality',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      stressLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stressLevel',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      stressLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stressLevel',
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> stressLevelEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stressLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition>
      stressLevelGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stressLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> stressLevelLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stressLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterFilterCondition> stressLevelBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stressLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyMoodQueryObject
    on QueryBuilder<DailyMood, DailyMood, QFilterCondition> {}

extension DailyMoodQueryLinks
    on QueryBuilder<DailyMood, DailyMood, QFilterCondition> {}

extension DailyMoodQuerySortBy on QueryBuilder<DailyMood, DailyMood, QSortBy> {
  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortByEnergyLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyLevel', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortByEnergyLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyLevel', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortByJournalEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journalEntryId', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortByJournalEntryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journalEntryId', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortByMood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortByMoodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortByProductivityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productivityLevel', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy>
      sortByProductivityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productivityLevel', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortBySleepQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepQuality', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortBySleepQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepQuality', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortByStressLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> sortByStressLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.desc);
    });
  }
}

extension DailyMoodQuerySortThenBy
    on QueryBuilder<DailyMood, DailyMood, QSortThenBy> {
  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByEnergyLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyLevel', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByEnergyLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'energyLevel', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByJournalEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journalEntryId', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByJournalEntryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'journalEntryId', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByMood() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByMoodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mood', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByProductivityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productivityLevel', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy>
      thenByProductivityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productivityLevel', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenBySleepQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepQuality', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenBySleepQualityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepQuality', Sort.desc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByStressLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.asc);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QAfterSortBy> thenByStressLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stressLevel', Sort.desc);
    });
  }
}

extension DailyMoodQueryWhereDistinct
    on QueryBuilder<DailyMood, DailyMood, QDistinct> {
  QueryBuilder<DailyMood, DailyMood, QDistinct> distinctByActivities() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activities');
    });
  }

  QueryBuilder<DailyMood, DailyMood, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<DailyMood, DailyMood, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<DailyMood, DailyMood, QDistinct> distinctByEnergyLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'energyLevel');
    });
  }

  QueryBuilder<DailyMood, DailyMood, QDistinct> distinctByJournalEntryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'journalEntryId');
    });
  }

  QueryBuilder<DailyMood, DailyMood, QDistinct> distinctByMood(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mood', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DailyMood, DailyMood, QDistinct> distinctByProductivityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productivityLevel');
    });
  }

  QueryBuilder<DailyMood, DailyMood, QDistinct> distinctBySleepQuality() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepQuality');
    });
  }

  QueryBuilder<DailyMood, DailyMood, QDistinct> distinctByStressLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stressLevel');
    });
  }
}

extension DailyMoodQueryProperty
    on QueryBuilder<DailyMood, DailyMood, QQueryProperty> {
  QueryBuilder<DailyMood, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyMood, List<String>, QQueryOperations> activitiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activities');
    });
  }

  QueryBuilder<DailyMood, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<DailyMood, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DailyMood, int?, QQueryOperations> energyLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'energyLevel');
    });
  }

  QueryBuilder<DailyMood, int?, QQueryOperations> journalEntryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'journalEntryId');
    });
  }

  QueryBuilder<DailyMood, MoodLevel, QQueryOperations> moodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mood');
    });
  }

  QueryBuilder<DailyMood, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<DailyMood, int?, QQueryOperations> productivityLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productivityLevel');
    });
  }

  QueryBuilder<DailyMood, int?, QQueryOperations> sleepQualityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepQuality');
    });
  }

  QueryBuilder<DailyMood, int?, QQueryOperations> stressLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stressLevel');
    });
  }
}
