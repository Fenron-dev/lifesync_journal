import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/models/daily_mood.dart';
import '../../core/services/dashboard_service.dart';

/// Haupt-Dashboard Screen
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  MoodStats? _stats;
  Map<DateTime, MoodLevel> _heatmapData = {};
  List<MoodInsight> _insights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final service = ref.read(dashboardServiceProvider);
    try {
      final futures = await Future.wait([
        service.getMoodStats(days: 30),
        service.getMoodHeatmap(months: 12),
        service.generateInsights(),
      ]);

      if (!mounted) return;
      setState(() {
        _stats = futures[0] as MoodStats;
        _heatmapData = futures[1] as Map<DateTime, MoodLevel>;
        _insights = futures[2] as List<MoodInsight>;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showMoodCalendar(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Mood Entry
                    _buildQuickMoodCard(),
                    const SizedBox(height: 20),
                    
                    // Mood Heatmap
                    _buildHeatmapCard(),
                    const SizedBox(height: 20),
                    
                    // Statistiken
                    _buildStatsCard(),
                    const SizedBox(height: 20),
                    
                    // Insights
                    _buildInsightsCard(),
                    const SizedBox(height: 20),
                    
                    // Wochenübersicht
                    _buildWeeklyOverview(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMoodEntrySheet(),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ============ QUICK MOOD CARD ============

  Widget _buildQuickMoodCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wie fühlst du dich heute?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: MoodLevel.values.map((mood) {
                return _buildMoodButton(mood);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodButton(MoodLevel mood) {
    return GestureDetector(
      onTap: () => _saveQuickMood(mood),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: _getMoodColor(mood).withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: _getMoodColor(mood),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            _getMoodEmoji(mood),
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }

  // ============ HEATMAP CARD ============

  Widget _buildHeatmapCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stimmungs-Heatmap',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Letzte 12 Monate',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHeatmap(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap() {
    final now = DateTime.now();
    final weeks = <Widget>[];
    
    // Berechne die letzten 52 Wochen
    for (int week = 0; week < 52; week++) {
      final days = <Widget>[];
      
      for (int day = 0; day < 7; day++) {
        final date = now.subtract(Duration(days: (51 - week) * 7 + (6 - day)));
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final mood = _heatmapData[normalizedDate];
        
        days.add(
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: mood != null
                      ? _getMoodColor(mood).withValues(alpha: _getMoodIntensity(mood))
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      }
      
      weeks.add(Row(children: days));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: weeks.reversed.toList(),
      ),
    );
  }

  // ============ STATS CARD ============

  Widget _buildStatsCard() {
    if (_stats == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistiken (30 Tage)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Durchschnittliche Stimmung
            _buildStatRow(
              label: 'Ø Stimmung',
              value: '${(_stats!.averageMood * 10).round() / 10}',
              maxValue: 5,
              color: _getAverageMoodColor(_stats!.averageMood),
            ),
            
            // Energie
            if (_stats!.averageEnergy > 0)
              _buildStatRow(
                label: 'Ø Energie',
                value: '${(_stats!.averageEnergy * 10).round() / 10}',
                maxValue: 5,
                color: Colors.green,
              ),
            
            // Stress
            if (_stats!.averageStress > 0)
              _buildStatRow(
                label: 'Ø Stress',
                value: '${(_stats!.averageStress * 10).round() / 10}',
                maxValue: 5,
                color: _stats!.averageStress > 3 ? Colors.red : Colors.green,
                inverse: true,
              ),
            
            // Schlaf
            if (_stats!.averageSleep > 0)
              _buildStatRow(
                label: 'Ø Schlafqualität',
                value: '${(_stats!.averageSleep * 10).round() / 10}',
                maxValue: 5,
                color: Colors.indigo,
              ),
            
            const SizedBox(height: 16),
            
            // Mood-Verteilung
            Text(
              'Verteilung',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            _buildMoodDistribution(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required double maxValue,
    required Color color,
    bool inverse = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: double.parse(value) / maxValue,
                minHeight: 8,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDistribution() {
    if (_stats == null || _stats!.moodDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = _stats!.moodDistribution.values.reduce((a, b) => a + b);

    return Row(
      children: MoodLevel.values.map((mood) {
        final count = _stats!.moodDistribution[mood] ?? 0;
        final percentage = total > 0 ? count / total : 0.0;

        return Expanded(
          child: Tooltip(
            message: '${_getMoodName(mood)}: $count (${(percentage * 100).toInt()}%)',
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: _getMoodColor(mood),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  _getMoodEmoji(mood),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============ INSIGHTS CARD ============

  Widget _buildInsightsCard() {
    if (_insights.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber[700]),
                const SizedBox(width: 8),
                Text(
                  'Insights',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_insights.take(5).map((insight) => _buildInsightItem(insight))),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(MoodInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getInsightColor(insight.type).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getInsightColor(insight.type).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getInsightIcon(insight.type),
            color: _getInsightColor(insight.type),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ WEEKLY OVERVIEW ============

  Widget _buildWeeklyOverview() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Diese Woche',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(7, (index) {
                final date = weekStart.add(Duration(days: index));
                final mood = _heatmapData[DateTime(date.year, date.month, date.day)];
                final isToday = date.day == now.day;
                
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][index],
                        style: TextStyle(
                          fontSize: 12,
                          color: isToday 
                              ? Theme.of(context).colorScheme.primary
                              : null,
                          fontWeight: isToday ? FontWeight.bold : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: mood != null
                              ? _getMoodColor(mood).withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: isToday
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            mood != null ? _getMoodEmoji(mood) : '?',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ============ ACTIONS ============

  Future<void> _saveQuickMood(MoodLevel mood) async {
    final service = ref.read(dashboardServiceProvider);
    await service.saveDailyMood(
      date: DateTime.now(),
      mood: mood,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stimmung gespeichert: ${_getMoodEmoji(mood)} ${_getMoodName(mood)}'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    _loadData();
  }

  void _showMoodEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MoodEntrySheet(
        onSaved: () {
          Navigator.pop(context);
          _loadData();
        },
      ),
    );
  }

  void _showMoodCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MoodCalendarScreen(),
      ),
    );
  }

  // ============ HELPERS ============

  String _getMoodEmoji(MoodLevel mood) {
    return switch (mood) {
      MoodLevel.veryBad => '😢',
      MoodLevel.bad => '😔',
      MoodLevel.neutral => '😐',
      MoodLevel.good => '😊',
      MoodLevel.veryGood => '😃',
    };
  }

  String _getMoodName(MoodLevel mood) {
    return switch (mood) {
      MoodLevel.veryBad => 'Sehr schlecht',
      MoodLevel.bad => 'Schlecht',
      MoodLevel.neutral => 'Neutral',
      MoodLevel.good => 'Gut',
      MoodLevel.veryGood => 'Sehr gut',
    };
  }

  Color _getMoodColor(MoodLevel mood) {
    return switch (mood) {
      MoodLevel.veryBad => Colors.red,
      MoodLevel.bad => Colors.orange,
      MoodLevel.neutral => Colors.grey,
      MoodLevel.good => Colors.lightGreen,
      MoodLevel.veryGood => Colors.green,
    };
  }

  double _getMoodIntensity(MoodLevel mood) {
    return switch (mood) {
      MoodLevel.veryBad => 0.9,
      MoodLevel.bad => 0.7,
      MoodLevel.neutral => 0.4,
      MoodLevel.good => 0.6,
      MoodLevel.veryGood => 0.9,
    };
  }

  Color _getAverageMoodColor(double avg) {
    if (avg >= 4) return Colors.green;
    if (avg >= 3) return Colors.lightGreen;
    if (avg >= 2) return Colors.orange;
    return Colors.red;
  }

  Color _getInsightColor(InsightType type) {
    return switch (type) {
      InsightType.positive => Colors.green,
      InsightType.negative => Colors.red,
      InsightType.trend => Colors.blue,
      InsightType.suggestion => Colors.orange,
      InsightType.pattern => Colors.purple,
    };
  }

  IconData _getInsightIcon(InsightType type) {
    return switch (type) {
      InsightType.positive => Icons.thumb_up,
      InsightType.negative => Icons.warning,
      InsightType.trend => Icons.trending_up,
      InsightType.suggestion => Icons.tips_and_updates,
      InsightType.pattern => Icons.pattern,
    };
  }
}

// ============ MOOD ENTRY SHEET ============

class MoodEntrySheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;

  const MoodEntrySheet({super.key, required this.onSaved});

  @override
  ConsumerState<MoodEntrySheet> createState() => _MoodEntrySheetState();
}

class _MoodEntrySheetState extends ConsumerState<MoodEntrySheet> {
  MoodLevel _selectedMood = MoodLevel.neutral;
  int _energy = 3;
  int _stress = 3;
  int _sleep = 3;
  int _productivity = 3;
  final _noteController = TextEditingController();
  final Set<String> _selectedActivities = {};

  final _availableActivities = [
    'Sport', 'Arbeit', 'Freunde', 'Familie', 'Lesen',
    'Musik', 'Natur', 'Reisen', 'Kochen', 'Gaming',
    'Schlaf', 'Meditation', 'Einkaufen', 'Kino', 'Date',
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tagesform eintragen',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // Stimmung
              Text('Stimmung', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: MoodLevel.values.map((mood) {
                  final isSelected = _selectedMood == mood;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = mood),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                            : null,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _getMoodEmoji(mood),
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Energie
              _buildSlider(
                label: 'Energie',
                value: _energy,
                icon: Icons.battery_charging_full,
                color: Colors.green,
                onChanged: (v) => setState(() => _energy = v.round()),
              ),

              // Stress
              _buildSlider(
                label: 'Stress',
                value: _stress,
                icon: Icons.psychology,
                color: Colors.red,
                onChanged: (v) => setState(() => _stress = v.round()),
              ),

              // Schlaf
              _buildSlider(
                label: 'Schlafqualität',
                value: _sleep,
                icon: Icons.bedtime,
                color: Colors.indigo,
                onChanged: (v) => setState(() => _sleep = v.round()),
              ),

              // Produktivität
              _buildSlider(
                label: 'Produktivität',
                value: _productivity,
                icon: Icons.work,
                color: Colors.orange,
                onChanged: (v) => setState(() => _productivity = v.round()),
              ),

              const SizedBox(height: 16),

              // Aktivitäten
              Text('Aktivitäten', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableActivities.map((activity) {
                  final isSelected = _selectedActivities.contains(activity);
                  return FilterChip(
                    label: Text(activity),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedActivities.add(activity);
                        } else {
                          _selectedActivities.remove(activity);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Notiz
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Notiz (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveMood,
                  child: const Text('Speichern'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlider({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label),
            const Spacer(),
            Text(
              '$value',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: onChanged,
          activeColor: color,
        ),
      ],
    );
  }

  Future<void> _saveMood() async {
    final service = ref.read(dashboardServiceProvider);
    await service.saveDailyMood(
      date: DateTime.now(),
      mood: _selectedMood,
      energyLevel: _energy,
      stressLevel: _stress,
      sleepQuality: _sleep,
      productivityLevel: _productivity,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      activities: _selectedActivities.toList(),
    );

    if (!mounted) return;
    widget.onSaved();
  }

  String _getMoodEmoji(MoodLevel mood) {
    return switch (mood) {
      MoodLevel.veryBad => '😢',
      MoodLevel.bad => '😔',
      MoodLevel.neutral => '😐',
      MoodLevel.good => '😊',
      MoodLevel.veryGood => '😃',
    };
  }
}

// ============ MOOD CALENDAR SCREEN ============

class MoodCalendarScreen extends ConsumerStatefulWidget {
  const MoodCalendarScreen({super.key});

  @override
  ConsumerState<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends ConsumerState<MoodCalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  Map<DateTime, DailyMood> _moodData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthData();
  }

  Future<void> _loadMonthData() async {
    final service = ref.read(dashboardServiceProvider);
    final start = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final end = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    
    final moods = await service.getMoodsInRange(start, end);
    
    setState(() {
      _moodData = {
        for (var m in moods) m.date: m
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMMM yyyy', 'de_DE').format(_focusedMonth)),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildCalendar(),
    );
  }

  Widget _buildCalendar() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startWeekday = firstDay.weekday;

    final days = <Widget>[];
    
    // Wochentags-Header
    final weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    for (final day in weekdays) {
      days.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            day,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Leere Zellen vor dem ersten Tag
    for (int i = 1; i < startWeekday; i++) {
      days.add(const SizedBox());
    }

    // Tage des Monats
    for (int day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final mood = _moodData[date];
      
      days.add(_buildDayCell(date, mood, day));
    }

    return GridView.count(
      crossAxisCount: 7,
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      children: days,
    );
  }

  Widget _buildDayCell(DateTime date, DailyMood? mood, int day) {
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    return GestureDetector(
      onTap: () => _showDayDetail(date, mood),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: mood != null
              ? _getMoodColor(mood.mood).withValues(alpha: 0.2)
              : null,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : null,
              ),
            ),
            if (mood != null)
              Text(
                _getMoodEmoji(mood.mood),
                style: const TextStyle(fontSize: 20),
              ),
          ],
        ),
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
      _isLoading = true;
    });
    _loadMonthData();
  }

  void _showDayDetail(DateTime date, DailyMood? mood) {
    if (mood == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(DateFormat('dd.MM.yyyy').format(date)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(_getMoodEmoji(mood.mood), style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Text(_getMoodName(mood.mood)),
              ],
            ),
            if (mood.note != null) ...[
              const SizedBox(height: 12),
              Text(mood.note!),
            ],
            if (mood.activities.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: mood.activities.map((a) => Chip(label: Text(a))).toList(),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(MoodLevel mood) {
    return switch (mood) {
      MoodLevel.veryBad => '😢',
      MoodLevel.bad => '😔',
      MoodLevel.neutral => '😐',
      MoodLevel.good => '😊',
      MoodLevel.veryGood => '😃',
    };
  }

  String _getMoodName(MoodLevel mood) {
    return switch (mood) {
      MoodLevel.veryBad => 'Sehr schlecht',
      MoodLevel.bad => 'Schlecht',
      MoodLevel.neutral => 'Neutral',
      MoodLevel.good => 'Gut',
      MoodLevel.veryGood => 'Sehr gut',
    };
  }

  Color _getMoodColor(MoodLevel mood) {
    return switch (mood) {
      MoodLevel.veryBad => Colors.red,
      MoodLevel.bad => Colors.orange,
      MoodLevel.neutral => Colors.grey,
      MoodLevel.good => Colors.lightGreen,
      MoodLevel.veryGood => Colors.green,
    };
  }
}
