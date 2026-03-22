import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/services/health_service.dart';

/// Health Screen - Integration mit Apple Health & Google Fit
///
/// Zeigt:
/// - Gesundheits-Score
/// - Schritte, Schlaf, Herzfrequenz
/// - Aktive Energie, Distanz
/// - Workouts
/// - Wochenübersicht mit Charts
class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  final HealthService _healthService = HealthService();
  
  bool _isAuthorized = false;
  bool _isLoading = true;
  DailyHealthSummary? _todaySummary;
  List<DailyHealthSummary>? _weeklySummary;
  
  @override
  void initState() {
    super.initState();
    _checkAuthorizationAndLoadData();
  }
  
  Future<void> _checkAuthorizationAndLoadData() async {
    setState(() => _isLoading = true);
    
    // Check if authorized
    _isAuthorized = _healthService.isAuthorized;
    
    if (!_isAuthorized) {
      // Request authorization
      _isAuthorized = await _healthService.requestAuthorization();
    }
    
    if (_isAuthorized) {
      // Load data
      final today = DateTime.now();
      _todaySummary = await _healthService.getDailySummary(today);
      _weeklySummary = await _healthService.getWeeklySummary();
    }
    
    setState(() => _isLoading = false);
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
            else if (!_isAuthorized)
              _buildAuthorizationRequest(context)
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _checkAuthorizationAndLoadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHealthScoreCard(context),
                        const SizedBox(height: 20),
                        _buildConnectionStatus(context),
                        const SizedBox(height: 20),
                        _buildMetricsGrid(context),
                        const SizedBox(height: 20),
                        _buildWeeklyChart(context),
                        const SizedBox(height: 20),
                        _buildAdditionalStats(context),
                        const SizedBox(height: 20),
                        _buildWorkoutsSection(context),
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
            'Gesundheit',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkAuthorizationAndLoadData,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAuthorizationRequest(BuildContext context) {
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
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Gesundheitsdaten aktivieren',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Verbinde Apple Health oder Google Fit, um deine Gesundheitsdaten in LifeSync zu sehen.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                final authorized = await _healthService.requestAuthorization();
                if (authorized) {
                  _checkAuthorizationAndLoadData();
                }
              },
              icon: const Icon(Icons.link),
              label: const Text('Gesundheit verbinden'),
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
  
  Widget _buildHealthScoreCard(BuildContext context) {
    final score = _todaySummary?.healthScore ?? 0;
    
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
                  child: Icon(
                    Icons.directions_run,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }
  
  Widget _buildConnectionStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.green, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apple Health verbunden',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  'Letzte Synchronisation: vor 5 Min',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }
  
  Widget _buildMetricsGrid(BuildContext context) {
    final metrics = [
      _MetricData(
        icon: Icons.directions_walk,
        label: 'Schritte',
        value: _todaySummary?.steps ?? 0,
        unit: '',
        goal: 10000,
        color: Colors.green,
        trend: '+12%',
        trendUp: true,
      ),
      _MetricData(
        icon: Icons.bedtime,
        label: 'Schlaf',
        value: (_todaySummary?.sleepHours ?? 0).toDouble(),
        unit: 'h',
        goal: 8,
        color: Colors.purple,
        trend: '0%',
        trendUp: false,
      ),
      _MetricData(
        icon: Icons.favorite,
        label: 'Herzfrequenz',
        value: _todaySummary?.avgHeartRate ?? 0,
        unit: 'bpm',
        goal: 70,
        color: Colors.red,
        trend: '-3',
        trendUp: false,
      ),
      _MetricData(
        icon: Icons.bolt,
        label: 'Aktive Energie',
        value: _todaySummary?.activeEnergy ?? 0,
        unit: 'kcal',
        goal: 500,
        color: Colors.orange,
        trend: '+8%',
        trendUp: true,
      ),
    ];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        return _MetricCard(metric: metrics[index])
            .animate()
            .fadeIn(duration: 300.ms, delay: Duration(milliseconds: 200 + index * 50))
            .slideY(begin: 0.1, end: 0);
      },
    );
  }
  
  Widget _buildWeeklyChart(BuildContext context) {
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
              children: _weeklySummary?.asMap().entries.map((entry) {
                final isToday = entry.key == 6;
                final height = (entry.value.steps / 12000).clamp(0.1, 1.0);
                final weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
                
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
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
                        weekdays[entry.key],
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isToday 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList() ?? [],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 400.ms);
  }
  
  Widget _buildAdditionalStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            '${_todaySummary?.distance.toStringAsFixed(1) ?? 0} km',
            'Distanz',
            Colors.teal,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            '${_todaySummary?.flights ?? 0}',
            'Stockwerke',
            Colors.amber,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            '${_todaySummary?.weight.toStringAsFixed(1) ?? 0} kg',
            'Gewicht',
            Colors.pink,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 450.ms);
  }
  
  Widget _buildStatItem(BuildContext context, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWorkoutsSection(BuildContext context) {
    final workouts = _todaySummary?.workouts ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Heutige Workouts',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        if (workouts.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                style: BorderStyle.solid,
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
                    'Noch keine Workouts heute',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...workouts.map((workout) => _WorkoutCard(workout: workout)),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 500.ms);
  }
}

// ============================================================================
// HELPER WIDGETS
// ============================================================================

class _MetricData {
  final IconData icon;
  final String label;
  final num value;
  final String unit;
  final num goal;
  final Color color;
  final String trend;
  final bool trendUp;
  
  _MetricData({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.goal,
    required this.color,
    required this.trend,
    required this.trendUp,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricData metric;
  
  const _MetricCard({required this.metric});
  
  @override
  Widget build(BuildContext context) {
    final progress = (metric.value / metric.goal).clamp(0.0, 1.0);
    
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
                  color: metric.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(metric.icon, color: metric.color, size: 20),
              ),
              Row(
                children: [
                  Icon(
                    metric.trendUp ? Icons.trending_up : Icons.trending_down,
                    size: 12,
                    color: metric.trendUp ? Colors.green : Colors.red,
                  ),
                  Text(
                    metric.trend,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: metric.trendUp ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${metric.value.toInt()}${metric.unit}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation(metric.color),
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 2),
          Text(
            'Ziel: ${metric.goal}${metric.unit}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final WorkoutData workout;
  
  const _WorkoutCard({required this.workout});
  
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
            child: Text(workout.emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(workout.typeName),
        subtitle: Row(
          children: [
            Icon(Icons.timer, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            Text(' ${workout.duration.inMinutes} Min'),
            const SizedBox(width: 12),
            Icon(Icons.bolt, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            Text(' ${workout.calories} kcal'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to workout detail
        },
      ),
    );
  }
}
