import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/quick_entry/quick_entry_sheet.dart';

/// Quick Add Button - Der zentrale Plus-Button
class QuickAddButton extends StatefulWidget {
  const QuickAddButton({super.key});

  @override
  State<QuickAddButton> createState() => _QuickAddButtonState();
}

class _QuickAddButtonState extends State<QuickAddButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primary,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _handleTap(context),
        borderRadius: BorderRadius.circular(28),
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(
            Icons.add,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          curve: Curves.elasticOut,
        );
  }

  void _handleTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const QuickEntrySheet(),
    );
  }
}
