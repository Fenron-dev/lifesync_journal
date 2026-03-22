import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:yaml_writer/yaml_writer.dart';

import '../models/entry.dart';
import '../models/vault.dart';
import '../models/media.dart';
import '../models/properties.dart';

/// Storage Service - Lokale Datenhaltung
/// 
/// Verwaltet:
/// - Isar-Datenbank für Index und Metadaten
/// - Markdown-Dateien mit YAML-Frontmatter
/// - Medien-Dateien im Vault-Ordner
/// - Konfigurationsdateien
class StorageService {
  final Isar _isar;
  final _uuid = const Uuid();
  final _yamlWriter = YamlWriter();
  
  StorageService(this._isar);
  
  // ==================== VAULT OPERATIONS ====================
  
  /// Erstelle einen neuen Vault
  Future<Vault> createVault({
    required String name,
    required String basePath,
    String iconName = 'folder',
    String colorHex = '#1F4E79',
    bool isEncrypted = true,
    String vaultType = 'personal',
  }) async {
    // Erstelle Vault-Ordner
    final vaultPath = p.join(basePath, _sanitizeFilename(name));
    final vaultDir = Directory(vaultPath);
    
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }
    
    // Erstelle Unterordner
    await Directory(p.join(vaultPath, 'attachments')).create();
    await Directory(p.join(vaultPath, 'daily')).create();
    await Directory(p.join(vaultPath, 'templates')).create();
    
    // Erstelle Vault-Objekt
    final vault = Vault.create(
      name: name,
      path: vaultPath,
      iconName: iconName,
      colorHex: colorHex,
      isEncrypted: isEncrypted,
      vaultType: vaultType,
    );
    
    // Speichere in Isar
    await _isar.writeTxn(() async {
      await _isar.vaults.put(vault);
    });
    
    // Erstelle Konfigurationsdatei
    await _saveVaultConfig(vault);
    
