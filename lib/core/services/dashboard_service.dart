import 'dart:math';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/daily_mood.dart';
import '../../../main.dart';

part 'dashboard_service.g.dart';

/// Provider für DashboardService
@riverpod
DashboardService dashboardService(DashboardServiceRef ref) {
  return DashboardService(db);
}

class DashboardService {
  final Isar _db;

  DashboardService(this._db);

  // ============ MOOD TRACKING ============

  /// Speichert Tagesform
  Future<DailyMood> saveDailyMood({
    required DateTime date,
    required MoodLevel mood,
    int? energyLevel,
    int? stressLevel,
    int? sleepQuality,
    int? productivityLevel,
    String? note,
    List<String>? activities,
    int? journalEntryId,
  }) async {
    final normalizedDate = _normalizeDate(date);
    
    // Prüfe ob schon ein Eintrag existiert
    final existing = await _db.dailyMoods
        .where()
        .dateEqualTo(normalizedDate)
        .findFirst();

    final dailyMood = existing ?? DailyMood()
      ..date = normalizedDate
      ..createdAt = DateTime.now();

    dailyMood
      ..mood = mood
      ..energyLevel = energyLevel ?? existing?.energyLevel
      ..stressLevel = stressLevel ?? existing?.stressLevel
      ..sleepQuality = sleepQuality ?? existing?.sleepQuality
      ..productivityLevel = productivityLevel ?? existing?.productivityLevel
      ..note = note ?? existing?.note
      ..activities = activities ?? existing?.activities ?? []
      ..journalEntryId = journalEntryId ?? existing?.journalEntryId;

    await _db.writeTxn(() async {
      await _db.dailyMoods.put(dailyMood);
    });

    return dailyMood;
  }

  /// Holt Tagesform für ein Datum
  Future<DailyMood?> getDailyMood(DateTime date) async {
    return await _db.dailyMoods
        .where()
        .dateEqualTo(_normalizeDate(date))
        .findFirst();
  }

  /// Holt alle Mood-Einträge in einem Zeitraum
  Future<List<DailyMood>> getMoodsInRange(DateTime start, DateTime end) async {
    return await _db.dailyMoods
        .where()
        .dateBetween(_normalizeDate(start), _normalizeDate(end))
        .sortByDateDesc()
        .findAll();
  }

  // ============ STATISTICS ============

  /// Berechnet Mood-Statistiken für einen Zeitraum
  Future<MoodStats> getMoodStats({int days = 30}) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    
    final entries = await getMoodsInRange(start, now);
    
    if (entries.isEmpty) {
      return MoodStats(
        averageMood: 0,
        averageEnergy: 0,
        averageStress: 0,
        averageSleep: 0,
        moodDistribution: {},
        entries: [],
        topActivities: {},
      );
    }

    // Durchschnitte berechnen
    final avgMood = entries.map((e) => e.mood.index + 1).reduce((a, b) => a + b) / entries.length;
    
    final energyEntries = entries.where((e) => e.energyLevel != null).toList();
    final avgEnergy = energyEntries.isEmpty ? 0.0 
        : energyEntries.map((e) => e.energyLevel!).reduce((a, b) => a + b) / energyEntries.length;
    
    final stressEntries = entries.where((e) => e.stressLevel != null).toList();
    final avgStress = stressEntries.isEmpty ? 0.0 
        : stressEntries.map((e) => e.stressLevel!).reduce((a, b) => a + b) / stressEntries.length;
    
    final sleepEntries = entries.where((e) => e.sleepQuality != null).toList();
    final avgSleep = sleepEntries.isEmpty ? 0.0 
        : sleepEntries.map((e) => e.sleepQuality!).reduce((a, b) => a + b) / sleepEntries.length;

    // Mood-Verteilung
    final moodDistribution = <MoodLevel, int>{};
    for (final entry in entries) {
      moodDistribution[entry.mood] = (moodDistribution[entry.mood] ?? 0) + 1;
    }

    // Top Aktivitäten
    final activityCount = <String, int>{};
    for (final entry in entries) {
      for (final activity in entry.activities) {
        activityCount[activity] = (activityCount[activity] ?? 0) + 1;
      }
    }
    
    final sortedActivities = activityCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topActivities = Map.fromEntries(sortedActivities.take(10));

