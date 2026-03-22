import 'package:isar/isar.dart';

part 'properties.g.dart';

/// Properties - Benutzerspezifische Eigenschaften für Einträge
/// 
/// Ermöglicht die Definition von custom Properties wie:
/// - Mood, Energie, Schlaf (Standard)
/// - Gewicht, Schritte, Wasser (Fitness)
/// - Custom-Definierte Eigenschaften
@collection
class Properties {
  /// Eindeutige ID
  Id id = Isar.autoIncrement;
  
  /// Name der Property
  @Index(unique: true)
  late String name;
  
  /// Anzeigename
  late String displayName;
  
  /// Datentyp
  String propertyType = 'number'; // number, text, select, multiselect, date, boolean
  
  /// Icon-Name
  String iconName = 'label';
  
  /// Farbe (Hex)
  String colorHex = '#2E75B6';
  
  /// Beschreibung
  String description = '';
  
  /// Einheit (z.B. 'kg', 'Stunden', 'ml')
  String? unit;
  
  /// Minimalwert (für Zahlen)
  double? minValue;
  
  /// Maximalwert (für Zahlen)
  double? maxValue;
  
  /// Schrittweite (für Slider)
  double? stepValue;
  
  /// Optionen (für Select/MultiSelect, komma-getrennt)
  String options = '';
  
  /// Standardwert
  String defaultValue = '';
  
  /// Ist es eine Standard-Property?
  @Index()
  bool isBuiltin = false;
  
  /// Ist sie aktiv?
  @Index()
  bool isActive = true;
  
  /// Sortierung
  int sortOrder = 0;
  
  /// Pflichtfeld?
  bool isRequired = false;
  
  /// In Schnelleingabe anzeigen?
  bool showInQuickAdd = true;
  
  /// In Dashboard anzeigen?
  bool showInDashboard = true;
  
  /// Vault-spezifisch (leer = alle Vaults)
  @Index()
  String vaultIds = ''; // Komma-getrennt, leer = alle
  
  /// Erstellungsdatum
  DateTime createdAt = DateTime.now();
  
  /// Konstruktor
  Properties();
  
  /// Optionen als Liste
  List<String> get optionList => 
      options.isEmpty ? [] : options.split(',').map((s) => s.trim()).toList();
  
  /// Vault-IDs als Liste
  List<int> get vaultIdList => vaultIds.isEmpty
      ? []
      : vaultIds.split(',')
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .toList();
}

/// Standard-Properties
class BuiltinProperties {
  static const String mood = 'mood';
  static const String energy = 'energy';
  static const String sleep = 'sleep';
  static const String weight = 'weight';
  static const String steps = 'steps';
  static const String water = 'water';
  static const String caffeine = 'caffeine';
  static const String stress = 'stress';
  static const String pain = 'pain';
  static const String gratitude = 'gratitude_count';
  
  /// Erstelle Standard-Properties
  static List<Properties> createBuiltinProperties() {
    return [
      Properties()
        ..name = mood
        ..displayName = 'Stimmung'
        ..propertyType = 'select'
        ..iconName = 'sentiment_satisfied'
        ..options = '1,2,3,4,5'
        ..minValue = 1
        ..maxValue = 5
        ..defaultValue = '3'
        ..isBuiltin = true
        ..showInQuickAdd = true
        ..sortOrder = 1,
      
      Properties()
        ..name = energy
        ..displayName = 'Energie'
        ..propertyType = 'select'
        ..iconName = 'battery_charging_full'
        ..colorHex = '#4CAF50'
        ..options = '1,2,3,4,5'
        ..minValue = 1
        ..maxValue = 5
        ..defaultValue = '3'
        ..isBuiltin = true
        ..showInQuickAdd = true
        ..sortOrder = 2,
      
      Properties()
        ..name = sleep
        ..displayName = 'Schlaf'
        ..propertyType = 'number'
        ..iconName = 'bedtime'
        ..colorHex = '#673AB7'
        ..unit = 'h'
        ..minValue = 0
        ..maxValue = 24
        ..stepValue = 0.5
        ..defaultValue = '7'
        ..isBuiltin = true
        ..showInQuickAdd = true
        ..sortOrder = 3,
      
      Properties()
        ..name = weight
        ..displayName = 'Gewicht'
        ..propertyType = 'number'
        ..iconName = 'monitor_weight'
        ..colorHex = '#FF9800'
        ..unit = 'kg'
        ..minValue = 20
        ..maxValue = 300
        ..stepValue = 0.1
        ..isBuiltin = true
        ..showInQuickAdd = false
        ..sortOrder = 10,
      
      Properties()
        ..name = steps
        ..displayName = 'Schritte'
        ..propertyType = 'number'
        ..iconName = 'directions_walk'
        ..colorHex = '#2196F3'
        ..minValue = 0
        ..maxValue = 100000
        ..stepValue = 100
        ..isBuiltin = true
        ..showInQuickAdd = false
        ..sortOrder = 11,
      
      Properties()
        ..name = water
        ..displayName = 'Wasser'
        ..propertyType = 'number'
        ..iconName = 'water_drop'
        ..colorHex = '#03A9F4'
        ..unit = 'ml'
        ..minValue = 0
        ..maxValue = 10000
        ..stepValue = 100
        ..defaultValue = '2000'
        ..isBuiltin = true
        ..showInQuickAdd = false
        ..sortOrder = 12,
      
      Properties()
        ..name = stress
        ..displayName = 'Stress'
        ..propertyType = 'select'
        ..iconName = 'psychology'
        ..colorHex = '#F44336'
        ..options = '1,2,3,4,5'
        ..minValue = 1
        ..maxValue = 5
        ..defaultValue = '2'
        ..isBuiltin = true
        ..showInQuickAdd = true
        ..sortOrder = 4,
      
      Properties()
        ..name = gratitude
        ..displayName = 'Dankbarkeit'
        ..propertyType = 'number'
        ..iconName = 'favorite'
        ..colorHex = '#E91E63'
        ..description = 'Anzahl der Dinge, für die du dankbar bist'
        ..minValue = 0
        ..maxValue = 100
        ..stepValue = 1
        ..defaultValue = '3'
        ..isBuiltin = true
        ..showInQuickAdd = true
        ..sortOrder = 5,
    ];
  }
}

/// Property-Typen
enum PropertyType {
  number('Zahl', 'Ganze oder Dezimalzahl'),
  text('Text', 'Freitext'),
  select('Auswahl', 'Einzelne Auswahl'),
  multiselect('Mehrfachauswahl', 'Mehrere Optionen'),
  date('Datum', 'Datumsauswahl'),
  time('Zeit', 'Zeitauswahl'),
  boolean('Ja/Nein', 'Boolescher Wert'),
  rating('Bewertung', '1-5 Sterne'),
  slider('Schieberegler', 'Numerischer Slider');
  
  final String label;
  final String description;
  
  const PropertyType(this.label, this.description);
}
