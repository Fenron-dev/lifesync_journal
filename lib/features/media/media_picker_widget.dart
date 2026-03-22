import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/models/journal_attachment.dart';
import '../../core/services/attachment_service.dart';

/// Media Picker Widget für Journal-Einträge
class MediaPickerWidget extends ConsumerStatefulWidget {
  final int journalEntryId;
  final Function(JournalAttachment)? onAttachmentAdded;
  final Function(int)? onAttachmentRemoved;

  const MediaPickerWidget({
    super.key,
    required this.journalEntryId,
    this.onAttachmentAdded,
    this.onAttachmentRemoved,
  });

  @override
  ConsumerState<MediaPickerWidget> createState() => _MediaPickerWidgetState();
}

class _MediaPickerWidgetState extends ConsumerState<MediaPickerWidget> {
  List<JournalAttachment> _attachments = [];
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  Future<void> _loadAttachments() async {
    final service = ref.read(attachmentServiceProvider);
    final attachments = await service.getAttachmentsForEntry(widget.journalEntryId);
    setState(() {
      _attachments = attachments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aktions-Buttons
        Row(
          children: [
            // Foto aufnehmen
            _buildActionButton(
              icon: Icons.camera_alt,
              label: 'Foto',
              onTap: _capturePhoto,
            ),
            const SizedBox(width: 8),
            
            // Galerie
            _buildActionButton(
              icon: Icons.photo_library,
              label: 'Galerie',
              onTap: _pickFromGallery,
            ),
            const SizedBox(width: 8),
            
            // Audio aufnehmen
            _buildActionButton(
              icon: _isRecording ? Icons.stop : Icons.mic,
              label: _isRecording ? 'Stop' : 'Audio',
              color: _isRecording ? Colors.red : null,
              onTap: _toggleAudioRecording,
            ),
          ],
        ),

        // Attachments Vorschau
        if (_attachments.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildAttachmentsGrid(),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: (color ?? Theme.of(context).colorScheme.primary)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (color ?? Theme.of(context).colorScheme.primary)
                  .withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color ?? Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentsGrid() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _attachments.length,
        itemBuilder: (context, index) {
          return _buildAttachmentPreview(_attachments[index]);
        },
      ),
    );
  }

  Widget _buildAttachmentPreview(JournalAttachment attachment) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          // Preview
          GestureDetector(
            onTap: () => _showAttachmentDetail(attachment),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildPreviewContent(attachment),
              ),
            ),
          ),
          
          // Delete Button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _deleteAttachment(attachment),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
          
          // Type Indicator
          if (attachment.type == AttachmentType.audio)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(attachment.durationSeconds ?? 0),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent(JournalAttachment attachment) {
    switch (attachment.type) {
      case AttachmentType.image:
        return FutureBuilder<Uint8List?>(
          future: ref.read(attachmentServiceProvider).loadThumbnail(attachment),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              );
            }
            return Container(
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.image, size: 32)),
            );
          },
        );
      
      case AttachmentType.audio:
        return Container(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Center(
            child: Icon(
              Icons.audiotrack,
              size: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      
      case AttachmentType.video:
        return Container(
          color: Colors.grey[800],
          child: const Center(
            child: Icon(Icons.play_circle, size: 40, color: Colors.white),
          ),
        );
      
      default:
        return Container(
          color: Colors.grey[300],
          child: Center(child: Icon(Icons.insert_drive_file, size: 32)),
        );
    }
  }

  // ============ ACTIONS ============

  Future<void> _capturePhoto() async {
    final service = ref.read(attachmentServiceProvider);
    final attachment = await service.capturePhoto(
      journalEntryId: widget.journalEntryId,
    );
    
    if (attachment != null && mounted) {
      setState(() => _attachments.add(attachment));
      widget.onAttachmentAdded?.call(attachment);
    }
  }

  Future<void> _pickFromGallery() async {
    final service = ref.read(attachmentServiceProvider);
    final attachments = await service.pickMultipleImages(
      journalEntryId: widget.journalEntryId,
    );
    
    if (attachments.isNotEmpty && mounted) {
      setState(() => _attachments.addAll(attachments));
      for (final a in attachments) {
        widget.onAttachmentAdded?.call(a);
      }
    }
  }

  Future<void> _toggleAudioRecording() async {
    final service = ref.read(attachmentServiceProvider);
    
    if (_isRecording) {
      // Stop recording
      final attachment = await service.stopAudioRecording(
        journalEntryId: widget.journalEntryId,
      );
      
      if (attachment != null && mounted) {
        setState(() {
          _attachments.add(attachment);
          _isRecording = false;
        });
        widget.onAttachmentAdded?.call(attachment);
      }
    } else {
      // Start recording
      final success = await service.startAudioRecording();
      if (success && mounted) {
        setState(() => _isRecording = true);
        
        // Zeige Recording-Indikator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎙️ Aufnahme gestartet...'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _deleteAttachment(JournalAttachment attachment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anhang löschen?'),
        content: const Text('Möchtest du diesen Anhang wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final service = ref.read(attachmentServiceProvider);
      await service.deleteAttachment(attachment.id);
      
      setState(() {
        _attachments.removeWhere((a) => a.id == attachment.id);
      });
      
      widget.onAttachmentRemoved?.call(attachment.id);
    }
  }

  void _showAttachmentDetail(JournalAttachment attachment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AttachmentDetailView(attachment: attachment),
    );
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}

// ============ ATTACHMENT DETAIL VIEW ============

class AttachmentDetailView extends ConsumerWidget {
  final JournalAttachment attachment;

  const AttachmentDetailView({super.key, required this.attachment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 1.0,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      // Media Preview
                      _buildMediaPreview(context, ref),
                      
                      // Info
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Type & Size
                            Row(
                              children: [
                                _buildInfoChip(
                                  icon: _getTypeIcon(),
                                  label: _getTypeName(),
                                ),
                                const SizedBox(width: 8),
                                _buildInfoChip(
                                  icon: Icons.storage,
                                  label: _formatFileSize(attachment.fileSize),
                                ),
                                if (attachment.width != null) ...[
                                  const SizedBox(width: 8),
                                  _buildInfoChip(
                                    icon: Icons.aspect_ratio,
                                    label: '${attachment.width}×${attachment.height}',
                                  ),
                                ],
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Date
                            ListTile(
                              leading: const Icon(Icons.access_time),
                              title: const Text('Erstellt'),
                              subtitle: Text(
                                DateFormat('dd.MM.yyyy HH:mm').format(attachment.createdAt),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            
                            if (attachment.caption != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Beschreibung',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(attachment.caption!),
                            ],
                            
                            const SizedBox(height: 24),
                            
                            // Actions
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _exportAttachment(ref),
                                    icon: const Icon(Icons.share),
                                    label: const Text('Exportieren'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () => _deleteAttachment(context, ref),
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Löschen'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMediaPreview(BuildContext context, WidgetRef ref) {
    switch (attachment.type) {
      case AttachmentType.image:
        return FutureBuilder<Uint8List?>(
          future: ref.read(attachmentServiceProvider).loadAttachment(attachment),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.memory(
                  snapshot.data!,
                  fit: BoxFit.contain,
                ),
              );
            }
            return const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            );
          },
        );
      
      case AttachmentType.audio:
        return Container(
          height: 200,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.audio_file,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  _formatDuration(attachment.durationSeconds ?? 0),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                // Audio Player würde hier implementiert werden
                FilledButton.icon(
                  onPressed: () {
                    // Audio abspielen
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Abspielen'),
                ),
              ],
            ),
          ),
        );
      
      default:
        return Container(
          height: 200,
          color: Colors.grey[200],
          child: Center(
            child: Icon(_getTypeIcon(), size: 80),
          ),
        );
    }
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    return switch (attachment.type) {
      AttachmentType.image => Icons.image,
      AttachmentType.audio => Icons.audiotrack,
      AttachmentType.video => Icons.videocam,
      AttachmentType.file => Icons.insert_drive_file,
      AttachmentType.sketch => Icons.draw,
    };
  }

  String _getTypeName() {
    return switch (attachment.type) {
      AttachmentType.image => 'Bild',
      AttachmentType.audio => 'Audio',
      AttachmentType.video => 'Video',
      AttachmentType.file => 'Datei',
      AttachmentType.sketch => 'Zeichnung',
    };
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  Future<void> _exportAttachment(WidgetRef ref) async {
    // Export-Dialog würde hier implementiert werden
  }

  Future<void> _deleteAttachment(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anhang löschen?'),
        content: const Text('Möchtest du diesen Anhang wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final service = ref.read(attachmentServiceProvider);
      await service.deleteAttachment(attachment.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

// ============ STORAGE STATS SCREEN ============

class StorageStatsScreen extends ConsumerStatefulWidget {
  const StorageStatsScreen({super.key});

  @override
  ConsumerState<StorageStatsScreen> createState() => _StorageStatsScreenState();
}

class _StorageStatsScreenState extends ConsumerState<StorageStatsScreen> {
  StorageStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final service = ref.read(attachmentServiceProvider);
    final stats = await service.getStorageStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speicherverwaltung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _cleanupOldFiles,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_stats == null) return const SizedBox();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Gesamtübersicht
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Speicherverbrauch',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _stats!.formattedSize,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_stats!.totalFiles} Dateien',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Nach Typ
        Text(
          'Nach Dateityp',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        
        _buildTypeCard(
          icon: Icons.image,
          label: 'Bilder',
          count: _stats!.imageCount,
          color: Colors.green,
        ),
        _buildTypeCard(
          icon: Icons.audiotrack,
          label: 'Audio',
          count: _stats!.audioCount,
          color: Colors.blue,
        ),
        _buildTypeCard(
          icon: Icons.videocam,
          label: 'Videos',
          count: _stats!.videoCount,
          color: Colors.purple,
        ),
        _buildTypeCard(
          icon: Icons.insert_drive_file,
          label: 'Andere',
          count: _stats!.otherCount,
          color: Colors.grey,
        ),
        
        const SizedBox(height: 24),
        
        // Optimierung
        FilledButton.icon(
          onPressed: _optimizeStorage,
          icon: const Icon(Icons.compress),
          label: const Text('Speicher optimieren'),
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: Text(
          '$count',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }

  Future<void> _cleanupOldFiles() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alte Dateien bereinigen?'),
        content: const Text('Dies löscht Anhänge von Einträgen, die älter als 1 Jahr sind.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Bereinigen'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final service = ref.read(attachmentServiceProvider);
      final deleted = await service.cleanupOldAttachments();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$deleted alte Dateien gelöscht')),
        );
        _loadStats();
      }
    }
  }

  Future<void> _optimizeStorage() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Optimiere Speicher...'),
          ],
        ),
      ),
    );

    final service = ref.read(attachmentServiceProvider);
    await service.optimizeStorage();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speicher optimiert!')),
      );
      _loadStats();
    }
  }
}
