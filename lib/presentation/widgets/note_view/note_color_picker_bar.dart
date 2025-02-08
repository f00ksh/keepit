import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/providers/note_view_provider.dart';
import 'package:keepit/presentation/widgets/theme_color_picker.dart';

class NoteColorPickerBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onColorSelected;

  const NoteColorPickerBar({
    super.key,
    required this.selectedIndex,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ThemeColorPicker(
        selectedIndex: selectedIndex,
        onColorSelected: onColorSelected,
      ),
    );
  }
}
