import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../core/providers/app_provider.dart';
import '../../core/models/entry_type.dart';
import '../quick_entry/quick_entry_sheet.dart';
import '../../shared/widgets/streak_indicator.dart';

/// Home Screen - Hauptansicht der App
/// 
/// Zeigt:
/// - Begrüßung mit aktuellem Streak
/// - Statistik-Karten (Streak, Level, XP)
/// - Heutige Einträge
/// - Quick-Add FAB
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(entriesForDateProvider(_selectedDate));
    final streak = ref.watch(streakProvider);
    final xp = ref.watch(xpProvider);
    final level = ref.watch(levelProvider);
    
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(entriesForDateProvider(_selectedDate));
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                elevation: 0,
                backgroundColor: theme.scaffoldBackgroundColor,
                title: Text(
                  _formatDateTitle(_selectedDate),
                  style: theme.textTheme.titleMedium,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: _showDatePicker,
                    tooltip: 'Kalender',
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => Navigator.pushNamed(context, '/search'),
                    tooltip: 'Suchen',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    tooltip: 'Einstellungen',
                  ),
                ],
              ),
              
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Greeting
                    _buildGreeting(context, streak),
                    
                    const SizedBox(height: 24),
                    
                    // Stats
                    _buildStatsRow(context, streak, level, xp),
                    
                    const SizedBox(height: 32),
                    
                    // Section Header
                    Row(
                      children: [
                        Text(
                          'Heute',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          icon: const Icon(Icons.history, size: 18),
                          label: const Text('On This Day'),
                          onPressed: _showOnThisDay,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
              
              // Entries List
              entriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return SliverFillRemaining(
                      child: _buildEmptyState(context),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildEntryCard(context, entries[index]),
                        childCount: entries.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => SliverFillRemaining(
                  child: Center(
                    child: Text('Fehler: $error'),
                  ),
                ),
              ),
              
              // Bottom padding for FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildGreeting(BuildContext context, int streak) {
    final hour = DateTime.now().hour;
    
    String greeting;
    String emoji;
    if (hour < 12) {
      greeting = 'Guten Morgen';
      emoji = '☀️';
    } else if (hour < 18) {
      greeting = 'Guten Tag';
      emoji = '🌤️';
    } else {
      greeting = 'Guten Abend';
      emoji = '🌙';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$emoji $greeting!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (streak > 0) ...[
          const SizedBox(height: 8),
          StreakIndicator(streak: streak),
        ],
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildStatsRow(BuildContext context, int streak, int level, int xp) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_outlined,
            label: 'Streak',
            value: '$streak',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.stars_outlined,
            label: 'Level',
            value: '$level',
            color: Colors.purple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_events_outlined,
            label: 'XP',
            value: '$xp',
            color: Colors.green,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Noch keine Einträge für heute',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tippe auf den + Button um einen Eintrag zu erstellen',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildEntryCard(BuildContext context, dynamic entry) {
    // Simplified - in real app would use Entry model
    final title = entry.title ?? 'Eintrag';
    final content = entry.content ?? '';
    final type = entry.entryType ?? 'note';
    final mood = entry.mood;
    final createdAt = entry.createdAt ?? DateTime.now();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to entry detail
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _EntryTypeIcon(type: type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title.isNotEmpty ? title : _formatTime(createdAt),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (mood != null) ...[
                    Text(
                      ['😩', '😔', '😐', '🙂', '😊'][(mood - 1).clamp(0, 4)],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ],
              ),
              if (content.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  content.length > 100 ? '${content.substring(0, 100)}...' : content,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                _formatTime(createdAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _showQuickAdd,
      icon: const Icon(Icons.add),
      label: const Text('Neu'),
    ).animate().scale(
      begin: const Offset(0.5, 0.5),
      end: const Offset(1, 1),
      curve: Curves.elasticOut,
      delay: 500.ms,
    );
  }

  void _showQuickAdd() {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickEntrySheet(),
    );
  }

  void _showDatePicker() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (selected != null) {
      setState(() => _selectedDate = selected);
    }
  }

  void _showOnThisDay() {
    // Show entries from previous years on this day
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('On This Day - Coming Soon!')),
    );
  }

  String _formatDateTitle(DateTime date) {
    final weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    const months = [
      'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun',
      'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'
    ];
    
    return '${weekdays[date.weekday - 1]}, ${date.day}. ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime time) {
    return DateFormat.Hm('de').format(time);
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Entry Type Icon Widget
class _EntryTypeIcon extends StatelessWidget {
  final String type;
  
  const _EntryTypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    final entryType = EntryType.values.firstWhere(
      (t) => t.name == type,
      orElse: () => EntryType.note,
    );
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        entryType.emoji,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
