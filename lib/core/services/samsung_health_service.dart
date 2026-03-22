import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/entry.dart';
import 'storage_service.dart';

/// Samsung Health Service - Integration mit Samsung Health & Health Connect
/// 
/// Unterstützt:
/// - Samsung Health (via Health Connect API)
/// - Schritte, Schlaf, Herzfrequenz, Workouts
/// - Automatische Synchronisation
/// - Daten-Export in Journal-Einträge
/// 
/// Hinweis: Samsung Health auf Android nutzt Health Connect API
/// für Daten-Zugriff durch Dritt-Apps.
class SamsungHealthService {
  final StorageService _storage;
  
  // Health Connect API Konstanten
  static const String healthConnectPackage = 'com.google.android.apps.healthdata';
  static const String samsungHealthPackage = 'com.sec.android.app.shealth';
  
  // Berechtigungen
  static const List<String> requiredPermissions = [
    'androidx.health.permission.Steps',
    'androidx.health.permission.HeartRate',
    'androidx.health.permission.Sleep',
    'androidx.health.permission.Exercise',
    'androidx.health.permission.Distance',
    'androidx.health.permission.Calories',
    'androidx.health.permission.OxygenSaturation',
    'androidx.health.permission.RestingHeartRate',
    'androidx.health.permission.ActiveCaloriesBurned',
    'androidx.health.permission.TotalCaloriesBurned',
  ];
  
  // Status
  final _healthStatusController = StreamController<HealthConnectionStatus>.broadcast();
  final _healthDataController = StreamController<HealthDataUpdate>.broadcast();
  
  Stream<HealthConnectionStatus> get healthStatus => _healthStatusController.stream;
  Stream<HealthDataUpdate> get healthData => _healthDataController.stream;
  
  // Gecachte Daten
  HealthDataCache? _cachedData;

  // Verbindung
  bool _isConnected = false;
  
  SamsungHealthService(this._storage);
  
  // ==================== VERBINDUNG ====================
  
  /// Prüfe ob Samsung Health / Health Connect verfügbar ist
  Future<bool> isHealthConnectAvailable() async {
    if (!Platform.isAndroid) return false;
    
    // In echter Implementierung würde hier die Health Connect API abgefragt
    // final status = await HealthConnect.getClientStatus();
    return true; // Für Demo
  }
  
  /// Prüfe ob Samsung Health installiert ist
  Future<bool> isSamsungHealthInstalled() async {
    if (!Platform.isAndroid) return false;
    
    // In echter Implementierung:
    // final packageManager = await PackageManager.getInstalledPackages();
    // return packageManager.any((p) => p.packageName == samsungHealthPackage);
    return true; // Für Demo
  }
  
  /// Verbinde mit Health Connect / Samsung Health
  Future<HealthConnectionStatus> connect() async {
    _healthStatusController.add(HealthConnectionStatus.connecting);
    
    try {
      // 1. Prüfe Verfügbarkeit
      final available = await isHealthConnectAvailable();
      if (!available) {
        _healthStatusController.add(HealthConnectionStatus.notAvailable);
        return HealthConnectionStatus.notAvailable;
      }
      
      // 2. Prüfe Samsung Health Installation
      final samsungInstalled = await isSamsungHealthInstalled();
      if (!samsungInstalled) {
        _healthStatusController.add(HealthConnectionStatus.appNotInstalled);
        return HealthConnectionStatus.appNotInstalled;
      }
      
      // 3. Request Permissions
      final permissionsGranted = await requestPermissions();
      if (!permissionsGranted) {
        _healthStatusController.add(HealthConnectionStatus.permissionDenied);
        return HealthConnectionStatus.permissionDenied;
      }
      
      _isConnected = true;
      _healthStatusController.add(HealthConnectionStatus.connected);
      return HealthConnectionStatus.connected;
      
    } catch (e) {
      _healthStatusController.add(HealthConnectionStatus.error);
      return HealthConnectionStatus.error;
    }
  }
  
