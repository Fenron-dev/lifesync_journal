import 'dart:async';
import 'package:flutter/foundation.dart';

/// Health Data Service - Integration mit Apple Health & Google Fit
/// 
/// Unterstützte Daten:
/// - Schritte
/// - Schlaf (Dauer, Qualität)
/// - Herzfrequenz
/// - Aktive Energie
/// - Workouts
/// - Distanz
/// - Flights (Stockwerke)
/// - Wasser-Aufnahme
/// - Gewicht
/// 
/// Verwendet das `health` Package für iOS HealthKit und Android Google Fit
class HealthService {
  // Singleton
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();
  
  bool _isAuthorized = false;
  final StreamController<HealthDataEvent> _eventController = 
      StreamController<HealthDataEvent>.broadcast();
  
  /// Stream von Health-Daten-Updates
  Stream<HealthDataEvent> get eventStream => _eventController.stream;
  
  /// Ist Health-Zugriff autorisiert?
  bool get isAuthorized => _isAuthorized;
  
  /// Health-Berechtigungen anfordern
  Future<bool> requestAuthorization() async {
    try {
      // In real implementation:
      // final health = Health();
      // _isAuthorized = await health.requestAuthorization(
      //   _readTypes.map((t) => HealthDataType.values.firstWhere(
      //     (v) => v.name == t.name,
      //   )).toList(),
      //   permissions: [
      //     HealthDataAccess.READ,
      //   ],
      // );
      
      // Simulated for preview
      await Future.delayed(const Duration(milliseconds: 500));
      _isAuthorized = true;
      
      _eventController.add(HealthDataEvent(
        type: HealthEventType.authorizationChanged,
        data: {'authorized': true},
      ));
      
      return _isAuthorized;
    } catch (e) {
      debugPrint('Health authorization error: $e');
      return false;
    }
  }
  
  /// Schritte für einen Zeitraum abrufen
  Future<List<HealthDataPoint>> getSteps({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      // In real implementation:
      // final health = Health();
      // final data = await health.getHealthDataFromTypes(
      //   types: [HealthDataType.STEPS],
      //   startTime: start,
      //   endTime: end,
      // );
      // return data.map(_convertToHealthDataPoint).toList();
      
      // Simulated data for preview
      return _generateSimulatedSteps(start, end);
    } catch (e) {
      debugPrint('Error fetching steps: $e');
      return [];
    }
  }
  
  /// Schlaf-Daten für einen Zeitraum abrufen
  Future<List<SleepData>> getSleepData({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      // Simulated data
      return _generateSimulatedSleep(start, end);
    } catch (e) {
      debugPrint('Error fetching sleep: $e');
      return [];
    }
  }
  
  /// Herzfrequenz für einen Zeitraum abrufen
  Future<List<HealthDataPoint>> getHeartRate({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      // Simulated data
      return _generateSimulatedHeartRate(start, end);
    } catch (e) {
      debugPrint('Error fetching heart rate: $e');
      return [];
    }
  }
  
  /// Workouts für einen Zeitraum abrufen
  Future<List<WorkoutData>> getWorkouts({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      // Simulated data
      return _generateSimulatedWorkouts(start, end);
    } catch (e) {
      debugPrint('Error fetching workouts: $e');
      return [];
    }
  }
  
  /// Tägliche Gesundheitszusammenfassung abrufen
  Future<DailyHealthSummary> getDailySummary(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    
    final steps = await getSteps(start: start, end: end);
    final sleep = await getSleepData(start: start.subtract(const Duration(days: 1)), end: end);
    final heartRate = await getHeartRate(start: start, end: end);
    final workouts = await getWorkouts(start: start, end: end);
    
    final totalSteps = steps.fold<int>(0, (sum, p) => sum + (p.value as int));
    final totalSleep = sleep.fold<double>(0, (sum, s) => sum + s.duration.inMinutes) / 60;
    final avgHeartRate = heartRate.isNotEmpty
        ? heartRate.fold<double>(0, (sum, p) => sum + (p.value as double)) / heartRate.length
        : 0.0;
    
    return DailyHealthSummary(
      date: date,
      steps: totalSteps,
      sleepHours: totalSleep,
      avgHeartRate: avgHeartRate,
      activeEnergy: 450.0 + (date.day % 300), // Simulated
      distance: (totalSteps * 0.0008).roundToDouble(), // Approximate
      flights: 5 + (date.day % 10), // Simulated
      workouts: workouts,
      weight: 75.0 + ((date.day % 5) * 0.1), // Simulated
    );
  }
  
