import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/entry.dart';
import '../models/habit.dart';
import '../models/daily_mood.dart';
import '../models/journal_attachment.dart';
import 'encryption_service.dart';
import '../../../main.dart';

part 'backup_service.g.dart';

/// Provider für BackupService
@riverpod
BackupService backupService(BackupServiceRef ref) {
  return BackupService(db);
}

/// Backup-Metadaten
class BackupMetadata {
  final String version;
  final DateTime createdAt;
  final String deviceName;
  final int journalCount;
  final int habitCount;
  final int moodCount;
  final int attachmentCount;
  final String checksum;

  BackupMetadata({
    required this.version,
    required this.createdAt,
    required this.deviceName,
    required this.journalCount,
    required this.habitCount,
    required this.moodCount,
    required this.attachmentCount,
    required this.checksum,
  });

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    return BackupMetadata(
      version: json['version'] as String? ?? '1.0',
      createdAt: createdAt,
      deviceName: json['deviceName'] as String? ?? 'Unknown',
      journalCount: json['journalCount'] as int? ?? 0,
      habitCount: json['habitCount'] as int? ?? 0,
      moodCount: json['moodCount'] as int? ?? 0,
      attachmentCount: json['attachmentCount'] as int? ?? 0,
      checksum: json['checksum'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'version': version,
    'createdAt': createdAt.toIso8601String(),
    'deviceName': deviceName,
    'journalCount': journalCount,
    'habitCount': habitCount,
    'moodCount': moodCount,
    'attachmentCount': attachmentCount,
    'checksum': checksum,
  };
}

/// Backup-Fortschritt
class BackupProgress {
  final int current;
  final int total;
  final String currentStep;
  final bool isComplete;

  BackupProgress({
    required this.current,
    required this.total,
    required this.currentStep,
    this.isComplete = false,
  });

  double get progress => total > 0 ? current / total : 0;
}

class BackupService {
  final Isar _db;
  static const String _backupVersion = '2.0';

  // Gerätegebundener Schlüssel-ID in FlutterSecureStorage
  static const _backupKeyId = 'device_backup_key_v1';

  // Binäres Format: [1 Byte Version=1][12 Bytes Nonce][16 Bytes MAC][N Bytes Ciphertext]
  static const _formatVersion = 1;
  static const _nonceLength = 12;
  static const _macLength = 16;
  static const _headerLength = 1 + _nonceLength + _macLength; // 29 Bytes

  final _encryptionService = EncryptionService();

  BackupService(this._db);

  /// Gibt den gerätegebundenen Backup-Schlüssel zurück.
  /// Wird beim ersten Aufruf zufällig generiert und sicher gespeichert.
  Future<SecretKey> _getBackupKey() async {
    final stored = await _encryptionService.getSecureReference(_backupKeyId);
    if (stored != null) {
      return SecretKey(base64Decode(stored));
    }
    final random = Random.secure();
    final keyBytes = Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );
    await _encryptionService.storeSecureReference(
      _backupKeyId,
      base64Encode(keyBytes),
    );
    return SecretKey(keyBytes);
  }

  // ============ EXPORT ============

