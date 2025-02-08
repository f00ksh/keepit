import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/providers/note_view_provider.dart';
import 'package:keepit/presentation/widgets/note_view/note_color_picker_bar.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/presentation/widgets/note_actions.dart';
import 'package:keepit/presentation/widgets/theme_color_picker.dart';

class NotePage extends ConsumerStatefulWidget {
  final Note note;  // Changed from noteId to Note

  const NotePage({
    super.key,
    required this.note,
  });

  @override
  ConsumerState<NotePage> createState() => _NotePageState();
}

class _NotePageState extends ConsumerState<NotePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  late Note _note;  // Local note state

  @override
  void initState() {
    super.initState();
    _note = widget.note;  // Initialize with passed note
    _titleController.text = _note.title;
    _contentController.text = _note.content;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showColorPicker(BuildContext context, Note note) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ThemeColorPicker(
        selectedIndex: note.colorIndex,
        onColorSelected: (index) {
          setState(() {
            _note = _note.copyWith(
              colorIndex: index,
              updatedAt: DateTime.now(),
            );
          });
          // Update in storage
          ref.read(notesProvider.notifier).updateNote(_note.id, _note);
          Navigator.pop(context); // Close the bottom sheet
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: getNoteColor(context, _note.colorIndex),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          NoteActions(note: _note, showDelete: true, showRestore: false),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: getNoteColor(context, _note.colorIndex),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    style: Theme.of(context).textTheme.titleLarge,
                    onChanged: (value) {
                      setState(() {
                        _note = _note.copyWith(
                          title: value,
                          updatedAt: DateTime.now(),
                        );
                      });
                      // Update in storage
                      ref.read(notesProvider.notifier).updateNote(widget.note.id, _note);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        hintText: 'Note',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) {
                        ref
                            .read(noteViewProvider(widget.note.id).notifier)
                            .updateContent(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: getNoteColor(context, _note.colorIndex),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edited ${_note.updatedAt.toString().split('.')[0]}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                IconButton(
                  icon: const Icon(Icons.color_lens_outlined),
                  onPressed: () => _showColorPicker(context, _note),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
