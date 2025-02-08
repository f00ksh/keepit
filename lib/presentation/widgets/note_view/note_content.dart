import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/providers/note_view_provider.dart';

/// This widget renders the note title and content text fields.
/// It manages its own text editing controllers to avoid recreating them on every rebuild.
class NoteContent extends ConsumerStatefulWidget {
  final Note note;
  final String noteId;

  const NoteContent({
    super.key,
    required this.note,
    required this.noteId,
  });

  @override
  ConsumerState<NoteContent> createState() => _NoteContentState();
}

class _NoteContentState extends ConsumerState<NoteContent> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void didUpdateWidget(covariant NoteContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the controllers if the underlying note state changes.
    if (oldWidget.note.title != widget.note.title) {
      _titleController.text = widget.note.title;
    }
    if (oldWidget.note.content != widget.note.content) {
      _contentController.text = widget.note.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration.collapsed(
              hintText: 'Title',
            ),
            style: Theme.of(context).textTheme.headlineSmall,
            maxLines: 1,
            onChanged: (value) => ref
                .read(noteViewProvider(widget.noteId).notifier)
                .updateTitle(value),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _contentController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Start writing...',
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: null,
              expands: true,
              onChanged: (value) => ref
                  .read(noteViewProvider(widget.noteId).notifier)
                  .updateContent(value),
            ),
          ),
        ],
      ),
    );
  }
}
