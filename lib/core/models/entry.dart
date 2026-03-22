import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'entry.g.dart';

/// Journal Entry - Ein einzelner Eintrag im Journal
/// 
/// Speichert alle Informationen zu einem Eintrag inklusive:
/// - Markdown-Inhalt mit YAML-Frontmatter
/// - Metadaten (Stimmung, Energie, Tags, etc.)
/// - Verweise auf Medien und Vault
@collection
class Entry {
  /// Eindeutige ID (UUID-basiert)
  Id id = Isar.autoIncrement;
  
  /// UUID für externe Referenzierung
  @Index(unique: true)
  late String uuid;
  
  /// Vault-Referenz
  @Index()
  int vaultId = 0;
  
  /// Titel des Eintrags
  String title = '';
  
  /// Markdown-Inhalt (inkl. YAML-Frontmatter)
  String content = '';
  
  /// YAML-Frontmatter als JSON-String
  String frontmatter = '{}';
  
  /// Eintragstyp (note, mood, photo, etc.)
  @Index()
  String entryType = 'note';
  
  /// Erstellungsdatum
  @Index()
  DateTime createdAt = DateTime.now();
  
  /// Änderungsdatum
  DateTime updatedAt = DateTime.now();
  
  /// Datum des Eintrags (kann von createdAt abweichen)
  @Index()
  DateTime entryDate = DateTime.now();
  
  /// Tags als kommagetrennte Liste
  @Index()
  String tags = '';
  
  /// Stimmung (1-5)
  int? mood;
  
  /// Energie (1-5)
  int? energy;
  
  /// Schlafstunden
  double? sleepHours;
  
  /// Ort (als "lat,lng" String)
  String? location;
  
  /// Ort-Name
  String? locationName;
  
  /// Wetter-Bedingung
  String? weather;
  
  /// Temperatur in Grad Celsius
  double? temperature;
  
  /// Mondphase
  String? moonPhase;
  
  /// Verknüpfte Medien-IDs (komma-getrennt)
  String mediaIds = '';
  
  /// Favorit-Markierung
  @Index()
  bool isFavorite = false;
  
  /// Gelöscht-Markierung (Soft Delete)
  @Index()
  bool isDeleted = false;
  
  /// Gelöscht am
  DateTime? deletedAt;
  
  /// Template-ID falls aus Template erstellt
  @Index()
  String? templateId;
  
  /// Streak-Status beim Erstellen
  int? streakAtCreation;
  
  /// XP erhalten für diesen Eintrag
  int xpEarned = 0;
  
  /// Konstruktor
  Entry() {
    uuid = const Uuid().v4();
  }
  
  /// Erstelle Eintrag aus Markdown-Datei
  factory Entry.fromMarkdown({
    required String content,
    required int vaultId,
    Map<String, dynamic>? frontmatter,
  }) {
    final entry = Entry()
      ..vaultId = vaultId
      ..content = content
      ..frontmatter = _mapToJson(frontmatter ?? {});
    
    // Parse title from first heading
    final titleMatch = RegExp(r'^#\s+(.+)$', multiLine: true).firstMatch(content);
    if (titleMatch != null) {
      entry.title = titleMatch.group(1) ?? '';
    }
    
    // Extract tags from frontmatter
    if (frontmatter != null && frontmatter['tags'] != null) {
      final tags = frontmatter['tags'];
      if (tags is List) {
        entry.tags = tags.join(',');
      } else if (tags is String) {
        entry.tags = tags;
      }
    }
    
    // Extract other properties from frontmatter
    if (frontmatter != null) {
      entry.mood = frontmatter['mood'] as int?;
      entry.energy = frontmatter['energy'] as int?;
      entry.sleepHours = (frontmatter['sleep'] as num?)?.toDouble();
      entry.entryType = frontmatter['entry_type'] as String? ?? 'note';
      
      if (frontmatter['date'] != null) {
        entry.entryDate = DateTime.tryParse(frontmatter['date'].toString()) ?? DateTime.now();
      }
      
      if (frontmatter['location'] != null) {
        entry.locationName = frontmatter['location'].toString();
      }
    }
    
    return entry;
  }
  
