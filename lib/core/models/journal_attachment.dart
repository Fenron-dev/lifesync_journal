import 'package:isar/isar.dart';

part 'journal_attachment.g.dart';

/// Typ des Anhangs
enum AttachmentType {
  image,    // Foto
  audio,    // Sprachnotiz
  video,    // Video
  file,     // Dokument
  sketch,   // Zeichnung
}

@Collection()
class JournalAttachment {
  Id id = Isar.autoIncrement;

  /// Verknüpfter Journal-Eintrag
  @Index()
  late int journalEntryId;

  /// Typ des Anhangs
  @Enumerated(EnumType.name)
  late AttachmentType type;

  /// Original-Dateiname
  String? originalFileName;

  /// Lokaler Pfad (verschlüsselt gespeichert)
  late String localPath;

  /// Dateigröße in Bytes
  late int fileSize;

  /// MIME-Type
  String? mimeType;

  /// Breite (für Bilder/Videos)
  int? width;

  /// Höhe (für Bilder/Videos)
  int? height;

  /// Dauer in Sekunden (für Audio/Video)
  int? durationSeconds;

  /// Thumbnail-Pfad (für Bilder/Videos)
  String? thumbnailPath;

  /// Erstellungsdatum
  late DateTime createdAt;

  /// Optional: Beschreibung/Caption
  String? caption;

  /// Sortierreihenfolge
  int sortOrder = 0;

  /// Metadaten als JSON
  String? metadata;

  /// Ist das Medium verschlüsselt gespeichert?
  bool isEncrypted = true;

  /// Hash für Integritätsprüfung
  String? contentHash;
}

/// Speicherstatistiken
class StorageStats {
  final int totalFiles;
  final int totalSize;
  final int imageCount;
  final int audioCount;
  final int videoCount;
  final int otherCount;

  StorageStats({
    required this.totalFiles,
    required this.totalSize,
    required this.imageCount,
    required this.audioCount,
    required this.videoCount,
    required this.otherCount,
  });

  String get formattedSize => _formatBytes(totalSize);

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
