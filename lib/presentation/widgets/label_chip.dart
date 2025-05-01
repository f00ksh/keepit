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
  final bool truncateText;
  final int maxTextLength;

  const LabelChip({
    super.key,
    required this.label,
    this.onTap,
    this.noteColorIndex,
    this.wallpaperIndex,
    this.truncateText = false,
    this.maxTextLength = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (label == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.labelMedium;

    // Use semi-transparent colors to show what's behind
    final backgroundColor =
        colorScheme.surfaceContainer.withValues(alpha: 0.65);

    // Truncate text if needed
    String displayText = label!.name;
    if (truncateText && displayText.length > maxTextLength) {
      displayText = '${displayText.substring(0, maxTextLength)}...';
    }

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
              displayText,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
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

    // Check if we have long labels
    bool hasLongLabels = false;
    if (visibleLabelIds.isNotEmpty) {
      final firstLabelId = visibleLabelIds.first;
      final firstLabel = ref.watch(labelByIdProvider(firstLabelId));

      // If first label is long (more than 10 chars), only show one label
      if (firstLabel != null && firstLabel.name.length > 10) {
        hasLongLabels = true;
      }
    }

    // Fixed: Removed the Expanded widget that was causing the error
    return RepaintBoundary(
      child: Wrap(
        spacing: 3,
        runSpacing: 3,
        children: [
          if (hasLongLabels && visibleLabelIds.isNotEmpty)
            // Show only the first label with truncation if it's long
            _buildSingleLongLabel(context, ref, visibleLabelIds.first,
                visibleLabelIds.length - 1 + remainingCount)
          else
            // Show multiple labels as before
            ...visibleLabelIds.map((labelId) {
              final label = ref.watch(labelByIdProvider(labelId));
              // Skip rendering if label is null
              if (label == null) return const SizedBox.shrink();

              return LabelChip(
                noteColorIndex: note.colorIndex,
                wallpaperIndex: note.wallpaperIndex,
                label: label,
                onTap: onTap,
                truncateText: true,
                maxTextLength: 10,
              );
            }),

          // Show the "+X" chip if there are more labels and we're not in long label mode
          if (remainingCount > 0 && !hasLongLabels)
            _buildRemainingCountChip(context, remainingCount),
        ],
      ),
    );
  }

  // Build a single label with a count indicator for long labels
  Widget _buildSingleLongLabel(
      BuildContext context, WidgetRef ref, String labelId, int otherCount) {
    final label = ref.watch(labelByIdProvider(labelId));
    if (label == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LabelChip(
          noteColorIndex: note.colorIndex,
          wallpaperIndex: note.wallpaperIndex,
          label: label,
          onTap: onTap,
          truncateText: true,
          maxTextLength: 15, // Allow longer text for single label
        ),
        if (otherCount > 0)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: _buildRemainingCountChip(context, otherCount),
          ),
      ],
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
