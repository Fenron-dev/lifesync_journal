import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/entry.dart';
import 'storage_service.dart';

/// Home Screen Widget Service
/// 
/// Unterstützt drei Widget-Typen:
/// 1. Quick Entry Widget - Schneller Eintrag mit einem Tap
/// 2. Streak Widget - Zeigt aktuelle Streak und XP
/// 3. Daily Quote Widget - Tägliches Zitat mit Streak
/// 
/// Platform-spezifische Implementierung:
/// - iOS: home_widget package
/// - Android: flutter_android_widgets + WorkManager
class HomeWidgetService {
  final StorageService _storage;
  
  // Widget IDs
  static const String quickEntryWidgetId = 'lifesync_quick_entry';
  static const String streakWidgetId = 'lifesync_streak';
  static const String quoteWidgetId = 'lifesync_quote';
  
  // Callback IDs
  static const String quickEntryCallback = 'quickEntryCallback';
  static const String refreshCallback = 'refreshCallback';
  
  // Status
  final _widgetUpdateController = StreamController<WidgetUpdate>.broadcast();
  Stream<WidgetUpdate> get widgetUpdates => _widgetUpdateController.stream;
  
  // Cached Data
  int _currentStreak = 0;
  int _totalXP = 0;
  String _dailyQuote = '';
  int _entriesToday = 0;
  
  HomeWidgetService(this._storage);
  
  // ==================== INITIALIZATION ====================
  
  /// Initialisiere Widget-Service
  Future<void> initialize() async {
    // Lade gespeicherte Daten
    await _loadWidgetData();
    
    // Registriere Callbacks
    await _registerCallbacks();
    
    // Update alle Widgets
    await updateAllWidgets();
  }
  
  /// Lade Widget-Daten aus Speicher
  Future<void> _loadWidgetData() async {
    final prefs = await SharedPreferences.getInstance();
    
    _currentStreak = prefs.getInt('widget_streak') ?? 0;
    _totalXP = prefs.getInt('widget_xp') ?? 0;
    _dailyQuote = prefs.getString('widget_daily_quote') ?? _getDefaultQuote();
    
    // Berechne Einträge heute
    final today = DateTime.now();
    final entries = await _storage.loadEntriesForDate(today);
    _entriesToday = entries.length;
  }
  
  /// Registriere Widget-Callbacks
  Future<void> _registerCallbacks() async {
    // In echter Implementierung mit home_widget package:
    // await HomeWidget.registerInteractiveCallback(
    //   interactiveCallback: quickEntryCallback,
    //   callback: _handleQuickEntry,
    // );
    // 
    // await HomeWidget.registerInteractiveCallback(
    //   interactiveCallback: refreshCallback,
    //   callback: _handleRefresh,
    // );
  }
  
  // ==================== WIDGET UPDATES ====================
  
  /// Update alle Widgets
  Future<void> updateAllWidgets() async {
    await Future.wait([
      updateQuickEntryWidget(),
      updateStreakWidget(),
      updateQuoteWidget(),
    ]);
  }
  
  /// Update Quick Entry Widget
  Future<void> updateQuickEntryWidget() async {
    final data = QuickEntryWidgetData(
      entriesToday: _entriesToday,
      streak: _currentStreak,
      lastEntryTime: DateTime.now(),
    );
    
    await _saveWidgetData(quickEntryWidgetId, data.toJson());
    
    // Platform-spezifisches Update
    if (Platform.isIOS) {
      await _updateIOSWidget(quickEntryWidgetId, data.toJson());
    } else if (Platform.isAndroid) {
      await _updateAndroidWidget(quickEntryWidgetId, data.toJson());
    }
    
    _widgetUpdateController.add(WidgetUpdate(
      widgetId: quickEntryWidgetId,
      data: data.toJson(),
      timestamp: DateTime.now(),
    ));
  }
  
  /// Update Streak Widget
  Future<void> updateStreakWidget() async {
    final data = StreakWidgetData(
      streak: _currentStreak,
      xp: _totalXP,
      level: _calculateLevel(_totalXP),
      progress: _calculateLevelProgress(_totalXP),
      entriesToday: _entriesToday,
    );
    
    await _saveWidgetData(streakWidgetId, data.toJson());
    
    if (Platform.isIOS) {
      await _updateIOSWidget(streakWidgetId, data.toJson());
    } else if (Platform.isAndroid) {
      await _updateAndroidWidget(streakWidgetId, data.toJson());
    }
    
    _widgetUpdateController.add(WidgetUpdate(
      widgetId: streakWidgetId,
      data: data.toJson(),
      timestamp: DateTime.now(),
    ));
  }
  
  /// Update Quote Widget
  Future<void> updateQuoteWidget() async {
    // Tägliches Zitat aktualisieren
    await _updateDailyQuote();
    
    final data = QuoteWidgetData(
      quote: _dailyQuote,
      author: _getQuoteAuthor(),
      streak: _currentStreak,
      date: DateTime.now(),
    );
    
    await _saveWidgetData(quoteWidgetId, data.toJson());
    
    if (Platform.isIOS) {
      await _updateIOSWidget(quoteWidgetId, data.toJson());
    } else if (Platform.isAndroid) {
      await _updateAndroidWidget(quoteWidgetId, data.toJson());
    }
    
    _widgetUpdateController.add(WidgetUpdate(
      widgetId: quoteWidgetId,
      data: data.toJson(),
      timestamp: DateTime.now(),
    ));
  }
  