  /// Request Permissions für Health Data
  Future<bool> requestPermissions() async {
    // In echter Implementierung mit Health Connect API:
    // final result = await HealthConnect.requestPermissions(requiredPermissions);
    // return result.granted.containsAll(requiredPermissions);
    
    return true; // Für Demo
  }
  
  /// Trenne Verbindung
  Future<void> disconnect() async {
    _isConnected = false;
    _healthStatusController.add(HealthConnectionStatus.disconnected);
  }
  
  // ==================== DATEN ABFRAGEN ====================
  
  /// Lade alle Gesundheitsdaten für einen Zeitraum
  Future<HealthDataCache> fetchHealthData({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isConnected) {
      throw Exception('Nicht mit Health Connect verbunden');
    }
    
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
    final end = endDate ?? DateTime.now();
    
    // Parallele Abfrage aller Daten
    final results = await Future.wait([
      fetchSteps(start, end),
      fetchHeartRate(start, end),
      fetchSleep(start, end),
      fetchWorkouts(start, end),
      fetchCalories(start, end),
      fetchDistance(start, end),
      fetchOxygenSaturation(start, end),
    ]);
    
    _cachedData = HealthDataCache(
      steps: results[0] as List<StepsData>,
      heartRate: results[1] as List<HeartRateData>,
      sleep: results[2] as List<SleepData>,
      workouts: results[3] as List<WorkoutData>,
      calories: results[4] as List<CaloriesData>,
      distance: results[5] as List<DistanceData>,
      oxygenSaturation: results[6] as List<OxygenSaturationData>,
      fetchedAt: DateTime.now(),
    );
    
    // Benachrichtige über neue Daten
    _healthDataController.add(HealthDataUpdate(
      type: HealthDataType.all,
      timestamp: DateTime.now(),
      data: _cachedData!,
    ));
    
    return _cachedData!;
  }
  
  /// Lade Schritte
  Future<List<StepsData>> fetchSteps(DateTime start, DateTime end) async {
    // In echter Implementierung:
    // final response = await HealthConnect.readRecords(
    //   type: RecordType.Steps,
    //   timeRangeFilter: TimeRangeFilter.between(start, end),
    // );
    
    // Demo-Daten generieren
    return _generateDemoSteps(start, end);
  }
  
  /// Lade Herzfrequenz
  Future<List<HeartRateData>> fetchHeartRate(DateTime start, DateTime end) async {
    return _generateDemoHeartRate(start, end);
  }
  
  /// Lade Schlaf-Daten
  Future<List<SleepData>> fetchSleep(DateTime start, DateTime end) async {
    return _generateDemoSleep(start, end);
  }
  
  /// Lade Workouts
  Future<List<WorkoutData>> fetchWorkouts(DateTime start, DateTime end) async {
    return _generateDemoWorkouts(start, end);
  }
  
  /// Lade Kalorien
  Future<List<CaloriesData>> fetchCalories(DateTime start, DateTime end) async {
    return _generateDemoCalories(start, end);
  }
  
  /// Lade Distanz
  Future<List<DistanceData>> fetchDistance(DateTime start, DateTime end) async {
    return _generateDemoDistance(start, end);
  }
  
  /// Lade Sauerstoffsättigung
  Future<List<OxygenSaturationData>> fetchOxygenSaturation(DateTime start, DateTime end) async {
    return _generateDemoOxygen(start, end);
  }
  
  // ==================== HEUTE DATEN ====================
  
  /// Hole heutige Gesundheitszusammenfassung
  Future<TodayHealthSummary> getTodaySummary() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final data = await fetchHealthData(
      startDate: startOfDay,
      endDate: today,
    );
    
