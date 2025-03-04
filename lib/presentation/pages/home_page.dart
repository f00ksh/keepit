import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/data/providers/labels_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final screenIndex = ref.watch(navigationProvider);
    final selectedLabel = ref.watch(selectedLabelProvider);
    debugPrint(
        'HomePage build - screenIndex: $screenIndex, selectedLabel: $selectedLabel');

    final notes = _getNotesForIndex(ref, screenIndex);
    debugPrint('HomePage build - notes count: ${notes.length}');

    return Scaffold(
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
      body: GestureDetector(
        onTap: () => _searchFocusNode.unfocus(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            AppSearchBar(
              isSearchActive: false,
              focusNode: _searchFocusNode,
            ),
            notes.isEmpty
                ? SliverEmptyState(
                    message: _getEmptyMessage(screenIndex),
                    icon: _getEmptyIcon(screenIndex),
                  )
                : _buildGridForIndex(screenIndex, notes),
          ],
        ),
      ),
      floatingActionButton: screenIndex == 0
          ? FloatingActionButton.extended(
              heroTag: 'add_note_fab',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.addNote),
              label: const Text('Add Note'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildGridForIndex(int index, List<Note> notes) {
    final selectedLabel = ref.watch(selectedLabelProvider);
    debugPrint(
        'Building grid for index: $index, selectedLabel: $selectedLabel');
    debugPrint('Notes count: ${notes.length}');

    return switch (index) {
      0 => ReorderableGrid(),
      _ => NoteGrid(notes: notes),
    };
  }

  List<Note> _getNotesForIndex(WidgetRef ref, int index) {
    final selectedLabel = ref.watch(selectedLabelProvider);
    debugPrint(
        'Getting notes for index: $index, selectedLabel: $selectedLabel');

    if (selectedLabel != null) {
      final labelNotes = ref.watch(notesByLabelIdProvider(selectedLabel));
      debugPrint('Label notes count: ${labelNotes.length}');
      return labelNotes;
    }

    final notes = switch (index) {
      0 => ref.watch(mainNotesProvider),
      1 => ref.watch(favoriteNotesProvider),
      2 => ref.watch(archivedNotesProvider),
      3 => ref.watch(trashedNotesProvider),
      _ => const <Note>[],
    };
    debugPrint('Regular notes count for index $index: ${notes.length}');
    return notes;
  }

  String _getEmptyMessage(int index) {
    final selectedLabel = ref.watch(selectedLabelProvider);
    debugPrint(
        'Getting empty message for index: $index, selectedLabel: $selectedLabel');

    if (selectedLabel != null) {
      final label = ref.watch(labelByIdProvider(selectedLabel));
      debugPrint('Label name: ${label?.name}');
      return 'No notes with label "${label?.name ?? ''}"';
    }

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
      0 => Icons.note_outlined,
      1 => Icons.favorite_outline,
      2 => Icons.archive_outlined,
      3 => Icons.delete_outline,
      _ => Icons.note_outlined,
    };
  }
}
