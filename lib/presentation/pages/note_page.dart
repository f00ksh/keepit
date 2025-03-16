import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/routes/app_router.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/widgets/label_chip.dart';
import 'package:keepit/presentation/widgets/theme_color_picker.dart';
import 'package:keepit/presentation/widgets/note_page/note_todos_section.dart';
import 'package:keepit/presentation/widgets/note_page/note_bottom_bar.dart';

class NotePage extends ConsumerStatefulWidget {
  final String noteId;
  final String heroTag;
  final NoteType? initialNoteType;

  const NotePage({
    super.key,
    required this.noteId,
    required this.heroTag,
    this.initialNoteType,
  });

  @override
  ConsumerState<NotePage> createState() => _NotePageState();
}

class _NotePageState extends ConsumerState<NotePage> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  late String _heroTag;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _heroTag = widget.heroTag;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final note = ref.read(singleNoteProvider(
          widget.noteId, widget.initialNoteType ?? NoteType.text));
      _titleController.text = note.title;
      _contentController.text = note.content;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Directly watch the specific note - will automatically rebuild when note changes
    final note = ref.watch(singleNoteProvider(
        widget.noteId, widget.initialNoteType ?? NoteType.text));

    return PopScope(
      onPopInvokedWithResult: _handlePop,
      child: Hero(
        tag: _heroTag,
        child: Builder(
          builder: (context) {
            _updateHeroTag();
            return Scaffold(
              backgroundColor: getNoteColor(context, note.colorIndex),
              appBar: _buildAppBar(note),
              body: _buildBody(note),
              bottomNavigationBar: NoteBottomBar(
                note: note,
                onColorPick: () => _showColorPicker(note),
                onMoreOptions: () => _showMoreOptions(note),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(Note note) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleField(),
                if (widget.initialNoteType == NoteType.text ||
                    (note.content.isNotEmpty && note.todos.isEmpty))
                  _buildContentField(),
                if (widget.initialNoteType == NoteType.todo ||
                    note.todos.isNotEmpty)
                  NoteTodosSection(
                    note: note,
                    onChanged: () => _hasChanges = true,
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: NoteLabelsSection(
            note: note,
            isEditable: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      decoration: const InputDecoration(
        hintText: 'Title',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      style: Theme.of(context).textTheme.titleLarge,
      onChanged: (_) => _hasChanges = true,
    );
  }

  Widget _buildContentField() {
    return TextField(
      controller: _contentController,
      decoration: const InputDecoration(
        hintText: 'Start writing...',
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      style: Theme.of(context).textTheme.bodyLarge,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (_) => _hasChanges = true,
    );
  }

  AppBar _buildAppBar(Note note) {
    return AppBar(
      backgroundColor: getNoteColor(context, note.colorIndex),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: Icon(
                  note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              onPressed: () => _updateNote(note, isPinned: !note.isPinned),
            ),
            IconButton(
              icon: Icon(
                  note.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: () => _updateNote(note, isFavorite: !note.isFavorite),
            ),
            if (!note.isDeleted)
              IconButton(
                icon: const Icon(Icons.notification_add_outlined),
                onPressed: () {
                  // TODO: Implement reminder feature
                },
              ),
            if (note.isDeleted) ...[
              IconButton(
                icon: const Icon(Icons.delete_forever),
                onPressed: () {
                  // TODO: Implement permanent delete
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: () {
                  _updateNote(note, isDeleted: false);
                  Navigator.pop(context);
                },
              ),
            ],
            if (note.isArchived && !note.isDeleted)
              IconButton(
                icon: const Icon(Icons.unarchive),
                onPressed: () {
                  _updateNote(note, isArchived: false);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ],
    );
  }

  void _updateNote(
    Note note, {
    bool? isPinned,
    bool? isFavorite,
    bool? isArchived,
    bool? isDeleted,
  }) {
    ref.read(notesProvider.notifier).updateNoteStatus(
          note.id,
          isPinned: isPinned,
          isFavorite: isFavorite,
          isArchived: isArchived,
          isDeleted: isDeleted,
        );
  }

  void _updateHeroTag() {
    if (_heroTag == widget.heroTag) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _heroTag = 'note_${widget.noteId}';
        });
      });
    }
  }

  Future<void> _handlePop(bool didPop, dynamic result) async {
    if (!mounted) return;

    final notesNotifier = ref.read(notesProvider.notifier);
    final note = notesNotifier.getNote(widget.noteId);
    if (note == null) return;

    // Check if note is empty including the case of single empty todo
    final isEmpty = _isNoteEmpty(note);

    if (_hasChanges) {
      final updatedNote = note.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        todos: note.todos,
        updatedAt: DateTime.now(),
        noteType: widget.initialNoteType,
      );

      await Future.delayed(const Duration(milliseconds: 150));
      notesNotifier.updateNote(widget.noteId, updatedNote);
      _hasChanges = false;
    }

    if (isEmpty) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      await notesNotifier.cleanupEmptyNote(widget.noteId);
    }
  }

  // Add this helper method to check if note is empty
  bool _isNoteEmpty(Note note) {
    final hasNoTitle = _titleController.text.trim().isEmpty;
    final hasNoContent = _contentController.text.trim().isEmpty;

    // For todo notes, check if there's only one empty todo
    if (note.noteType == NoteType.todo) {
      return hasNoTitle &&
          hasNoContent &&
          note.todos.length == 1 &&
          note.todos.first.content.trim().isEmpty;
    }

    // For text notes
    return hasNoTitle && hasNoContent && note.todos.isEmpty;
  }

  void _showMoreOptions(Note note) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          ref.watch(notesProvider);
          final currentNote =
              ref.read(notesProvider.notifier).getNote(widget.noteId);

          if (currentNote == null) {
            Navigator.pop(context);
            return const SizedBox.shrink();
          }

          final colorScheme = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final handleColor = isDark
              ? colorScheme.onSurface.withOpacity(0.4)
              : colorScheme.onSurfaceVariant.withOpacity(0.4);
          final noteColor = getNoteColor(context, currentNote.colorIndex);

          return Container(
            decoration: BoxDecoration(
              color: noteColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: handleColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                if (!currentNote.isDeleted && !currentNote.isArchived) ...[
                  ListTile(
                    leading: const Icon(Icons.archive_outlined),
                    title: const Text('Archive'),
                    onTap: () {
                      _updateNote(currentNote, isArchived: true);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Delete'),
                    onTap: () async {
                      ScaffoldMessenger.of(context).clearSnackBars();

                      final messenger = ScaffoldMessenger.of(context);
                      final notesNotifier = ref.read(notesProvider.notifier);

                      Navigator.pop(context);
                      Navigator.pop(context);

                      await Future.delayed(const Duration(milliseconds: 300));

                      await notesNotifier.updateNoteStatus(
                        currentNote.id,
                        isDeleted: true,
                      );

                      messenger.showSnackBar(
                        SnackBar(
                          content: const Text('Note moved to trash'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () async {
                              await notesNotifier.updateNoteStatus(
                                currentNote.id,
                                isDeleted: false,
                              );
                              messenger.clearSnackBars();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: const Text('Labels'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.labels,
                      arguments: {
                        'noteId': widget.noteId,
                        'selectedLabelIds': currentNote.labelIds,
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.send_outlined),
                  title: const Text('Send'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showColorPicker(Note note) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          ref.watch(notesProvider);
          final currentNote =
              ref.read(notesProvider.notifier).getNote(widget.noteId);

          if (currentNote == null) {
            Navigator.pop(context);
            return const SizedBox.shrink();
          }

          final noteColor = getNoteColor(context, currentNote.colorIndex);
          final colorScheme = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final handleColor = isDark
              ? colorScheme.onSurface.withOpacity(0.4)
              : colorScheme.onSurfaceVariant.withOpacity(0.4);

          return Container(
            decoration: BoxDecoration(
              color: noteColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: handleColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                ColorPickerContent(
                  noteId: widget.noteId,
                  initialColorIndex: currentNote.colorIndex,
                ),
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
