part of '../quick_entry_sheet.dart';

/// Audio Form - Formular für Audio-Aufnahmen und Transkription
class _AudioForm extends ConsumerStatefulWidget {
  final Future<void> Function({
    required String content,
    String? title,
    int? mood,
    int? energy,
    List<String>? tags,
    Map<String, dynamic>? extraData,
  }) onSave;
  
  const _AudioForm({required this.onSave});

  @override
  ConsumerState<_AudioForm> createState() => _AudioFormState();
}

class _AudioFormState extends ConsumerState<_AudioForm> 
    with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  String? _transcription;
  Duration _recordingDuration = Duration.zero;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        children: [
          // Recording Area
          Expanded(
            child: _transcription != null
                ? _buildTranscriptionPreview(context)
                : _buildRecordingArea(context),
          ),
          
          const SizedBox(height: 16),
          
          // Note Input
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'Zusätzliche Notizen... (optional)',
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          if (_transcription == null) ...[
            // Record Button
            _buildRecordButton(context),
          ] else ...[
            // Save / Retry Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _resetRecording,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Neu aufnehmen'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Speichern'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordingArea(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _isRecording 
            ? Colors.red.withValues(alpha: 0.05)
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isRecording 
              ? Colors.red.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Microphone Icon or Waveform
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _isRecording ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording 
                        ? Colors.red.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    _isRecording ? Icons.mic : Icons.mic_none,
                    size: 48,
                    color: _isRecording 
                        ? Colors.red
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Duration or Instruction
          if (_isRecording) ...[
            Text(
              _formatDuration(_recordingDuration),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aufnahme läuft...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
            ),
          ] else ...[
            Text(
              'Tippe zum Aufnehmen',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Sprachaufnahme mit automatischer Transkription',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Transcribe Toggle
          if (_isRecording)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  'Automatische Transkription aktiv',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Transkription',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: _editTranscription,
                tooltip: 'Bearbeiten',
              ),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _transcription!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordButton(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startRecording(),
      onTapUp: (_) => _stopRecording(),
      onTapCancel: () => _stopRecording(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _isRecording 
              ? Colors.red 
              : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              _isRecording 
                  ? 'Loslassen zum Stoppen'
                  : 'Halten zum Aufnehmen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startRecording() {
    setState(() => _isRecording = true);
    _pulseController.repeat(reverse: true);
    
    // TODO: Implement actual recording
    // _recording = await _audioRecorder.start();
    
    // Simulate recording duration
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isRecording) {
        setState(() => _recordingDuration = const Duration(seconds: 1));
      }
    });
  }

  void _stopRecording() {
    if (!_isRecording) return;
    
    setState(() => _isRecording = false);
    _pulseController.stop();
    _pulseController.reset();
    
    // TODO: Implement actual stop and transcribe
    // final path = await _audioRecorder.stop();
    // _transcription = await _speechService.transcribe(path);
    
    // Simulate transcription
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _transcription = 'Dies ist eine simulierte Transkription. '
              'Die eigentliche Spracherkennung wird mit dem speech_to_text '
              'Package implementiert.';
        });
      }
    });
  }

  void _resetRecording() {
    setState(() {
      _transcription = null;
      _recordingDuration = Duration.zero;
    });
  }

  void _editTranscription() {
    final controller = TextEditingController(text: _transcription);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Transkription bearbeiten'),
        content: TextField(
          controller: controller,
          maxLines: 10,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _transcription = controller.text);
              Navigator.pop(context);
            },
            child: const Text('Übernehmen'),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get _isSaving => false; // Placeholder

  Future<void> _save() async {
    await widget.onSave(
      content: _transcription ?? 'Audio-Aufnahme',
      title: '🎤 Audio-Notiz',
      extraData: {
        'has_audio': true,
        'duration_seconds': _recordingDuration.inSeconds,
        'transcribed': _transcription != null,
      },
    );
  }
}
