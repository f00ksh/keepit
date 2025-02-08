import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/providers/note_view_provider.dart';
import 'package:keepit/presentation/widgets/loading_overlay.dart';
import 'package:keepit/core/utils/error_handler.dart';
import 'package:keepit/presentation/widgets/note_view/note_color_picker_bar.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/presentation/widgets/note_actions.dart';

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
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadNote();
  }

  void _loadNote() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(noteViewProvider(widget.noteId).notifier).loadNote();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _initializeControllers(Note note) {
    if (!_isInitialized) {
      _titleController.text = note.title;
      _contentController.text = note.content;
      _isInitialized = true;
    }
  }

  void _showColorPicker(BuildContext context, Note note) {
    showModalBottomSheet(
      context: context,
      builder: (context) => NoteColorPickerBar(
        note: note,
        noteId: widget.noteId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteState = ref.watch(noteViewProvider(widget.noteId));

    return noteState.when(
      data: (note) {
        _initializeControllers(note);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: getNoteColor(context, note.colorIndex),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              NoteActions(
                note: note,
                showDelete: true,
                showRestore: false,
              ),
            ],
          ),
          body: LoadingOverlay(
            isLoading: noteState.isLoading,
            child: Column(
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
                            contentPadding: EdgeInsets.all(16),
                          ),
                          style: Theme.of(context).textTheme.titleLarge,
                          onChanged: (value) {
                            ref
                                .read(noteViewProvider(widget.noteId).notifier)
                                .updateTitle(value);
                          },
                        ),
                        const Divider(height: 1),
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
                                  .read(
                                      noteViewProvider(widget.noteId).notifier)
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
                    color: getNoteColor(context, note.colorIndex),
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edited ${note.updatedAt.toString().split('.')[0]}',
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
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const LoadingOverlay(
          isLoading: true,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${ErrorHandler.getErrorMessage(error)}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadNote,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
