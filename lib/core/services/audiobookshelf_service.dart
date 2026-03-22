import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entry.dart';
import 'storage_service.dart';

/// Audiobookshelf Service - Integration mit Audiobookshelf Server
/// 
/// Audiobookshelf ist ein Self-Hosted Audiobook/Podcast Server.
/// 
/// Features:
/// - Sync Hörbuch-Fortschritt
/// - Importiere Hörbücher als Journal-Einträge
/// - Tracking von Hörzeiten
/// - Automatische Bookmarks
/// 
/// API Docs: https://api.audiobookshelf.org/
class AudiobookshelfService {
  final StorageService _storage;

  // Connection
  String? _serverUrl;
  String? _apiToken;
  String? _userId;
  
  // Cache
  List<Audiobook>? _cachedLibrary;
  List<ListeningSession>? _recentSessions;
  UserStats? _userStats;
  
  // Status
  final _connectionStatusController = StreamController<AudiobookshelfConnectionStatus>.broadcast();
  final _syncProgressController = StreamController<SyncProgress>.broadcast();
  
  Stream<AudiobookshelfConnectionStatus> get connectionStatus => _connectionStatusController.stream;
  Stream<SyncProgress> get syncProgress => _syncProgressController.stream;
  
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  AudiobookshelfService(this._storage);
  
  // ==================== CONNECTION ====================
  
  /// Konfiguriere Verbindung
  Future<void> configure({
    required String serverUrl,
    required String apiToken,
  }) async {
    _serverUrl = serverUrl.replaceAll(RegExp(r'/$'), '');
    _apiToken = apiToken;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audiobookshelf_url', _serverUrl!);
    await prefs.setString('audiobookshelf_token', _apiToken!);
  }
  
  /// Lade gespeicherte Konfiguration
  Future<void> loadConfiguration() async {
    final prefs = await SharedPreferences.getInstance();
    
    _serverUrl = prefs.getString('audiobookshelf_url');
    _apiToken = prefs.getString('audiobookshelf_token');
    
    if (_serverUrl != null && _apiToken != null) {
      await connect();
    }
  }
  
