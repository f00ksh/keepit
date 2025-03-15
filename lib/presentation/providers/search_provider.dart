import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/domain/models/note.dart';

part 'search_provider.g.dart';

// Search query provider
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

// Show search results provider
@riverpod
class ShowSearchResults extends _$ShowSearchResults {
  @override
  bool build() => false;

  void setShow(bool show) => state = show;
}

// Selected search labels provider
@riverpod
class SelectedSearchLabels extends _$SelectedSearchLabels {
  @override
  List<String> build() => [];

  void toggleLabel(String labelId) {
    if (state.contains(labelId)) {
      state = state.where((id) => id != labelId).toList();
    } else {
      state = [...state, labelId];
    }
  }

  void clear() => state = [];
}

// Selected search color provider
@riverpod
class SelectedSearchColor extends _$SelectedSearchColor {
  @override
  int? build() => null;

  void setColor(int? colorIndex) => state = colorIndex;
}

// Filtered notes provider
@riverpod
List<Note> searchFilteredNotes(ref) {
  final allNotes = ref.watch(notesProvider);
  final query = ref.watch(searchQueryProvider);
  final selectedLabels = ref.watch(selectedSearchLabelsProvider);
  final selectedColor = ref.watch(selectedSearchColorProvider);

  // Start with all notes that aren't deleted
  var filteredNotes = allNotes.where((note) => !note.isDeleted).toList();

  // Filter by search query if provided
  if (query.isNotEmpty) {
    final lowercaseQuery = query.toLowerCase();
    filteredNotes = filteredNotes.where((note) {
      return note.title.toLowerCase().contains(lowercaseQuery) ||
          note.content.toLowerCase().contains(lowercaseQuery) ||
          note.todos.any(
              (todo) => todo.content.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // Filter by selected labels if any
  if (selectedLabels.isNotEmpty) {
    filteredNotes = filteredNotes.where((note) {
      // Make sure labelIds is not null and is a List<String>
      final labelIds = note.labelIds;
      if (labelIds == null) return false;

      // Check if note contains all selected labels
      return selectedLabels.every((labelId) => labelIds.contains(labelId));
    }).toList();
  }

  // Filter by selected color if set
  if (selectedColor != null) {
    filteredNotes = filteredNotes
        .where((note) => note.colorIndex == selectedColor)
        .toList();
  }

  return filteredNotes;
}
