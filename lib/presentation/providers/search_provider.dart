import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/data/providers/notes_provider.dart';

part 'search_provider.g.dart';

@riverpod
class SearchActive extends _$SearchActive {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
Future<List<Note>> filteredNotes(ref) async {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final notes = await ref.watch(notesProvider.future);

  if (query.isEmpty) return notes;

  return notes.where((note) {
    return note.title.toLowerCase().contains(query) ||
        note.content.toLowerCase().contains(query);
  }).toList();
}

@riverpod
Future<List<Note>> searchNotes(ref, String query) async {
  if (query.isEmpty) return [];

  final notes = await ref.watch(notesProvider.future);
  final searchLower = query.toLowerCase();

  return notes.where((note) {
    final titleMatch = note.title.toLowerCase().contains(searchLower);
    final contentMatch = note.content.toLowerCase().contains(searchLower);
    return titleMatch || contentMatch;
  }).toList();
}

@riverpod
class SearchHistory extends _$SearchHistory {
  static const maxHistory = 10;

  @override
  List<String> build() => [];

  void addQuery(String query) {
    if (query.isEmpty) return;

    state = [
      query,
      ...state.where((q) => q != query),
    ].take(maxHistory).toList();
  }

  void removeQuery(String query) {
    state = state.where((q) => q != query).toList();
  }

  void clearHistory() {
    state = [];
  }
}
