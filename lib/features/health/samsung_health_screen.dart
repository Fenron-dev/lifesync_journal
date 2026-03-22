import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/samsung_health_service.dart' hide samsungHealthServiceProvider;
import '../../core/providers/app_provider.dart';

/// Samsung Health Screen - Integration mit Samsung Health via Health Connect
///
/// Features:
/// - Schritte, Herzfrequenz, Schlaf, Workouts
/// - Kalorien, Distanz, Sauerstoffsättigung
/// - Wochenübersicht mit Charts
/// - Journal-Integration
class SamsungHealthScreen extends ConsumerStatefulWidget {
  const SamsungHealthScreen({super.key});

  @override
  ConsumerState<SamsungHealthScreen> createState() => _SamsungHealthScreenState();
}

class _SamsungHealthScreenState extends ConsumerState<SamsungHealthScreen> {
  HealthConnectionStatus _connectionStatus = HealthConnectionStatus.disconnected;
  bool _isLoading = true;
  TodayHealthSummary? _todaySummary;
  HealthDataCache? _weeklyData;
  
  StreamSubscription<HealthConnectionStatus>? _statusSubscription;
  
  @override
  void initState() {
    super.initState();
    _initializeHealth();
  }
  
  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }
  
  Future<void> _initializeHealth() async {
    setState(() => _isLoading = true);
    
    final healthService = ref.read(samsungHealthServiceProvider);
    if (healthService == null) {
      setState(() {
        _connectionStatus = HealthConnectionStatus.notAvailable;
        _isLoading = false;
      });
      return;
    }
    
    // Listen to connection status
    _statusSubscription = healthService.healthStatus.listen((status) {
      setState(() => _connectionStatus = status);
    });
    
    // Connect
    final status = await healthService.connect();
    
    if (status == HealthConnectionStatus.connected) {
      await _loadHealthData();
    }
    
    setState(() => _isLoading = false);
  }
  
  Future<void> _loadHealthData() async {
    final healthService = ref.read(samsungHealthServiceProvider);
    if (healthService == null) return;
    
    // Load today's summary
    _todaySummary = await healthService.getTodaySummary();
    
    // Load weekly data
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    _weeklyData = await healthService.fetchHealthData(
      startDate: weekStart,
      endDate: now,
    );
    
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_connectionStatus != HealthConnectionStatus.connected)
              _buildConnectionRequired(context)
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadHealthData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildConnectionStatus(context),
                        const SizedBox(height: 20),
                        _buildHealthScoreCard(context),
                        const SizedBox(height: 20),
                        _buildMetricsGrid(context),
                        const SizedBox(height: 20),
                        _buildWeeklyChart(context),
                        const SizedBox(height: 20),
                        _buildSleepSection(context),
                        const SizedBox(height: 20),
                        _buildWorkoutsSection(context),
                        const SizedBox(height: 20),
                        _buildCreateEntryButton(context),
                        const SizedBox(height: 80), // Bottom nav space
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            'Samsung Health',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHealthData,
          ),
        ],
      ),
    );
  }
  
  Widget _buildConnectionRequired(BuildContext context) {
    String title;
    String subtitle;
    IconData icon;
    Color color;
    String buttonText;
    
    switch (_connectionStatus) {
      case HealthConnectionStatus.notAvailable:
        title = 'Health Connect nicht verfügbar';
        subtitle = 'Bitte installiere Health Connect aus dem Play Store.';
        icon = Icons.health_and_safety;
        color = Colors.orange;
        buttonText = 'Play Store öffnen';
        break;
      case HealthConnectionStatus.appNotInstalled:
        title = 'Samsung Health nicht gefunden';
        subtitle = 'Installiere Samsung Health, um deine Gesundheitsdaten zu synchronisieren.';
        icon = Icons.download;
        color = Colors.blue;
        buttonText = 'Samsung Health installieren';
        break;
      case HealthConnectionStatus.permissionDenied:
        title = 'Berechtigungen erforderlich';
        subtitle = 'Bitte erlaube LifeSync den Zugriff auf deine Gesundheitsdaten.';
        icon = Icons.lock_open;
        color = Colors.red;
        buttonText = 'Berechtigungen erteilen';
        break;
      case HealthConnectionStatus.error:
        title = 'Verbindungsfehler';
        subtitle = 'Es ist ein Fehler aufgetreten. Bitte versuche es erneut.';
        icon = Icons.error_outline;
        color = Colors.red;
        buttonText = 'Erneut versuchen';
        break;
      default:
        title = 'Verbinde...';
        subtitle = 'Bitte warte, während die Verbindung hergestellt wird.';
        icon = Icons.sync;
        color = Colors.blue;
        buttonText = 'Warten';
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: color,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _initializeHealth,
              icon: Icon(icon),
              label: Text(buttonText),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Später'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConnectionStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1428A0), const Color(0xFF0D47A1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Samsung Logo Placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'S',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Samsung Health',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Verbunden • Synchronisiert vor 5 Min',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHealthScoreCard(BuildContext context) {
    final score = _calculateHealthScore();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gesundheits-Score',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$score',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'von 100 Punkten',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
                Center(
                  child: Text(
                    score >= 80 ? '🔥' : score >= 60 ? '💪' : '📈',
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  int _calculateHealthScore() {
    if (_todaySummary == null) return 0;
    
    int score = 0;
    
    // Steps (max 25 points)
    if (_todaySummary!.steps != null) {
      final stepsProgress = _todaySummary!.steps!.total / _todaySummary!.steps!.goal;
      score += (stepsProgress.clamp(0.0, 1.0) * 25).round();
    }
    
    // Sleep (max 25 points)
    if (_todaySummary!.sleep != null) {
      final sleepHours = _todaySummary!.sleep!.totalHours;
      if (sleepHours >= 7 && sleepHours <= 9) {
        score += 25;
      } else if (sleepHours >= 6 && sleepHours < 7) {
        score += 20;
      } else if (sleepHours >= 5 && sleepHours < 6) {
        score += 15;
      }
    }
    
    // Heart Rate (max 25 points)
    if (_todaySummary!.heartRate != null) {
      final avg = _todaySummary!.heartRate!.average;
      if (avg >= 60 && avg <= 100) {
        score += 25;
      } else if (avg >= 50 && avg < 60) {
        score += 20;
      } else if (avg > 100 && avg <= 120) {
        score += 15;
      }
    }
    
    // Workouts (max 25 points)
    if (_todaySummary!.workouts != null) {
      final workoutMinutes = _todaySummary!.workouts!.totalDuration.inMinutes;
      if (workoutMinutes >= 30) {
        score += 25;
      } else if (workoutMinutes >= 20) {
        score += 20;
      } else if (workoutMinutes >= 10) {
        score += 15;
      }
    }
    
    return score;
  }
  
  Widget _buildMetricsGrid(BuildContext context) {
    final metrics = <Widget>[];
    
    // Steps
    if (_todaySummary?.steps != null) {
      metrics.add(_MetricCard(
        icon: Icons.directions_walk,
        label: 'Schritte',
        value: _todaySummary!.steps!.total,
        unit: '',
        goal: _todaySummary!.steps!.goal,
        color: Colors.green,
        progress: _todaySummary!.steps!.progress,
      ));
    }
    
    // Heart Rate
    if (_todaySummary?.heartRate != null) {
      metrics.add(_MetricCard(
        icon: Icons.favorite,
        label: 'Herzfrequenz',
        value: _todaySummary!.heartRate!.average.round(),
        unit: 'bpm',
        goal: 70,
        color: Colors.red,
        subtitle: '${_todaySummary!.heartRate!.min}-${_todaySummary!.heartRate!.max} bpm',
      ));
    }
    
    // Sleep
    if (_todaySummary?.sleep != null) {
      metrics.add(_MetricCard(
        icon: Icons.bedtime,
        label: 'Schlaf',
        value: _todaySummary!.sleep!.totalHours.toStringAsFixed(1),
        unit: 'h',
        goal: 8,
        color: Colors.purple,
        subtitle: 'Qualität: ${_todaySummary!.sleep!.quality}%',
      ));
    }
    
    // Calories
    if (_todaySummary?.calories != null) {
      metrics.add(_MetricCard(
        icon: Icons.local_fire_department,
        label: 'Kalorien',
        value: _todaySummary!.calories!.active,
        unit: 'kcal',
        goal: 500,
        color: Colors.orange,
        subtitle: 'Gesamt: ${_todaySummary!.calories!.total} kcal',
      ));
    }
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: metrics,
    );
  }
  
  Widget _buildWeeklyChart(BuildContext context) {
    if (_weeklyData == null || _weeklyData!.steps.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    final today = DateTime.now();
    final todayWeekday = today.weekday - 1;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wochenübersicht',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                'Schritte',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final isToday = index == todayWeekday;
                final stepsData = _weeklyData!.steps;
                final steps = index < stepsData.length ? stepsData[index].count : 0;
                final height = (steps / 12000).clamp(0.1, 1.0);
                
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: isToday 
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          height: height * 80,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weekdays[index],
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isToday 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSleepSection(BuildContext context) {
    if (_weeklyData == null || _weeklyData!.sleep.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final lastSleep = _weeklyData!.sleep.last;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bedtime, color: Colors.purple),
              const SizedBox(width: 8),
              Text(
                'Letzte Nacht',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Sleep phases
          Row(
            children: [
              Expanded(
                child: _buildSleepPhase(
                  'Tiefschlaf',
                  lastSleep.deepSleepHours.toStringAsFixed(1),
                  'h',
                  Colors.indigo,
                ),
              ),
              Expanded(
                child: _buildSleepPhase(
                  'Leichtschlaf',
                  lastSleep.lightSleepHours.toStringAsFixed(1),
                  'h',
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSleepPhase(
                  'REM',
                  lastSleep.remSleepHours.toStringAsFixed(1),
                  'h',
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Sleep timeline bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 16,
              child: Row(
                children: [
                  Expanded(
                    flex: (lastSleep.deepSleepHours * 10).round(),
                    child: Container(color: Colors.indigo),
                  ),
                  Expanded(
                    flex: (lastSleep.lightSleepHours * 10).round(),
                    child: Container(color: Colors.blue.shade300),
                  ),
                  Expanded(
                    flex: (lastSleep.remSleepHours * 10).round(),
                    child: Container(color: Colors.purple.shade300),
                  ),
                  Expanded(
                    flex: (lastSleep.awakeHours * 10).round(),
                    child: Container(color: Colors.orange.shade300),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${lastSleep.startTime.hour}:${lastSleep.startTime.minute.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                '${lastSleep.endTime.hour}:${lastSleep.endTime.minute.toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSleepPhase(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value$unit',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildWorkoutsSection(BuildContext context) {
    if (_weeklyData == null || _weeklyData!.workouts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.fitness_center,
                size: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'Keine Workouts diese Woche',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workouts diese Woche',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        ...(_weeklyData!.workouts.take(3).map((workout) => _WorkoutCard(workout: workout))),
      ],
    );
  }
  
  Widget _buildCreateEntryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () {
          _createHealthJournalEntry();
        },
        icon: const Icon(Icons.note_add),
        label: const Text('Gesundheitsdaten in Journal speichern'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
  
  Future<void> _createHealthJournalEntry() async {
    if (_weeklyData == null) return;
    
    final healthService = ref.read(samsungHealthServiceProvider);
    if (healthService == null) return;
    
    try {
      await healthService.createHealthJournalEntry(
        date: DateTime.now(),
        data: _weeklyData!,
        notes: '',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gesundheitsdaten gespeichert!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ============================================================================
// HELPER WIDGETS
// ============================================================================

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final dynamic value;
  final String unit;
  final num goal;
  final Color color;
  final double? progress;
  final String? subtitle;
  
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.goal,
    required this.color,
    this.progress,
    this.subtitle,
  });
  
  @override
  Widget build(BuildContext context) {
    final progressValue = progress ?? (value is num ? (value / goal).clamp(0.0, 1.0) : 0.0);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (progress != null && progress! >= 1.0)
                Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
          const Spacer(),
          Text(
            '$value$unit',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          else
            Column(
              children: [
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation(color),
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ziel: $goal$unit',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutData workout;
  
  const _WorkoutCard({required this.workout});
  
  String get _workoutEmoji {
    switch (workout.type.toLowerCase()) {
      case 'laufen':
      case 'running':
        return '🏃';
      case 'radfahren':
      case 'cycling':
      case 'biking':
        return '🚴';
      case 'schwimmen':
      case 'swimming':
        return '🏊';
      case 'yoga':
        return '🧘';
      case 'krafttraining':
      case 'strength':
        return '🏋️';
      case 'hiit':
        return '⚡';
      default:
        return '💪';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(_workoutEmoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(workout.type),
        subtitle: Row(
          children: [
            const Icon(Icons.timer, size: 12),
            Text(' ${workout.durationMinutes} Min'),
            if (workout.calories != null) ...[
              const SizedBox(width: 12),
              const Icon(Icons.local_fire_department, size: 12),
              Text(' ${workout.calories} kcal'),
            ],
          ],
        ),
        trailing: workout.distanceKm != null
            ? Text('${workout.distanceKm!.toStringAsFixed(1)} km')
            : null,
      ),
    );
  }
}
