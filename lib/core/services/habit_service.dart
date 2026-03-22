import 'dart:math';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/habit.dart';
import '../../../main.dart';

part 'habit_service.g.dart';

/// Provider für HabitService
@riverpod
HabitService habitService(HabitServiceRef ref) {
  return HabitService(db);
}

class HabitService {
  final Isar _db;

  HabitService(this._db);

  // ============ HABIT CRUD ============

  /// Erstellt ein neues Habit
  Future<Habit> createHabit({
    required String name,
    String? description,
    HabitCategory category = HabitCategory.custom,
    String iconName = 'check_circle',
    String colorHex = '#4CAF50',
    HabitFrequency frequency = HabitFrequency.daily,
    int targetCount = 1,
    List<int> activeDays = const [1, 2, 3, 4, 5, 6, 7],
    List<String> linkedTags = const [],
  }) async {
    final habit = Habit()
      ..name = name
      ..description = description
      ..category = category
      ..iconName = iconName
      ..colorHex = colorHex
      ..frequency = frequency
      ..targetCount = targetCount
      ..activeDays = activeDays
      ..linkedTags = linkedTags
      ..createdAt = DateTime.now()
      ..isActive = true
      ..sortOrder = await _getNextSortOrder();

    await _db.writeTxn(() async {
      await _db.habits.put(habit);
    });

    return habit;
  }

  Future<int> _getNextSortOrder() async {
    final lastHabit = await _db.habits
        .where()
        .sortBySortOrderDesc()
        .findFirst();
    return (lastHabit?.sortOrder ?? -1) + 1;
  }

  /// Holt alle aktiven Habits
  Future<List<Habit>> getActiveHabits() async {
    return await _db.habits
        .filter()
        .isActiveEqualTo(true)
        .sortBySortOrder()
        .findAll();
  }

  /// Holt alle Habits (inkl. inaktive)
  Future<List<Habit>> getAllHabits() async {
    return await _db.habits
        .where()
        .sortBySortOrder()
        .findAll();
  }

  /// Holt Habits nach Kategorie
  Future<List<Habit>> getHabitsByCategory(HabitCategory category) async {
    return await _db.habits
        .filter()
        .isActiveEqualTo(true)
        .and()
        .categoryEqualTo(category)
        .sortBySortOrder()
        .findAll();
  }

  /// Holt Habits für einen bestimmten Wochentag
  Future<List<Habit>> getHabitsForDay(DateTime date) async {
    final weekday = date.weekday;
    
    final allHabits = await getActiveHabits();
    
    return allHabits.where((h) {
      if (h.frequency == HabitFrequency.daily) return true;
      if (h.frequency == HabitFrequency.weekly) {
        return h.activeDays.contains(weekday);
      }
      return true;
    }).toList();
  }

  /// Aktualisiert ein Habit
  Future<void> updateHabit(Habit habit) async {
    await _db.writeTxn(() async {
      await _db.habits.put(habit);
    });
  }

  /// Löscht ein Habit (soft delete)
  Future<void> deleteHabit(int habitId) async {
    await _db.writeTxn(() async {
      final habit = await _db.habits.get(habitId);
      if (habit != null) {
        habit.isActive = false;
        await _db.habits.put(habit);
      }
    });
  }

  /// Endgültig löschen
  Future<void> permanentlyDeleteHabit(int habitId) async {
    await _db.writeTxn(() async {
      // Zuerst alle Completions löschen
      await _db.habitCompletions
          .where()
          .habitIdEqualTo(habitId)
          .deleteAll();
      // Dann das Habit
      await _db.habits.delete(habitId);
    });
  }

  // ============ COMPLETIONS ============

  /// Markiert ein Habit als erledigt
  Future<HabitCompletion> completeHabit(
    int habitId, {
    int count = 1,
    String? note,
    int? journalEntryId,
    DateTime? date,
  }) async {
    final completionDate = _normalizeDate(date ?? DateTime.now());
    
    // Prüfe ob schon eine Completion existiert
    final existing = await _db.habitCompletions
        .where()
        .habitIdEqualTo(habitId)
        .filter()
        .dateEqualTo(completionDate)
        .findFirst();

    final completion = existing ?? HabitCompletion()
      ..habitId = habitId
      ..date = completionDate
      ..createdAt = DateTime.now();

    completion
      ..count = (existing?.count ?? 0) + count
      ..note = note ?? existing?.note
      ..journalEntryId = journalEntryId ?? existing?.journalEntryId;

    await _db.writeTxn(() async {
      await _db.habitCompletions.put(completion);
    });

    return completion;
  }

