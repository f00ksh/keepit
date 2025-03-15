import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/data/providers/labels_provider.dart';
import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/domain/models/note.dart';
import '../../domain/models/label.dart';
import '../../core/theme/app_theme.dart';

class LabelChip extends StatelessWidget {
  final Label? label;
  final int? noteColorIndex;
  final bool isSelected;
  final bool removable;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const LabelChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.removable = false,
    this.onTap,
    this.onRemove,
    this.noteColorIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (label == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final noteColor = getNoteColor(context, noteColorIndex ?? 0);

    // Adjust blend color and opacity based on theme
    final blendedColor = isDark
        ? Color.alphaBlend(Colors.white.withOpacity(0.2), noteColor!)
        : Color.alphaBlend(Colors.grey.withOpacity(0.2), noteColor!);

    final labelColor = isDark ? Colors.white : Colors.white;

    return FilterChip(
      visualDensity: VisualDensity(horizontal: -4, vertical: -4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      label: Text(
        // material 3 style
        style: Theme.of(context).textTheme.labelMedium,
        label!.name,
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (onTap != null) onTap!();
      },
      onDeleted: removable ? onRemove : null,
      deleteIcon: Icon(Icons.close, size: 12, color: labelColor),
      backgroundColor: blendedColor,
      selectedColor: blendedColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: BorderSide(
          color: noteColor,
          width: 1,
        ),
      ),
    );
  }
}

class NoteLabelsSection extends ConsumerWidget {
  final Note note;
  final bool isEditable;

  const NoteLabelsSection({
    super.key,
    required this.note,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (note.labelIds.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: note.labelIds.map((labelId) {
        return LabelChip(
          noteColorIndex: note.colorIndex,
          label: ref.watch(labelByIdProvider(labelId)),
          onTap: isEditable
              ? () => ref
                  .read(notesProvider.notifier)
                  .removeLabelFromNote(note.id, labelId)
              : null,
        );
      }).toList(),
    );
  }
}
