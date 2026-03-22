import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'vault.g.dart';

/// Vault - Ein verschlüsselter Speicherbereich
/// 
/// Jeder Vault ist ein eigenständiger, verschlüsselter Bereich,
/// der verschiedene Einträge, Medien und Konfigurationen enthält.
/// Vaults werden als Ordner im Dateisystem gespeichert.
@collection
class Vault {
  /// Eindeutige ID
  Id id = Isar.autoIncrement;
  
  /// UUID für externe Referenzierung
  @Index(unique: true)
  late String uuid;
  
  /// Name des Vaults
  @Index()
  late String name;
  
  /// Beschreibung
  String description = '';
  
  /// Icon-Name (Material Icons)
  String iconName = 'folder';
  
  /// Farbe (als Hex-String)
  String colorHex = '#1F4E79';
  
  /// Pfad zum Vault-Ordner (relativ oder absolut)
  @Index(unique: true)
  late String path;
  
  /// Erstellungsdatum
  DateTime createdAt = DateTime.now();
  
  /// Änderungsdatum
  DateTime updatedAt = DateTime.now();
  
  /// Anzahl der Einträge (denormalisiert für Performance)
  int entryCount = 0;
  
  /// Gesamtgröße in Bytes
  int totalSizeBytes = 0;
  
  /// Ist der Vault verschlüsselt?
  bool isEncrypted = true;
  
  /// Ist der Vault aktuell geöffnet?
  @ignore
  bool isOpen = false;
  
  /// Zeitstempel der letzten Öffnung
  DateTime? lastOpenedAt;
  
  /// Standard-Vault für neue Einträge?
  @Index()
  bool isDefault = false;
  
  /// Sync-Provider (none, icloud, dropbox, syncthing, local)
  String syncProvider = 'none';
  
  /// Sync-Status
  String syncStatus = 'not_configured';
  
  /// Letzter Sync-Zeitstempel
  DateTime? lastSyncedAt;
  
  /// Vault-Typ (personal, fitness, media, projects, travel)
  @Index()
  String vaultType = 'personal';
  
  /// Template für Daily Notes
  String dailyTemplate = '';
  
  /// Konstruktor
  Vault() {
    uuid = const Uuid().v4();
  }
  
  /// Erstelle einen neuen Vault
  factory Vault.create({
    required String name,
    required String path,
    String iconName = 'folder',
    String colorHex = '#1F4E79',
    bool isEncrypted = true,
    String vaultType = 'personal',
  }) {
    return Vault()
      ..name = name
      ..path = path
      ..iconName = iconName
      ..colorHex = colorHex
      ..isEncrypted = isEncrypted
      ..vaultType = vaultType;
  }
  
  /// Pfad zur Attachments-Ordner
  String get attachmentsPath => '$path/attachments';
  
  /// Pfad zur Config-Datei
  String get configPath => '$path/lifesync.yaml';
  
  /// Pfad zur Index-Datenbank
  String get indexPath => '$path/.lifesync/index.db';
  
  /// Menschenlesbare Größe
  String get readableSize {
    if (totalSizeBytes < 1024) return '$totalSizeBytes B';
    if (totalSizeBytes < 1024 * 1024) return '${(totalSizeBytes / 1024).toStringAsFixed(1)} KB';
    if (totalSizeBytes < 1024 * 1024 * 1024) {
      return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(totalSizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Konvertiere zu JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'name': name,
    'description': description,
    'iconName': iconName,
    'colorHex': colorHex,
    'path': path,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'entryCount': entryCount,
    'totalSizeBytes': totalSizeBytes,
    'isEncrypted': isEncrypted,
    'lastOpenedAt': lastOpenedAt?.toIso8601String(),
    'isDefault': isDefault,
    'syncProvider': syncProvider,
    'syncStatus': syncStatus,
    'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    'vaultType': vaultType,
    'dailyTemplate': dailyTemplate,
  };
  
  /// Erstelle aus JSON
  factory Vault.fromJson(Map<String, dynamic> json) {
    return Vault()
      ..id = json['id'] as int? ?? Isar.autoIncrement
      ..uuid = json['uuid'] as String
      ..name = json['name'] as String
      ..description = json['description'] as String? ?? ''
      ..iconName = json['iconName'] as String? ?? 'folder'
      ..colorHex = json['colorHex'] as String? ?? '#1F4E79'
      ..path = json['path'] as String
      ..createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now()
      ..updatedAt = DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now()
      ..entryCount = json['entryCount'] as int? ?? 0
      ..totalSizeBytes = json['totalSizeBytes'] as int? ?? 0
      ..isEncrypted = json['isEncrypted'] as bool? ?? true
      ..lastOpenedAt = json['lastOpenedAt'] != null
          ? DateTime.tryParse(json['lastOpenedAt'] as String? ?? '')
          : null
      ..isDefault = json['isDefault'] as bool? ?? false
      ..syncProvider = json['syncProvider'] as String? ?? 'none'
      ..syncStatus = json['syncStatus'] as String? ?? 'not_configured'
      ..lastSyncedAt = json['lastSyncedAt'] != null
          ? DateTime.tryParse(json['lastSyncedAt'] as String? ?? '')
          : null
      ..vaultType = json['vaultType'] as String? ?? 'personal'
      ..dailyTemplate = json['dailyTemplate'] as String? ?? '';
  }
}

/// Vault-Typen mit Beschreibungen
enum VaultType {
  personal('Persönlich', 'Persönliches Tagebuch mit allen Einträgen', 'person', '#1F4E79'),
  fitness('Fitness', 'Sport, Gesundheit und Ernährung', 'fitness_center', '#2E7D32'),
  media('Medien', 'Konsumierte Filme, Serien, Bücher', 'movie', '#7B1FA2'),
  projects('Projekte', 'Arbeit und Side-Projects', 'work', '#F57C00'),
  travel('Reisen', 'Reiseberichte und Erinnerungen', 'flight', '#00838F'),
  gratitude('Dankbarkeit', 'Dankbarkeitstagebuch', 'favorite', '#C62828'),
  habits('Gewohnheiten', 'Habit-Tracking und Ziele', 'track_changes', '#1565C0');
  
  final String label;
  final String description;
  final String iconName;
  final String defaultColor;
  
  const VaultType(this.label, this.description, this.iconName, this.defaultColor);
}
