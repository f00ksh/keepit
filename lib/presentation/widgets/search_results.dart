import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/presentation/providers/search_provider.dart';
import 'package:keepit/presentation/widgets/note_card.dart';

class SearchResults extends ConsumerWidget {
  const SearchResults({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(filteredNotesProvider);
    final query = ref.watch(searchQueryProvider);

    return query.isEmpty
        ? const Center(child: Text('Start typing to search notes'))
        : results.when(
            data: (notes) => notes.isEmpty
                ? Center(child: Text('No results for "$query"'))
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: notes.length,
                    itemBuilder: (context, index) => NoteCard(
                      note: notes[index],
                    ),
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) =>
                Center(child: Text('Error: ${error.toString()}')),
          );
  }
}
