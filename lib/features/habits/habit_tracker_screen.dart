import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/models/habit.dart';
import '../../core/services/habit_service.dart';

/// Habit Tracker Screen mit heutigen Habits
class HabitTrackerScreen extends ConsumerStatefulWidget {
  const HabitTrackerScreen({super.key});

  @override
  ConsumerState<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends ConsumerState<HabitTrackerScreen> {
  DateTime _selectedDate = DateTime.now();
  Map<int, HabitCompletion> _completions = {};
  List<Habit> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final service = ref.read(habitServiceProvider);
    final habits = await service.getHabitsForDay(_selectedDate);
    final completions = await service.getCompletionsForDate(_selectedDate);

    setState(() {
      _habits = habits;
      _completions = completions;
      _isLoading = false;
    });
  }

  Future<void> _toggleHabit(Habit habit) async {
    final service = ref.read(habitServiceProvider);
    
    if (_completions.containsKey(habit.id)) {
      await service.uncompleteHabit(habit.id, _selectedDate);
    } else {
      await service.completeHabit(habit.id, date: _selectedDate);
    }
    
    await _loadData();
  }

  Future<void> _incrementHabit(Habit habit) async {
    final service = ref.read(habitServiceProvider);
    final current = _completions[habit.id]?.count ?? 0;
    
    if (current < habit.targetCount) {
      await service.setCompletionCount(
        habit.id,
        _selectedDate,
        current + 1,
      );
      await _loadData();
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _isLoading = true;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d. MMMM', 'de_DE');
    final isToday = _isToday(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddHabitSheet(),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/habits/stats'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Datums-Navigation
          _buildDateNavigation(dateFormat, isToday),
          
          // Habits Liste
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _habits.isEmpty
                    ? _buildEmptyState()
                    : _buildHabitsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Neues Habit'),
      ),
    );
  }

