import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/providers/filtered_notes_provider.dart';
import 'package:keepit/presentation/providers/navigation_provider.dart';
import 'package:keepit/presentation/providers/notes_provider.dart';
import 'package:keepit/presentation/widgets/async_note_grid.dart';
import 'package:keepit/presentation/widgets/base_notes_page.dart';
import 'package:keepit/presentation/widgets/add_note_button.dart';
import 'package:keepit/core/services/navigation_service.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenIndex = ref.watch(navigationProvider);

    return BaseNotesPage(
      title: 'HomePage',
      content: AsyncNoteGrid(
        notes: _getNotesForIndex(ref, screenIndex),
        emptyMessage: _getEmptyMessage(screenIndex),
        emptyIcon: _getEmptyIcon(screenIndex),
        useReorderable: screenIndex == 0,
      ),
      currentIndex: screenIndex,
      onDestinationSelected: (index) {
        NavigationService.handleDestinationChange(
          context,
          ref,
          index,
          (index) => ref.read(navigationProvider.notifier).setIndex(index),
        );
      },
      floatingActionButton: screenIndex == 0
          ? const AddNoteButton(heroTag: 'home_add_note_fab')
          : null,
    );
  }

  AsyncValue<List<Note>> _getNotesForIndex(WidgetRef ref, int index) {
    return switch (index) {
      0 => ref.watch(notesProvider),
      1 => ref.watch(favoriteNotesProvider),
      2 => ref.watch(archivedNotesProvider),
      3 => ref.watch(trashedNotesProvider),
      _ => const AsyncValue.data([]),
    };
  }

  String _getEmptyMessage(int index) {
    return switch (index) {
      0 => 'No notes',
      1 => 'No favorite notes',
      2 => 'No archived notes',
      3 => 'No notes in trash',
      _ => '',
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