  /// Verbinde mit Audiobookshelf
  Future<AudiobookshelfConnectionStatus> connect() async {
    if (_serverUrl == null || _apiToken == null) {
      _connectionStatusController.add(AudiobookshelfConnectionStatus.notConfigured);
      return AudiobookshelfConnectionStatus.notConfigured;
    }
    
    _connectionStatusController.add(AudiobookshelfConnectionStatus.connecting);
    
    try {
      // Teste Verbindung
      final response = await _get('/api/me');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _userId = data['id'] as String?;
        
        _isConnected = true;
        _connectionStatusController.add(AudiobookshelfConnectionStatus.connected);
        return AudiobookshelfConnectionStatus.connected;
      } else if (response.statusCode == 401) {
        _connectionStatusController.add(AudiobookshelfConnectionStatus.invalidToken);
        return AudiobookshelfConnectionStatus.invalidToken;
      } else {
        _connectionStatusController.add(AudiobookshelfConnectionStatus.error);
        return AudiobookshelfConnectionStatus.error;
      }
    } catch (e) {
      _connectionStatusController.add(AudiobookshelfConnectionStatus.serverUnreachable);
      return AudiobookshelfConnectionStatus.serverUnreachable;
    }
  }
  
  /// Trenne Verbindung
  Future<void> disconnect() async {
    _isConnected = false;
    _serverUrl = null;
    _apiToken = null;
    _userId = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('audiobookshelf_url');
    await prefs.remove('audiobookshelf_token');
    
    _connectionStatusController.add(AudiobookshelfConnectionStatus.disconnected);
  }
  
  // ==================== LIBRARY ====================
  
  /// Lade Bibliothek
  Future<List<Audiobook>> fetchLibrary() async {
    if (!_isConnected) {
      throw Exception('Nicht verbunden');
    }
    
    final response = await _get('/api/libraries');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final libraries = data['libraries'] as List;
      
      // Hole Items aus erster Bibliothek
      if (libraries.isNotEmpty) {
        final libraryId = libraries[0]['id'] as String;
        final itemsResponse = await _get('/api/libraries/$libraryId/items');
        
        if (itemsResponse.statusCode == 200) {
          final itemsData = jsonDecode(itemsResponse.body) as Map<String, dynamic>;
          final results = itemsData['results'] as List;
          
          _cachedLibrary = results.map((item) => Audiobook.fromJson(item as Map<String, dynamic>)).toList();
          return _cachedLibrary!;
        }
      }
    }
    
    return [];
  }
  
  /// Suche in Bibliothek
  Future<List<Audiobook>> searchLibrary(String query) async {
    if (!_isConnected) {
      throw Exception('Nicht verbunden');
    }
    
    final response = await _get('/api/libraries?search=${Uri.encodeQueryComponent(query)}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List? ?? [];
      
      return results.map((item) => Audiobook.fromJson(item as Map<String, dynamic>)).toList();
    }
    
    return [];
  }
  
  // ==================== LISTENING PROGRESS ====================
  
  /// Hole aktuellen Hörfortschritt
  Future<ListeningProgress?> getCurrentProgress(String libraryItemId) async {
    if (!_isConnected || _userId == null) {
      throw Exception('Nicht verbunden');
    }
    
    final response = await _get('/api/me/progress/$libraryItemId');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ListeningProgress.fromJson(data);
    }
    
    return null;
  }
  
  /// Hole alle Hörfortschritte
  Future<List<ListeningProgress>> getAllProgress() async {
    if (!_isConnected || _userId == null) {
      throw Exception('Nicht verbunden');
    }
    
    final response = await _get('/api/me/progress');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final progress = data['progress'] as List? ?? [];
      
      return progress.map((p) => ListeningProgress.fromJson(p as Map<String, dynamic>)).toList();
    }
    
    return [];
  }
  
  /// Hole kürzlich gehörte
  Future<List<ListeningSession>> getRecentSessions({int limit = 10}) async {
    if (!_isConnected) {
      throw Exception('Nicht verbunden');
    }
    
    final response = await _get('/api/me/listening-sessions?limit=$limit');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final sessions = data['sessions'] as List? ?? [];
      
      _recentSessions = sessions.map((s) => ListeningSession.fromJson(s as Map<String, dynamic>)).toList();
      return _recentSessions!;
    }
    
    return [];
  }
  
  /// Hole Statistiken
  Future<UserStats> getUserStats() async {
    if (!_isConnected) {
      throw Exception('Nicht verbunden');
    }
    
    final response = await _get('/api/me/stats');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _userStats = UserStats.fromJson(data);
      return _userStats!;
    }
    
    return UserStats.empty();
  }
  
  // ==================== SYNC TO JOURNAL ====================
  
  /// Sync Hörfortschritt in Journal
  Future<Entry> syncProgressToJournal({
    required ListeningProgress progress,
    String? notes,
  }) async {
    // Hole Audiobook-Details
    final audiobook = await _getAudiobook(progress.libraryItemId);
    
    final entry = Entry()
      ..entryType = 'audiobook'
      ..title = audiobook?.title ?? 'Hörbuch'
      ..entryDate = DateTime.now()
      ..content = _generateProgressContent(progress, audiobook, notes);
    
    return await _storage.saveEntry(entry);
  }
  
  /// Sync alle kürzlich gehörten als Journal-Eintrag
  Future<List<Entry>> syncRecentSessions() async {
    final sessions = await getRecentSessions(limit: 20);
    final entries = <Entry>[];
    
    for (final session in sessions) {
      final audiobook = await _getAudiobook(session.libraryItemId);
      
      final entry = Entry()
        ..entryType = 'audiobook'
        ..title = audiobook?.title ?? 'Hörbuch'
        ..entryDate = session.startedAt
        ..content = _generateSessionContent(session, audiobook);
      
      entries.add(await _storage.saveEntry(entry));
    }
    
    return entries;
  }
  
  /// Erstelle wöchentliche Hörstatistik als Eintrag
  Future<Entry> createWeeklyListeningReport() async {
    final stats = await getUserStats();
    final sessions = await getRecentSessions(limit: 50);
    
    // Filtere diese Woche
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekSessions = sessions.where((s) => s.startedAt.isAfter(weekStart)).toList();
    
    final totalMinutes = weekSessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    
    final entry = Entry()
      ..entryType = 'audiobook'
      ..title = 'Hörstatistik Woche ${weekStart.day}.${weekStart.month}'
      ..entryDate = now
      ..content = _generateWeeklyReportContent(stats, weekSessions, totalMinutes);
    
    return await _storage.saveEntry(entry);
  }
  
  // ==================== HELPERS ====================
  
  Future<Audiobook?> _getAudiobook(String libraryItemId) async {
    if (_cachedLibrary != null) {
      return _cachedLibrary!.firstWhere(
        (a) => a.id == libraryItemId,
        orElse: () => throw StateError('Not found'),
      );
    }
    
    try {
      final response = await _get('/api/items/$libraryItemId');
      if (response.statusCode == 200) {
        return Audiobook.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }
    } catch (_) {}
    
    return null;
  }
  
  String _generateProgressContent(ListeningProgress progress, Audiobook? audiobook, String? notes) {
    final buffer = StringBuffer();
    
    buffer.writeln('# 📚 ${audiobook?.title ?? "Hörbuch"}');
    buffer.writeln();
    
    if (audiobook?.author != null) {
      buffer.writeln('**Autor:** ${audiobook!.author}');
    }
    
    if (audiobook?.series != null) {
      buffer.writeln('**Serie:** ${audiobook!.series}');
    }
    
    buffer.writeln();
    buffer.writeln('## Fortschritt');
    buffer.writeln('- **Gehört:** ${_formatDuration(progress.currentTime)}');
    buffer.writeln('- **Gesamt:** ${_formatDuration(progress.totalDuration)}');
    buffer.writeln('- **Fortschritt:** ${(progress.progress * 100).toStringAsFixed(1)}%');
    
    if (progress.isFinished) {
      buffer.writeln('- **Status:** ✅ Abgeschlossen');
    }
    
    if (notes != null && notes.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('## Notizen');
      buffer.writeln(notes);
    }
    
    return buffer.toString();
  }
  
  String _generateSessionContent(ListeningSession session, Audiobook? audiobook) {
    final buffer = StringBuffer();
    
    buffer.writeln('# 📚 ${audiobook?.title ?? "Hörbuch"}');
    buffer.writeln();
    
    if (audiobook?.author != null) {
      buffer.writeln('**Autor:** ${audiobook!.author}');
    }
    
    buffer.writeln();
    buffer.writeln('## Session');
    buffer.writeln('- **Dauer:** ${session.durationMinutes} Minuten');
    buffer.writeln('- **Gestartet:** ${_formatDateTime(session.startedAt)}');
    buffer.writeln('- **Beendet:** ${_formatDateTime(session.endedAt)}');
    
    return buffer.toString();
  }
  
  String _generateWeeklyReportContent(UserStats stats, List<ListeningSession> sessions, int totalMinutes) {
    final buffer = StringBuffer();
    
    buffer.writeln('# 📊 Wöchentliche Hörstatistik');
    buffer.writeln();
    
    buffer.writeln('## Übersicht');
    buffer.writeln('- **Gesamtzeit:** ${(totalMinutes / 60).toStringAsFixed(1)} Stunden');
    buffer.writeln('- **Sessions:** ${sessions.length}');
    buffer.writeln('- **Ø pro Session:** ${(totalMinutes / sessions.length).toStringAsFixed(0)} Minuten');
    
    buffer.writeln();
    buffer.writeln('## Gehörte Bücher');
    
    final bookSessions = <String, int>{};
    for (final session in sessions) {
      bookSessions[session.libraryItemId] = (bookSessions[session.libraryItemId] ?? 0) + session.durationMinutes;
    }
    
    for (final entry in bookSessions.entries) {
      buffer.writeln('- ${entry.key}: ${(entry.value / 60).toStringAsFixed(1)}h');
    }
    
    return buffer.toString();
  }
  
  String _formatDuration(double seconds) {
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).floor();
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }
  
  String _formatDateTime(DateTime dt) {
    return '${dt.day}.${dt.month}.${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
  
  // ==================== HTTP HELPERS ====================
  
  Future<http.Response> _get(String endpoint) async {
    final url = '$_serverUrl$endpoint';
    
    return await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_apiToken',
        'Content-Type': 'application/json',
      },
    );
  }
  
  /// Dispose
  void dispose() {
    _connectionStatusController.close();
    _syncProgressController.close();
  }
}