    return MoodStats(
      averageMood: avgMood,
      averageEnergy: avgEnergy,
      averageStress: avgStress,
      averageSleep: avgSleep,
      moodDistribution: moodDistribution,
      entries: entries,
      topActivities: topActivities,
    );
  }

  /// Heatmap-Daten für das letzte Jahr
  Future<Map<DateTime, MoodLevel>> getMoodHeatmap({int months = 12}) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: months * 30));
    
    final entries = await getMoodsInRange(start, now);
    
    return {
      for (var entry in entries)
        entry.date: entry.mood
    };
  }

  // ============ INSIGHTS ============

  /// Generiert Insights basierend auf Mood-Daten
  Future<List<MoodInsight>> generateInsights() async {
    final stats = await getMoodStats(days: 30);
    final insights = <MoodInsight>[];

    if (stats.entries.isEmpty) {
      return [
        MoodInsight(
          title: 'Noch keine Daten',
          description: 'Tracke deine Tagesform regelmäßig, um personalisierte Insights zu erhalten.',
          type: InsightType.suggestion,
        ),
      ];
    }

    // Trend-Erkennung
    if (stats.moodTrend.abs() > 0.3) {
      insights.add(MoodInsight(
        title: stats.moodTrend > 0 ? 'Aufwärts-Trend! 📈' : 'Abwärts-Trend 📉',
        description: stats.moodTrend > 0
            ? 'Deine Stimmung hat sich in der letzten Woche im Vergleich zur Vorwoche verbessert. Weiter so!'
            : 'Deine Stimmung war in der letzten Woche niedriger als in der Vorwoche. Achte auf Selbstfürsorge.',
        type: InsightType.trend,
        relevance: 0.9,
      ));
    }

    // Aktivitäts-Korrelationen
    if (stats.topActivities.isNotEmpty) {
      final topActivity = stats.topActivities.entries.first;
      final avgWithActivity = await _getAverageMoodWithActivity(topActivity.key);
      final avgWithout = await _getAverageMoodWithoutActivity(topActivity.key);
      
      if (avgWithActivity != null && avgWithout != null) {
        final diff = avgWithActivity - avgWithout;
        
        if (diff.abs() > 0.5) {
          insights.add(MoodInsight(
            title: diff > 0 
                ? '"${topActivity.key}" macht dich glücklicher! 😊'
                : '"${topActivity.key}" scheint dich zu belasten 😔',
            description: diff > 0
                ? 'An Tagen mit "${topActivity.key}" ist deine durchschnittliche Stimmung ${(diff * 10).round() / 10} Punkte höher.'
                : 'An Tagen mit "${topActivity.key}" ist deine durchschnittliche Stimmung ${(diff.abs() * 10).round() / 10} Punkte niedriger.',
            type: diff > 0 ? InsightType.positive : InsightType.negative,
            relevance: 0.85,
          ));
        }
      }
    }

    // Schlaf-Mood Korrelation
    if (stats.averageSleep > 0) {
      final sleepCorrelation = await _calculateSleepMoodCorrelation();
      if (sleepCorrelation.abs() > 0.3) {
        insights.add(MoodInsight(
          title: 'Schlaf beeinflusst deine Stimmung 😴',
          description: sleepCorrelation > 0
              ? 'Besserer Schlaf korreliert mit besserer Stimmung. Achte auf ausreichend Schlaf!'
              : 'Es gibt eine interessante Beziehung zwischen deinem Schlaf und deiner Stimmung.',
          type: InsightType.pattern,
          relevance: 0.8,
        ));
      }
    }

    // Streak-Motivation
    final streak = await _getCurrentStreak();
    if (streak >= 7) {
      insights.add(MoodInsight(
        title: '$streak Tage in Folge! 🔥',
        description: 'Du trackest deine Tagesform seit $streak Tagen. Großartige Konsistenz!',
        type: InsightType.positive,
        relevance: 0.75,
      ));
    }

    // Stress-Pattern
    if (stats.averageStress > 3.5) {
      insights.add(MoodInsight(
        title: 'Hoher Stress-Level erkannt 😰',
        description: 'Dein durchschnittlicher Stresslevel ist hoch. Versuche, mehr Entspannung in deinen Alltag einzubauen.',
        type: InsightType.suggestion,
        relevance: 0.9,
      ));
    }

    // Durchschnitts-Stimmung
    insights.add(MoodInsight(
      title: 'Deine durchschnittliche Stimmung',
      description: 'In den letzten 30 Tagen lag deine durchschnittliche Stimmung bei ${(stats.averageMood * 10).round() / 10} von 5.',
      type: InsightType.pattern,
      relevance: 0.6,
    ));

    // Sortiere nach Relevanz
    insights.sort((a, b) => b.relevance.compareTo(a.relevance));
    
    return insights;
  }

  Future<double?> _getAverageMoodWithActivity(String activity) async {
    final entries = await _db.dailyMoods
        .where()
        .filter()
        .activitiesElementEqualTo(activity)
        .findAll();
    
    if (entries.isEmpty) return null;
    return entries.map((e) => e.mood.index + 1).reduce((a, b) => a + b) / entries.length;
  }

  Future<double?> _getAverageMoodWithoutActivity(String activity) async {
    final allEntries = await _db.dailyMoods.where().findAll();
    final entries = allEntries.where((e) => !e.activities.contains(activity)).toList();
    
    if (entries.isEmpty) return null;
    return entries.map((e) => e.mood.index + 1).reduce((a, b) => a + b) / entries.length;
  }

  Future<double> _calculateSleepMoodCorrelation() async {
    final entries = await _db.dailyMoods
        .where()
        .filter()
        .sleepQualityIsNotNull()
        .findAll();
    
    if (entries.length < 5) return 0;
    
    // Vereinfachte Korrelationsberechnung
    final sleepValues = entries.map((e) => e.sleepQuality!.toDouble()).toList();
    final moodValues = entries.map((e) => (e.mood.index + 1).toDouble()).toList();
    
    return _pearsonCorrelation(sleepValues, moodValues);
  }

  double _pearsonCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.isEmpty) return 0;
    
    final n = x.length;
    final sumX = x.reduce((a, b) => a + b);
    final sumY = y.reduce((a, b) => a + b);
    final sumXY = List.generate(n, (i) => x[i] * y[i]).reduce((a, b) => a + b);
    final sumX2 = x.map((v) => v * v).reduce((a, b) => a + b);
    final sumY2 = y.map((v) => v * v).reduce((a, b) => a + b);
    
    final numerator = n * sumXY - sumX * sumY;
    final denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));
    
    return denominator == 0 ? 0 : numerator / denominator;
  }

  Future<int> _getCurrentStreak() async {
    final now = DateTime.now();
    var streak = 0;
    var checkDate = _normalizeDate(now);
    
    while (true) {
      final entry = await _db.dailyMoods
          .where()
          .dateEqualTo(checkDate)
          .findFirst();
      
      if (entry == null) break;
      
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }

  // ============ HELPER ============

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Exportiert Mood-Daten
  Future<Map<String, dynamic>> exportMoodData() async {
    final entries = await _db.dailyMoods.where().findAll();
    
    return {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'entries': entries.map((e) => {
          'date': e.date.toIso8601String(),
          'mood': e.mood.name,
          'energyLevel': e.energyLevel,
          'stressLevel': e.stressLevel,
          'sleepQuality': e.sleepQuality,
          'productivityLevel': e.productivityLevel,
          'note': e.note,
          'activities': e.activities,
          'journalEntryId': e.journalEntryId,
          'createdAt': e.createdAt.toIso8601String(),
        }).toList(),
    };
  }

  /// Importiert Mood-Daten
  Future<void> importMoodData(Map<String, dynamic> data) async {
    await _db.writeTxn(() async {
      for (final entry in (data['entries'] as List)) {
        final mood = DailyMood()
          ..date = DateTime.parse(entry['date'])
          ..mood = MoodLevel.values.byName(entry['mood'])
          ..energyLevel = entry['energyLevel']
          ..stressLevel = entry['stressLevel']
          ..sleepQuality = entry['sleepQuality']
          ..productivityLevel = entry['productivityLevel']
          ..note = entry['note']
          ..activities = List<String>.from(entry['activities'])
          ..journalEntryId = entry['journalEntryId']
          ..createdAt = DateTime.parse(entry['createdAt']);
        
        await _db.dailyMoods.put(mood);
      }
    });
  }
}
