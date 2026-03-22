import 'package:isar/isar.dart';

part 'habit.g.dart';

/// Habit-Kategorie für visuelle Gruppierung
enum HabitCategory {
  health,      // Gesundheit
  fitness,     // Sport
  mindfulness, // Achtsamkeit
  productivity,// Produktivität
  learning,    // Lernen
  social,      // Sozial
  custom,      // Eigenes
}

/// Häufigkeit des Habits
enum HabitFrequency {
  daily,       // Täglich
  weekly,      // Wöchentlich (bestimmte Tage)
  specific,    // Bestimmte Tage im Monat
}

@Collection()
class Habit {
  Id id = Isar.autoIncrement;

  /// Name des Habits
  @Index()
  late String name;

  /// Beschreibung/Notizen
  String? description;

  /// Kategorie für Gruppierung
  @Enumerated(EnumType.name)
  late HabitCategory category;

  /// Icon-Name (Material Icons)
  late String iconName;

  /// Farbe als Hex-String
  late String colorHex;

  /// Häufigkeit
  @Enumerated(EnumType.name)
  late HabitFrequency frequency;

  /// Ziel pro Tag/Woche (z.B. 8 Gläser Wasser)
  int targetCount = 1;

  /// Wochentage (1=Montag, 7=Sonntag) für weekly frequency
  List<int> activeDays = [1, 2, 3, 4, 5, 6, 7];

  /// Erstellungsdatum
  late DateTime createdAt;

  /// Ist das Habit aktiv?
  bool isActive = true;

  /// Sortierreihenfolge
  int sortOrder = 0;

  /// Verknüpfte Journal-Tags (automatische Verknüpfung)
  List<String> linkedTags = [];
}

/// Einzelne Habit-Erfüllung
@Collection()
class HabitCompletion {
  Id id = Isar.autoIncrement;

  /// Referenz zum Habit
  @Index()
  late int habitId;

  /// Datum der Erfüllung (ohne Zeit)
  late DateTime date;

  /// Anzahl der Erfüllungen (z.B. 5 Gläser Wasser)
  int count = 1;

  /// Optionale Notiz
  String? note;

  /// Verknüpfter Journal-Eintrag
  @Index()
  int? journalEntryId;

  /// Erstellungszeitstempel
  late DateTime createdAt;
}

/// Habit-Statistiken für Dashboard
class HabitStats {
  final int habitId;
  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final double completionRate;
  final Map<DateTime, int> last30Days;

  HabitStats({
    required this.habitId,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletions,
    required this.completionRate,
    required this.last30Days,
  });
}
