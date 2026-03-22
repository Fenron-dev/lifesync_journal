part of '../quick_entry_sheet.dart';

/// Note Form - Formular für Text-Notizen
class _NoteForm extends ConsumerStatefulWidget {
  final EntryType type;
  final Future<void> Function({
    required String content,
    String? title,
    int? mood,
    int? energy,
    List<String>? tags,
    Map<String, dynamic>? extraData,
  }) onSave;
  
  const _NoteForm({
    required this.onSave,
    this.type = EntryType.note,
  });

  @override
  ConsumerState<_NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends ConsumerState<_NoteForm> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final _focusNode = FocusNode();
  
  bool _isSaving = false;
  int? _mood;
  int? _energy;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    // Auto-Focus auf Content
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    _focusNode.dispose();
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
          // Title Input
          TextField(
            controller: _titleController,
            style: theme.textTheme.titleMedium,
            decoration: const InputDecoration(
              hintText: 'Titel (optional)',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          
          const Divider(height: 1),
          
          // Content Input
          Expanded(
            child: TextField(
              controller: _contentController,
              focusNode: _focusNode,
              style: theme.textTheme.bodyLarge,
              decoration: const InputDecoration(
                hintText: 'Was möchtest du festhalten?',
                border: InputBorder.none,
              ),
              maxLines: null,
              expands: true,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
            ),
          ),
          
          // Properties Row
          _buildPropertiesRow(context),
          
          // Tags
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildTagsRow(context),
          ],
          
          // Action Bar
          _buildActionBar(context),
        ],
      ),
    );
  }

  Widget _buildPropertiesRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Mood Quick Select
          _buildMoodSelector(context),
          const SizedBox(width: 12),
          // Energy Quick Select
          _buildEnergySelector(context),
          const SizedBox(width: 12),
          // Tag Button
          ActionChip(
            avatar: const Icon(Icons.label_outline, size: 18),
            label: const Text('Tags'),
            onPressed: _showTagDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Stimmung:',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          final value = index + 1;
          final isSelected = _mood == value;
          final mood = MoodLevelExtension.fromValue(value);
          
          return GestureDetector(
            onTap: () => setState(() {
              _mood = isSelected ? null : value;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected 
                    ? mood.color.withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
              child: Text(
                mood.emoji,
                style: TextStyle(
                  fontSize: isSelected ? 24 : 20,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEnergySelector(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Energie:',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          final value = index + 1;
          final isSelected = _energy == value;
          final energyColor = [Colors.red, Colors.orange, Colors.amber, Colors.lightGreen, Colors.green][index];

          return GestureDetector(
            onTap: () => setState(() {
              _energy = isSelected ? null : value;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? energyColor.withValues(alpha: 0.2)
                    : Colors.transparent,
              ),
              child: Text(
                '⚡',
                style: TextStyle(
                  fontSize: isSelected ? 20 : 16,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTagsRow(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: _tags.map((tag) {
        return Chip(
          label: Text('#$tag'),
          onDeleted: () => setState(() {
            _tags.remove(tag);
          }),
          deleteIcon: const Icon(Icons.close, size: 16),
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    final hasContent = _contentController.text.trim().isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          // Character Count
          Text(
            '${_contentController.text.length} Zeichen',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const Spacer(),
          // Save Button
          FilledButton.icon(
            onPressed: hasContent && !_isSaving ? _save : null,
            icon: _isSaving 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _showTagDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tags hinzufügen'),
        content: TextField(
          controller: _tagController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'z.B. wichtig, idee, projekt',
            helperText: 'Mehrere Tags mit Komma trennen',
          ),
          onSubmitted: (_) => _addTags(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: _addTags,
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
  }

  void _addTags() {
    final input = _tagController.text.trim();
    if (input.isEmpty) return;
    
    setState(() {
      final newTags = input
          .split(',')
          .map((t) => t.trim().replaceAll('#', ''))
          .where((t) => t.isNotEmpty && !_tags.contains(t))
          .toList();
      _tags.addAll(newTags);
      _tagController.clear();
    });
    
    Navigator.pop(context);
  }

  Future<void> _save() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    await widget.onSave(
      content: _contentController.text.trim(),
      title: _titleController.text.trim().isEmpty 
          ? null 
          : _titleController.text.trim(),
      mood: _mood,
      energy: _energy,
      tags: _tags.isEmpty ? null : _tags,
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}
