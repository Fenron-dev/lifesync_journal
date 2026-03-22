import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/home_widget_service.dart';

/// Widget Configuration Screen
class WidgetSettingsScreen extends ConsumerStatefulWidget {
  const WidgetSettingsScreen({super.key});

  @override
  ConsumerState<WidgetSettingsScreen> createState() => _WidgetSettingsScreenState();
}

class _WidgetSettingsScreenState extends ConsumerState<WidgetSettingsScreen> {
  List<WidgetConfig> _configuredWidgets = [];
  int _currentStreak = 14;
  int _totalXP = 245;
  
  @override
  void initState() {
    super.initState();
    _loadWidgetConfigs();
  }
  
  Future<void> _loadWidgetConfigs() async {
    // Demo data
    setState(() {
      _configuredWidgets = [
        WidgetConfig(widgetId: 'widget_1', type: WidgetType.quickEntry),
        WidgetConfig(widgetId: 'widget_2', type: WidgetType.streak),
        WidgetConfig(widgetId: 'widget_3', type: WidgetType.quote),
      ];
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen Widgets'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Card
          _buildInfoCard(),
          const SizedBox(height: 24),
          
          // Available Widgets
          Text(
            'Verfügbare Widgets',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          
          _buildWidgetTypeCard(
            type: WidgetType.quickEntry,
            title: 'Quick Entry',
            description: 'Schneller Eintrag mit einem Tap',
            icon: '⚡',
            color: Colors.indigo,
            preview: _buildQuickEntryPreview(),
          ),
          
          const SizedBox(height: 12),
          
          _buildWidgetTypeCard(
            type: WidgetType.streak,
            title: 'Streak Widget',
            description: 'Zeigt deine aktuelle Streak und XP',
            icon: '🔥',
            color: Colors.orange,
            preview: _buildStreakPreview(),
          ),
          
          const SizedBox(height: 12),
          
          _buildWidgetTypeCard(
            type: WidgetType.quote,
            title: 'Tägliches Zitat',
            description: 'Inspirierendes Zitat jeden Tag',
            icon: '💭',
            color: Colors.purple,
            preview: _buildQuotePreview(),
          ),
          
          const SizedBox(height: 24),
          
          // Configured Widgets
          if (_configuredWidgets.isNotEmpty) ...[
            Text(
              'Aktive Widgets',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...(_configuredWidgets.map((config) => _buildActiveWidgetCard(config))),
          ],
        ],
      ),
    );
  }
  
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.widgets, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Widgets',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Füge Widgets zu deinem Home Screen hinzu, um schnell Einträge zu erstellen oder deine Streak zu sehen.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip('$_currentStreak 🔥', 'Streak'),
              const SizedBox(width: 12),
              _buildStatChip('$_totalXP ⭐', 'XP'),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
  
  Widget _buildWidgetTypeCard({
    required WidgetType type,
    required String title,
    required String description,
    required String icon,
    required Color color,
    required Widget preview,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _addWidget(type),
                ),
              ],
            ),
            const SizedBox(height: 16),
            preview,
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickEntryPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade400, Colors.purple.shade400],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LifeSync', style: TextStyle(fontWeight: FontWeight.w600)),
              Text('Tap für neuen Eintrag', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('14 🔥', style: TextStyle(color: Colors.orange.shade700, fontSize: 12)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStreakPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.red.shade400],
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('🔥', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('14 Tage', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
              Text('Level 2 • 245 XP', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          const Spacer(),
          const Column(
            children: [
              Text('2', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Text('heute', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuotePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '"Der einzige Weg, großartige Arbeit zu leisten, ist zu lieben, was man tut."',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('— Steve Jobs', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('14 🔥', style: TextStyle(color: Colors.orange.shade700, fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActiveWidgetCard(WidgetConfig config) {
    String title;
    String icon;
    Color color;
    
    switch (config.type) {
      case WidgetType.quickEntry:
        title = 'Quick Entry';
        icon = '⚡';
        color = Colors.indigo;
        break;
      case WidgetType.streak:
        title = 'Streak Widget';
        icon = '🔥';
        color = Colors.orange;
        break;
      case WidgetType.quote:
        title = 'Tägliches Zitat';
        icon = '💭';
        color = Colors.purple;
        break;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
        ),
        title: Text(title),
        subtitle: Text(config.widgetId),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _removeWidget(config.widgetId),
        ),
      ),
    );
  }
  
  void _addWidget(WidgetType type) {
    // In echter Implementierung würde hier das native Widget hinzugefügt
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${type.name} Widget hinzugefügt!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Anzeigen',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to home screen
          },
        ),
      ),
    );
  }
  
  void _removeWidget(String widgetId) {
    setState(() {
      _configuredWidgets.removeWhere((w) => w.widgetId == widgetId);
    });
  }
}
