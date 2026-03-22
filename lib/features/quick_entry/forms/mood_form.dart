part of '../quick_entry_sheet.dart';

/// Mood Form - Formular für Stimmungs-Einträge
class _MoodForm extends ConsumerStatefulWidget {
  final Future<void> Function({
    required String content,
    String? title,
    int? mood,
    int? energy,
    List<String>? tags,
    Map<String, dynamic>? extraData,
  }) onSave;
  
  const _MoodForm({required this.onSave});

  @override
  ConsumerState<_MoodForm> createState() => _MoodFormState();
}

class _MoodFormState extends ConsumerState<_MoodForm> {
  int? _mood;
  int? _energy;
  double? _sleep;
  int? _stress;
  String? _note;
  
  final _moodEmojis = ['😩', '😔', '😐', '🙂', '😊'];
  final _moodLabels = ['Schrecklich', 'Schlecht', 'Neutral', 'Gut', 'Ausgezeichnet'];
  
  bool _isSaving = false;

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
            // Mood Selector (Groß und Prominent)
            _buildMoodSelector(context),
            
            const SizedBox(height: 24),
            
            // Energy & Sleep Row
            Row(
              children: [
                Expanded(
                  child: _buildSliderProperty(
                    context: context,
                    label: 'Energie',
                    icon: '⚡',
                    value: _energy?.toDouble(),
                    color: Colors.green,
                    onChanged: (v) => setState(() => _energy = v?.round()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSliderProperty(
                    context: context,
                    label: 'Schlaf',
                    icon: '😴',
                    value: _sleep,
                    color: Colors.purple,
                    max: 12,
                    divisions: 24,
                    unit: 'h',
                    onChanged: (v) => setState(() => _sleep = v),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Stress
            _buildSliderProperty(
              context: context,
              label: 'Stress',
              icon: '🧠',
              value: _stress?.toDouble(),
              color: Colors.red,
              isReversed: true, // Niedriger = besser
              onChanged: (v) => setState(() => _stress = v?.round()),
            ),
            
            const SizedBox(height: 24),
            
            // Note Input
            TextField(
              onChanged: (v) => _note = v,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Was beschäftigt dich? (optional)',
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _mood != null && !_isSaving ? _save : null,
                icon: _isSaving 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: const Text('Stimmung speichern'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context) {
    return Column(
      children: [
        Text(
          'Wie fühlst du dich heute?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (index) {
            final value = index + 1;
            final isSelected = _mood == value;
            final mood = MoodLevelExtension.fromValue(value);
            
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _mood = value);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected 
                      ? mood.color.withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected 
                        ? mood.color
                        : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _moodEmojis[index],
                      style: TextStyle(
                        fontSize: isSelected ? 40 : 32,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              curve: Curves.elasticOut,
              delay: Duration(milliseconds: index * 50),
            );
          }),
        ),
        const SizedBox(height: 16),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _mood != null ? 1 : 0,
          child: Text(
            _mood != null ? _moodLabels[_mood! - 1] : '',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: MoodLevelExtension.fromValue(_mood ?? 3).color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliderProperty({
    required BuildContext context,
    required String label,
    required String icon,
    required double? value,
    required Color color,
    required void Function(double?) onChanged,
    double max = 5,
    int divisions = 5,
    String unit = '',
    bool isReversed = false,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge,
              ),
              const Spacer(),
              if (value != null)
                Text(
                  '${value.toStringAsFixed(unit == 'h' ? 1 : 0)}$unit',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.1),
            ),
            child: Slider(
              value: value ?? (max / 2),
              min: 1,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    // Generate content from mood
    final content = _note ?? 'Stimmung: ${_moodLabels[_mood! - 1]}';
    
    await widget.onSave(
      content: content,
      title: 'Stimmung: ${_moodEmojis[_mood! - 1]}',
      mood: _mood,
      energy: _energy,
      extraData: {
        'sleep': _sleep,
        'stress': _stress,
      },
    );
    
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}
