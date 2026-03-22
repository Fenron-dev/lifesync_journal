import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'media.g.dart';

/// Media - Ein Medienanhang für einen Eintrag
/// 
/// Unterstützt:
/// - Bilder (JPEG, PNG, HEIC, WebP)
/// - Videos (MP4, MOV)
/// - Audio (MP3, M4A, WAV, OGG)
/// - Dokumente (PDF, EPUB)
@collection
class Media {
  /// Eindeutige ID
  Id id = Isar.autoIncrement;
  
  /// UUID
  @Index(unique: true)
  late String uuid;
  
  /// Dateiname
  @Index()
  late String filename;
  
  /// Originaler Dateiname beim Import
  String originalFilename = '';
  
  /// MIME-Type
  String mimeType = 'application/octet-stream';
  
  /// Medien-Typ
  @Index()
  String mediaType = 'file'; // image, video, audio, document, file
  
  /// Pfad zur Datei (relativ zum Vault)
  late String path;
  
  /// Pfad zum Thumbnail (für Bilder/Videos)
  String? thumbnailPath;
  
  /// Dateigröße in Bytes
  int sizeBytes = 0;
  
  /// Breite (für Bilder/Videos)
  int? width;
  
  /// Höhe (für Bilder/Videos)
  int? height;
  
  /// Dauer in Sekunden (für Audio/Video)
  int? durationSeconds;
  
  /// Hash der Datei (für Deduplizierung)
  @Index()
  String? fileHash;
  
  /// Erstellungsdatum
  DateTime createdAt = DateTime.now();
  
  /// Aufnahmedatum (aus EXIF/Metadaten)
  DateTime? capturedAt;
  
  /// GPS-Koordinaten (aus EXIF)
  String? location; // "lat,lng"
  
  /// Device-Name der Aufnahme
  String? deviceName;
  
  /// Verknüpfte Eintrag-IDs (komma-getrennt)
  @Index()
  String entryIds = '';
  
  /// Vault-ID
  @Index()
  int vaultId = 0;
  
  /// Beschriftung/Alt-Text
  String caption = '';
  
  /// Ist favorisiert?
  @Index()
  bool isFavorite = false;
  
  /// Ist vom Server synchronisiert?
  bool isSynced = false;
  
  /// Konstruktor
  Media() {
    uuid = const Uuid().v4();
  }
  
  /// Menschenlesbare Größe
  String get readableSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Dauer als formatierter String
  String get readableDuration {
    if (durationSeconds == null) return '';
    final hours = durationSeconds! ~/ 3600;
    final minutes = (durationSeconds! % 3600) ~/ 60;
    final seconds = durationSeconds! % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// Dimensionen als String
  String get dimensions {
    if (width != null && height != null) {
      return '${width}x$height';
    }
    return '';
  }
  
  /// Ist es ein Bild?
  bool get isImage => mediaType == 'image';
  
  /// Ist es ein Video?
  bool get isVideo => mediaType == 'video';
  
  /// Ist es Audio?
  bool get isAudio => mediaType == 'audio';
  
  /// Verknüpfte Eintrag-IDs als Liste
  List<int> get entryIdList => entryIds.isEmpty
      ? []
      : entryIds.split(',')
          .map((s) => int.tryParse(s.trim()))
          .whereType<int>()
          .toList();
}

/// Unterstützte Medien-Typen
enum MediaType {
  image('Bild', ['jpg', 'jpeg', 'png', 'heic', 'webp', 'gif']),
  video('Video', ['mp4', 'mov', 'avi', 'mkv', 'webm']),
  audio('Audio', ['mp3', 'm4a', 'wav', 'ogg', 'flac', 'aac']),
  document('Dokument', ['pdf', 'epub']),
  file('Datei', []);
  
  final String label;
  final List<String> extensions;
  
  const MediaType(this.label, this.extensions);
  
  static MediaType fromExtension(String extension) {
    final ext = extension.toLowerCase().replaceAll('.', '');
    for (final type in MediaType.values) {
      if (type.extensions.contains(ext)) return type;
    }
    return MediaType.file;
  }
  
  static MediaType fromMimeType(String mimeType) {
    if (mimeType.startsWith('image/')) return MediaType.image;
    if (mimeType.startsWith('video/')) return MediaType.video;
    if (mimeType.startsWith('audio/')) return MediaType.audio;
    if (mimeType == 'application/pdf' || mimeType == 'application/epub+zip') {
      return MediaType.document;
    }
    return MediaType.file;
  }
}
