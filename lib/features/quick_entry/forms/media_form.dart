part of '../quick_entry_sheet.dart';

/// Media Form - Formular für Medien-Einträge (Filme, Serien, Bücher, etc.)
class _MediaForm extends ConsumerStatefulWidget {
  final EntryType type;
  final Future<void> Function({
    required String content,
    String? title,
    int? mood,
    int? energy,
    List<String>? tags,
    Map<String, dynamic>? extraData,
  }) onSave;
  
  const _MediaForm({
    required this.type,
    required this.onSave,
  });

  @override
  ConsumerState<_MediaForm> createState() => _MediaFormState();
}

class _MediaFormState extends ConsumerState<_MediaForm> {
  final _titleController = TextEditingController();
  final _creatorController = TextEditingController();
  final _noteController = TextEditingController();
  
  int? _rating;
  String _status = 'completed'; // watching, completed, dropped, planned
  String _type = 'movie'; // movie, series, book, audiobook, music, game
  
  bool _isSaving = false;
  
  final _statusOptions = {
    'watching': ('Gerade dabei', Icons.play_circle_outline),
    'completed': ('Abgeschlossen', Icons.check_circle_outline),
    'dropped': ('Abgebrochen', Icons.cancel_outlined),
    'planned': ('Geplant', Icons.schedule),
  };
  
  final _mediaTypes = {
    'movie': ('Film', '🎬'),
    'series': ('Serie', '📺'),
    'book': ('Buch', '📚'),
    'audiobook': ('Hörbuch', '🎧'),
    'music': ('Musik', '🎵'),
    'game': ('Spiel', '🎮'),
    'podcast': ('Podcast', '🎙️'),
    'anime': ('Anime', '⛩️'),
  };

  @override
  void dispose() {
    _titleController.dispose();
    _creatorController.dispose();
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Type Selector
            Text(
              'Was möchtest du dokumentieren?',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildMediaTypeSelector(context),
            
            const SizedBox(height: 20),
            
            // Title Input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Titel',
                hintText: _getPlaceholderTitle(),
                prefixIcon: Text(
                  _mediaTypes[_type]?.$2 ?? '📺',
                  style: const TextStyle(fontSize: 20),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 48),
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
            ),
            
            const SizedBox(height: 16),
            
            // Creator/Autor/Regisseur Input
            TextField(
              controller: _creatorController,
              decoration: InputDecoration(
                labelText: _getCreatorLabel(),
                hintText: _getCreatorPlaceholder(),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 20),
            
            // Status Selector
            Text(
              'Status',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            _buildStatusSelector(context),
            
            const SizedBox(height: 20),
            
            // Rating
            Text(
              'Bewertung',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            _buildRatingSelector(context),
            
            const SizedBox(height: 20),
            
            // Notes
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Notizen',
                hintText: 'Was möchtest du darüber sagen?',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _titleController.text.isNotEmpty && !_isSaving 
                    ? _save 
                    : null,
                icon: _isSaving 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_getSaveLabel()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTypeSelector(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _mediaTypes.entries.map((entry) {
          final isSelected = _type == entry.key;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.value.$2),
                  const SizedBox(width: 4),
                  Text(entry.value.$1),
                ],
              ),
              onSelected: (_) => setState(() => _type = entry.key),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusSelector(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _statusOptions.entries.map((entry) {
        final isSelected = _status == entry.key;
        
        return ChoiceChip(
          avatar: Icon(
            entry.value.$2,
            size: 18,
            color: isSelected ? null : Theme.of(context).colorScheme.outline,
          ),
          label: Text(entry.value.$1),
          selected: isSelected,
          onSelected: (_) => setState(() => _status = entry.key),
        );
      }).toList(),
    );
  }

  Widget _buildRatingSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        final isSelected = _rating != null && value <= _rating!;
        
        return GestureDetector(
          onTap: () => setState(() {
            _rating = _rating == value ? null : value;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            child: Icon(
              isSelected ? Icons.star : Icons.star_border,
              color: isSelected 
                  ? Colors.amber
                  : Theme.of(context).colorScheme.outline,
              size: 36,
            ),
          ),
        );
      }),
    );
  }

  String _getPlaceholderTitle() {
    switch (_type) {
      case 'movie':
        return 'z.B. Der Herr der Ringe';
      case 'series':
        return 'z.B. Breaking Bad';
      case 'book':
        return 'z.B. 1984';
      case 'audiobook':
        return 'z.B. Harry Potter';
      case 'music':
        return 'z.B. Album oder Song';
      case 'game':
        return 'z.B. The Legend of Zelda';
      case 'podcast':
        return 'z.B. Podcast-Name';
      case 'anime':
        return 'z.B. Attack on Titan';
      default:
        return 'Titel eingeben';
    }
  }

  String _getCreatorLabel() {
    switch (_type) {
      case 'movie':
        return 'Regisseur';
      case 'series':
      case 'anime':
        return 'Studio / Creator';
      case 'book':
        return 'Autor';
      case 'audiobook':
        return 'Autor / Sprecher';
      case 'music':
        return 'Künstler';
      case 'game':
        return 'Entwickler';
      case 'podcast':
        return 'Host';
      default:
        return 'Ersteller';
    }
  }

  String _getCreatorPlaceholder() {
    switch (_type) {
      case 'movie':
        return 'z.B. Peter Jackson';
      case 'book':
        return 'z.B. George Orwell';
      case 'music':
        return 'z.B. Queen';
      default:
        return 'Optional';
    }
  }

  String _getSaveLabel() {
    switch (_status) {
      case 'completed':
        return 'Als abgeschlossen speichern';
      case 'watching':
        return 'Als "gerade dabei" speichern';
      case 'dropped':
        return 'Als abgebrochen speichern';
      case 'planned':
        return 'Zur Watchlist hinzufügen';
      default:
        return 'Speichern';
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    // Build content
    final emoji = _mediaTypes[_type]?.$2 ?? '📺';
    final ratingStars = _rating != null 
        ? ' ⭐' * _rating! 
        : '';
    
    final content = '''
$emoji **${_titleController.text}**
${_creatorController.text.isNotEmpty ? 'von ${_creatorController.text}' : ''}

Status: ${_statusOptions[_status]?.$1 ?? 'Unbekannt'}$ratingStars

${_noteController.text}
'''.trim();
    
    await widget.onSave(
      content: content,
      title: '$emoji ${_titleController.text}',
      extraData: {
        'media_type': _type,
        'media_status': _status,
        'rating': _rating,
        'creator': _creatorController.text.isNotEmpty 
            ? _creatorController.text 
            : null,
      },
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}