    return TodayHealthSummary(
      date: today,
      steps: data.steps.isEmpty 
          ? null 
          : StepsSummary(
              total: data.steps.fold(0, (sum, s) => sum + s.count),
              goal: 10000,
              data: data.steps,
            ),
      heartRate: data.heartRate.isEmpty
          ? null
          : HeartRateSummary(
              average: data.heartRate.map((h) => h.bpm).reduce((a, b) => a + b) / data.heartRate.length,
              min: data.heartRate.map((h) => h.bpm).reduce((a, b) => a < b ? a : b),
              max: data.heartRate.map((h) => h.bpm).reduce((a, b) => a > b ? a : b),
              data: data.heartRate,
            ),
      sleep: data.sleep.isEmpty
          ? null
          : SleepSummary(
              totalHours: data.sleep.fold(0.0, (sum, s) => sum + s.durationHours),
              quality: _calculateSleepQuality(data.sleep),
              data: data.sleep,
            ),
      calories: data.calories.isEmpty
          ? null
          : CaloriesSummary(
              total: data.calories.fold(0, (sum, c) => sum + c.calories),
              active: data.calories.where((c) => c.isActive).fold(0, (sum, c) => sum + c.calories),
              data: data.calories,
            ),
      workouts: data.workouts.isEmpty
          ? null
          : WorkoutsSummary(
              count: data.workouts.length,
              totalDuration: Duration(
                minutes: data.workouts.fold(0, (sum, w) => sum + w.durationMinutes),
              ),
              totalCalories: data.workouts.fold(0, (sum, w) => sum + (w.calories ?? 0)),
              data: data.workouts,
            ),
    );
  }
  
  // ==================== JOURNAL INTEGRATION ====================
  
  /// Erstelle Journal-Eintrag aus Gesundheitsdaten
  Future<Entry> createHealthJournalEntry({
    required DateTime date,
    required HealthDataCache data,
    String? notes,
  }) async {
    final entry = Entry()
      ..entryType = 'health'
      ..title = 'Gesundheits-Check ${_formatDate(date)}'
      ..entryDate = date
      ..content = _generateHealthContent(data, notes);
    
    // Füge Gesundheits-Metadaten hinzu
    if (data.steps.isNotEmpty) {
      // entry.healthData = HealthEntryData(steps: data.steps.fold(0, (sum, s) => sum + s.count));
    }
    
    return await _storage.saveEntry(entry);
  }
  
  /// Generiere Markdown-Content aus Gesundheitsdaten
  String _generateHealthContent(HealthDataCache data, String? notes) {
    final buffer = StringBuffer();
    
    buffer.writeln('# Gesundheits-Übersicht');
    buffer.writeln();
    
    // Schritte
    if (data.steps.isNotEmpty) {
      final total = data.steps.fold(0, (sum, s) => sum + s.count);
      buffer.writeln('## 👟 Schritte');
      buffer.writeln('- **Total:** $total Schritte');
      buffer.writeln('- **Ziel:** 10.000 Schritte');
      buffer.writeln('- **Fortschritt:** ${(total / 10000 * 100).toStringAsFixed(1)}%');
      buffer.writeln();
    }
    
    // Herzfrequenz
    if (data.heartRate.isNotEmpty) {
      final avg = data.heartRate.map((h) => h.bpm).reduce((a, b) => a + b) / data.heartRate.length;
      final min = data.heartRate.map((h) => h.bpm).reduce((a, b) => a < b ? a : b);
      final max = data.heartRate.map((h) => h.bpm).reduce((a, b) => a > b ? a : b);
      buffer.writeln('## ❤️ Herzfrequenz');
      buffer.writeln('- **Durchschnitt:** ${avg.toStringAsFixed(0)} BPM');
      buffer.writeln('- **Minimum:** $min BPM');
      buffer.writeln('- **Maximum:** $max BPM');
      buffer.writeln();
    }
    
    // Schlaf
    if (data.sleep.isNotEmpty) {
      final totalHours = data.sleep.fold(0.0, (sum, s) => sum + s.durationHours);
      buffer.writeln('## 😴 Schlaf');
      buffer.writeln('- **Dauer:** ${totalHours.toStringAsFixed(1)} Stunden');
      buffer.writeln('- **Qualität:** ${_calculateSleepQuality(data.sleep)}%');
      buffer.writeln();
    }
    
    // Workouts
    if (data.workouts.isNotEmpty) {
      buffer.writeln('## 🏃 Workouts');
      for (final workout in data.workouts) {
        buffer.writeln('- **${workout.type}:** ${workout.durationMinutes} Min.');
        if (workout.calories != null) {
          buffer.writeln('  - Kalorien: ${workout.calories}');
        }
      }
      buffer.writeln();
    }
    
    // Notizen
    if (notes != null && notes.isNotEmpty) {
      buffer.writeln('## 📝 Notizen');
      buffer.writeln(notes);
    }
    
    return buffer.toString();
  }
  
  // ==================== AUTOMATISCHE SYNC ====================
  
  /// Starte automatische Synchronisation
  Future<void> startAutoSync({Duration interval = const Duration(hours: 1)}) async {
    // Speichere Sync-Interval
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('health_auto_sync', true);
    await prefs.setInt('health_sync_interval', interval.inMinutes);
    
    // In echter Implementierung würde hier ein Background Worker gestartet
    // der periodisch die Daten synchronisiert
  }
  
  /// Stoppe automatische Synchronisation
  Future<void> stopAutoSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('health_auto_sync', false);
  }
  
  // ==================== HELPER METHODS ====================
  
  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
  
  int _calculateSleepQuality(List<SleepData> sleepData) {
    if (sleepData.isEmpty) return 0;
    
    // Einfache Qualitätsberechnung basierend auf Schlafdauer
    final totalHours = sleepData.fold(0.0, (sum, s) => sum + s.durationHours);
    
    if (totalHours >= 7 && totalHours <= 9) return 100;
    if (totalHours >= 6 && totalHours < 7) return 85;
    if (totalHours >= 5 && totalHours < 6) return 70;
    if (totalHours > 9) return 75; // Zu viel Schlaf
    return 50; // Zu wenig Schlaf
  }
  
  // ==================== DEMO DATA GENERATORS ====================
  
  List<StepsData> _generateDemoSteps(DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    return List.generate(days, (i) {
      final date = start.add(Duration(days: i));
      return StepsData(
        timestamp: date,
        count: 5000 + (date.day * 345) % 8000, // 5000-13000 Schritte
        source: 'Samsung Health',
      );
    });
  }
  
  List<HeartRateData> _generateDemoHeartRate(DateTime start, DateTime end) {
    final data = <HeartRateData>[];
    final hours = end.difference(start).inHours;
    
    for (var i = 0; i < hours; i += 4) {
      final time = start.add(Duration(hours: i));
      data.add(HeartRateData(
        timestamp: time,
        bpm: 60 + (time.hour * 7) % 40, // 60-100 BPM
        source: 'Samsung Health',
      ));
    }
    
    return data;
  }
  
  List<SleepData> _generateDemoSleep(DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    return List.generate(days, (i) {
      final date = start.add(Duration(days: i));
      final sleepStart = DateTime(date.year, date.month, date.day, 23, 0);
      final duration = 6.0 + (date.day % 4) * 0.5; // 6-8 Stunden
      
      return SleepData(
        startTime: sleepStart,
        endTime: sleepStart.add(Duration(hours: duration.toInt(), minutes: ((duration % 1) * 60).toInt())),
        durationHours: duration,
        deepSleepHours: duration * 0.2,
        lightSleepHours: duration * 0.5,
        remSleepHours: duration * 0.25,
        awakeHours: duration * 0.05,
        quality: 70 + (date.day % 30),
        source: 'Samsung Health',
      );
    });
  }
  
  List<WorkoutData> _generateDemoWorkouts(DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    final workouts = <WorkoutData>[];
    
    final workoutTypes = ['Laufen', 'Radfahren', 'Schwimmen', 'Yoga', 'Krafttraining', 'HIIT'];
    
    for (var i = 0; i < days; i++) {
      final date = start.add(Duration(days: i));
      
      // 40% Chance für Workout pro Tag
      if (date.day % 3 == 0) {
        final type = workoutTypes[date.day % workoutTypes.length];
        workouts.add(WorkoutData(
          timestamp: DateTime(date.year, date.month, date.day, 7, 0),
          type: type,
          durationMinutes: 30 + (date.day % 60),
          calories: 200 + (date.day * 17) % 400,
          distanceKm: type == 'Laufen' ? 3.0 + (date.day % 10) : null,
          heartRateAvg: 120 + (date.day % 40),
          source: 'Samsung Health',
        ));
      }
    }
    
    return workouts;
  }
  
  List<CaloriesData> _generateDemoCalories(DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    return List.generate(days, (i) {
      final date = start.add(Duration(days: i));
      return CaloriesData(
        timestamp: date,
        calories: 1800 + (date.day * 47) % 800,
        isActive: false,
        source: 'Samsung Health',
      );
    });
  }
  
  List<DistanceData> _generateDemoDistance(DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    return List.generate(days, (i) {
      final date = start.add(Duration(days: i));
      return DistanceData(
        timestamp: date,
        distanceMeters: 3000.0 + (date.day * 876) % 10000,
        source: 'Samsung Health',
      );
    });
  }
  
  List<OxygenSaturationData> _generateDemoOxygen(DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    return List.generate(days, (i) {
      final date = start.add(Duration(days: i));
      return OxygenSaturationData(
        timestamp: DateTime(date.year, date.month, date.day, 8, 0),
        percentage: 95.0 + (date.day % 5),
        source: 'Samsung Health',
      );
    });
  }
  
  /// Dispose
  void dispose() {
    _healthStatusController.close();
    _healthDataController.close();
  }
}

