import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/presentation/providers/filtered_notes_provider.dart';
import 'package:keepit/presentation/widgets/base_notes_page.dart';
import 'package:keepit/presentation/widgets/note_grid.dart';
import 'package:keepit/presentation/widgets/sliver_empty_state.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteNotes = ref.watch(favoriteNotesProvider);

    return BaseNotesPage(
      title: 'Favorites',
      content: favoriteNotes.when(
        data: (notes) => notes.isEmpty
            ? const SliverEmptyState(
                message: 'No favorite notes',
                icon: Icons.favorite_outline,
              )
            : NoteGrid(notes: notes),
        loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => SliverToBoxAdapter(
          child: Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
