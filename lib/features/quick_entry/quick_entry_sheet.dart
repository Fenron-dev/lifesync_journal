import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../../core/constants/app_config.dart';
import '../../core/models/daily_mood.dart';
import '../../core/models/entry_type.dart';
import '../../core/providers/app_provider.dart';

part 'widgets/entry_type_card.dart';
part 'forms/note_form.dart';
part 'forms/mood_form.dart';
part 'forms/photo_form.dart';
part 'forms/audio_form.dart';
part 'forms/media_form.dart';

/// Quick Entry Sheet - Schnelleingabe für verschiedene Eintragstypen
/// 
/// Design-Prinzipien:
/// - Maximal 2 Taps bis zum Eingabefeld
/// - Optimiert für eine Hand
/// - Klare visuelle Hierarchie
class QuickEntrySheet extends ConsumerStatefulWidget {
  final EntryType? initialType;
  
  const QuickEntrySheet({super.key, this.initialType});

  @override
  ConsumerState<QuickEntrySheet> createState() => _QuickEntrySheetState();
}

class _QuickEntrySheetState extends ConsumerState<QuickEntrySheet> {
  EntryType? _selectedType;
  bool _showForm = false;
  
  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    if (_selectedType != null) {
      _showForm = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      height: _showForm 
          ? MediaQuery.of(context).size.height * 0.85 
          : 420 + bottomPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          _buildHandle(context),
          
          // Header
          _buildHeader(context),
          
          // Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _showForm 
                  ? _buildFormContent(context)
                  : _buildTypeSelector(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          if (_showForm) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _showForm = false;
                  _selectedType = null;
                });
              },
            ),
            const SizedBox(width: 8),
          ],
          Text(
            _showForm 
                ? '${_selectedType!.emoji} ${_selectedType!.label}'
                : 'Neuer Eintrag',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Schnellzugriff
          Text(
            'Schnellzugriff',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          
          // Häufige Typen (Horizontale Liste)
          _buildQuickAccessRow(context),
          
          const SizedBox(height: 24),
          
          // Alle Typen
          Text(
            'Alle Eintragstypen',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              padding: const EdgeInsets.only(bottom: 20),
              children: EntryType.values.map((type) {
                return _EntryTypeCard(
                  type: type,
                  isSelected: _selectedType == type,
                  onTap: () => _selectType(type),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessRow(BuildContext context) {
    // Die 4 häufigsten Typen
    final quickTypes = [
      EntryType.note,
      EntryType.mood,
      EntryType.photo,
      EntryType.gratitude,
    ];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: quickTypes.map((type) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _QuickAccessButton(
              type: type,
              onTap: () => _selectType(type),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    switch (_selectedType) {
      case EntryType.mood:
        return _MoodForm(onSave: _saveEntry);
      case EntryType.photo:
        return _PhotoForm(onSave: _saveEntry);
      case EntryType.audio:
        return _AudioForm(onSave: _saveEntry);
      case EntryType.media:
      case EntryType.book:
        return _MediaForm(type: _selectedType!, onSave: _saveEntry);
      default:
        return _NoteForm(type: _selectedType!, onSave: _saveEntry);
    }
  }

  void _selectType(EntryType type) {
    HapticFeedback.lightImpact();
    
    setState(() {
      _selectedType = type;
      _showForm = true;
    });
  }

  Future<void> _saveEntry({
    required String content,
    String? title,
    int? mood,
    int? energy,
    List<String>? tags,
    Map<String, dynamic>? extraData,
  }) async {
    // In a real app, this would save to the storage service
    // final storage = ref.read(storageServiceProvider);
    // await storage.saveEntry(entry);
    
    // Update streak and XP
    final currentStreak = ref.read(streakProvider);
    ref.read(streakProvider.notifier).state = currentStreak + 1;
    
    final currentXp = ref.read(xpProvider);
    ref.read(xpProvider.notifier).state = currentXp + AppConfig.xpPerEntry;
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text('${_selectedType?.emoji ?? "📝"} '),
              const Text('Eintrag gespeichert'),
              const Spacer(),
              Text('+${AppConfig.xpPerEntry} XP'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// ============================================================================
// QUICK ACCESS BUTTON
// ============================================================================

class _QuickAccessButton extends StatelessWidget {
  final EntryType type;
  final VoidCallback onTap;
  
  const _QuickAccessButton({
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type.emoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 6),
              Text(
                type.label,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 150.ms)
    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }
}