// ==================== DATA MODELS ====================

/// Health Connection Status
enum HealthConnectionStatus {
  disconnected,
  connecting,
  connected,
  notAvailable,
  appNotInstalled,
  permissionDenied,
  error,
}

/// Health Data Types
enum HealthDataType {
  steps,
  heartRate,
  sleep,
  workouts,
  calories,
  distance,
  oxygenSaturation,
  all,
}

/// Health Data Update Event
class HealthDataUpdate {
  final HealthDataType type;
  final DateTime timestamp;
  final HealthDataCache data;
  
  HealthDataUpdate({
    required this.type,
    required this.timestamp,
    required this.data,
  });
}

/// Health Data Cache
class HealthDataCache {
  final List<StepsData> steps;
  final List<HeartRateData> heartRate;
  final List<SleepData> sleep;
  final List<WorkoutData> workouts;
  final List<CaloriesData> calories;
  final List<DistanceData> distance;
  final List<OxygenSaturationData> oxygenSaturation;
  final DateTime fetchedAt;
  
  HealthDataCache({
    required this.steps,
    required this.heartRate,
    required this.sleep,
    required this.workouts,
    required this.calories,
    required this.distance,
    required this.oxygenSaturation,
    required this.fetchedAt,
  });
}

/// Steps Data
class StepsData {
  final DateTime timestamp;
  final int count;
  final String source;
  