  /// Gesundheitsdaten der letzten 7 Tage abrufen
  Future<List<DailyHealthSummary>> getWeeklySummary() async {
    final now = DateTime.now();
    final summaries = <DailyHealthSummary>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      summaries.add(await getDailySummary(date));
    }
    
    return summaries;
  }
  
  // Simulated data generators for preview
  
  List<HealthDataPoint> _generateSimulatedSteps(DateTime start, DateTime end) {
    final points = <HealthDataPoint>[];
    var current = start;
    
    while (current.isBefore(end)) {
      final hour = current.hour;
      // More steps during daytime
      final baseSteps = hour >= 6 && hour <= 22 ? 300 : 50;
      final variance = (current.day + hour) % 200;
      
      points.add(HealthDataPoint(
        type: HealthDataType.steps,
        value: baseSteps + variance,
        unit: 'count',
        dateFrom: current,
        dateTo: current.add(const Duration(hours: 1)),
      ));
      
      current = current.add(const Duration(hours: 1));
    }
    
    return points;
  }
  
  List<SleepData> _generateSimulatedSleep(DateTime start, DateTime end) {
    final sleepData = <SleepData>[];
    var current = start;
    
    while (current.isBefore(end)) {
      if (current.hour >= 22 || current.hour < 6) {
        // Generate sleep session between 22:00-06:00
        final sleepStart = DateTime(current.year, current.month, current.day, 22, 30);
        final sleepEnd = sleepStart.add(Duration(hours: 7 + (current.day % 2), minutes: 15 + (current.minute % 30)));
        
        sleepData.add(SleepData(
          start: sleepStart,
          end: sleepEnd,
          duration: sleepEnd.difference(sleepStart),
          quality: 0.7 + ((current.day % 3) * 0.1),
          phases: [
            SleepPhase(type: SleepPhaseType.deep, start: sleepStart, duration: const Duration(minutes: 90)),
            SleepPhase(type: SleepPhaseType.light, start: sleepStart.add(const Duration(minutes: 90)), duration: const Duration(minutes: 120)),
            SleepPhase(type: SleepPhaseType.rem, start: sleepStart.add(const Duration(hours: 3, minutes: 30)), duration: const Duration(minutes: 60)),
            SleepPhase(type: SleepPhaseType.light, start: sleepStart.add(const Duration(hours: 4, minutes: 30)), duration: const Duration(minutes: 150)),
          ],
        ));
      }
      current = current.add(const Duration(days: 1));
    }
    
    return sleepData;
  }
  
  List<HealthDataPoint> _generateSimulatedHeartRate(DateTime start, DateTime end) {
    final points = <HealthDataPoint>[];
    var current = start;
    
    while (current.isBefore(end)) {
      // Resting heart rate between 55-75
      final baseRate = 60 + (current.minute % 15);
      
      points.add(HealthDataPoint(
        type: HealthDataType.heartRate,
        value: baseRate.toDouble(),
        unit: 'bpm',
        dateFrom: current,
        dateTo: current.add(const Duration(minutes: 5)),
      ));
      
      current = current.add(const Duration(minutes: 30));
    }
    
    return points;
  }
  
  List<WorkoutData> _generateSimulatedWorkouts(DateTime start, DateTime end) {
    final workouts = <WorkoutData>[];
    var current = start;
    
    while (current.isBefore(end)) {
      // Random workout every few days
      if (current.day % 3 == 0 && current.hour == 7) {
        final workoutTypes = [
          WorkoutType.running,
          WorkoutType.cycling,
          WorkoutType.yoga,
          WorkoutType.strength,
        ];
        
        workouts.add(WorkoutData(
          type: workoutTypes[current.day % workoutTypes.length],
          start: current,
          end: current.add(Duration(minutes: 30 + (current.day % 30))),
          calories: 200 + (current.day % 300),
          distance: current.day % 2 == 0 ? 5.0 + (current.day % 3) : null,
          heartRateAvg: 130 + (current.day % 20),
          heartRateMax: 160 + (current.day % 15),
        ));
      }
      current = current.add(const Duration(days: 1));
    }
    
    return workouts;
  }
}

// ============================================================================
// DATA MODELS
// ============================================================================

/// Health Data Types
enum HealthDataType {
  steps,
  sleepDuration,
  heartRate,
  activeEnergyBurned,
  distanceWalkingRunning,
  flightsClimbed,
  water,
  weight,
  bodyMassIndex,
  restingHeartRate,
  walkingHeartRate,
  heartRateVariabilitySDNN,
  oxygenSaturation,
  bodyTemperature,
  bloodPressureSystolic,
  bloodPressureDiastolic,
  respiratoryRate,
}

