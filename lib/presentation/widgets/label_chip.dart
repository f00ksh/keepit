import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/data/providers/labels_provider.dart';
import 'package:keepit/domain/models/note.dart';
import '../../domain/models/label.dart';

class LabelChip extends StatelessWidget {
  final Label? label;
  final int? noteColorIndex;
  final int? wallpaperIndex;
  final VoidCallback? onTap;

  const LabelChip({
    super.key,
    required this.label,
    this.onTap,
    this.noteColorIndex,
    this.wallpaperIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (label == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelMedium;

    // Use semi-transparent colors to show what's behind
    final backgroundColor =
        colorScheme.surfaceContainer.withValues(alpha: 0.65);

    // Use RepaintBoundary to isolate repaints
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label!.name,
              style: textStyle,
            ),
          ),
        ),
      ),
    );
  }
}

class NoteLabelsSection extends ConsumerWidget {
  final Note note;
  final VoidCallback? onTap;
  final int? maxLabelsToShow;

  const NoteLabelsSection({
    super.key,
    required this.note,
    this.onTap,
    this.maxLabelsToShow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (note.labelIds.isEmpty) return const SizedBox.shrink();

    final labelIds = note.labelIds;
    final visibleLabelIds = maxLabelsToShow != null
        ? labelIds.take(maxLabelsToShow!).toList()
        : labelIds.toList();
    final remainingCount = labelIds.length - visibleLabelIds.length;

    // Fixed: Removed the Expanded widget that was causing the error
    return RepaintBoundary(
      child: Wrap(
        spacing: 3,
        runSpacing: 3,
        children: [
          ...visibleLabelIds.map((labelId) {
            final label = ref.watch(labelByIdProvider(labelId));
            // Skip rendering if label is null
            if (label == null) return const SizedBox.shrink();

            return LabelChip(
              noteColorIndex: note.colorIndex,
              wallpaperIndex: note.wallpaperIndex,
              label: label,
              onTap: onTap,
            );
          }),

          // Show the "+X" chip if there are more labels
          if (remainingCount > 0)
            _buildRemainingCountChip(context, remainingCount),
        ],
      ),
    );
  }

  Widget _buildRemainingCountChip(BuildContext context, int count) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelMedium;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+$count',
                style: textStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
