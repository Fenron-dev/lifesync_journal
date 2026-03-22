import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Journal Screen - Hauptansicht aller Einträge
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTag = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Kalender-Ansicht
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Erweiterte Suche
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Suchleiste
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Einträge durchsuchen...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          
          // Filter Tags
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text('Alle'),
                  selected: _selectedTag.isEmpty,
                  onSelected: (_) => setState(() => _selectedTag = ''),
                ),
                const SizedBox(width: 8),
                ...['Wichtig', 'Idee', 'Reise', 'Arbeit'].map((tag) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(tag),
                    selected: _selectedTag == tag,
                    onSelected: (_) => setState(() => _selectedTag = tag),
                  ),
                )),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Einträge
          Expanded(
            child: _buildEntriesList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/journal/new'),
        icon: const Icon(Icons.add),
        label: const Text('Neuer Eintrag'),
      ),
    );
  }

  Widget _buildEntriesList() {
    // In echter App würde hier Isar-Query stehen
    // Demo-Daten für Vorschau
    final entries = [
      {
        'title': 'Guten Morgen!',
        'content': 'Heute ist ein wunderbarer Tag. Die Sonne scheint...',
        'date': DateTime.now(),
        'mood': '😊',
        'tags': ['Alltag'],
      },
      {
        'title': 'Projekt-Ideen',
        'content': 'Neue Ideen für das Journal-Projekt:\n- KI-Assistent\n- Mood Tracking...',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'mood': '💡',
        'tags': ['Idee', 'Arbeit'],
      },
      {
        'title': 'Wochenende',
        'content': 'Endlich Wochenende! Pläne:\n- Wandern\n- Lesen\n- Freunde treffen',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'mood': '😃',
        'tags': ['Freizeit'],
      },
    ];

    if (entries.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildEntryCard(entry);
      },
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // context.push('/journal/${entry['id']}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    entry['mood'] as String,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry['title'] as String,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    DateFormat('dd.MM.').format(entry['date'] as DateTime),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Content Preview
              Text(
                entry['content'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              
              const SizedBox(height: 12),
              
              // Tags
              Wrap(
                spacing: 8,
                children: (entry['tags'] as List).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Noch keine Einträge',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tippe auf +, um deinen ersten Eintrag zu erstellen.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Journal Editor Screen
class JournalEditorScreen extends ConsumerStatefulWidget {
  final int? entryId;

  const JournalEditorScreen({super.key, this.entryId});

  @override
  ConsumerState<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends ConsumerState<JournalEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _mood = '😊';
  final Set<String> _tags = {};
  bool _isEditing = false;

  final _availableMoods = ['😢', '😔', '😐', '😊', '😃', '💡', '😤', '😴'];
  final _suggestedTags = ['Alltag', 'Idee', 'Arbeit', 'Reise', 'Wichtig', 'Freizeit', 'Gesundheit'];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.entryId != null;
    
    if (_isEditing) {
      // Lade existierenden Eintrag
      _loadEntry();
    }
  }

  void _loadEntry() {
    // In echter App: Lade aus Isar
    // Demo-Daten
    _titleController.text = 'Guten Morgen!';
    _contentController.text = 'Heute ist ein wunderbarer Tag...';
    _mood = '😊';
    _tags.addAll(['Alltag']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Eintrag bearbeiten' : 'Neuer Eintrag'),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview),
            onPressed: _showPreview,
            tooltip: 'Vorschau',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveEntry,
            tooltip: 'Speichern',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Picker
            Text(
              'Stimmung',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: _availableMoods.map((mood) {
                final isSelected = _mood == mood;
                return GestureDetector(
                  onTap: () => setState(() => _mood = mood),
                  child: Container(
                    width: 44,
                    height: 44,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(mood, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titel',
                hintText: 'Titel des Eintrags...',
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            const SizedBox(height: 16),
            
            // Content
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Inhalt',
                hintText: 'Schreibe deine Gedanken...',
                alignLabelWithHint: true,
              ),
              maxLines: 10,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            
            const SizedBox(height: 20),
            
            // Tags
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestedTags.map((tag) {
                final isSelected = _tags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _tags.add(tag);
                      } else {
                        _tags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Foto hinzufügen
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Foto'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Audio aufnehmen
                    },
                    icon: const Icon(Icons.mic),
                    label: const Text('Audio'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Markdown Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Markdown wird unterstützt. Verwende **fett**, *kursiv*, # Überschriften',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPreview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 1.0,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text(_mood, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _titleController.text.isEmpty
                            ? 'Ohne Titel'
                            : _titleController.text,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, d. MMMM yyyy', 'de_DE').format(DateTime.now()),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _tags.map((tag) => Chip(label: Text(tag))).toList(),
                ),
                const Divider(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Text(
                      _contentController.text.isEmpty
                          ? 'Kein Inhalt'
                          : _contentController.text,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte gib einen Inhalt ein')),
      );
      return;
    }

    // In echter App: Speichere in Isar
    // final entry = JournalEntry()
    //   ..title = _titleController.text
    //   ..content = _contentController.text
    //   ..mood = _mood
    //   ..tags = _tags.toList()
    //   ..createdAt = DateTime.now();

    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Eintrag aktualisiert' : 'Eintrag gespeichert'),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