/// Health Event Types
enum HealthEventType {
  authorizationChanged,
  dataUpdated,
  workoutDetected,
  sleepDetected,
}

/// Health Data Event
class HealthDataEvent {
  final HealthEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  HealthDataEvent({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Health Data Point
class HealthDataPoint {
  final HealthDataType type;
  final dynamic value;
  final String unit;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String? source;
  
  HealthDataPoint({
    required this.type,
    required this.value,
    required this.unit,
    required this.dateFrom,
    required this.dateTo,
    this.source,
  });
}

/// Sleep Data
class SleepData {
  final DateTime start;
  final DateTime end;
  final Duration duration;
  final double quality; // 0.0 - 1.0
  final List<SleepPhase> phases;
  
  SleepData({
    required this.start,
    required this.end,
    required this.duration,
    required this.quality,
    this.phases = const [],
  });
}

/// Sleep Phase
class SleepPhase {
  final SleepPhaseType type;
  final DateTime start;
  final Duration duration;
  
  SleepPhase({
    required this.type,
    required this.start,
    required this.duration,
  });
}

/// Sleep Phase Type
enum SleepPhaseType {
  deep,
  light,
  rem,
  awake,
}

/// Workout Type
enum WorkoutType {
  walking,
  running,
  cycling,
  swimming,
  yoga,
  strength,
  hiit,
  hiking,
  dancing,
  crossTraining,
}

/// Workout Data
class WorkoutData {
  final WorkoutType type;
  final DateTime start;
  final DateTime end;
  final int calories;
  final double? distance;
  final int? heartRateAvg;
  final int? heartRateMax;
  final String? source;
  
  WorkoutData({
    required this.type,
    required this.start,
    required this.end,
    required this.calories,
    this.distance,
    this.heartRateAvg,
    this.heartRateMax,
    this.source,
  });
  
  Duration get duration => end.difference(start);
  
  String get typeName {
    switch (type) {
      case WorkoutType.walking: return 'Gehen';
      case WorkoutType.running: return 'Laufen';
      case WorkoutType.cycling: return 'Radfahren';
      case WorkoutType.swimming: return 'Schwimmen';
      case WorkoutType.yoga: return 'Yoga';
      case WorkoutType.strength: return 'Krafttraining';
      case WorkoutType.hiit: return 'HIIT';
      case WorkoutType.hiking: return 'Wandern';
      case WorkoutType.dancing: return 'Tanzen';
      case WorkoutType.crossTraining: return 'Cross-Training';
    }
  }
  
  String get emoji {
    switch (type) {
      case WorkoutType.walking: return '🚶';
      case WorkoutType.running: return '🏃';
      case WorkoutType.cycling: return '🚴';
      case WorkoutType.swimming: return '🏊';
      case WorkoutType.yoga: return '🧘';
      case WorkoutType.strength: return '💪';
      case WorkoutType.hiit: return '🔥';
      case WorkoutType.hiking: return '🥾';
      case WorkoutType.dancing: return '💃';
      case WorkoutType.crossTraining: return '⚡';
    }
  }
}

/// Daily Health Summary
class DailyHealthSummary {
  final DateTime date;
  final int steps;
  final double sleepHours;
  final double avgHeartRate;
  final double activeEnergy;
  final double distance;
  final int flights;
  final List<WorkoutData> workouts;
  final double weight;
  
  DailyHealthSummary({
    required this.date,
    required this.steps,
    required this.sleepHours,
    required this.avgHeartRate,
    required this.activeEnergy,
    required this.distance,
    required this.flights,
    required this.workouts,
    required this.weight,
  });
  
  /// Steps goal progress (default: 10,000 steps)
  double get stepsProgress => (steps / 10000).clamp(0.0, 1.0);
  
  /// Sleep goal progress (default: 8 hours)
  double get sleepProgress => (sleepHours / 8).clamp(0.0, 1.0);
  
  /// Active energy goal progress (default: 500 kcal)
  double get energyProgress => (activeEnergy / 500).clamp(0.0, 1.0);
  
  /// Overall health score (0-100)
  int get healthScore {
    final stepsScore = stepsProgress * 30;
    final sleepScore = sleepProgress * 30;
    final energyScore = energyProgress * 20;
    final workoutScore = workouts.isNotEmpty ? 20 : 0;
    
    return (stepsScore + sleepScore + energyScore + workoutScore).round();
  }
}