// ==================== DATA MODELS ====================

/// Connection Status
enum AudiobookshelfConnectionStatus {
  disconnected,
  connecting,
  connected,
  notConfigured,
  invalidToken,
  serverUnreachable,
  error,
}

/// Sync Progress
class SyncProgress {
  final int current;
  final int total;
  final String status;
  
  SyncProgress({required this.current, required this.total, required this.status});
  
  double get progress => total > 0 ? current / total : 0;
}

/// Audiobook Model
class Audiobook {
  final String id;
  final String title;
  final String? author;
  final String? series;
  final String? seriesSequence;
  final String? narrator;
  final String? description;
  final String? coverPath;
  final double duration;
  final int size;
  final List<String> genres;
  final List<String> tags;
  final DateTime addedAt;
  final DateTime? lastPlayedAt;
  
  Audiobook({
    required this.id,
    required this.title,
    this.author,
    this.series,
    this.seriesSequence,
    this.narrator,
    this.description,
    this.coverPath,
    required this.duration,
    required this.size,
    required this.genres,
    required this.tags,
    required this.addedAt,
    this.lastPlayedAt,
  });
  
  factory Audiobook.fromJson(Map<String, dynamic> json) {
    final media = json['media'] as Map<String, dynamic>? ?? {};
    final metadata = media['metadata'] as Map<String, dynamic>? ?? {};
    
    return Audiobook(
      id: json['id'] as String? ?? '',
      title: metadata['title'] as String? ?? 'Unknown',
      author: metadata['authorName'] as String?,
      series: metadata['seriesName'] as String?,
      seriesSequence: metadata['seriesSequence'] as String?,
      narrator: metadata['narratorName'] as String?,
      description: metadata['description'] as String?,
      coverPath: media['coverPath'] as String?,
      duration: (media['duration'] as num?)?.toDouble() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 0,
      genres: (metadata['genres'] as List?)?.map((g) => g.toString()).toList() ?? [],
      tags: (metadata['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
      addedAt: DateTime.fromMillisecondsSinceEpoch((json['addedAt'] as num?)?.toInt() ?? 0),
      lastPlayedAt: json['lastPlayedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((json['lastPlayedAt'] as num).toInt())
          : null,
    );
  }
  
  String get formattedDuration {
    final hours = (duration / 3600).floor();
    final minutes = ((duration % 3600) / 60).floor();
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }
}

/// Listening Progress
class ListeningProgress {
  final String id;
  final String libraryItemId;
  final double currentTime;
  final double totalDuration;
  final double progress;
  final bool isFinished;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final DateTime updatedAt;
  
  ListeningProgress({
    required this.id,
    required this.libraryItemId,
    required this.currentTime,
    required this.totalDuration,
    required this.progress,
    required this.isFinished,
    required this.startedAt,
    this.finishedAt,
    required this.updatedAt,
  });
  
  factory ListeningProgress.fromJson(Map<String, dynamic> json) {
    return ListeningProgress(
      id: json['id'] as String? ?? '',
      libraryItemId: json['libraryItemId'] as String? ?? '',
      currentTime: (json['currentTime'] as num?)?.toDouble() ?? 0,
      totalDuration: (json['duration'] as num?)?.toDouble() ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      isFinished: json['isFinished'] as bool? ?? false,
      startedAt: DateTime.fromMillisecondsSinceEpoch((json['startedAt'] as num?)?.toInt() ?? 0),
      finishedAt: json['finishedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((json['finishedAt'] as num).toInt())
          : null,
      updatedAt: DateTime.fromMillisecondsSinceEpoch((json['updatedAt'] as num?)?.toInt() ?? 0),
    );
  }
}

/// Listening Session
class ListeningSession {
  final String id;
  final String libraryItemId;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationMinutes;
  final double timeListening;
  final String? mediaPlayer;
  
  ListeningSession({
    required this.id,
    required this.libraryItemId,
    required this.startedAt,
    required this.endedAt,
    required this.durationMinutes,
    required this.timeListening,
    this.mediaPlayer,
  });
  
  factory ListeningSession.fromJson(Map<String, dynamic> json) {
    return ListeningSession(
      id: json['id'] as String? ?? '',
      libraryItemId: json['libraryItemId'] as String? ?? '',
      startedAt: DateTime.fromMillisecondsSinceEpoch((json['startedAt'] as num?)?.toInt() ?? 0),
      endedAt: DateTime.fromMillisecondsSinceEpoch((json['endedAt'] as num?)?.toInt() ?? 0),
      durationMinutes: (json['duration'] as num?)?.toInt() ?? 0,
      timeListening: (json['timeListening'] as num?)?.toDouble() ?? 0,
      mediaPlayer: json['mediaPlayer'] as String?,
    );
  }
}

/// User Stats
class UserStats {
  final int totalTimeListened;
  final int totalBooks;
  final int totalSessions;
  final double avgSessionDuration;
  final Map<String, int> timeByGenre;
  
  UserStats({
    required this.totalTimeListened,
    required this.totalBooks,
    required this.totalSessions,
    required this.avgSessionDuration,
    required this.timeByGenre,
  });
  
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalTimeListened: (json['totalTimeListened'] as num?)?.toInt() ?? 0,
      totalBooks: (json['totalBooks'] as num?)?.toInt() ?? 0,
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
      avgSessionDuration: (json['avgSessionDuration'] as num?)?.toDouble() ?? 0,
      timeByGenre: Map<String, int>.from(json['timeByGenre'] as Map? ?? {}),
    );
  }
  
  factory UserStats.empty() => UserStats(
    totalTimeListened: 0,
    totalBooks: 0,
    totalSessions: 0,
    avgSessionDuration: 0,
    timeByGenre: {},
  );
  
  String get formattedTotalTime {
    final hours = (totalTimeListened / 3600).floor();
    final minutes = ((totalTimeListened % 3600) / 60).floor();
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }
}

/// Riverpod Provider
final audiobookshelfServiceProvider = StateProvider<AudiobookshelfService?>((ref) {
  return null;
});
