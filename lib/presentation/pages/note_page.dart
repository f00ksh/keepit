import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/routes/app_router.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/providers/note_view_provider.dart';
import 'package:keepit/presentation/widgets/label_chip.dart';
import 'package:keepit/presentation/widgets/note_hero.dart';
import 'package:keepit/presentation/widgets/theme_color_picker.dart';
import 'package:uuid/uuid.dart';

class NotePage extends ConsumerStatefulWidget {
  final String? noteId; // null means new note
  final String heroTag; // Add this parameter

  const NotePage({
    super.key,
    this.noteId,
    required this.heroTag, // Required for both new and existing notes
  });

  @override
  ConsumerState<NotePage> createState() => _NotePageState();
}

class _NotePageState extends ConsumerState<NotePage> {
  late String _noteId;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _heroTag; // Add hero tag state variable that can be updated

  @override
  void initState() {
    super.initState();
    _noteId = widget.noteId ?? const Uuid().v4();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _heroTag = widget.heroTag; // Initialize with the provided hero tag

    // Initialize controllers after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final note = ref.read(noteViewProvider(_noteId));
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
    final note = ref.watch(noteViewProvider(_noteId));

    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        // Save note if it has content
        if (note.title.isNotEmpty || note.content.isNotEmpty) {
          // If this is a new note (using the temporary hero tag), update the hero tag to match the note's ID
          if (widget.noteId == null && _heroTag == widget.heroTag) {
            setState(() {
              _heroTag = 'note_$_noteId'; // Use the same format as note cards
            });
          }
          await ref.read(noteViewProvider(_noteId).notifier).saveNote();
        }
      },
      child: NoteHeroWidget(
        tag: _heroTag, // Use the updatable hero tag
        child: Builder(
          builder: (context) {
            // Save the note after the hero animation completes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (note.title.isNotEmpty || note.content.isNotEmpty) {
                ref.read(noteViewProvider(_noteId).notifier).saveNote();

                // If this is a new note, update the hero tag after saving
                if (widget.noteId == null && _heroTag == widget.heroTag) {
                  setState(() {
                    _heroTag =
                        'note_$_noteId'; // Update to match note card format
                  });
                }
              }
            });

            return Scaffold(
              backgroundColor: getNoteColor(context, note.colorIndex),
              appBar: _buildAppBar(note),
              body: _buildContent(note),
              bottomNavigationBar: _buildEditInfo(note),
              bottomSheet: null,
            );
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar(Note note) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
          onPressed: () => _updateNote(note, isPinned: !note.isPinned),
        ),
        IconButton(
          icon: Icon(note.isFavorite ? Icons.favorite : Icons.favorite_border),
          onPressed: () => _updateNote(note, isFavorite: !note.isFavorite),
        ),
        // Show reminder button for non-deleted notes
        if (!note.isDeleted) ...[
          IconButton(
            icon: const Icon(Icons.notification_add_outlined),
            onPressed: () {
              // TODO: Implement reminder feature
            },
          ),
        ],
        // Show delete button only in trash
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
        // Show unarchive button only in archive
        if (note.isArchived && !note.isDeleted) ...[
          IconButton(
            icon: const Icon(Icons.unarchive),
            onPressed: () {
              _updateNote(note, isArchived: false);
              Navigator.pop(context);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildContent(Note note) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                  onChanged: (value) {
                    ref
                        .read(noteViewProvider(_noteId).notifier)
                        .updateTitle(value);
                  },
                ),
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Start writing...',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    ref
                        .read(noteViewProvider(_noteId).notifier)
                        .updateContent(value);
                  },
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

  Widget _buildEditInfo(Note note) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.color_lens_outlined),
            onPressed: () => _showColorPicker(note),
          ),
          Text(
            'Edited ${_formatEditedDate(note.updatedAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(note),
          ),
        ],
      ),
    );
  }

  void _updateNote(
    Note note, {
    bool? isPinned,
    bool? isFavorite,
    bool? isArchived,
    bool? isDeleted,
  }) {
    final notifier = ref.read(noteViewProvider(_noteId).notifier);
    if (isPinned != null) notifier.togglePin();
    if (isFavorite != null) notifier.toggleFavorite();
    if (isArchived != null) notifier.toggleArchive();
    if (isDeleted != null) notifier.moveToTrash();
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

  void _showMoreOptions(Note note) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final colorScheme = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final handleColor = isDark
              ? colorScheme.onSurface.withOpacity(0.4)
              : colorScheme.onSurfaceVariant.withOpacity(0.4);
          final noteColor = getNoteColor(context, note.colorIndex);

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
                // Show archive/delete only for normal notes
                if (!note.isDeleted && !note.isArchived) ...[
                  ListTile(
                    leading: const Icon(Icons.archive_outlined),
                    title: const Text('Archive'),
                    onTap: () {
                      _updateNote(note, isArchived: true);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Delete'),
                    onTap: () {
                      ref
                          .read(noteViewProvider(_noteId).notifier)
                          .moveToTrash();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                ],
                // Common options for all notes
                ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: const Text('Labels'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.labels,
                      arguments: {
                        'noteId': _noteId,
                        'selectedLabelIds':
                            ref.read(noteViewProvider(_noteId)).labelIds,
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.send_outlined),
                  title: const Text('Send'),
                  onTap: () {
                    // TODO: Implement send feature
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
          final currentNote = ref.watch(noteViewProvider(_noteId));
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
                  noteId: _noteId,
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
