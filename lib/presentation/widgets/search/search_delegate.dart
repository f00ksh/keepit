import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/providers/search_provider.dart';
import 'package:keepit/presentation/widgets/search/search_history_list.dart';

class NoteSearchDelegate extends SearchDelegate<Note?> {
  final WidgetRef ref;

  NoteSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return CustomScrollView(
        slivers: [
          SearchHistoryList(
            onQuerySelected: (query) {
              this.query = query;
              showResults(context);
            },
          ),
        ],
      );
    }
    return _buildSearchResults();
  }

  @override
  void close(BuildContext context, Note? result) {
    if (query.isNotEmpty) {
      ref.read(searchHistoryProvider.notifier).addQuery(query);
    }
    super.close(context, result);
  }

  Widget _buildSearchResults() {
    return Consumer(
      builder: (context, ref, _) {
        final searchResults = ref.watch(searchNotesProvider(query));

        return searchResults.when(
          data: (notes) => ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
                title: Text(note.title),
                subtitle: Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => close(context, note),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
    );
  }
}
