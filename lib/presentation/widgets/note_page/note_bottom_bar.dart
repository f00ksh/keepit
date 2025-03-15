import 'package:flutter/material.dart';
import 'package:keepit/domain/models/note.dart';

class NoteBottomBar extends StatelessWidget {
  final Note note;
  final VoidCallback onColorPick;
  final VoidCallback onMoreOptions;

  const NoteBottomBar({
    super.key,
    required this.note,
    required this.onColorPick,
    required this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            onPressed: onColorPick,
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