  // ==================== QUICK ENTRY FROM WIDGET ====================
  
  /// Handle Quick Entry vom Widget
  Future<Entry> handleQuickEntryFromWidget({
    String type = 'note',
    String? content,
  }) async {
    // Erstelle neuen Eintrag
    final entry = Entry()
      ..entryType = type
      ..title = 'Quick Entry'
      ..content = content ?? ''
      ..entryDate = DateTime.now();
    
    // Speichere Eintrag
    final savedEntry = await _storage.saveEntry(entry);
    
    // Update Streak und XP
    await _updateStreakAndXP();
    
    // Update Widgets
    await updateAllWidgets();
    
    // Benachrichtige App
    _widgetUpdateController.add(WidgetUpdate(
      widgetId: 'quick_entry_created',
      data: {'entryId': savedEntry.id},
      timestamp: DateTime.now(),
    ));
    
    return savedEntry;
  }
  
  /// Update Streak und XP nach Eintrag
  Future<void> _updateStreakAndXP() async {
    final today = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    
    // Prüfe ob heute schon ein Eintrag erstellt wurde
    final lastEntryDate = prefs.getString('last_entry_date');
    final todayStr = '${today.year}-${today.month}-${today.day}';
    
    if (lastEntryDate != todayStr) {
      // Neuer Tag - prüfe Streak
      final lastDate = lastEntryDate != null 
          ? DateTime.parse(lastEntryDate) 
          : null;
      
      if (lastDate != null) {
        final diff = today.difference(lastDate).inDays;
        if (diff == 1) {
          // Streak fortgesetzt
          _currentStreak++;
        } else if (diff > 1) {
          // Streak gebrochen
          _currentStreak = 1;
        }
      } else {
        _currentStreak = 1;
      }
      
      // XP hinzu
      final xp = _calculateXPForEntry(today);
      _totalXP += xp;
      
      // Speichere
      await prefs.setString('last_entry_date', todayStr);
      await prefs.setInt('widget_streak', _currentStreak);
      await prefs.setInt('widget_xp', _totalXP);
    }
    
    // Update entries today
    final entries = await _storage.loadEntriesForDate(today);
    _entriesToday = entries.length;
  }
  
  // ==================== WIDGET CONFIGURATION ====================
  
  /// Konfiguriere Widget
  Future<void> configureWidget({
    required String widgetId,
    required WidgetType type,
    Map<String, dynamic>? config,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('widget_type_$widgetId', type.name);
    if (config != null) {
      await prefs.setString('widget_config_$widgetId', jsonEncode(config));
    }
    
    // Update das Widget
    switch (type) {
      case WidgetType.quickEntry:
        await updateQuickEntryWidget();
        break;
      case WidgetType.streak:
        await updateStreakWidget();
        break;
      case WidgetType.quote:
        await updateQuoteWidget();
        break;
    }
  }
  
  /// Entferne Widget
  Future<void> removeWidget(String widgetId) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove('widget_type_$widgetId');
    await prefs.remove('widget_config_$widgetId');
    await prefs.remove('widget_data_$widgetId');
  }
  
  // ==================== BACKGROUND UPDATES ====================
  
  /// Starte tägliche Hintergrund-Updates
  Future<void> startBackgroundUpdates() async {
    // In echter Implementierung mit workmanager oder background_fetch:
    // await Workmanager.initialize(
    //   callbackDispatcher,
    //   isInDebugMode: false,
    // );
    // 
    // await Workmanager.registerPeriodicTask(
    //   'widget-update',
    //   'updateWidgets',
    //   frequency: Duration(hours: 1),
    // );
  }
  
  /// Stoppe Hintergrund-Updates
  Future<void> stopBackgroundUpdates() async {
    // await Workmanager.cancelByTag('widget-update');
  }
  
  // ==================== PLATFORM-SPECIFIC ====================
  
  /// iOS Widget Update
  Future<void> _updateIOSWidget(String widgetId, Map<String, dynamic> data) async {
    // Mit home_widget package:
    // await HomeWidget.saveWidgetData(widgetId, data);
    // await HomeWidget.updateWidget(
    //   name: widgetId,
    //   iOSName: 'LifeSync_$widgetId',
    // );
  }
  
  /// Android Widget Update
  Future<void> _updateAndroidWidget(String widgetId, Map<String, dynamic> data) async {
    // Mit flutter_android_widgets:
    // await AndroidWidget.updateWidget(
    //   widgetId: widgetId,
    //   data: data,
    // );
  }
  
  /// Speichere Widget-Daten
  Future<void> _saveWidgetData(String widgetId, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('widget_data_$widgetId', jsonEncode(data));
  }
  
  // ==================== QUOTES ====================
  
  /// Update tägliches Zitat
  Future<void> _updateDailyQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final lastQuoteDate = prefs.getString('last_quote_date');
    final today = '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
    
