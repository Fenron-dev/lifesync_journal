import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'daily_mood.g.dart';

/// Stimmungswerte (1-5)
enum MoodLevel {
  veryBad,    // 😢 1
  bad,        // 😔 2
  neutral,    // 😐 3
  good,       // 😊 4
  veryGood,   // 😃 5
}

extension MoodLevelExtension on MoodLevel {
  /// Creates a MoodLevel from a 1-5 integer value.
  static MoodLevel fromValue(int value) {
    switch (value) {
      case 1: return MoodLevel.veryBad;
      case 2: return MoodLevel.bad;
      case 3: return MoodLevel.neutral;
      case 4: return MoodLevel.good;
      case 5: return MoodLevel.veryGood;
      default: return MoodLevel.neutral;
    }
  }

  Color get color {
    switch (this) {
      case MoodLevel.veryBad:  return Colors.red;
      case MoodLevel.bad:      return Colors.orange;
      case MoodLevel.neutral:  return Colors.amber;
      case MoodLevel.good:     return Colors.lightGreen;
      case MoodLevel.veryGood: return Colors.green;
    }
  }

  String get emoji {
    switch (this) {
      case MoodLevel.veryBad:  return '😢';
      case MoodLevel.bad:      return '😔';
      case MoodLevel.neutral:  return '😐';
      case MoodLevel.good:     return '😊';
      case MoodLevel.veryGood: return '😃';
    }
  }
}

/// Tagesform-Eintrag
@Collection()
class DailyMood {
  Id id = Isar.autoIncrement;

  /// Datum (ohne Zeit)
  @Index(unique: true)
  late DateTime date;

  /// Stimmung (1-5)
  @Enumerated(EnumType.name)
  late MoodLevel mood;

  /// Energielevel (1-5)
  int? energyLevel;

  /// Stresslevel (1-5, 1 = entspannt, 5 = sehr gestresst)
  int? stressLevel;

  /// Schlafqualität (1-5)
  int? sleepQuality;

  /// Produktivität (1-5)
  int? productivityLevel;

  /// Kurze Notiz
  String? note;

  /// Verknüpfte Tags/Aktivitäten
  List<String> activities = [];

  /// Verknüpfter Journal-Eintrag
  @Index()
  int? journalEntryId;

  /// Erstellungszeit
  late DateTime createdAt;
}

/// Mood-Statistiken für einen Zeitraum
class MoodStats {
  final double averageMood;
  final double averageEnergy;
  final double averageStress;
  final double averageSleep;
  final Map<MoodLevel, int> moodDistribution;
  final List<DailyMood> entries;
  final Map<String, int> topActivities;

  MoodStats({
    required this.averageMood,
    required this.averageEnergy,
    required this.averageStress,
    required this.averageSleep,
    required this.moodDistribution,
    required this.entries,
    required this.topActivities,
  });

  /// Trend im Vergleich zur Vorwoche
  double get moodTrend {
    if (entries.length < 14) return 0;
    
    final recentWeek = entries.take(7).toList();
    final previousWeek = entries.skip(7).take(7).toList();
    
    final recentAvg = _avgMood(recentWeek);
    final previousAvg = _avgMood(previousWeek);
    
    return recentAvg - previousAvg;
  }

  double _avgMood(List<DailyMood> moods) {
    if (moods.isEmpty) return 0;
    return moods.map((m) => m.mood.index + 1).reduce((a, b) => a + b) / moods.length;
  }
}

/// Insight-Ergebnis
class MoodInsight {
  final String title;
  final String description;
  final InsightType type;
  final double relevance;

  MoodInsight({
    required this.title,
    required this.description,
    required this.type,
    this.relevance = 1.0,
  });
}

enum InsightType {
  positive,    // Positive Korrelation
  negative,    // Negative Korrelation
  trend,       // Trend-Erkennung
  suggestion,  // Handlungsempfehlung
  pattern,     // Muster-Erkennung
}
