part of '../quick_entry_sheet.dart';

/// Photo Form - Formular für Foto-Einträge
class _PhotoForm extends ConsumerStatefulWidget {
  final Future<void> Function({
    required String content,
    String? title,
    int? mood,
    int? energy,
    List<String>? tags,
    Map<String, dynamic>? extraData,
  }) onSave;
  
  const _PhotoForm({required this.onSave});

  @override
  ConsumerState<_PhotoForm> createState() => _PhotoFormState();
}

class _PhotoFormState extends ConsumerState<_PhotoForm> {
  File? _selectedImage;
  String _note = '';
  int? _mood;
  
  bool _isSaving = false;
  
  final _noteController = TextEditingController();

  @override
  void dispose() {
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
          // Photo Area
          Expanded(
            child: _selectedImage != null
                ? _buildImagePreview(context)
                : _buildPhotoPlaceholder(context),
          ),
          
          const SizedBox(height: 16),
          
          // Mood Quick Select
          _buildMoodQuickSelect(context),
          
          const SizedBox(height: 16),
          
          // Note Input
          TextField(
            controller: _noteController,
            onChanged: (v) => _note = v,
            decoration: InputDecoration(
              hintText: 'Beschreibe das Foto... (optional)',
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galerie'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _selectedImage != null && !_isSaving ? _save : null,
              icon: _isSaving 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Foto speichern'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Foto hinzufügen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Wähle aus der Galerie oder mache ein neues Foto',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Remove Button
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => setState(() => _selectedImage = null),
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodQuickSelect(BuildContext context) {
    return Row(
      children: [
        Text(
          'Stimmung:',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(5, (index) {
                final value = index + 1;
                final isSelected = _mood == value;
                
                return GestureDetector(
                  onTap: () => setState(() {
                    _mood = isSelected ? null : value;
                  }),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      ['😩', '😔', '😐', '🙂', '😊'][index],
                      style: TextStyle(
                        fontSize: isSelected ? 28 : 24,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (image != null && mounted) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );
    if (image != null && mounted) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    await widget.onSave(
      content: _note.isNotEmpty ? _note : 'Foto-Eintrag',
      title: '📷 Foto',
      mood: _mood,
      extraData: {
        'has_photo': true,
        'photo_path': _selectedImage?.path,
      },
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}