  StepsData({
    required this.timestamp,
    required this.count,
    required this.source,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'count': count,
    'source': source,
  };
}

/// Heart Rate Data
class HeartRateData {
  final DateTime timestamp;
  final int bpm;
  final String source;
  
  HeartRateData({
    required this.timestamp,
    required this.bpm,
    required this.source,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'bpm': bpm,
    'source': source,
  };
}

/// Sleep Data
class SleepData {
  final DateTime startTime;
  final DateTime endTime;
  final double durationHours;
  final double deepSleepHours;
  final double lightSleepHours;
  final double remSleepHours;
  final double awakeHours;
  final int quality;
  final String source;
  
  SleepData({
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.deepSleepHours,
    required this.lightSleepHours,
    required this.remSleepHours,
    required this.awakeHours,
    required this.quality,
    required this.source,
  });
  
  Map<String, dynamic> toJson() => {
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'durationHours': durationHours,
    'deepSleepHours': deepSleepHours,
    'lightSleepHours': lightSleepHours,
    'remSleepHours': remSleepHours,
    'awakeHours': awakeHours,
    'quality': quality,
    'source': source,
  };
}

/// Workout Data
class WorkoutData {
  final DateTime timestamp;
  final String type;
  final int durationMinutes;
  final int? calories;
  final double? distanceKm;
  final int? heartRateAvg;
  final String source;
  