  /// Konvertiere zu Markdown mit YAML-Frontmatter
  String toMarkdown() {
    final buffer = StringBuffer();
    
    // YAML Frontmatter
    buffer.writeln('---');
    buffer.writeln('title: "$title"');
    buffer.writeln('date: ${entryDate.toIso8601String()}');
    buffer.writeln('entry_type: "$entryType"');
    
    if (mood != null) buffer.writeln('mood: $mood');
    if (energy != null) buffer.writeln('energy: $energy');
    if (sleepHours != null) buffer.writeln('sleep: $sleepHours');
    if (tags.isNotEmpty) buffer.writeln('tags: [${tags.split(',').map((t) => '"$t"').join(', ')}]');
    if (locationName != null) buffer.writeln('location: "$locationName"');
    if (weather != null) buffer.writeln('weather: "$weather"');
    if (moonPhase != null) buffer.writeln('moon_phase: "$moonPhase"');
    
    buffer.writeln('---');
    buffer.writeln();
    buffer.write(content);
    
    return buffer.toString();
  }
  
  /// Tag-Liste
  List<String> get tagList => tags.isEmpty ? [] : tags.split(',');
  
  /// Medien-ID-Liste
  List<int> get mediaIdList => mediaIds.isEmpty
      ? []
      : mediaIds.split(',')
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .toList();
  
  static String _mapToJson(Map<String, dynamic> map) {
    // Simple JSON conversion (use jsonEncode in production)
    return map.entries
        .map((e) => '${e.key}: ${_valueToString(e.value)}')
        .join('\n');
  }
  
  static String _valueToString(dynamic value) {
    if (value is String) return '"$value"';
    if (value is List) return '[${value.map(_valueToString).join(', ')}]';
    return value.toString();
  }
  
  /// Konvertiere zu JSON (für Sync)
  Map<String, dynamic> toJson() => {
    'id': id,
    'uuid': uuid,
    'vaultId': vaultId,
    'title': title,
    'content': content,
    'frontmatter': frontmatter,
    'entryType': entryType,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'entryDate': entryDate.toIso8601String(),
    'tags': tags,
    'mood': mood,
    'energy': energy,
    'sleepHours': sleepHours,
    'location': location,
    'locationName': locationName,
    'weather': weather,
    'temperature': temperature,
    'moonPhase': moonPhase,
    'mediaIds': mediaIds,
    'isFavorite': isFavorite,
    'isDeleted': isDeleted,
    'deletedAt': deletedAt?.toIso8601String(),
    'templateId': templateId,
    'streakAtCreation': streakAtCreation,
    'xpEarned': xpEarned,
  };
  
  /// Erstelle aus JSON (für Sync)
  factory Entry.fromJson(Map<String, dynamic> json) {
    final entry = Entry()
      ..id = json['id'] as int? ?? Isar.autoIncrement
      ..uuid = json['uuid'] as String
      ..vaultId = json['vaultId'] as int? ?? 0
      ..title = json['title'] as String? ?? ''
      ..content = json['content'] as String? ?? ''
      ..frontmatter = json['frontmatter'] as String? ?? '{}'
      ..entryType = json['entryType'] as String? ?? 'note'
      ..createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now()
      ..updatedAt = DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now()
      ..entryDate = DateTime.tryParse(json['entryDate'] as String? ?? '') ?? DateTime.now()
      ..tags = json['tags'] as String? ?? ''
      ..mood = json['mood'] as int?
      ..energy = json['energy'] as int?
      ..sleepHours = (json['sleepHours'] as num?)?.toDouble()
      ..location = json['location'] as String?
      ..locationName = json['locationName'] as String?
      ..weather = json['weather'] as String?
      ..temperature = (json['temperature'] as num?)?.toDouble()
      ..moonPhase = json['moonPhase'] as String?
      ..mediaIds = json['mediaIds'] as String? ?? ''
      ..isFavorite = json['isFavorite'] as bool? ?? false
      ..isDeleted = json['isDeleted'] as bool? ?? false
      ..templateId = json['templateId'] as String?
      ..streakAtCreation = json['streakAtCreation'] as int?
      ..xpEarned = json['xpEarned'] as int? ?? 0;
    
    if (json['deletedAt'] != null) {
      entry.deletedAt = DateTime.tryParse(json['deletedAt'] as String? ?? '');
    }
    
    return entry;
  }
}