  Widget _buildDateNavigation(DateFormat dateFormat, bool isToday) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeDate(-1),
          ),
          GestureDetector(
            onTap: _showDatePicker,
            child: Column(
              children: [
                Text(
                  isToday ? 'Heute' : dateFormat.format(_selectedDate),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${_getCompletedCount()}/${_habits.length} erledigt',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList() {
    // Gruppiere nach Kategorie
    final grouped = <HabitCategory, List<Habit>>{};
    for (final habit in _habits) {
      grouped.putIfAbsent(habit.category, () => []).add(habit);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Progress Card
        _buildProgressCard(),
        const SizedBox(height: 16),
        
        // Habits nach Kategorie
        ...grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryHeader(entry.key),
              ...entry.value.map((habit) => _buildHabitCard(habit)),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildProgressCard() {
    final completed = _getCompletedCount();
    final total = _habits.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tagesfortschritt',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(HabitCategory category) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 20,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 8),
          Text(
            _getCategoryName(category),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitCard(Habit habit) {
    final completion = _completions[habit.id];
    final isCompleted = completion != null && completion.count >= habit.targetCount;
    final progress = habit.targetCount > 1
        ? (completion?.count ?? 0) / habit.targetCount
        : (isCompleted ? 1.0 : 0.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: habit.targetCount == 1 ? () => _toggleHabit(habit) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox/Progress
              GestureDetector(
                onTap: () => _toggleHabit(habit),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? _parseColor(habit.colorHex)
                        : Colors.transparent,
                    border: Border.all(
                      color: _parseColor(habit.colorHex),
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white)
                      : habit.targetCount > 1
                          ? Center(
                              child: Text(
                                '${completion?.count ?? 0}/${habit.targetCount}',
                                style: TextStyle(
                                  color: _parseColor(habit.colorHex),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                ),
              ),
              const SizedBox(width: 16),
              
              // Habit Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? Theme.of(context).colorScheme.outline
                            : null,
                      ),
                    ),
                    if (habit.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        habit.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (habit.targetCount > 1) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(_parseColor(habit.colorHex)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Increment Button (für Multi-Count)
              if (habit.targetCount > 1 && !isCompleted)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _incrementHabit(habit),
                  color: _parseColor(habit.colorHex),
                ),
              
              // Streak Badge
              FutureBuilder<HabitStats>(
                future: ref.read(habitServiceProvider).getHabitStats(habit.id),
                builder: (context, snapshot) {
                  final streak = snapshot.data?.currentStreak ?? 0;
                  if (streak < 3) return const SizedBox.shrink();
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '$streak',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.track_changes,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Keine Habits für diesen Tag',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Füge dein erstes Habit hinzu!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showAddHabitSheet(),
            icon: const Icon(Icons.add),
            label: const Text('Habit erstellen'),
          ),
        ],
      ),
    );
  }

  // ============ HELPER METHODS ============

  void _showAddHabitSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddHabitSheet(
        onSaved: () {
          Navigator.pop(context);
          _loadData();
        },
      ),
    );
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isLoading = true;
      });
      _loadData();
    }
  }

  int _getCompletedCount() {
    return _habits.where((h) {
      final c = _completions[h.id];
      return c != null && c.count >= h.targetCount;
    }).length;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  IconData _getCategoryIcon(HabitCategory category) {
    return switch (category) {
      HabitCategory.health => Icons.favorite,
      HabitCategory.fitness => Icons.fitness_center,
      HabitCategory.mindfulness => Icons.self_improvement,
      HabitCategory.productivity => Icons.work,
      HabitCategory.learning => Icons.school,
      HabitCategory.social => Icons.people,
      HabitCategory.custom => Icons.star,
    };
  }

  String _getCategoryName(HabitCategory category) {
    return switch (category) {
      HabitCategory.health => 'Gesundheit',
      HabitCategory.fitness => 'Fitness',
      HabitCategory.mindfulness => 'Achtsamkeit',
      HabitCategory.productivity => 'Produktivität',
      HabitCategory.learning => 'Lernen',
      HabitCategory.social => 'Sozial',
      HabitCategory.custom => 'Eigenes',
    };
  }
}

// ============ ADD HABIT SHEET ============

class AddHabitSheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;

  const AddHabitSheet({super.key, required this.onSaved});

  @override
  ConsumerState<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<AddHabitSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  HabitCategory _category = HabitCategory.custom;
  String _iconName = 'check_circle';
  String _colorHex = '#4CAF50';
  HabitFrequency _frequency = HabitFrequency.daily;
  int _targetCount = 1;
  final Set<int> _activeDays = {1, 2, 3, 4, 5, 6, 7};

  final List<String> _availableIcons = [
    'check_circle', 'favorite', 'fitness_center', 'self_improvement',
    'work', 'school', 'book', 'water_drop', 'restaurant',
    'bedtime', 'directions_run', 'medication', 'pets', 'code',
  ];

  final List<String> _availableColors = [
    '#4CAF50', '#2196F3', '#FF9800', '#E91E63',
    '#9C27B0', '#00BCD4', '#FF5722', '#795548',
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
                'Neues Habit',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'z.B. 8 Gläser Wasser trinken',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Beschreibung
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Beschreibung (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Kategorie
              Text('Kategorie', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: HabitCategory.values.map((cat) {
                  return ChoiceChip(
                    label: Text(_getCategoryName(cat)),
                    selected: _category == cat,
                    onSelected: (selected) {
                      if (selected) setState(() => _category = cat);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Icon
              Text('Icon', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableIcons.map((icon) {
                  return GestureDetector(
                    onTap: () => setState(() => _iconName = icon),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _iconName == icon
                            ? _parseColor(_colorHex)
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconData(icon),
                        color: _iconName == icon ? Colors.white : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Farbe
              Text('Farbe', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableColors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _colorHex = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _parseColor(color),
                        shape: BoxShape.circle,
                        border: _colorHex == color
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Häufigkeit
              Text('Häufigkeit', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<HabitFrequency>(
                segments: const [
                  ButtonSegment(value: HabitFrequency.daily, label: Text('Täglich')),
                  ButtonSegment(value: HabitFrequency.weekly, label: Text('Wochentage')),
                ],
                selected: {_frequency},
                onSelectionChanged: (set) {
                  setState(() => _frequency = set.first);
                },
              ),
              
              if (_frequency == HabitFrequency.weekly) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (int i = 1; i <= 7; i++)
                      FilterChip(
                        label: Text(['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][i - 1]),
                        selected: _activeDays.contains(i),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _activeDays.add(i);
                            } else {
                              _activeDays.remove(i);
                            }
                          });
                        },
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // Ziel-Anzahl
              Text('Ziel pro Tag', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _targetCount > 1
                        ? () => setState(() => _targetCount--)
                        : null,
                  ),
                  Container(
                    width: 60,
                    alignment: Alignment.center,
                    child: Text(
                      '$_targetCount',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _targetCount < 99
                        ? () => setState(() => _targetCount++)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveHabit,
                  child: const Text('Habit erstellen'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveHabit() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte gib einen Namen ein')),
      );
      return;
    }

    final service = ref.read(habitServiceProvider);
    await service.createHabit(
      name: _nameController.text,
      description: _descController.text.isEmpty ? null : _descController.text,
      category: _category,
      iconName: _iconName,
      colorHex: _colorHex,
      frequency: _frequency,
      targetCount: _targetCount,
      activeDays: _frequency == HabitFrequency.weekly
          ? _activeDays.toList()
          : [1, 2, 3, 4, 5, 6, 7],
    );

    widget.onSaved();
  }

  String _getCategoryName(HabitCategory category) {
    return switch (category) {
      HabitCategory.health => 'Gesundheit',
      HabitCategory.fitness => 'Fitness',
      HabitCategory.mindfulness => 'Achtsamkeit',
      HabitCategory.productivity => 'Produktivität',
      HabitCategory.learning => 'Lernen',
      HabitCategory.social => 'Sozial',
      HabitCategory.custom => 'Eigenes',
    };
  }

  IconData _getIconData(String iconName) {
    return switch (iconName) {
      'favorite' => Icons.favorite,
      'fitness_center' => Icons.fitness_center,
      'self_improvement' => Icons.self_improvement,
      'work' => Icons.work,
      'school' => Icons.school,
      'book' => Icons.book,
      'water_drop' => Icons.water_drop,
      'restaurant' => Icons.restaurant,
      'bedtime' => Icons.bedtime,
      'directions_run' => Icons.directions_run,
      'medication' => Icons.medication,
      'pets' => Icons.pets,
      'code' => Icons.code,
      _ => Icons.check_circle,
    };
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}

// ============ HABIT STATS SCREEN ============

class HabitStatsScreen extends ConsumerStatefulWidget {
  const HabitStatsScreen({super.key});

  @override
  ConsumerState<HabitStatsScreen> createState() => _HabitStatsScreenState();
}

class _HabitStatsScreenState extends ConsumerState<HabitStatsScreen> {
  List<Habit> _habits = [];
  Map<int, HabitStats> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final service = ref.read(habitServiceProvider);
    final habits = await service.getAllHabits();
    final statsMap = <int, HabitStats>{};

    for (final habit in habits) {
      statsMap[habit.id] = await service.getHabitStats(habit.id);
    }

    setState(() {
      _habits = habits;
      _stats = statsMap;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Statistiken'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                final stats = _stats[habit.id];
                
                return _buildStatsCard(habit, stats);
              },
            ),
    );
  }

  Widget _buildStatsCard(Habit habit, HabitStats? stats) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _parseColor(habit.colorHex),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIconData(habit.iconName),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habit.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: 'Akt. Streak',
                  value: '${stats?.currentStreak ?? 0}',
                  color: Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.emoji_events,
                  label: 'Bester Streak',
                  value: '${stats?.longestStreak ?? 0}',
                  color: Colors.amber,
                ),
                _buildStatItem(
                  icon: Icons.check_circle,
                  label: 'Gesamt',
                  value: '${stats?.totalCompletions ?? 0}',
                  color: Colors.green,
                ),
                _buildStatItem(
                  icon: Icons.percent,
                  label: 'Rate',
                  value: '${((stats?.completionRate ?? 0) * 100).toInt()}%',
                  color: Colors.blue,
                ),
              ],
            ),
            
            // Heatmap
            const SizedBox(height: 16),
            _buildHeatmap(stats),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildHeatmap(HabitStats? stats) {
    if (stats == null) return const SizedBox.shrink();

    final days = List.generate(30, (i) {
      final date = DateTime.now().subtract(Duration(days: 29 - i));
      final count = stats.last30Days[DateTime(date.year, date.month, date.day)] ?? 0;
      return {'date': date, 'count': count};
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Letzte 30 Tage',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 30,
          child: Row(
            children: days.map((day) {
              final intensity = (day['count'] as int) > 0 ? 1.0 : 0.1;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: intensity),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _parseColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  IconData _getIconData(String iconName) {
    return switch (iconName) {
      'favorite' => Icons.favorite,
      'fitness_center' => Icons.fitness_center,
      'self_improvement' => Icons.self_improvement,
      'work' => Icons.work,
      'school' => Icons.school,
      'book' => Icons.book,
      'water_drop' => Icons.water_drop,
      'restaurant' => Icons.restaurant,
      'bedtime' => Icons.bedtime,
      'directions_run' => Icons.directions_run,
      'medication' => Icons.medication,
      'pets' => Icons.pets,
      'code' => Icons.code,
      _ => Icons.check_circle,
    };
  }
}