  /// Entfernt eine Completion
  Future<void> uncompleteHabit(int habitId, DateTime date) async {
    final completionDate = _normalizeDate(date);
    
    await _db.writeTxn(() async {
      await _db.habitCompletions
          .where()
          .habitIdEqualTo(habitId)
          .filter()
          .dateEqualTo(completionDate)
          .deleteAll();
    });
  }

  /// Setzt Completion-Count
  Future<void> setCompletionCount(
    int habitId,
    DateTime date,
    int count, {
    String? note,
  }) async {
    final completionDate = _normalizeDate(date);
    
    if (count <= 0) {
      await uncompleteHabit(habitId, date);
      return;
    }

    await _db.writeTxn(() async {
      final existing = await _db.habitCompletions
          .where()
          .habitIdEqualTo(habitId)
          .filter()
          .dateEqualTo(completionDate)
          .findFirst();

      final completion = existing ?? HabitCompletion()
        ..habitId = habitId
        ..date = completionDate
        ..createdAt = DateTime.now();

      completion
        ..count = count
        ..note = note ?? existing?.note;

      await _db.habitCompletions.put(completion);
    });
  }

  /// Holt Completions für ein Datum
  Future<Map<int, HabitCompletion>> getCompletionsForDate(DateTime date) async {
    final completionDate = _normalizeDate(date);
    
    final completions = await _db.habitCompletions
        .where()
        .filter()
        .dateEqualTo(completionDate)
        .findAll();

    return {for (var c in completions) c.habitId: c};
  }

  /// Holt alle Completions für ein Habit in einem Zeitraum
  Future<List<HabitCompletion>> getCompletionsForHabit(
    int habitId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start = _normalizeDate(startDate ?? DateTime.now().subtract(const Duration(days: 30)));
    final end = _normalizeDate(endDate ?? DateTime.now());

    return await _db.habitCompletions
        .where()
        .habitIdEqualTo(habitId)
        .filter()
        .dateBetween(start, end)
        .sortByDateDesc()
        .findAll();
  }

  // ============ STATISTIKEN ============

  /// Berechnet Statistiken für ein Habit
  Future<HabitStats> getHabitStats(int habitId, {int days = 30}) async {
    final habit = await _db.habits.get(habitId);
    if (habit == null) {
      return HabitStats(
        habitId: habitId,
        currentStreak: 0,
        longestStreak: 0,
        totalCompletions: 0,
        completionRate: 0,
        last30Days: {},
      );
    }

    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    
    // Hole alle Completions im Zeitraum
    final completions = await getCompletionsForHabit(
      habitId,
      startDate: startDate,
      endDate: now,
    );

    // Map: Datum -> Count
    final completionMap = <DateTime, int>{};
    for (var c in completions) {
      completionMap[c.date] = c.count;
    }

    // Berechne aktive Tage im Zeitraum
    final activeDays = _getActiveDaysInPeriod(habit, startDate, now);
    
    // Completion Rate
    final completedDays = completionMap.entries
        .where((e) => e.value >= habit.targetCount)
        .length;
    final completionRate = activeDays.isNotEmpty
        ? completedDays / activeDays.length
        : 0.0;

    // Streaks berechnen
    final streaks = _calculateStreaks(habit, completionMap, now);
    
    // Total completions
    final totalCompletions = completions.fold<int>(0, (sum, c) => sum + c.count);

    return HabitStats(
      habitId: habitId,
      currentStreak: streaks['current']!,
      longestStreak: streaks['longest']!,
      totalCompletions: totalCompletions,
      completionRate: completionRate,
      last30Days: completionMap,
    );
  }

