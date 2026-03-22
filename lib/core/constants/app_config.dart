/// App Configuration - Constants and Settings
/// 
/// Zentrale Konfiguration für:
/// - App-Metadaten
/// - Feature Flags
/// - Default-Werte
/// - Limits und Constraints

class AppConfig {
  // ==================== APP INFO ====================
  
  static const String appName = 'LifeSync';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appDescription = 'Dein persönliches Journal für Gedanken, Erlebnisse und Erinnerungen.';
  
  // ==================== FEATURE FLAGS ====================
  
  /// Enable experimental features
  static const bool enableExperimentalFeatures = false;
  
  /// Enable LAN Sync
  static const bool enableLanSync = true;
  
  /// Enable Samsung Health integration
  static const bool enableSamsungHealth = true;
  
  /// Enable Home Screen Widgets
  static const bool enableHomeWidgets = true;
  
  /// Enable Audiobookshelf integration
  static const bool enableAudiobookshelf = true;
  
  // ==================== STORAGE ====================
  
  /// Database name
  static const String databaseName = 'lifesync';
  
  /// Maximum entries per page
  static const int maxEntriesPerPage = 50;
  
  /// Maximum media file size (in bytes) - 100MB
  static const int maxMediaFileSize = 100 * 1024 * 1024;
  
  /// Maximum media files per entry
  static const int maxMediaPerEntry = 10;
  
  /// Maximum tag length
  static const int maxTagLength = 50;
  
  /// Maximum tags per entry
  static const int maxTagsPerEntry = 10;
  
  /// Maximum title length
  static const int maxTitleLength = 200;
  
  /// Maximum content length
  static const int maxContentLength = 100000;
  
  // ==================== ENCRYPTION ====================
  
  /// Encryption algorithm
  static const String encryptionAlgorithm = 'AES-256-GCM';
  
  /// Key derivation iterations
  static const int keyDerivationIterations = 100000;
  
  /// Salt length in bytes
  static const int saltLength = 32;
  
  /// IV length in bytes
  static const int ivLength = 12;
  
  // ==================== LAN SYNC ====================
  
  /// Discovery port for LAN sync
  static const int syncDiscoveryPort = 37421;
  
  /// Sync port for LAN sync
  static const int syncPort = 37422;
  
  /// Service type for mDNS discovery
  static const String syncServiceType = '_lifesync._tcp';
  
  /// Maximum sync connections
  static const int maxSyncConnections = 5;
  
  /// Sync timeout in seconds
  static const int syncTimeoutSeconds = 30;
  
  /// Auto-sync interval in minutes
  static const int autoSyncIntervalMinutes = 60;
  
  // ==================== HEALTH ====================
  
  /// Steps goal per day
  static const int stepsGoalPerDay = 10000;
  
  /// Sleep goal in hours
  static const double sleepGoalHours = 8.0;
  
  /// Heart rate normal range
  static const int heartRateMin = 60;
  static const int heartRateMax = 100;
  
  /// Health data sync interval in minutes
  static const int healthSyncIntervalMinutes = 30;
  
  // ==================== GAMIFICATION ====================
  
  /// XP per entry
  static const int xpPerEntry = 10;
  
  /// XP bonus for streak (per week)
  static const int xpStreakBonusPerWeek = 20;
  
  /// XP for completing daily goal
  static const int xpDailyGoalBonus = 5;
  
  /// XP multiplier for weekends
  static const double xpWeekendMultiplier = 1.5;
  
  /// XP required per level
  static const int xpPerLevel = 100;
  
  // ==================== QUICK ENTRY ====================
  
  /// Default entry type
  static const String defaultEntryType = 'note';
  
  /// Quick entry animation duration in milliseconds
  static const int quickEntryAnimationMs = 200;
  
  /// Quick entry timeout in seconds
  static const int quickEntryTimeoutSeconds = 300;
  
  // ==================== UI ====================
  
  /// Default theme mode
  static const String defaultThemeMode = 'system';
  
  /// Default font size
  static const double defaultFontSize = 16.0;
  
  /// Minimum font size
  static const double minFontSize = 12.0;
  
  /// Maximum font size
  static const double maxFontSize = 24.0;
  
