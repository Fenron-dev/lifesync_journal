import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/journal_attachment.dart';
import 'encryption_service.dart';
import '../../../main.dart';

part 'attachment_service.g.dart';

/// Provider für AttachmentService
@riverpod
AttachmentService attachmentService(AttachmentServiceRef ref) {
  return AttachmentService(db);
}

class AttachmentService {
  final Isar _db;
  final _imagePicker = ImagePicker();
  final _recorder = AudioRecorder();
  final _uuid = const Uuid();
  final _encryptionService = EncryptionService();

  static const _attachmentKeyId = 'device_attachment_key_v1';
  static const _formatVersion = 1;
  static const _nonceLength = 12;
  static const _macLength = 16;
  static const _headerLength = 1 + _nonceLength + _macLength;

  bool _isRecording = false;
  String? _currentRecordingPath;

  AttachmentService(this._db);

  Future<void> dispose() async {
    await _recorder.dispose();
  }

  // ============ ENCRYPTION HELPERS ============

  Future<SecretKey> _getAttachmentKey() async {
    final stored = await _encryptionService.getSecureReference(_attachmentKeyId);
    if (stored != null) {
      return SecretKey(base64Decode(stored));
    }
    final random = Random.secure();
    final keyBytes = Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );
    await _encryptionService.storeSecureReference(
      _attachmentKeyId,
      base64Encode(keyBytes),
    );
    return SecretKey(keyBytes);
  }

  Future<void> _encryptAndSave(List<int> data, String path) async {
    final key = await _getAttachmentKey();
    final encrypted = await _encryptionService.encrypt(Uint8List.fromList(data), key);
    final output = Uint8List.fromList([
      _formatVersion,
      ...encrypted.nonce,
      ...encrypted.mac.bytes,
      ...encrypted.ciphertext,
    ]);
    await File(path).writeAsBytes(output);
  }

  Future<Uint8List> _decryptBytes(List<int> encryptedData) async {
    if (encryptedData.length <= _headerLength) {
      throw Exception('Verschlüsselte Daten zu kurz oder beschädigt');
    }
    final version = encryptedData[0];
    if (version != _formatVersion) {
      throw Exception('Nicht unterstützte Verschlüsselungsversion: $version');
    }
    final nonce = Uint8List.fromList(encryptedData.sublist(1, 1 + _nonceLength));
    final mac = Mac(encryptedData.sublist(1 + _nonceLength, _headerLength).toList());
    final ciphertext = Uint8List.fromList(encryptedData.sublist(_headerLength));
    final key = await _getAttachmentKey();
    return _encryptionService.decrypt(
      EncryptedData(ciphertext: ciphertext, nonce: nonce, mac: mac),
      key,
    );
  }

  // ============ IMAGE CAPTURE ============

  Future<JournalAttachment?> capturePhoto({
    required int journalEntryId,
    bool compress = true,
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 85,
  }) async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: quality,
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
    );
    if (image == null) return null;
    return _processImageFile(File(image.path), journalEntryId,
        compress: compress, maxWidth: maxWidth, maxHeight: maxHeight, quality: quality);
  }

  Future<JournalAttachment?> pickImage({
    required int journalEntryId,
    bool compress = true,
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 85,
  }) async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: quality,
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
    );
    if (image == null) return null;
    return _processImageFile(File(image.path), journalEntryId,
        compress: compress, maxWidth: maxWidth, maxHeight: maxHeight, quality: quality);
  }

  Future<List<JournalAttachment>> pickMultipleImages({
    required int journalEntryId,
    bool compress = true,
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 85,
  }) async {
    final List<XFile> images = await _imagePicker.pickMultiImage(
      imageQuality: quality,
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
    );
    final attachments = <JournalAttachment>[];
    for (final image in images) {
      final a = await _processImageFile(File(image.path), journalEntryId,
          compress: compress, maxWidth: maxWidth, maxHeight: maxHeight, quality: quality);
      if (a != null) attachments.add(a);
    }
    return attachments;
  }

  Future<JournalAttachment?> _processImageFile(
    File imageFile,
    int journalEntryId, {
    bool compress = true,
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 85,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;

      if (compress && (image.width > maxWidth || image.height > maxHeight)) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? maxWidth : null,
          height: image.height >= image.width ? maxHeight : null,
        );
      }

      final compressedBytes = img.encodeJpg(image, quality: quality);
      final fileName = '${_uuid.v4()}.jpg.enc';
      final appDir = await getApplicationDocumentsDirectory();
      final attachmentDir = Directory('${appDir.path}/attachments');
      if (!await attachmentDir.exists()) {
        await attachmentDir.create(recursive: true);
      }
      final localPath = '${attachmentDir.path}/$fileName';

      await _encryptAndSave(compressedBytes, localPath);

      final thumbnail = img.copyResize(image, width: 256);
      final thumbnailBytes = img.encodeJpg(thumbnail, quality: 70);
      final thumbnailPath = '$localPath.thumb';
      await _encryptAndSave(thumbnailBytes, thumbnailPath);

      final contentHash = sha256.convert(compressedBytes).toString();

      final attachment = JournalAttachment()
        ..journalEntryId = journalEntryId
        ..type = AttachmentType.image
        ..originalFileName = imageFile.path.split('/').last
        ..localPath = localPath
        ..fileSize = compressedBytes.length
        ..mimeType = 'image/jpeg'
        ..width = image.width
        ..height = image.height
        ..thumbnailPath = thumbnailPath
        ..createdAt = DateTime.now()
        ..isEncrypted = true
        ..contentHash = contentHash;

      await _db.writeTxn(() async {
        await _db.journalAttachments.put(attachment);
      });
      return attachment;
    } catch (e) {
      assert(() { debugPrint('[Attachment] _processImageFile failed: $e'); return true; }());
      return null;
    }
  }

  // ============ AUDIO RECORDING ============

  bool get isRecording => _isRecording;

  Future<bool> startAudioRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return false;

    final appDir = await getApplicationDocumentsDirectory();
    final recordingDir = Directory('${appDir.path}/recordings');
    if (!await recordingDir.exists()) {
      await recordingDir.create(recursive: true);
    }

    final fileName = '${_uuid.v4()}.aac';
    _currentRecordingPath = '${recordingDir.path}/$fileName';

    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, numChannels: 1, sampleRate: 44100),
      path: _currentRecordingPath!,
    );
    _isRecording = true;
    return true;
  }

  Future<JournalAttachment?> stopAudioRecording({required int journalEntryId}) async {
    if (!_isRecording || _currentRecordingPath == null) return null;

    final path = await _recorder.stop();
    _isRecording = false;

    if (path == null) {
      _currentRecordingPath = null;
      return null;
    }

    try {
      final audioFile = File(path);
      final bytes = await audioFile.readAsBytes();

      final appDir = await getApplicationDocumentsDirectory();
      final attachmentDir = Directory('${appDir.path}/attachments');
      if (!await attachmentDir.exists()) {
        await attachmentDir.create(recursive: true);
      }

      final encryptedFileName = '${_uuid.v4()}.aac.enc';
      final localPath = '${attachmentDir.path}/$encryptedFileName';

      await _encryptAndSave(bytes, localPath);
      await audioFile.delete();

      final contentHash = sha256.convert(bytes).toString();

      final attachment = JournalAttachment()
        ..journalEntryId = journalEntryId
        ..type = AttachmentType.audio
        ..localPath = localPath
        ..fileSize = bytes.length
        ..mimeType = 'audio/aac'
        ..createdAt = DateTime.now()
        ..isEncrypted = true
        ..contentHash = contentHash;

      await _db.writeTxn(() async {
        await _db.journalAttachments.put(attachment);
      });

      _currentRecordingPath = null;
      return attachment;
    } catch (e) {
      assert(() { debugPrint('[Attachment] stopAudioRecording failed: $e'); return true; }());
      _currentRecordingPath = null;
      return null;
    }
  }

  Future<void> cancelAudioRecording() async {
    await _recorder.stop();
    _isRecording = false;
    if (_currentRecordingPath != null) {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) await file.delete();
      _currentRecordingPath = null;
    }
  }

  // ============ FILE OPERATIONS ============

  Future<Uint8List?> loadAttachment(JournalAttachment attachment) async {
    try {
      final file = File(attachment.localPath);
      if (!await file.exists()) return null;
      return await _decryptBytes(await file.readAsBytes());
    } catch (e) {
      assert(() { debugPrint('[Attachment] loadAttachment failed: $e'); return true; }());
      return null;
    }
  }

  Future<Uint8List?> loadThumbnail(JournalAttachment attachment) async {
    if (attachment.thumbnailPath == null) return null;
    try {
      final file = File(attachment.thumbnailPath!);
      if (!await file.exists()) return null;
      return await _decryptBytes(await file.readAsBytes());
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteAttachment(int attachmentId) async {
    final attachment = await _db.journalAttachments.get(attachmentId);
    if (attachment == null) return;

    final file = File(attachment.localPath);
    if (await file.exists()) await file.delete();

    if (attachment.thumbnailPath != null) {
      final thumbFile = File(attachment.thumbnailPath!);
      if (await thumbFile.exists()) await thumbFile.delete();
    }

    await _db.writeTxn(() async {
      await _db.journalAttachments.delete(attachmentId);
    });
  }

  Future<List<JournalAttachment>> getAttachmentsForEntry(int journalEntryId) async {
    return _db.journalAttachments
        .where()
        .journalEntryIdEqualTo(journalEntryId)
        .sortBySortOrder()
        .findAll();
  }

  // ============ STORAGE MANAGEMENT ============

  Future<StorageStats> getStorageStats() async {
    final attachments = await _db.journalAttachments.where().findAll();
    int totalSize = 0, imageCount = 0, audioCount = 0, videoCount = 0, otherCount = 0;

    for (final a in attachments) {
      totalSize += a.fileSize;
      switch (a.type) {
        case AttachmentType.image:
          imageCount++;
        case AttachmentType.audio:
          audioCount++;
        case AttachmentType.video:
          videoCount++;
        default:
          otherCount++;
      }
    }

    return StorageStats(
      totalFiles: attachments.length,
      totalSize: totalSize,
      imageCount: imageCount,
      audioCount: audioCount,
      videoCount: videoCount,
      otherCount: otherCount,
    );
  }

  Future<int> cleanupOldAttachments({int daysOld = 365}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final toDelete = <int>[];
    final attachments = await _db.journalAttachments.where().findAll();
    for (final a in attachments) {
      if (a.createdAt.isBefore(cutoffDate)) {
        toDelete.add(a.id);
      }
    }
    for (final id in toDelete) {
      await deleteAttachment(id);
    }
    return toDelete.length;
  }

  Future<void> optimizeStorage() async {
    final images = await _db.journalAttachments
        .filter()
        .typeEqualTo(AttachmentType.image)
        .findAll();

    for (final image in images) {
      if (image.fileSize > 2 * 1024 * 1024) {
        final bytes = await loadAttachment(image);
        if (bytes != null) {
          final decoded = img.decodeImage(bytes);
          if (decoded != null) {
            final compressed = img.encodeJpg(decoded, quality: 70);
            await _encryptAndSave(compressed, image.localPath);
            image.fileSize = compressed.length;
            await _db.writeTxn(() async {
              await _db.journalAttachments.put(image);
            });
          }
        }
      }
    }
  }

  // ============ EXPORT/IMPORT ============

  Future<File?> exportAttachment(JournalAttachment attachment, String targetPath) async {
    final bytes = await loadAttachment(attachment);
    if (bytes == null) return null;

    String extension;
    switch (attachment.type) {
      case AttachmentType.image:
        extension = '.jpg';
      case AttachmentType.audio:
        extension = '.aac';
      case AttachmentType.video:
        extension = '.mp4';
      default:
        extension = '.bin';
    }

    final fileName = attachment.originalFileName ?? 'attachment_${attachment.id}$extension';
    final file = File('$targetPath/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<JournalAttachment?> importFile(
    String filePath,
    int journalEntryId, {
    AttachmentType? type,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) return null;

    final bytes = await file.readAsBytes();
    final fileName = filePath.split('/').last;
    final attachmentType = type ?? _detectType(fileName);

    final appDir = await getApplicationDocumentsDirectory();
    final attachmentDir = Directory('${appDir.path}/attachments');
    if (!await attachmentDir.exists()) {
      await attachmentDir.create(recursive: true);
    }

    final extension = fileName.split('.').last;
    final encryptedFileName = '${_uuid.v4()}.$extension.enc';
    final localPath = '${attachmentDir.path}/$encryptedFileName';

    await _encryptAndSave(bytes, localPath);

    final contentHash = sha256.convert(bytes).toString();

    final attachment = JournalAttachment()
      ..journalEntryId = journalEntryId
      ..type = attachmentType
      ..originalFileName = fileName
      ..localPath = localPath
      ..fileSize = bytes.length
      ..mimeType = _getMimeType(extension)
      ..createdAt = DateTime.now()
      ..isEncrypted = true
      ..contentHash = contentHash;

    await _db.writeTxn(() async {
      await _db.journalAttachments.put(attachment);
    });

    return attachment;
  }

  AttachmentType _detectType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(ext)) return AttachmentType.image;
    if (['mp3', 'aac', 'wav', 'm4a', 'ogg'].contains(ext)) return AttachmentType.audio;
    if (['mp4', 'mov', 'avi', 'mkv'].contains(ext)) return AttachmentType.video;
    return AttachmentType.file;
  }

  String _getMimeType(String extension) {
    const mimeTypes = {
      'jpg': 'image/jpeg', 'jpeg': 'image/jpeg', 'png': 'image/png',
      'gif': 'image/gif', 'webp': 'image/webp', 'mp3': 'audio/mpeg',
      'aac': 'audio/aac', 'wav': 'audio/wav', 'm4a': 'audio/mp4',
      'mp4': 'video/mp4', 'mov': 'video/quicktime', 'pdf': 'application/pdf',
    };
    return mimeTypes[extension.toLowerCase()] ?? 'application/octet-stream';
  }
}
