import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/note.dart';
import '../../data/providers/notes_provider.dart';

part 'filtered_notes_provider.g.dart';

@riverpod
List<Note> favoriteNotes(ref) {
  final notes = ref.watch(notesProvider);
  return notes.where((Note note) => note.isFavorite).toList();
}

@riverpod
List<Note> archivedNotes(ref) {
  final notes = ref.watch(notesProvider);
  return notes.where((Note note) => note.isArchived).toList();
}

@riverpod
List<Note> trashedNotes(ref) {
  final notes = ref.watch(notesProvider);
  return notes.where((Note note) => note.isDeleted).toList();
}

@riverpod
List<Note> mainNotes(ref) {
  final notes = ref.watch(notesProvider);
  return notes
      .where((Note note) => !note.isDeleted && !note.isArchived)
      .toList();
}

@riverpod
List<Note> labelNotes(ref, String labelId) {
  final notes = ref.watch(notesProvider);
  return notes.where((note) => note.labelIds.contains(labelId)).toList();
}

// For custom search/filter
@riverpod
class FilteredNotes extends _$FilteredNotes {
  @override
  List<Note> build({String? searchQuery, bool? isFavorite}) {
    final notes = ref.watch(notesProvider);

    return notes.where((note) {
      if (searchQuery != null &&
          !note.title.toLowerCase().contains(searchQuery.toLowerCase()) &&
          !note.content.toLowerCase().contains(searchQuery.toLowerCase())) {
        return false;
      }

      if (isFavorite != null && note.isFavorite != isFavorite) {
        return false;
      }

      return true;
    }).toList();
  }
}