  List<DateTime> _getActiveDaysInPeriod(
    Habit habit,
    DateTime start,
    DateTime end,
  ) {
    final days = <DateTime>[];
    var current = _normalizeDate(start);
    final endDate = _normalizeDate(end);

    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      if (_isHabitActiveOnDay(habit, current)) {
        days.add(current);
      }
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  bool _isHabitActiveOnDay(Habit habit, DateTime date) {
    if (habit.frequency == HabitFrequency.daily) return true;
    if (habit.frequency == HabitFrequency.weekly) {
      return habit.activeDays.contains(date.weekday);
    }
    return true;
  }

  Map<String, int> _calculateStreaks(
    Habit habit,
    Map<DateTime, int> completions,
    DateTime today,
  ) {
    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    // Gehe durch die letzten 365 Tage
    var checkDate = _normalizeDate(today);
    final startDate = today.subtract(const Duration(days: 365));

    while (checkDate.isAfter(startDate)) {
      final isCompleted = (completions[checkDate] ?? 0) >= habit.targetCount;
      final isActive = _isHabitActiveOnDay(habit, checkDate);

      if (isCompleted) {
        tempStreak++;
        longestStreak = max(longestStreak, tempStreak);
      } else if (isActive) {
        // Streak unterbrochen
        if (checkDate != _normalizeDate(today)) {
          // Wenn nicht heute, ist currentStreak beendet
          if (tempStreak > 0 && currentStreak == 0) {
            currentStreak = tempStreak;
          }
        }
        tempStreak = 0;
      }

      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // Wenn noch kein Streak gesetzt, nimm den aktuellen tempStreak
    if (currentStreak == 0 && tempStreak > 0) {
      currentStreak = tempStreak;
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }

  /// Holt Gesamtstatistiken für Dashboard
  Future<Map<String, dynamic>> getOverallStats() async {
    final habits = await getActiveHabits();
    final today = DateTime.now();
    
    int totalStreak = 0;
    int completedToday = 0;
    int totalHabits = habits.length;

    for (final habit in habits) {
      if (!_isHabitActiveOnDay(habit, today)) continue;

      final stats = await getHabitStats(habit.id);
      totalStreak = max(totalStreak, stats.currentStreak);

      final completions = await getCompletionsForDate(today);
      if (completions[habit.id] != null) {
        completedToday++;
      }
    }

    return {
      'totalHabits': totalHabits,
      'completedToday': completedToday,
      'longestStreak': totalStreak,
      'completionRate': totalHabits > 0 ? completedToday / totalHabits : 0,
    };
  }

  // ============ HELPER ============

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Exportiert alle Habits als JSON
  Future<Map<String, dynamic>> exportHabits() async {
    final habits = await getAllHabits();
    final completions = await _db.habitCompletions.where().findAll();

    return {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'habits': habits.map((h) => {
          'id': h.id,
          'name': h.name,
          'description': h.description,
          'category': h.category.name,
          'iconName': h.iconName,
          'colorHex': h.colorHex,
          'frequency': h.frequency.name,
          'targetCount': h.targetCount,
          'activeDays': h.activeDays,
          'createdAt': h.createdAt.toIso8601String(),
          'isActive': h.isActive,
          'sortOrder': h.sortOrder,
          'linkedTags': h.linkedTags,
        }).toList(),
      'completions': completions.map((c) => {
          'id': c.id,
          'habitId': c.habitId,
          'date': c.date.toIso8601String(),
          'count': c.count,
          'note': c.note,
          'journalEntryId': c.journalEntryId,
          'createdAt': c.createdAt.toIso8601String(),
        }).toList(),
    };
  }

  /// Importiert Habits aus JSON
  Future<void> importHabits(Map<String, dynamic> data) async {
    await _db.writeTxn(() async {
      // Habits importieren
      for (final h in (data['habits'] as List)) {
        final habit = Habit()
          ..name = h['name']
          ..description = h['description']
          ..category = HabitCategory.values.byName(h['category'])
          ..iconName = h['iconName']
          ..colorHex = h['colorHex']
          ..frequency = HabitFrequency.values.byName(h['frequency'])
          ..targetCount = h['targetCount']
          ..activeDays = List<int>.from(h['activeDays'])
          ..createdAt = DateTime.parse(h['createdAt'])
          ..isActive = h['isActive']
          ..sortOrder = h['sortOrder']
          ..linkedTags = List<String>.from(h['linkedTags']);
        
        await _db.habits.put(habit);
      }

      // Completions importieren
      for (final c in (data['completions'] as List)) {
        final completion = HabitCompletion()
          ..habitId = c['habitId']
          ..date = DateTime.parse(c['date'])
          ..count = c['count']
          ..note = c['note']
          ..journalEntryId = c['journalEntryId']
          ..createdAt = DateTime.parse(c['createdAt']);
        
        await _db.habitCompletions.put(completion);
      }
    });
  }
}
