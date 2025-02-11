import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/providers/note_view_provider.dart';
import 'package:keepit/presentation/widgets/note_hero.dart';
import 'package:keepit/presentation/widgets/note_view/note_color_picker_bar.dart';
import 'package:keepit/core/theme/app_theme.dart';

class NotePage extends ConsumerStatefulWidget {
  final String noteId;

  const NotePage({
    super.key,
    required this.noteId,
  });

  @override
  ConsumerState<NotePage> createState() => _NotePageState();
}

class _NotePageState extends ConsumerState<NotePage> {
  Timer? _saveTimer;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _initializeControllers(Note note) {
    if (!_isInitialized) {
      _titleController = TextEditingController(text: note.title);
      _contentController = TextEditingController(text: note.content);
      _isInitialized = true;
    }
  }

  void _debounceUpdate(Function() action) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), action);
  }

  void _showColorPicker(BuildContext context, Note note) {
    showModalBottomSheet(
      backgroundColor: getNoteColor(context, note.colorIndex),
      enableDrag: true,
      showDragHandle: true,
      context: context,
      builder: (context) => NoteColorPickerBar(
        noteId: widget.noteId,
      ),
    );
  }

  String _formatEditedDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      // Show time if less than 24 hours
      return 'Edited ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      // Show date without time if more than 24 hours
      final month = date.month.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      return 'Edited $day$month';
    }
  }

  @override
  Widget build(BuildContext context) {
    final note = ref.watch(noteViewProvider(widget.noteId));
    _initializeControllers(note);

    return Material(
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) {
            await ref
                .read(noteViewProvider(widget.noteId).notifier)
                .saveChanges();
          }
        },
        child: NoteHeroWidget(
          tag: 'note_${widget.noteId}',
          child: Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0,
              backgroundColor: getNoteColor(context, note.colorIndex),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                // Pin/Unpin
                IconButton(
                  icon: Icon(
                    note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  ),
                  onPressed: () => ref
                      .read(noteViewProvider(widget.noteId).notifier)
                      .togglePin(),
                ),
                // Favorite/Unfavorite
                IconButton(
                  icon: Icon(
                    note.isFavorite ? Icons.favorite : Icons.favorite_border,
                  ),
                  onPressed: () => ref
                      .read(noteViewProvider(widget.noteId).notifier)
                      .toggleFavorite(),
                ),
                // Archive/Unarchive
                IconButton(
                  icon: Icon(
                    note.isArchived
                        ? Icons.unarchive_outlined
                        : Icons.archive_outlined,
                  ),
                  onPressed: () => ref
                      .read(noteViewProvider(widget.noteId).notifier)
                      .toggleArchive(),
                ),

                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    ref
                        .read(noteViewProvider(widget.noteId).notifier)
                        .moveToTrash();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    color: getNoteColor(context, note.colorIndex),
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            hintText: 'Title',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                          ),
                          style: Theme.of(context).textTheme.titleLarge,
                          onChanged: (value) {
                            _debounceUpdate(() {
                              ref
                                  .read(
                                      noteViewProvider(widget.noteId).notifier)
                                  .updateTitle(value);
                            });
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
                              _debounceUpdate(() {
                                ref
                                    .read(noteViewProvider(widget.noteId)
                                        .notifier)
                                    .updateContent(value);
                              });
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
                    color: getNoteColor(context, note.colorIndex),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.upload_file),
                        onPressed: () => _showColorPicker(context, note),
                      ),
                      Text(
                        _formatEditedDate(note.updatedAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      IconButton(
                        icon: const Icon(Icons.color_lens_outlined),
                        onPressed: () => _showColorPicker(context, note),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
