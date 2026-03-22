import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/journal/journal_screen.dart';
import '../../features/habits/habit_tracker_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/backup/backup_screen.dart';
import '../../features/sync/sync_screen.dart';
import '../../features/health/samsung_health_screen.dart';
import '../../features/widgets/widget_settings_screen.dart';
import '../../features/audiobooks/audiobookshelf_screen.dart';
import '../../features/media/media_picker_widget.dart';

part 'app_router.g.dart';

/// Shell für Bottom Navigation
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Journal',
          ),
          NavigationDestination(
            icon: Icon(Icons.track_changes_outlined),
            selectedIcon: Icon(Icons.track_changes),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'Mehr',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    
    if (location.startsWith('/journal')) return 0;
    if (location.startsWith('/habits')) return 1;
    if (location.startsWith('/dashboard')) return 2;
    if (location.startsWith('/settings') ||
        location.startsWith('/sync') ||
        location.startsWith('/health') ||
        location.startsWith('/widgets') ||
        location.startsWith('/audiobooks') ||
        location.startsWith('/backup')) return 3;
    
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/journal');
        break;
      case 1:
        context.go('/habits');
        break;
      case 2:
        context.go('/dashboard');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}

/// Settings Screen mit Links zu allen Features
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mehr'),
      ),
      body: ListView(
        children: [
          // Sync Section
          _buildSectionHeader('Synchronisation'),
          _buildSettingsTile(
            context,
            icon: Icons.sync,
            title: 'LAN Sync',
            subtitle: 'Geräte im lokalen Netzwerk synchronisieren',
            destination: '/sync',
          ),
          _buildSettingsTile(
            context,
            icon: Icons.backup,
            title: 'Backup & Wiederherstellung',
            subtitle: 'Lokales Backup erstellen oder importieren',
            destination: '/backup',
          ),
          
          const Divider(height: 32),
          
          // Health Section
          _buildSectionHeader('Gesundheit'),
          _buildSettingsTile(
            context,
            icon: Icons.favorite,
            title: 'Samsung Health',
            subtitle: 'Gesundheitsdaten importieren',
            destination: '/health',
          ),
          
          const Divider(height: 32),
          
          // Widgets & Integration
          _buildSectionHeader('Widgets & Integration'),
          _buildSettingsTile(
            context,
            icon: Icons.widgets,
            title: 'Home Screen Widgets',
            subtitle: 'Widget-Einstellungen konfigurieren',
            destination: '/widgets',
          ),
          _buildSettingsTile(
            context,
            icon: Icons.audiotrack,
            title: 'Audiobookshelf',
            subtitle: 'Hörbücher verwalten und Journal-Export',
            destination: '/audiobooks',
          ),
          
          const Divider(height: 32),
          
          // Storage
          _buildSectionHeader('Speicher'),
          _buildSettingsTile(
            context,
            icon: Icons.storage,
            title: 'Speicherverwaltung',
            subtitle: 'Medien- und Datenverwaltung',
            destination: '/storage',
          ),
          
          const Divider(height: 32),
          
          // App Info
          _buildSectionHeader('Über LifeSync'),
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.book,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: const Text('LifeSync Journal'),
            subtitle: const Text('Version 2.0.0\nLocal-first • E2E Encrypted • Obsidian Compatible'),
            isThreeLine: true,
          ),
          
          const SizedBox(height: 32),
          
          // Footer
          Center(
            child: Column(
              children: [
                Text(
                  'Made with ❤️',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'AES-256-GCM Verschlüsselung',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String destination,
  }) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push(destination),
    );
  }
}

/// Router Provider
@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: '/journal',
    debugLogDiagnostics: true,
    
    routes: [
      // Shell Route mit Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          // Journal
          GoRoute(
            path: '/journal',
            name: 'journal',
            builder: (context, state) => const JournalScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'journal-new',
                builder: (context, state) => const JournalEditorScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'journal-edit',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  if (id == null) return const SizedBox.shrink();
                  return JournalEditorScreen(entryId: id);
                },
              ),
            ],
          ),
          
          // Habits
          GoRoute(
            path: '/habits',
            name: 'habits',
            builder: (context, state) => const HabitTrackerScreen(),
            routes: [
              GoRoute(
                path: 'stats',
                name: 'habit-stats',
                builder: (context, state) => const HabitStatsScreen(),
              ),
            ],
          ),
          
          // Dashboard
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          
          // Settings / Mehr
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      
      // Top-level Routes (ohne Bottom Nav)
      
      // Sync
      GoRoute(
        path: '/sync',
        name: 'sync',
        builder: (context, state) => const SyncScreen(),
      ),
      
      // Backup
      GoRoute(
        path: '/backup',
        name: 'backup',
        builder: (context, state) => const BackupScreen(),
      ),
      
      // Health
      GoRoute(
        path: '/health',
        name: 'health',
        builder: (context, state) => const SamsungHealthScreen(),
      ),
      
      // Widgets
      GoRoute(
        path: '/widgets',
        name: 'widgets',
        builder: (context, state) => const WidgetSettingsScreen(),
      ),
      
      // Audiobooks
      GoRoute(
        path: '/audiobooks',
        name: 'audiobooks',
        builder: (context, state) => const AudiobookshelfScreen(),
      ),
      
      // Storage
      GoRoute(
        path: '/storage',
        name: 'storage',
        builder: (context, state) => const StorageStatsScreen(),
      ),
    ],
    
    // Error Handler
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Fehler'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Seite nicht gefunden',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unbekannter Fehler',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/journal'),
              child: const Text('Zurück zum Journal'),
            ),
          ],
        ),
      ),
    ),
  );
}