    if (lastQuoteDate != today) {
      // Neues Zitat für heute
      _dailyQuote = _getRandomQuote();
      await prefs.setString('widget_daily_quote', _dailyQuote);
      await prefs.setString('last_quote_date', today);
    }
  }
  
  /// Zitate-Sammlung
  static const List<Map<String, String>> _quotes = [
    {'quote': 'Der einzige Weg, großartige Arbeit zu leisten, ist zu lieben, was man tut.', 'author': 'Steve Jobs'},
    {'quote': 'Jeder Tag ist eine neue Chance, das zu tun, wovon du träumst.', 'author': 'Unbekannt'},
    {'quote': 'Der Anfang ist der wichtigste Teil der Arbeit.', 'author': 'Platon'},
    {'quote': 'Kleine Schritte führen zu großen Ergebnissen.', 'author': 'Unbekannt'},
    {'quote': 'Schreibe es auf, bevor es verloren geht.', 'author': 'Unbekannt'},
    {'quote': 'Dankbarkeit ist das Gedächtnis des Herzens.', 'author': 'Jean-Baptiste Massieu'},
    {'quote': 'Jede Reise beginnt mit einem ersten Schritt.', 'author': 'Lao Tzu'},
    {'quote': 'Das Leben ist das, was passiert, während du andere Pläne machst.', 'author': 'John Lennon'},
    {'quote': 'Sei du selbst die Veränderung, die du dir wünschst für diese Welt.', 'author': 'Mahatma Gandhi'},
    {'quote': 'Der beste Zeitpunkt, einen Baum zu pflanzen, war vor 20 Jahren. Der zweitbeste ist jetzt.', 'author': 'Chinesisches Sprichwort'},
  ];
  
  String _getRandomQuote() {
    final index = DateTime.now().day % _quotes.length;
    return _quotes[index]['quote']!;
  }
  
  String _getQuoteAuthor() {
    final index = DateTime.now().day % _quotes.length;
    return _quotes[index]['author']!;
  }
  
  String _getDefaultQuote() {
    return _quotes[0]['quote']!;
  }
  
  // ==================== HELPERS ====================
  
  int _calculateLevel(int xp) {
    // Level = floor(sqrt(xp / 100))
    return (xp / 100).floor();
  }
  
  double _calculateLevelProgress(int xp) {
    final currentLevel = _calculateLevel(xp);
    final xpInCurrentLevel = xp - (currentLevel * 100);
    return xpInCurrentLevel / 100;
  }
  
  int _calculateXPForEntry(DateTime date) {
    // Basis XP
    int xp = 10;
    
    // Bonus für Streak
    if (_currentStreak > 7) xp += 5;
    if (_currentStreak > 14) xp += 10;
    if (_currentStreak > 30) xp += 20;
    
    // Bonus für Wochenende
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      xp += 5;
    }
    
    return xp;
  }
  
  /// Dispose
  void dispose() {
    _widgetUpdateController.close();
  }
}

// ==================== DATA MODELS ====================

/// Widget Type
enum WidgetType {
  quickEntry,
  streak,
  quote,
}

/// Widget Update Event
class WidgetUpdate {
  final String widgetId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  WidgetUpdate({
    required this.widgetId,
    required this.data,
    required this.timestamp,
  });
}

/// Quick Entry Widget Data
class QuickEntryWidgetData {
  final int entriesToday;
  final int streak;
  final DateTime lastEntryTime;
  
  QuickEntryWidgetData({
    required this.entriesToday,
    required this.streak,
    required this.lastEntryTime,
  });
  
  Map<String, dynamic> toJson() => {
    'entriesToday': entriesToday,
    'streak': streak,
    'lastEntryTime': lastEntryTime.toIso8601String(),
  };
}

/// Streak Widget Data
class StreakWidgetData {
  final int streak;
  final int xp;
  final int level;
  final double progress;
  final int entriesToday;
  
  StreakWidgetData({
    required this.streak,
    required this.xp,
    required this.level,
    required this.progress,
    required this.entriesToday,
  });
  
  Map<String, dynamic> toJson() => {
    'streak': streak,
    'xp': xp,
    'level': level,
    'progress': progress,
    'entriesToday': entriesToday,
  };
}

/// Quote Widget Data
class QuoteWidgetData {
  final String quote;
  final String author;
  final int streak;
  final DateTime date;
  
  QuoteWidgetData({
    required this.quote,
    required this.author,
    required this.streak,
    required this.date,
  });
  
  Map<String, dynamic> toJson() => {
    'quote': quote,
    'author': author,
    'streak': streak,
    'date': date.toIso8601String(),
  };
}

/// Widget Configuration
class WidgetConfig {
  final String widgetId;
  final WidgetType type;
  final Map<String, dynamic>? customConfig;
  
  WidgetConfig({
    required this.widgetId,
    required this.type,
    this.customConfig,
  });
}

/// Riverpod Provider
final homeWidgetServiceProvider = StateProvider<HomeWidgetService?>((ref) {
  return null; // Wird in main.dart initialisiert
});
