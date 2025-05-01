import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/routes/app_router.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/domain/models/todo_item.dart';
import 'package:keepit/presentation/providers/note_action_provider.dart';
import 'package:keepit/presentation/widgets/label_chip.dart';
import 'package:keepit/presentation/widgets/theme_color_picker.dart';
import 'package:keepit/presentation/widgets/note_page/note_todos_section.dart';
import 'package:keepit/presentation/widgets/note_page/note_bottom_bar.dart';
import 'package:keepit/presentation/widgets/wallpaper_picker.dart';
import 'package:keepit/presentation/widgets/color_indicator.dart';
import 'package:keepit/core/theme/text_styles.dart';

class NotePage extends ConsumerStatefulWidget {
  final String noteId;
  final String heroTag;

  const NotePage({
    super.key,
    required this.noteId,
    required this.heroTag,
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
      // Initialize text controllers
      final note = ref.read(singleNoteProvider(widget.noteId));
      // Check if mounted before accessing controllers
      if (mounted) {
        _titleController.text = note.title;
        _contentController.text = note.content;
      }

      // Update hero tag only once after the first frame if needed
      if (mounted && _heroTag == widget.heroTag) {
        setState(() {
          _heroTag = 'note_${widget.noteId}';
        });
      }
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
    debugPrint(
        'NotePage build triggered at ${DateTime.now()} for noteId: ${widget.noteId} ');

    final note = ref.watch(singleNoteProvider(widget.noteId));
    debugPrint(note.noteType.toString());

    // Get wallpaper asset path if set
    final wallpaperPath =
        AppTheme.getNoteWallpaperAssetPath(context, note.wallpaperIndex);
    // Create the image provider directly in build if path exists
    final wallpaperImage = wallpaperPath != null
        ? ResizeImage(
            AssetImage(wallpaperPath),
            width: 600,
          )
        : null;
    // Precache the image if it exists
    if (wallpaperImage != null) {
      precacheImage(wallpaperImage, context);
    }
    return PopScope(
      onPopInvokedWithResult: _handlePop,
      child: Hero(
        tag: _heroTag, // Use the state variable _heroTag directly
        child: Builder(
          builder: (context) {
            // _updateHeroTag(); // REMOVE this call from here
            return Scaffold(
              backgroundColor: Colors.transparent, // Make scaffold transparent
              body: Container(
                decoration: BoxDecoration(
                  color: getNoteColor(context, note.colorIndex),
                  borderRadius:
                      BorderRadius.circular(12), // Add rounded corners
                  image: wallpaperImage != null
                      ? DecorationImage(
                          image: wallpaperImage,
                          fit: BoxFit.fill,
                        )
                      : null,
                ),
                child: Column(
                  children: [
                    // AppBar equivalent
                    _buildCustomAppBar(note),
                    // Main content (takes all remaining space)
                    Expanded(
                      child: _buildBodyContent(note),
                    ),
                    // Bottom bar
                    NoteBottomBar(
                      note: note,
                      onColorPick: () => _showCustomizationOptions(note),
                      onMoreOptions: () => _showMoreOptions(note),
                      onNoteTypeChange: () => _showNoteTypeOptions(note),
                      isTransparent: note.wallpaperIndex != 0,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBodyContent(Note note) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleField(),
          if (note.noteType == NoteType.text ||
              (note.content.isNotEmpty && note.todos.isEmpty))
            _buildContentField(),
          if (note.noteType == NoteType.todo || note.todos.isNotEmpty)
            NoteTodosSection(
              note: note,
              onChanged: () {
                _hasChanges = true;
              },
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14),
            child: Row(
              children: [
                NoteLabelsSection(
                  note: note,
                ),
                // Show color indicator when note has wallpaper and color
                if (note.wallpaperIndex != 0 &&
                    note.colorIndex != AppTheme.noColorIndex)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ColorIndicator(colorIndex: note.colorIndex),
                  ),
              ],
            ),
          ),
        ],
      ),
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
      style: AppTextStyles.noteTitleStyle(context),
      onChanged: (_) {
        _hasChanges = true;
      },
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
      style: AppTextStyles.noteContentStyle(context),
      maxLines: null,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      onChanged: (_) {
        _hasChanges = true;
      },
    );
  }

  // Replace _buildCustomAppBar with a custom widget that works with the Stack
  Widget _buildCustomAppBar(Note note) {
    return Container(
      height: kToolbarHeight + MediaQuery.of(context).padding.top,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  icon: Icon(
                      note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                  onPressed: () {
                    // Store action in state provider and navigate back
                    ref
                        .read(noteActionNotifierProvider.notifier)
                        .updateNoteAction(
                          NoteAction(
                            noteId: note.id,
                            isPinned: !note.isPinned,
                          ),
                        );

                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: Icon(
                      note.isFavorite ? Icons.favorite : Icons.favorite_border),
                  onPressed: () {
                    // Store action in state provider and navigate back
                    ref
                        .read(noteActionNotifierProvider.notifier)
                        .updateNoteAction(
                          NoteAction(
                            noteId: note.id,
                            isFavorite: !note.isFavorite,
                          ),
                        );

                    Navigator.pop(context);
                  },
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
                      // Store action in state provider and navigate back
                      ref
                          .read(noteActionNotifierProvider.notifier)
                          .updateNoteAction(
                            NoteAction(
                              noteId: note.id,
                              isDeleted: false,
                            ),
                          );

                      Navigator.pop(context);
                    },
                  ),
                ],
                if (note.isArchived && !note.isDeleted)
                  IconButton(
                    icon: const Icon(Icons.unarchive),
                    onPressed: () {
                      // Store action in state provider and navigate back
                      ref
                          .read(noteActionNotifierProvider.notifier)
                          .updateNoteAction(
                            NoteAction(
                              noteId: note.id,
                              isArchived: false,
                            ),
                          );

                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Remove this method as we'll use _handlePop instead
  // void _updateNote(...) { ... }

  Future<void> _handlePop(bool didPop, dynamic result) async {
    if (!mounted) return;

    final notesNotifier = ref.read(notesProvider.notifier);
    final note = notesNotifier.getNote(widget.noteId);
    if (note == null) return;

    // Check if there's a pending note action
    final noteAction = ref.read(noteActionNotifierProvider);
    if (noteAction != null && noteAction.noteId == widget.noteId) {
      // Clear the action to prevent it from being processed again
      ref.read(noteActionNotifierProvider.notifier).updateNoteAction(null);

      // Process the action after a short delay to allow hero animation to complete
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;

      await notesNotifier.updateNoteStatus(
        noteAction.noteId,
        isPinned: noteAction.isPinned,
        isFavorite: noteAction.isFavorite,
        isArchived: noteAction.isArchived,
        isDeleted: noteAction.isDeleted,
      );

      // Return early since we've processed an action
      return;
    }

    // Check if note is empty including the case of single empty todo
    final isEmpty = _isNoteEmpty(note);
    if (_hasChanges) {
      final updatedNote = note.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        todos: note.todos,
        updatedAt: DateTime.now(),
        noteType: note.noteType,
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

          // Get colors based on wallpaper or note color
          final backgroundColor =
              currentNote.wallpaperIndex != AppTheme.noWallpaperIndex &&
                      currentNote.wallpaperIndex != 0
                  ? getNoteWallpaperColor(context, currentNote.wallpaperIndex)
                  : getNoteColor(context, currentNote.colorIndex);

          final colorScheme = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final handleColor = isDark
              ? colorScheme.onSurface.withValues(alpha: 0.4)
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.4);

          return Container(
            decoration: BoxDecoration(
              color: backgroundColor,
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
                      // Store action in state provider and navigate back
                      ref
                          .read(noteActionNotifierProvider.notifier)
                          .updateNoteAction(NoteAction(
                            noteId: currentNote.id,
                            isArchived: true,
                          ));

                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Delete'),
                    onTap: () async {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      final messenger = ScaffoldMessenger.of(context);

                      // Store action in state provider and navigate back
                      ref
                          .read(noteActionNotifierProvider.notifier)
                          .updateNoteAction(
                            NoteAction(
                              noteId: currentNote.id,
                              isDeleted: true,
                            ),
                          );

                      Navigator.pop(context);
                      Navigator.pop(context);

                      // Show snackbar after a delay to allow hero animation to complete
                      await Future.delayed(const Duration(milliseconds: 300));

                      messenger.showSnackBar(
                        SnackBar(
                          content: const Text('Note moved to trash'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () async {
                              await ref
                                  .read(notesProvider.notifier)
                                  .updateNoteStatus(
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

  // Show a modal bottom sheet with note type options
  void _showNoteTypeOptions(Note note) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final currentNote = ref.read(singleNoteProvider(widget.noteId));

          // Get colors based on wallpaper or note color
          final backgroundColor =
              currentNote.wallpaperIndex != AppTheme.noWallpaperIndex &&
                      currentNote.wallpaperIndex != 0
                  ? getNoteWallpaperColor(context, currentNote.wallpaperIndex)
                  : getNoteColor(context, currentNote.colorIndex);

          final colorScheme = Theme.of(context).colorScheme;
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final handleColor = isDark
              ? colorScheme.onSurface.withValues(alpha: 0.4)
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.4);

          return Container(
            decoration: BoxDecoration(
              color: backgroundColor,
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
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('Text note'),
                  selected: currentNote.noteType == NoteType.text,
                  onTap: () {
                    if (currentNote.noteType != NoteType.text) {
                      // Convert to text note
                      final updatedNote = currentNote.copyWith(
                        noteType: NoteType.text,
                        updatedAt: DateTime.now(),
                      );
                      ref.read(notesProvider.notifier).updateNote(
                            currentNote.id,
                            updatedNote,
                          );
                      _hasChanges = true;
                    }
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.check_box_outlined),
                  title: const Text('Todo list'),
                  selected: currentNote.noteType == NoteType.todo,
                  onTap: () {
                    if (currentNote.noteType != NoteType.todo) {
                      // Convert to todo note
                      final updatedNote = currentNote.copyWith(
                        todos: [
                          TodoItem(
                            content: '',
                            index: 0,
                          )
                        ],
                      );
                      ref.read(notesProvider.notifier).updateNote(
                            currentNote.id,
                            updatedNote,
                          );
                      _hasChanges = true;
                      debugPrint('Note type: ${updatedNote.noteType}');
                    }
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

  // Modify this method to show both colors and wallpapers in a single column without divider
  void _showCustomizationOptions(Note note) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          ref.watch(notesProvider);
          final currentNote = ref.read(singleNoteProvider(widget.noteId));

          // Get colors based on wallpaper or note color
          final backgroundColor =
              currentNote.wallpaperIndex != AppTheme.noWallpaperIndex &&
                      currentNote.wallpaperIndex != 0
                  ? getNoteWallpaperColor(context, currentNote.wallpaperIndex)
                  : getNoteColor(context, currentNote.colorIndex);

          final colorScheme = Theme.of(context).colorScheme;

          return Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                // Center(
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(vertical: 8),
                //     child: Container(
                //       width: 32,
                //       height: 4,
                //       decoration: BoxDecoration(
                //         color: handleColor,
                //         borderRadius: BorderRadius.circular(2),
                //       ),
                //     ),
                //   ),
                // ),

                // Colors section
                Padding(
                  padding: const EdgeInsets.only(
                    left: 14.0,
                    right: 14.0,
                    top: 14.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Colors',
                      style: AppTextStyles.sectionTitleStyle(context),
                    ),
                  ),
                ),
                SizedBox(
                  height: 100, // Fixed height for color picker
                  child: ColorPickerContent(
                    // Note: Changes inside this widget also trigger provider updates
                    noteId: widget.noteId,
                    initialColorIndex: currentNote.colorIndex,
                  ),
                ),

                // No divider now

                // Wallpapers section
                Padding(
                  padding: const EdgeInsets.only(
                    left: 14.0,
                    right: 14.0,
                    top: 14.0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Wallpapers',
                      style: AppTextStyles.sectionTitleStyle(context),
                    ),
                  ),
                ),
                SizedBox(
                  height: 100, // Reduced height for wallpaper picker
                  child: WallpaperPickerContent(
                    // Note: Changes inside this widget also trigger provider updates
                    noteId: widget.noteId,
                    initialWallpaperIndex: currentNote.wallpaperIndex,
                  ),
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
