import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/providers/note_view_provider.dart';
import 'package:keepit/presentation/widgets/theme_color_picker.dart';

class NoteColorPickerBar extends ConsumerWidget {
  final Note note;
  final String noteId;

  const NoteColorPickerBar({
    super.key,
    required this.note,
    required this.noteId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ThemeColorPicker(
        selectedIndex: note.colorIndex,
        onColorSelected: (index) =>
            ref.read(noteViewProvider(noteId).notifier).updateColor(index),
      ),
    );
  }
}
