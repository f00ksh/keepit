import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/providers/notes_provider.dart';

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
        await notifier.toggleFavorite(note.id, !note.isFavorite);
        break;
      case 'unfavorite':
        await notifier.toggleFavorite(note.id, !note.isFavorite);

        break;
      case 'archive':
        await notifier.toggleArchive(note.id, !note.isArchived);
        break;
      case 'unarchive':
        await notifier.toggleArchive(note.id, !note.isArchived);
        break;
      case 'delete':
        await notifier.moveToTrash(note.id);

        break;
      case 'restore':
        await notifier.restoreFromTrash(note.id);
        break;
    }
  }
}
