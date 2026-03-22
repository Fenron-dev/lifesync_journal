import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/audiobookshelf_service.dart' hide audiobookshelfServiceProvider;
import '../../core/providers/app_provider.dart';

/// Audiobookshelf Screen - Hörbücher verwalten und syncen
class AudiobookshelfScreen extends ConsumerStatefulWidget {
  const AudiobookshelfScreen({super.key});

  @override
  ConsumerState<AudiobookshelfScreen> createState() => _AudiobookshelfScreenState();
}

class _AudiobookshelfScreenState extends ConsumerState<AudiobookshelfScreen> {
  AudiobookshelfConnectionStatus _connectionStatus = AudiobookshelfConnectionStatus.disconnected;
  bool _isLoading = true;
  
  // Server config
  final _serverController = TextEditingController();
  final _tokenController = TextEditingController();
  
  // Data
  List<Audiobook> _library = [];
  List<ListeningSession> _recentSessions = [];
  UserStats? _stats;
  
  StreamSubscription<AudiobookshelfConnectionStatus>? _statusSubscription;
  
  @override
  void initState() {
    super.initState();
    _initializeService();
  }
  
  @override
  void dispose() {
    _statusSubscription?.cancel();
    _serverController.dispose();
    _tokenController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeService() async {
    final service = ref.read(audiobookshelfServiceProvider);
    if (service == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    _statusSubscription = service.connectionStatus.listen((status) {
      setState(() => _connectionStatus = status);
    });
    
    await service.loadConfiguration();
    
    if (service.isConnected) {
      await _loadData();
    }
    
    setState(() => _isLoading = false);
  }
  
  Future<void> _loadData() async {
    final service = ref.read(audiobookshelfServiceProvider);
    if (service == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait<dynamic>([
        service.fetchLibrary(),
        service.getRecentSessions(),
        service.getUserStats(),
      ]);
      
      setState(() {
        _library = results[0] as List<Audiobook>;
        _recentSessions = results[1] as List<ListeningSession>;
        _stats = results[2] as UserStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  Future<void> _connect() async {
    final service = ref.read(audiobookshelfServiceProvider);
    if (service == null) return;
    
    if (_serverController.text.isEmpty || _tokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Server-URL und API-Token eingeben')),
      );
      return;
    }
    
    await service.configure(
      serverUrl: _serverController.text,
      apiToken: _tokenController.text,
    );
    
    final status = await service.connect();
    
    if (status == AudiobookshelfConnectionStatus.connected) {
      await _loadData();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audiobookshelf'),
        actions: [
          if (_connectionStatus == AudiobookshelfConnectionStatus.connected)
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _loadData,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _connectionStatus != AudiobookshelfConnectionStatus.connected
              ? _buildConnectionScreen()
              : _buildMainContent(),
    );
  }
  
  Widget _buildConnectionScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade400, Colors.orange.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headphones, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Mit Audiobookshelf verbinden',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Gib deine Server-URL und API-Token ein, um deine Hörbücher zu synchronisieren.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Server URL
          TextField(
            controller: _serverController,
            decoration: InputDecoration(
              labelText: 'Server URL',
              hintText: 'https://your-server.com',
              prefixIcon: const Icon(Icons.dns),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          
          // API Token
          TextField(
            controller: _tokenController,
            decoration: InputDecoration(
              labelText: 'API Token',
              hintText: 'Dein API-Token',
              prefixIcon: const Icon(Icons.key),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          
          // Connect Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _connect,
              icon: const Icon(Icons.link),
              label: const Text('Verbinden'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          
          // Error message
          if (_connectionStatus == AudiobookshelfConnectionStatus.serverUnreachable)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Server nicht erreichbar',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          
          if (_connectionStatus == AudiobookshelfConnectionStatus.invalidToken)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Ungültiges API-Token',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildMainContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Connection Status
        _buildConnectionStatus(),
        const SizedBox(height: 20),
        
        // Stats
        if (_stats != null) _buildStatsCard(),
        const SizedBox(height: 20),
        
        // Recent Sessions
        _buildRecentSessions(),
        const SizedBox(height: 20),
        
        // Library
        _buildLibrarySection(),
        const SizedBox(height: 20),
        
        // Sync Button
        _buildSyncButton(),
      ],
    );
  }
  
  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange.shade400, Colors.orange.shade400],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.headphones, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audiobookshelf',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Verbunden • ${_library.length} Hörbücher',
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
  
  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hörstatistik',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                context,
                _stats!.formattedTotalTime,
                'Gesamt',
                Icons.access_time,
                Colors.deepOrange,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                context,
                '${_stats!.totalBooks}',
                'Bücher',
                Icons.book,
                Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                context,
                '${_stats!.totalSessions}',
                'Sessions',
                Icons.play_circle,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentSessions() {
    if (_recentSessions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kürzlich gehört',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        ...(_recentSessions.take(5).map((session) => _SessionCard(
          session: session,
          audiobooks: _library,
        ))),
      ],
    );
  }
  
  Widget _buildLibrarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bibliothek',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              '${_library.length} Hörbücher',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (_library.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('Keine Hörbücher gefunden'),
            ),
          )
        else
          ...(_library.take(5).map((book) => _AudiobookCard(audiobook: book))),
      ],
    );
  }
  
  Widget _buildSyncButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _syncToJournal,
        icon: const Icon(Icons.note_add),
        label: const Text('Hörstatistik in Journal speichern'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.deepOrange,
        ),
      ),
    );
  }
  
  Future<void> _syncToJournal() async {
    final service = ref.read(audiobookshelfServiceProvider);
    if (service == null) return;
    
    try {
      await service.createWeeklyListeningReport();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hörstatistik gespeichert!'),
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

class _SessionCard extends StatelessWidget {
  final ListeningSession session;
  final List<Audiobook> audiobooks;
  
  const _SessionCard({
    required this.session,
    required this.audiobooks,
  });
  
  @override
  Widget build(BuildContext context) {
    final audiobook = audiobooks.firstWhere(
      (a) => a.id == session.libraryItemId,
      orElse: () => Audiobook(
        id: '',
        title: 'Unbekannt',
        duration: 0,
        size: 0,
        genres: [],
        tags: [],
        addedAt: DateTime.now(),
      ),
    );
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.deepOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.headphones, color: Colors.deepOrange),
        ),
        title: Text(
          audiobook.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${session.durationMinutes} Min • ${_formatDate(session.startedAt)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime dt) {
    return '${dt.day}.${dt.month}.${dt.year}';
  }
}

class _AudiobookCard extends StatelessWidget {
  final Audiobook audiobook;
  
  const _AudiobookCard({required this.audiobook});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.book, color: Colors.orange),
        ),
        title: Text(
          audiobook.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (audiobook.author != null)
              Text(
                audiobook.author!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            Text(
              audiobook.formattedDuration,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: audiobook.lastPlayedAt != null
            ? Icon(Icons.play_circle_outline, color: Colors.green.shade400)
            : null,
      ),
    );
  }
}