  /// Erstellt ein vollständiges verschlüsseltes Backup
  Future<File?> createFullBackup({
    bool includeAttachments = true,
    String? customPath,
    Function(BackupProgress)? onProgress,
  }) async {
    try {
      onProgress?.call(BackupProgress(
        current: 0,
        total: 5,
        currentStep: 'Sammle Daten...',
      ));

      // 1. Daten sammeln
      final data = await _collectAllData();

      onProgress?.call(BackupProgress(
        current: 1,
        total: 5,
        currentStep: 'Exportiere Anhänge...',
      ));

      // 2. Anhänge exportieren (optional)
      if (includeAttachments) {
        data['attachments'] = await _exportAttachments(onProgress);
      }

      onProgress?.call(BackupProgress(
        current: 2,
        total: 5,
        currentStep: 'Verschlüssele Daten...',
      ));

      // 3. JSON erstellen
      final jsonString = jsonEncode(data);
      final jsonBytes = Uint8List.fromList(utf8.encode(jsonString));

      // 4. Checksum berechnen (vor der Verschlüsselung)
      final checksum = sha256.convert(jsonBytes).toString();

      // 5. Mit gerätegebundenem Schlüssel und zufälligem Nonce verschlüsseln
      final key = await _getBackupKey();
      final encrypted = await _encryptionService.encrypt(jsonBytes, key);

      // Format: [1B version][12B nonce][16B mac][ciphertext]
      final encryptedData = Uint8List.fromList([
        _formatVersion,
        ...encrypted.nonce,
        ...encrypted.mac.bytes,
        ...encrypted.ciphertext,
      ]);

      onProgress?.call(BackupProgress(
        current: 3,
        total: 5,
        currentStep: 'Speichere Backup...',
      ));

      // 6. Datei speichern
      final fileName = 'lifesync_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.lsb';
      String filePath;

      if (customPath != null) {
        filePath = '$customPath/$fileName';
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        final backupDir = Directory('${appDir.path}/backups');
        if (!await backupDir.exists()) {
          await backupDir.create(recursive: true);
        }
        filePath = '${backupDir.path}/$fileName';
      }

      final file = File(filePath);
      await file.writeAsBytes(encryptedData);

      onProgress?.call(BackupProgress(
        current: 4,
        total: 5,
        currentStep: 'Erstelle Metadaten...',
      ));

      // 7. Metadaten-Datei
      final metadata = BackupMetadata(
        version: _backupVersion,
        createdAt: DateTime.now(),
        deviceName: Platform.localHostname,
        journalCount: (data['journalEntries'] as List).length,
        habitCount: (data['habits'] as List).length,
        moodCount: (data['moods'] as List).length,
        attachmentCount: includeAttachments ? (data['attachments'] as Map).length : 0,
        checksum: checksum,
      );

      final metadataFile = File('$filePath.meta');
      await metadataFile.writeAsString(jsonEncode(metadata.toJson()));

      onProgress?.call(BackupProgress(
        current: 5,
        total: 5,
        currentStep: 'Fertig!',
        isComplete: true,
      ));

      return file;
    } catch (e) {
      assert(() { debugPrint('[Backup] createFullBackup failed: $e'); return true; }());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _collectAllData() async {
    final journalEntries = await _db.entrys.where().findAll();
    final habits = await _db.habits.where().findAll();
    final habitCompletions = await _db.habitCompletions.where().findAll();
    final moods = await _db.dailyMoods.where().findAll();
    final attachments = await _db.journalAttachments.where().findAll();

    return {
      'version': _backupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'journalEntries': journalEntries.map(_serializeJournalEntry).toList(),
      'habits': habits.map(_serializeHabit).toList(),
      'habitCompletions': habitCompletions.map(_serializeHabitCompletion).toList(),
      'moods': moods.map(_serializeMood).toList(),
      'attachmentMetadata': attachments.map(_serializeAttachmentMetadata).toList(),
    };
  }

  Future<Map<String, dynamic>> _exportAttachments(Function(BackupProgress)? onProgress) async {
    final attachments = await _db.journalAttachments.where().findAll();
    final result = <String, dynamic>{};

    for (int i = 0; i < attachments.length; i++) {
      final attachment = attachments[i];
      final file = File(attachment.localPath);

      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        result[attachment.id.toString()] = {
          'filename': attachment.originalFileName,
          'type': attachment.type.name,
          'data': base64Encode(bytes),
        };
      }

      if (onProgress != null && i % 10 == 0) {
        onProgress(BackupProgress(
          current: i,
          total: attachments.length,
          currentStep: 'Exportiere Anhang ${i + 1}/${attachments.length}',
        ));
      }
    }

    return result;
  }

  // ============ IMPORT ============

  /// Importiert ein verschlüsseltes Backup
  Future<BackupMetadata?> importBackup(
    String filePath, {
    bool mergeWithExisting = false,
    Function(BackupProgress)? onProgress,
  }) async {
    try {
      onProgress?.call(BackupProgress(
        current: 0,
        total: 5,
        currentStep: 'Lese Backup-Datei...',
      ));

      // 1. Datei lesen
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup-Datei nicht gefunden');
      }

      final encryptedData = await file.readAsBytes();

      onProgress?.call(BackupProgress(
        current: 1,
        total: 5,
        currentStep: 'Entschlüssele Daten...',
      ));

      // 2. Format validieren und entschlüsseln
      if (encryptedData.length <= _headerLength) {
        throw Exception('Backup-Datei ist beschädigt oder hat ein ungültiges Format');
      }

      final version = encryptedData[0];
      if (version != _formatVersion) {
        throw Exception('Nicht unterstützte Backup-Version: $version');
      }

      final nonce = Uint8List.fromList(encryptedData.sublist(1, 1 + _nonceLength));
      final mac = Mac(encryptedData.sublist(1 + _nonceLength, _headerLength).toList());
      final ciphertext = Uint8List.fromList(encryptedData.sublist(_headerLength));

      final key = await _getBackupKey();
      final decrypted = await _encryptionService.decrypt(
        EncryptedData(ciphertext: ciphertext, nonce: nonce, mac: mac),
        key,
      );

      final jsonString = utf8.decode(decrypted);
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Backup hat ein ungültiges Format');
      }
      final data = decoded;
      if (data['journalEntries'] is! List || data['habits'] is! List) {
        throw const FormatException('Backup-Struktur ist unvollständig');
      }

      onProgress?.call(BackupProgress(
        current: 2,
        total: 5,
        currentStep: 'Validiere Backup...',
      ));

      // 3. Checksum validieren
      final checksum = sha256.convert(decrypted).toString();

      BackupMetadata? metadata;
      final metaFile = File('$filePath.meta');
      if (await metaFile.exists()) {
        final metaData = jsonDecode(await metaFile.readAsString());
        metadata = BackupMetadata.fromJson(metaData as Map<String, dynamic>);

        if (metadata.checksum != checksum) {
          throw Exception('Backup ist beschädigt (Checksum-Mismatch)');
        }
      }

      onProgress?.call(BackupProgress(
        current: 3,
        total: 5,
        currentStep: 'Importiere Daten...',
      ));

      // 4. Daten importieren
      await _importData(data, mergeWithExisting, onProgress);

      onProgress?.call(BackupProgress(
        current: 4,
        total: 5,
        currentStep: 'Importiere Anhänge...',
      ));

      // 5. Anhänge importieren
      if (data['attachments'] != null) {
        await _importAttachments(data['attachments'] as Map<String, dynamic>);
      }

      onProgress?.call(BackupProgress(
        current: 5,
        total: 5,
        currentStep: 'Fertig!',
        isComplete: true,
      ));

      return metadata;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _importData(
    Map<String, dynamic> data,
    bool merge,
    Function(BackupProgress)? onProgress,
  ) async {
    await _db.writeTxn(() async {
      if (!merge) {
        await _db.clear();
      }

      final entries = (data['journalEntries'] as List)
          .map((e) => _deserializeJournalEntry(e as Map<String, dynamic>))
          .toList();
      await _db.entrys.putAll(entries);

      final habits = (data['habits'] as List)
          .map((h) => _deserializeHabit(h as Map<String, dynamic>))
          .toList();
      await _db.habits.putAll(habits);

      final completions = (data['habitCompletions'] as List)
          .map((c) => _deserializeHabitCompletion(c as Map<String, dynamic>))
          .toList();
      await _db.habitCompletions.putAll(completions);

      final moods = (data['moods'] as List)
          .map((m) => _deserializeMood(m as Map<String, dynamic>))
          .toList();
      await _db.dailyMoods.putAll(moods);
    });
  }

  Future<void> _importAttachments(Map<String, dynamic> attachments) async {
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentDir = Directory('${appDir.path}/attachments');
    if (!await attachmentDir.exists()) {
      await attachmentDir.create(recursive: true);
    }

    for (final entry in attachments.entries) {
      final data = entry.value as Map<String, dynamic>;
      final fileName = '${entry.key}_${data['filename']}';
      final filePath = '${attachmentDir.path}/$fileName';

      final bytes = base64Decode(data['data'] as String);
      await File(filePath).writeAsBytes(bytes);
    }
  }

  // ============ SHARE ============

  Future<void> shareBackup(File backupFile) async {
    await Share.shareXFiles(
      [XFile(backupFile.path)],
      subject: 'LifeSync Backup',
      text: 'LifeSync Journal Backup vom ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
    );
  }

  Future<String?> pickBackupFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['lsb'],
    );
    return result?.files.single.path;
  }

  // ============ SERIALIZATION ============

  Map<String, dynamic> _serializeJournalEntry(Entry entry) => entry.toJson();

  Entry _deserializeJournalEntry(Map<String, dynamic> json) =>
      Entry.fromJson(json);

  Map<String, dynamic> _serializeHabit(Habit habit) => {
    'id': habit.id,
    'name': habit.name,
    'description': habit.description,
    'category': habit.category.name,
    'iconName': habit.iconName,
    'colorHex': habit.colorHex,
    'frequency': habit.frequency.name,
    'targetCount': habit.targetCount,
    'activeDays': habit.activeDays,
    'createdAt': habit.createdAt.toIso8601String(),
    'isActive': habit.isActive,
    'sortOrder': habit.sortOrder,
    'linkedTags': habit.linkedTags,
  };

  Habit _deserializeHabit(Map<String, dynamic> json) {
    return Habit()
      ..id = json['id'] as int? ?? Isar.autoIncrement
      ..name = json['name'] as String? ?? ''
      ..description = json['description'] as String? ?? ''
      ..category = HabitCategory.values.byName(json['category'] as String? ?? 'health')
      ..iconName = json['iconName'] as String? ?? 'check'
      ..colorHex = json['colorHex'] as String? ?? '#2196F3'
      ..frequency = HabitFrequency.values.byName(json['frequency'] as String? ?? 'daily')
      ..targetCount = json['targetCount'] as int? ?? 1
      ..activeDays = List<int>.from(json['activeDays'] as List? ?? [])
      ..createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now()
      ..isActive = json['isActive'] as bool? ?? true
      ..sortOrder = json['sortOrder'] as int? ?? 0
      ..linkedTags = List<String>.from(json['linkedTags'] as List? ?? []);
  }

  Map<String, dynamic> _serializeHabitCompletion(HabitCompletion completion) => {
    'id': completion.id,
    'habitId': completion.habitId,
    'date': completion.date.toIso8601String(),
    'count': completion.count,
    'note': completion.note,
    'journalEntryId': completion.journalEntryId,
    'createdAt': completion.createdAt.toIso8601String(),
  };

  HabitCompletion _deserializeHabitCompletion(Map<String, dynamic> json) {
    return HabitCompletion()
      ..id = json['id'] as int? ?? Isar.autoIncrement
      ..habitId = json['habitId'] as int? ?? 0
      ..date = DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now()
      ..count = json['count'] as int? ?? 0
      ..note = json['note'] as String?
      ..journalEntryId = json['journalEntryId'] as int?
      ..createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
  }

  Map<String, dynamic> _serializeMood(DailyMood mood) => {
    'id': mood.id,
    'date': mood.date.toIso8601String(),
    'mood': mood.mood.name,
    'energyLevel': mood.energyLevel,
    'stressLevel': mood.stressLevel,
    'sleepQuality': mood.sleepQuality,
    'productivityLevel': mood.productivityLevel,
    'note': mood.note,
    'activities': mood.activities,
    'journalEntryId': mood.journalEntryId,
    'createdAt': mood.createdAt.toIso8601String(),
  };

  DailyMood _deserializeMood(Map<String, dynamic> json) {
    return DailyMood()
      ..id = json['id'] as int? ?? Isar.autoIncrement
      ..date = DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now()
      ..mood = MoodLevel.values.byName(json['mood'] as String? ?? 'neutral')
      ..energyLevel = json['energyLevel'] as int? ?? 3
      ..stressLevel = json['stressLevel'] as int? ?? 3
      ..sleepQuality = json['sleepQuality'] as int? ?? 3
      ..productivityLevel = json['productivityLevel'] as int? ?? 3
      ..note = json['note'] as String?
      ..activities = List<String>.from(json['activities'] as List? ?? [])
      ..journalEntryId = json['journalEntryId'] as int?
      ..createdAt = DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
  }

  Map<String, dynamic> _serializeAttachmentMetadata(JournalAttachment attachment) => {
    'id': attachment.id,
    'journalEntryId': attachment.journalEntryId,
    'type': attachment.type.name,
    'originalFileName': attachment.originalFileName,
    'localPath': attachment.localPath,
    'fileSize': attachment.fileSize,
    'mimeType': attachment.mimeType,
    'width': attachment.width,
    'height': attachment.height,
    'durationSeconds': attachment.durationSeconds,
    'thumbnailPath': attachment.thumbnailPath,
    'createdAt': attachment.createdAt.toIso8601String(),
    'caption': attachment.caption,
    'sortOrder': attachment.sortOrder,
    'isEncrypted': attachment.isEncrypted,
    'contentHash': attachment.contentHash,
  };

  // ============ BACKUP MANAGEMENT ============

  Future<List<BackupMetadata>> listAvailableBackups() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/backups');

    if (!await backupDir.exists()) return [];

    final backups = <BackupMetadata>[];

    await for (final entity in backupDir.list()) {
      if (entity is File && entity.path.endsWith('.meta')) {
        try {
          final json = jsonDecode(await entity.readAsString());
          backups.add(BackupMetadata.fromJson(json as Map<String, dynamic>));
        } catch (e) {
          assert(() { debugPrint('[Backup] Skipping corrupt metadata ${entity.path}: $e'); return true; }());
        }
      }
    }

    backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return backups;
  }

  Future<void> deleteBackup(String backupPath) async {
    final file = File(backupPath);
    final metaFile = File('$backupPath.meta');

    if (await file.exists()) await file.delete();
    if (await metaFile.exists()) await metaFile.delete();
  }

  Future<int> cleanupOldBackups({int keepLast = 5}) async {
    final backups = await listAvailableBackups();

    if (backups.length <= keepLast) return 0;

    final toDelete = backups.skip(keepLast);
    int deleted = 0;

    for (final backup in toDelete) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'lifesync_backup_${DateFormat('yyyyMMdd_HHmmss').format(backup.createdAt)}.lsb';
        await deleteBackup('${appDir.path}/backups/$fileName');
        deleted++;
      } catch (e) {
        assert(() { debugPrint('[Backup] Failed to delete old backup: $e'); return true; }());
      }
    }

    return deleted;
  }
}