  WorkoutData({
    required this.timestamp,
    required this.type,
    required this.durationMinutes,
    this.calories,
    this.distanceKm,
    this.heartRateAvg,
    required this.source,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'type': type,
    'durationMinutes': durationMinutes,
    'calories': calories,
    'distanceKm': distanceKm,
    'heartRateAvg': heartRateAvg,
    'source': source,
  };
}

/// Calories Data
class CaloriesData {
  final DateTime timestamp;
  final int calories;
  final bool isActive;
  final String source;
  
  CaloriesData({
    required this.timestamp,
    required this.calories,
    required this.isActive,
    required this.source,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'calories': calories,
    'isActive': isActive,
    'source': source,
  };
}

/// Distance Data
class DistanceData {
  final DateTime timestamp;
  final double distanceMeters;
  final String source;
  
  DistanceData({
    required this.timestamp,
    required this.distanceMeters,
    required this.source,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'distanceMeters': distanceMeters,
    'source': source,
  };
}

/// Oxygen Saturation Data
class OxygenSaturationData {
  final DateTime timestamp;
  final double percentage;
  final String source;
  
  OxygenSaturationData({
    required this.timestamp,
    required this.percentage,
    required this.source,
  });
  
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'percentage': percentage,
    'source': source,
  };
}

// ==================== SUMMARY MODELS ====================

/// Today Health Summary
class TodayHealthSummary {
  final DateTime date;
  final StepsSummary? steps;
  final HeartRateSummary? heartRate;
  final SleepSummary? sleep;
  final CaloriesSummary? calories;
  final WorkoutsSummary? workouts;
  
  TodayHealthSummary({
    required this.date,
    this.steps,
    this.heartRate,
    this.sleep,
    this.calories,
    this.workouts,
  });
}

class StepsSummary {
  final int total;
  final int goal;
  final List<StepsData> data;
  
  StepsSummary({
    required this.total,
    required this.goal,
    required this.data,
  });
  
  double get progress => total / goal;
  bool get goalReached => total >= goal;
}

class HeartRateSummary {
  final double average;
  final int min;
  final int max;
  final List<HeartRateData> data;
  
  HeartRateSummary({
    required this.average,
    required this.min,
    required this.max,
    required this.data,
  });
}

class SleepSummary {
  final double totalHours;
  final int quality;
  final List<SleepData> data;
  
  SleepSummary({
    required this.totalHours,
    required this.quality,
    required this.data,
  });
}

class CaloriesSummary {
  final int total;
  final int active;
  final List<CaloriesData> data;
  
  CaloriesSummary({
    required this.total,
    required this.active,
    required this.data,
  });
}

class WorkoutsSummary {
  final int count;
  final Duration totalDuration;
  final int totalCalories;
  final List<WorkoutData> data;
  
  WorkoutsSummary({
    required this.count,
    required this.totalDuration,
    required this.totalCalories,
    required this.data,
  });
}

/// Riverpod Provider
final samsungHealthServiceProvider = StateProvider<SamsungHealthService?>((ref) {
  return null; // Wird in main.dart initialisiert
});