  /// Animation duration in milliseconds
  static const int animationDurationMs = 300;
  
  /// Toast duration in seconds
  static const int toastDurationSeconds = 3;
  
  // ==================== WIDGETS ====================
  
  /// Widget refresh interval in minutes
  static const int widgetRefreshIntervalMinutes = 60;
  
  /// Maximum quote length for widget
  static const int maxQuoteLengthForWidget = 150;
  
  // ==================== AUDIOBOOKSHELF ====================
  
  /// Audiobookshelf API version
  static const String audiobookshelfApiVersion = '1.0';
  
  /// Maximum sessions to fetch
  static const int maxSessionsToFetch = 50;
  
  // ==================== VALIDATION ====================
  
  /// Password minimum length
  static const int passwordMinLength = 8;
  
  /// Password maximum length
  static const int passwordMaxLength = 128;
  
  /// Username minimum length
  static const int usernameMinLength = 3;
  
  /// Username maximum length
  static const int usernameMaxLength = 32;
  
  // ==================== TIME FORMATS ====================
  
  /// Date format for display
  static const String dateFormat = 'dd.MM.yyyy';
  
  /// Time format for display
  static const String timeFormat = 'HH:mm';
  
  /// Date time format for display
  static const String dateTimeFormat = 'dd.MM.yyyy HH:mm';
  
  /// ISO 8601 format for storage
  static const String isoDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS";
  
  // ==================== FILE EXTENSIONS ====================
  
  /// Supported image extensions
  static const List<String> supportedImageExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif',
  ];
  
  /// Supported audio extensions
  static const List<String> supportedAudioExtensions = [
    'mp3', 'm4a', 'wav', 'ogg', 'aac', 'flac',
  ];
  
  /// Supported video extensions
  static const List<String> supportedVideoExtensions = [
    'mp4', 'mov', 'avi', 'mkv', 'webm',
  ];
  
  /// Supported document extensions
  static const List<String> supportedDocumentExtensions = [
    'pdf', 'txt', 'md', 'json', 'csv',
  ];
  
  // ==================== ERROR MESSAGES ====================
  
  static const String errorGeneric = 'Ein Fehler ist aufgetreten. Bitte versuche es erneut.';
  static const String errorNetwork = 'Keine Netzwerkverbindung verfügbar.';
  static const String errorStorage = 'Fehler beim Speichern der Daten.';
  static const String errorEncryption = 'Fehler bei der Verschlüsselung.';
  static const String errorPermission = 'Berechtigung verweigert.';
  static const String errorNotFound = 'Nicht gefunden.';
  static const String errorInvalidInput = 'Ungültige Eingabe.';
  static const String errorSyncFailed = 'Synchronisation fehlgeschlagen.';
  static const String errorHealthNotConnected = 'Samsung Health nicht verbunden.';
  static const String errorVaultLocked = 'Vault ist gesperrt.';
}

/// Entry Types Configuration
class EntryTypes {
  static const List<String> all = [
    'note',
    'mood',
    'photo',
    'audio',
    'workout',
    'gratitude',
    'goal',
    'checkin',
    'journal',
    'dream',
    'idea',
    'event',
    'health',
    'audiobook',
  ];
  
  static const Map<String, String> icons = {
    'note': '📝',
    'mood': '😊',
    'photo': '📷',
    'audio': '🎙️',
    'workout': '🏃',
    'gratitude': '🙏',
    'goal': '🎯',
    'checkin': '✅',
    'journal': '📔',
    'dream': '💭',
    'idea': '💡',
    'event': '📅',
    'health': '❤️',
    'audiobook': '🎧',
  };
  
  static const Map<String, String> names = {
    'note': 'Notiz',
    'mood': 'Stimmung',
    'photo': 'Foto',
    'audio': 'Audio',
    'workout': 'Workout',
    'gratitude': 'Dankbarkeit',
    'goal': 'Ziel',
    'checkin': 'Check-in',
    'journal': 'Journal',
    'dream': 'Traum',
    'idea': 'Idee',
    'event': 'Ereignis',
    'health': 'Gesundheit',
    'audiobook': 'Hörbuch',
  };
}
