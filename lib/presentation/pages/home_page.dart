import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/data/providers/labels_provider.dart';
import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/providers/filtered_notes_provider.dart';
import 'package:keepit/presentation/providers/navigation_provider.dart';
import 'package:keepit/presentation/providers/selected_label_provider.dart';
import 'package:keepit/presentation/widgets/app_drawer.dart';

import 'package:keepit/presentation/widgets/note_grid.dart';
import 'package:keepit/presentation/widgets/reorderable_grid.dart';
import 'package:keepit/presentation/widgets/search_bar.dart';
import 'package:keepit/presentation/widgets/sliver_empty_state.dart';
import 'package:keepit/core/services/navigation_service.dart';
import 'package:keepit/core/routes/app_router.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

class HomePage extends ConsumerStatefulWidget {
  final int initialIndex;

  const HomePage({
    super.key,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final FocusNode _searchFocusNode = FocusNode();
  late bool _showNavigationDrawer;
  late final ScrollController _scrollController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _showNavigationDrawer = MediaQuery.of(context).size.width >= 640;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildGridForIndex(int index, List<Note> notes) {
    final selectedLabel = ref.watch(selectedLabelProvider);
    // Always use NoteGrid for label filtered view
    if (selectedLabel != null) {
      return NoteGrid(notes: notes);
    }

    // For main views
    return switch (index) {
      0 => ReorderableGrid(),
      _ => NoteGrid(notes: notes),
    };
  }

  List<Note> _getNotesForIndex(WidgetRef ref, int index) {
    final selectedLabel = ref.watch(selectedLabelProvider);
    if (selectedLabel != null) {
      // Watch the notes for the selected label
      final labelNotes = ref.watch(notesByLabelIdProvider(selectedLabel));
      return labelNotes;
    }

    // Handle regular note lists with explicit type casting
    final List<Note> notes = switch (index) {
      0 => ref.watch(mainNotesProvider),
      1 => ref.watch(favoriteNotesProvider),
      2 => ref.watch(archivedNotesProvider),
      3 => ref.watch(trashedNotesProvider),
      _ => ref.watch(mainNotesProvider),
    };

    return notes;
  }

  @override
  Widget build(BuildContext context) {
    final screenIndex = ref.watch(navigationProvider);
    final selectedLabel = ref.watch(selectedLabelProvider);
    final notes = _getNotesForIndex(ref, screenIndex);

    final body = AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          AppSearchBar(),
          notes.isEmpty
              ? SliverEmptyState(
                  message: _getEmptyMessage(screenIndex),
                  icon: _getEmptyIcon(screenIndex),
                )
              : _buildGridForIndex(screenIndex, notes),
        ],
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
        ),
      ),
      drawer: !_showNavigationDrawer
          ? Builder(
              builder: (BuildContext drawerContext) => AppDrawer(
                currentIndex: screenIndex,
                onDestinationSelected: (index) {
                  if (!mounted) return;
                  NavigationService.handleDestinationChange(
                    drawerContext,
                    ref,
                    index,
                    onIndexChanged: (index) =>
                        ref.read(navigationProvider.notifier).setIndex(index),
                  );
                },
              ),
            )
          : null,
      body: _showNavigationDrawer
          ? Row(
              children: [
                AppDrawer(
                  currentIndex: screenIndex,
                  onDestinationSelected: (index) {
                    if (!mounted) return;
                    NavigationService.handleDestinationChange(
                      context,
                      ref,
                      index,
                      onIndexChanged: (index) =>
                          ref.read(navigationProvider.notifier).setIndex(index),
                    );
                  },
                ),
                Expanded(child: body),
              ],
            )
          : body,
      floatingActionButton: screenIndex == 0 && selectedLabel == null
          ? FloatingActionButton(
              heroTag: 'text_note_fab',
              onPressed: () {
                _createNote(
                  context,
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  String _getEmptyMessage(int index) {
    return switch (index) {
      0 => 'No notes',
      1 => 'No favorite notes',
      2 => 'No archived notes',
      3 => 'No notes in trash',
      _ => 'No notes with this label',
    };
  }

  IconData _getEmptyIcon(int index) {
    return switch (index) {
      0 => Icons.lightbulb_outline,
      1 => Icons.favorite_outline,
      2 => Icons.archive_outlined,
      3 => Icons.delete_outline,
      _ => Icons.note_outlined,
    };
  }

  Future<void> _createNote(
    BuildContext context,
  ) async {
    final noteId = const Uuid().v4();
    final newNote = Note(
      id: noteId,
      title: '',
      content: '',
      colorIndex: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (!mounted) return;

    // Add the note first
    ref.read(notesProvider.notifier).addNote(newNote);

    // Navigate and wait for the hero animation
    Navigator.pushNamed(
      context,
      AppRoutes.addNote,
      arguments: {
        'noteId': noteId,
        'heroTag': 'text_note_fab',
      },
    );
  }
}
