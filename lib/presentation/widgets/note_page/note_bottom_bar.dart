import 'package:flutter/material.dart';
import 'package:keepit/domain/models/note.dart';

class NoteBottomBar extends StatelessWidget {
  final Note note;
  final VoidCallback onColorPick;
  final VoidCallback onMoreOptions;
  final bool isTransparent;
  final VoidCallback? onNoteTypeChange;

  const NoteBottomBar({
    super.key,
    required this.note,
    required this.onColorPick,
    required this.onMoreOptions,
    required this.isTransparent,
    this.onNoteTypeChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isTransparent ? Colors.transparent : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.color_lens_outlined),
                onPressed: onColorPick,
              ),
              if (onNoteTypeChange != null)
                IconButton(
                  icon: const Icon(Icons.note_alt_outlined),
                  onPressed: onNoteTypeChange,
                ),
            ],
          ),
          Text(
            'Edited ${_formatEditedDate(note.updatedAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: onMoreOptions,
          ),
        ],
      ),
    );
  }

  String _formatEditedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
