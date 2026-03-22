part of '../quick_entry_sheet.dart';

/// Entry Type Card - Einzelne Karte für einen Eintragstyp
class _EntryTypeCard extends StatefulWidget {
  final EntryType type;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _EntryTypeCard({
    required this.type,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<_EntryTypeCard> createState() => _EntryTypeCardState();
}

class _EntryTypeCardState extends State<_EntryTypeCard> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getTypeColor(widget.type);
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: widget.isSelected 
              ? color.withValues(alpha: 0.2)
              : _isPressed 
                  ? color.withValues(alpha: 0.1)
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isSelected 
                ? color
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: widget.isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (_isPressed) ...[
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji Icon
            AnimatedScale(
              duration: const Duration(milliseconds: 100),
              scale: _isPressed ? 1.2 : 1.0,
              child: Text(
                widget.type.emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
            const SizedBox(height: 6),
            // Label
            Text(
              widget.type.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: widget.isSelected 
                    ? color
                    : theme.colorScheme.onSurface,
                fontWeight: widget.isSelected 
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getTypeColor(EntryType type) {
    switch (type) {
      case EntryType.note:
        return Colors.blue;
      case EntryType.mood:
        return Colors.orange;
      case EntryType.photo:
        return Colors.green;
      case EntryType.audio:
        return Colors.purple;
      case EntryType.video:
        return Colors.red;
      case EntryType.workout:
        return Colors.teal;
      case EntryType.meal:
        return Colors.amber;
      case EntryType.media:
        return Colors.indigo;
      case EntryType.book:
        return Colors.brown;
      case EntryType.gratitude:
        return Colors.pink;
      case EntryType.idea:
        return Colors.yellow;
      case EntryType.contact:
        return Colors.cyan;
    }
  }
}