    return vault;
  }
  
  /// Lade alle Vaults
  Future<List<Vault>> loadVaults() async {
    return await _isar.vaults.where().sortByUpdatedAt().findAll();
  }
  
  /// Lade einen Vault nach ID
  Future<Vault?> loadVault(int id) async {
    return await _isar.vaults.get(id);
  }
  
  /// Lade den Standard-Vault
  Future<Vault?> loadDefaultVault() async {
    return await _isar.vaults
        .where()
        .isDefaultEqualTo(true)
        .findFirst() ?? await _isar.vaults.where().findFirst();
  }
  
  /// Setze einen Vault als Standard
  Future<void> setDefaultVault(int vaultId) async {
    await _isar.writeTxn(() async {
      // Entferne Default von allen Vaults
      final allVaults = await _isar.vaults.where().findAll();
      for (final v in allVaults) {
        v.isDefault = v.id == vaultId;
        await _isar.vaults.put(v);
      }
    });
  }
  
  // ==================== ENTRY OPERATIONS ====================
  
  /// Speichere einen Eintrag
  Future<Entry> saveEntry(Entry entry, {Vault? vault}) async {
    final targetVault = vault ?? await loadDefaultVault();
    if (targetVault == null) {
      throw Exception('Kein Vault gefunden');
    }
    
    entry.vaultId = targetVault.id;
    entry.updatedAt = DateTime.now();
    
    // Speichere in Isar
    await _isar.writeTxn(() async {
      await _isar.entrys.put(entry);

      // Aktualisiere Vault-Statistiken
      targetVault.entryCount = await _isar.entrys
          .where()
          .vaultIdEqualTo(targetVault.id)
          .count();
      targetVault.updatedAt = DateTime.now();
      await _isar.vaults.put(targetVault);
    });

    // Speichere als Markdown-Datei — bei Fehler bleibt Isar-Eintrag bestehen (inkonsistent)
    // aber ein Fehler hier sollte nicht den Isar-Schreib rückgängig machen
    try {
      await _saveEntryToFile(entry, targetVault);
    } catch (e) {
      // Datei-Schreib fehlgeschlagen; Isar-Daten sind korrekt, Datei fehlt
      // Fehler weitergeben damit der Aufrufer reagieren kann
      rethrow;
    }

    return entry;
  }
  
  /// Lade einen Eintrag nach ID
  Future<Entry?> loadEntry(int id) async {
    return await _isar.entrys.get(id);
  }
  
  /// Lade Einträge für ein Datum
  Future<List<Entry>> loadEntriesForDate(DateTime date, {int? vaultId}) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    var query = _isar.entrys
        .where()
        .entryDateBetween(startOfDay, endOfDay, includeUpper: false)
        .filter()
        .isDeletedEqualTo(false);
    
    if (vaultId != null) {
      query = query.vaultIdEqualTo(vaultId);
    }
    
    return await query.sortByCreatedAtDesc().findAll();
  }
  
  /// Lade Daily Note für ein Datum
  Future<Entry?> loadDailyNote(DateTime date, {int? vaultId}) async {
    final entries = await loadEntriesForDate(date, vaultId: vaultId);
    return entries.where((e) => e.entryType == 'daily').firstOrNull;
  }

  /// Erstelle oder lade Daily Note
  Future<Entry> getOrCreateDailyNote(DateTime date, {int? vaultId}) async {
    final existing = await loadDailyNote(date, vaultId: vaultId);
    if (existing != null) return existing;

    // Erstelle neue Daily Note
    final entry = Entry()
      ..entryType = 'daily'
      ..title = _formatDateTitle(date)
      ..entryDate = date
      ..content = await _generateDailyTemplate(date);

    if (vaultId != null) {
      entry.vaultId = vaultId;
    }

    return await saveEntry(entry);
  }
  
  /// Suche Einträge
  Future<List<Entry>> searchEntries(String query, {int? vaultId, int limit = 50}) async {
    if (query.isEmpty) return [];
    
    var queryBuilder = _isar.entrys
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .group((q) => q
          .titleContains(query, caseSensitive: false)
          .or()
          .contentContains(query, caseSensitive: false)
          .or()
          .tagsContains(query, caseSensitive: false));
    
    if (vaultId != null) {
      queryBuilder = queryBuilder.vaultIdEqualTo(vaultId);
    }
    
    return await queryBuilder
        .sortByUpdatedAtDesc()
        .limit(limit)
        .findAll();
  }
  
  /// Lösche einen Eintrag (Soft Delete)
  Future<void> deleteEntry(int entryId) async {
    await _isar.writeTxn(() async {
      final entry = await _isar.entrys.get(entryId);
      if (entry != null) {
        entry.isDeleted = true;
        entry.deletedAt = DateTime.now();
        await _isar.entrys.put(entry);
      }
    });
  }
  
  // ==================== MEDIA OPERATIONS ====================
  
  /// Speichere ein Medium
  Future<Media> saveMedia(Media media, Uint8List data, Vault vault) async {
    // Erstelle Dateiname
    final extension = p.extension(media.originalFilename);
    media.filename = '${_uuid.v4()}$extension';
    
    // Speichere Datei
    final filePath = p.join(vault.attachmentsPath, media.filename);
    final file = File(filePath);
    await file.writeAsBytes(data);
    
    media.path = p.relative(filePath, from: vault.path);
    media.sizeBytes = data.length;
    
    // Speichere in Isar
    await _isar.writeTxn(() async {
      await _isar.medias.put(media);
    });
    
    return media;
  }
  
  /// Lade Medien-Daten
  Future<Uint8List?> loadMediaData(Media media, Vault vault) async {
    final filePath = p.isAbsolute(media.path) 
        ? media.path 
        : p.join(vault.path, media.path);
    
    final file = File(filePath);
    if (!await file.exists()) return null;
    
    return await file.readAsBytes();
  }
  
  // ==================== PROPERTIES OPERATIONS ====================
  
  /// Lade alle Properties
  Future<List<Properties>> loadProperties() async {
    final props = await _isar.properties.where().sortBySortOrder().findAll();
    
    // Erstelle Standard-Properties falls nicht vorhanden
    if (props.isEmpty) {
      return await _createBuiltinProperties();
    }
    
    return props;
  }
  
  /// Speichere eine Property
  Future<Properties> saveProperty(Properties property) async {
    await _isar.writeTxn(() async {
      await _isar.properties.put(property);
    });
    return property;
  }
  
  // ==================== SYNC OPERATIONS ====================
  
  /// Exportiere Vault als JSON (für Sync)
  Future<Map<String, dynamic>> exportVaultToJson(int vaultId) async {
    final vault = await loadVault(vaultId);
    if (vault == null) throw Exception('Vault not found');
    
    final entries = await _isar.entrys
        .where()
        .vaultIdEqualTo(vaultId)
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
    
    return {
      'vault': vault.toJson(),
      'entries': entries.map((e) => e.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }
  
  /// Zähle alle Einträge
  Future<int> countEntries({int? vaultId}) async {
    if (vaultId != null) {
      return await _isar.entrys
          .where()
          .vaultIdEqualTo(vaultId)
          .filter()
          .isDeletedEqualTo(false)
          .count();
    }
    return await _isar.entrys
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .count();
  }
  
  /// Hole alle Einträge (für Sync)
  Future<List<Entry>> getAllEntries({DateTime? since}) async {
    var query = _isar.entrys
        .where()
        .filter()
        .isDeletedEqualTo(false);
    
    if (since != null) {
      query = query.updatedAtGreaterThan(since);
    }
    
    return await query.sortByUpdatedAtDesc().findAll();
  }
  
  /// Importiere Einträge aus JSON (für Sync)
  Future<void> importEntriesFromJson(List<Map<String, dynamic>> entriesJson) async {
    await _isar.writeTxn(() async {
      for (final json in entriesJson) {
        final entry = Entry.fromJson(json);
        await _isar.entrys.put(entry);
      }
    });
  }
  
  // ==================== HELPER METHODS ====================
  
  Future<void> _saveEntryToFile(Entry entry, Vault vault) async {
    final filename = _sanitizeFilename(entry.title.isEmpty 
        ? entry.uuid 
        : entry.title);
    final filePath = p.join(vault.path, '$filename.md');
    
    final file = File(filePath);
    await file.writeAsString(entry.toMarkdown());
  }
  
  Future<void> _saveVaultConfig(Vault vault) async {
    final configFile = File(vault.configPath);
    final config = {
      'name': vault.name,
      'uuid': vault.uuid,
      'icon': vault.iconName,
      'color': vault.colorHex,
      'type': vault.vaultType,
      'encrypted': vault.isEncrypted,
      'created': vault.createdAt.toIso8601String(),
    };
    
    await configFile.writeAsString(_yamlWriter.write(config));
  }
  
  Future<List<Properties>> _createBuiltinProperties() async {
    final builtin = BuiltinProperties.createBuiltinProperties();
    
    await _isar.writeTxn(() async {
      for (final prop in builtin) {
        await _isar.properties.put(prop);
      }
    });
    
    return builtin;
  }
  
  String _sanitizeFilename(String input) {
    return input
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .substring(0, input.length.clamp(0, 200));
  }
  
  String _formatDateTitle(DateTime date) {
    const weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    const months = [
      'Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun',
      'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'
    ];
    
    return '${weekdays[date.weekday - 1]}, ${date.day}. ${months[date.month - 1]} ${date.year}';
  }
  
  Future<String> _generateDailyTemplate(DateTime date) async {
    return '''# ${_formatDateTitle(date)}

## Morgen
- [ ] 

## Tagesziele
- 

## Notizen

''';
  }
}

/// Riverpod Provider
final storageServiceProvider = StateProvider<StorageService?>((ref) {
  return null; // Wird in main.dart initialisiert
});
