import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/data/providers/notes_provider.dart';

class NoteActions extends ConsumerWidget {
  final Note note;
  final bool showDelete;
  final bool showRestore;

  const NoteActions({
    super.key,
    required this.note,
    this.showDelete = true,
    this.showRestore = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleAction(value, context, ref),
      itemBuilder: (context) => [
        if (!note.isFavorite)
          const PopupMenuItem(
            value: 'favorite',
            child: ListTile(
              leading: Icon(Icons.favorite_outline),
              title: Text('Add to favorites'),
            ),
          ),
        if (note.isFavorite)
          const PopupMenuItem(
            value: 'unfavorite',
            child: ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Remove from favorites'),
            ),
          ),
        if (!note.isArchived)
          const PopupMenuItem(
            value: 'archive',
            child: ListTile(
              leading: Icon(Icons.archive_outlined),
              title: Text('Archive'),
            ),
          ),
        if (note.isArchived)
          const PopupMenuItem(
            value: 'unarchive',
            child: ListTile(
              leading: Icon(Icons.unarchive_outlined),
              title: Text('Unarchive'),
            ),
          ),
        if (showDelete)
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Move to trash'),
            ),
          ),
        if (showRestore)
          const PopupMenuItem(
            value: 'restore',
            child: ListTile(
              leading: Icon(Icons.restore),
              title: Text('Restore'),
            ),
          ),
      ],
    );
  }

  Future<void> _handleAction(
      String action, BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(notesProvider.notifier);

    switch (action) {
      case 'favorite':
      case 'unfavorite':
        await notifier.updateNoteStatus(
          note.id,
          isFavorite: !note.isFavorite,
        );
        break;

      case 'archive':
      case 'unarchive':
        await notifier.updateNoteStatus(
          note.id,
          isArchived: !note.isArchived,
        );
        break;

      case 'delete':
        await notifier.updateNoteStatus(
          note.id,
          isDeleted: true,
        );
        break;

      case 'restore':
        await notifier.updateNoteStatus(
          note.id,
          isDeleted: false,
        );
        break;
    }
  }
}
