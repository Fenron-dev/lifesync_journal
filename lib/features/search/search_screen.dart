import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../core/providers/app_provider.dart';
import '../../core/models/entry_type.dart';

/// Search Screen - Volltext-Suche mit Obsidian-Style Syntax
///
/// Features:
/// - Volltext-Suche in Titel und Inhalt
/// - Filter nach Typ, Stimmung, Tags
/// - Obsidian-kompatible Such-Syntax
/// - Zuletzt gesucht
/// - Suchvorschläge
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  
  bool _showFilters = false;
  bool _showHelp = false;
  
  // Filter state
  final Set<EntryType> _selectedTypes = {};
  final Set<int> _selectedMoods = {};
  final Set<String> _selectedTags = {};
  // Recent searches
  final List<String> _recentSearches = [
    'meditation',
    'projekt',
    'familie',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    HapticFeedback.lightImpact();
    ref.read(searchQueryProvider.notifier).state = query;
    
    // Add to recent searches
    if (query.trim().isNotEmpty && !_recentSearches.contains(query.trim())) {
      setState(() {
        _recentSearches.insert(0, query.trim());
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedTypes.clear();
      _selectedMoods.clear();
      _selectedTags.clear();
    });
  }

  bool get _hasActiveFilters =>
      _selectedTypes.isNotEmpty ||
      _selectedMoods.isNotEmpty ||
      _selectedTags.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            _buildSearchHeader(context),
            
            // Help Panel
            if (_showHelp) _buildHelpPanel(context),
            
            // Filters Panel
            if (_showFilters) _buildFiltersPanel(context),
            
            // Content
            Expanded(
              child: searchQuery.isEmpty && !_hasActiveFilters
                  ? _buildInitialContent(context)
                  : _buildSearchResults(context, searchResults),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Suchen...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
                setState(() {});
              },
              onSubmitted: _handleSearch,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.help_outline,
              color: _showHelp ? theme.colorScheme.primary : null,
            ),
            onPressed: () => setState(() => _showHelp = !_showHelp),
            tooltip: 'Such-Hilfe',
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _showFilters || _hasActiveFilters 
                  ? theme.colorScheme.primary 
                  : null,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: 'Filter',
          ),
        ],
      ),
    );
  }

  Widget _buildHelpPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Such-Syntax (Obsidian-Stil):',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          _buildSyntaxRow('type:note', 'Nach Eintragstyp filtern'),
          _buildSyntaxRow('mood:4', 'Nach Stimmung (1-5) filtern'),
          _buildSyntaxRow('tag:arbeit', 'Nach Tag filtern'),
          _buildSyntaxRow('date:2024-03-15', 'Nach Datum filtern'),
          const SizedBox(height: 8),
          Text(
            'Kombiniere Filter: type:mood tag:meditation energie',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildSyntaxRow(String syntax, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              syntax,
              style: TextStyle(
                fontFamily: 'monospace',
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Filter
          Text('Typ', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EntryType.values.map((type) {
              final isSelected = _selectedTypes.contains(type);
              return FilterChip(
                label: Text('${type.emoji} ${type.label}'),
                selected: isSelected,
                onSelected: (selected) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (selected) {
                      _selectedTypes.add(type);
                    } else {
                      _selectedTypes.remove(type);
                    }
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Mood Filter
          Text('Stimmung', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final mood = index + 1;
              final isSelected = _selectedMoods.contains(mood);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (isSelected) {
                      _selectedMoods.remove(mood);
                    } else {
                      _selectedMoods.add(mood);
                    }
                  });
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      ['😩', '😔', '😐', '🙂', '😊'][index],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              );
            }),
          ),
          
          // Clear Filters
          if (_hasActiveFilters) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: const Text('Filter zurücksetzen'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildInitialContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          Text(
            'Zuletzt gesucht',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((search) {
              return InkWell(
                onTap: () {
                  _controller.text = search;
                  _handleSearch(search);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        size: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 6),
                      Text(search),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 32),
          
          // Suggested Searches
          Text(
            'Vorschläge',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          ...[
            _SuggestedSearch(
              query: 'tag:meditation',
              label: 'Meditation Einträge',
              onTap: () => _applySuggestion('tag:meditation'),
            ),
            _SuggestedSearch(
              query: 'type:mood',
              label: 'Alle Stimmungen',
              onTap: () => _applySuggestion('type:mood'),
            ),
            _SuggestedSearch(
              query: 'mood:5',
              label: 'Beste Stimmung 😊',
              onTap: () => _applySuggestion('mood:5'),
            ),
            _SuggestedSearch(
              query: 'type:idea',
              label: 'Meine Ideen',
              onTap: () => _applySuggestion('type:idea'),
            ),
          ],
        ],
      ),
    );
  }

  void _applySuggestion(String query) {
    _controller.text = query;
    _handleSearch(query);
  }

  Widget _buildSearchResults(BuildContext context, AsyncValue<List<dynamic>> results) {
    return results.when(
      data: (entries) {
        if (entries.isEmpty) {
          return _buildEmptyState(context);
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '${entries.length} ${entries.length == 1 ? 'Ergebnis' : 'Ergebnisse'}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return _SearchResultCard(
                    entry: entry,
                    searchQuery: _controller.text,
                  ).animate().fadeIn(
                    duration: 200.ms,
                    delay: Duration(milliseconds: index * 50),
                  ).slideX(begin: 0.1, end: 0);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Fehler: $error'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Keine Ergebnisse gefunden',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Versuche andere Suchbegriffe',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// Search Result Card with highlighting
class _SearchResultCard extends StatelessWidget {
  final dynamic entry;
  final String searchQuery;
  
  const _SearchResultCard({
    required this.entry,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final typeConfig = EntryType.values.firstWhere(
      (t) => t.name == entry.entryType,
      orElse: () => EntryType.note,
    );
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to entry detail
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: typeConfig.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        typeConfig.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.title?.isNotEmpty == true 
                              ? entry.title 
                              : 'Eintrag',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          _formatDate(entry.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (entry.mood != null) ...[
                    Text(
                      ['😩', '😔', '😐', '🙂', '😊'][(entry.mood - 1).clamp(0, 4)],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ],
              ),
              if (entry.content?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                _buildHighlightedText(context, entry.content, searchQuery),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightedText(BuildContext context, String text, String query) {
    // Extract search terms (excluding syntax operators)
    final searchTerms = query
        .replaceAll(RegExp(r'\w+:\w+'), '')
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    
    if (searchTerms.isEmpty) {
      return Text(
        text.length > 120 ? '${text.substring(0, 120)}...' : text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    
    // Find first match position
    final lowerText = text.toLowerCase();
    int firstMatch = -1;
    for (final term in searchTerms) {
      final index = lowerText.indexOf(term);
      if (index != -1 && (firstMatch == -1 || index < firstMatch)) {
        firstMatch = index;
      }
    }
    
    // Extract snippet around match
    String snippet;
    if (firstMatch > 40) {
      snippet = '...${text.substring(firstMatch - 20)}';
    } else {
      snippet = text;
    }
    if (snippet.length > 120) {
      snippet = '${snippet.substring(0, 120)}...';
    }
    
    return Text(
      snippet,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMd('de').add_Hm().format(date);
  }
}

/// Suggested Search Item
class _SuggestedSearch extends StatelessWidget {
  final String query;
  final String label;
  final VoidCallback onTap;
  
  const _SuggestedSearch({
    required this.query,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.search,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(label),
        subtitle: Text(
          query,
          style: TextStyle(
            fontFamily: 'monospace',
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}


