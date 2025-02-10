import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/presentation/providers/note_view_provider.dart';
import 'package:keepit/presentation/widgets/theme_color_picker.dart';

class NoteColorPickerBar extends ConsumerWidget {
  final String noteId;

  const NoteColorPickerBar({
    super.key,
    required this.noteId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(noteViewProvider(noteId));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: getNoteColor(context, note.colorIndex),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ThemeColorPicker(
        selectedIndex: note.colorIndex,
        onColorSelected: (index) {
          ref.read(noteViewProvider(noteId).notifier).updateColorIndex(index);
        },
      ),
    );
  }
}
