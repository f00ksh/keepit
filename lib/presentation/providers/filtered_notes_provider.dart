import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/note.dart';
import 'notes_provider.dart';

part 'filtered_notes_provider.g.dart';

@riverpod
Future<List<Note>> favoriteNotes(ref) async {
  final notes = await ref.watch(notesProvider.future);
  return notes
      .where((note) => note.isFavorite && !note.isArchived && !note.isDeleted)
      .toList();
}

@riverpod
Future<List<Note>> archivedNotes(ref) async {
  final notes = await ref.watch(notesProvider.future);
  return notes.where((note) => note.isArchived && !note.isDeleted).toList();
}

@riverpod
Future<List<Note>> trashedNotes(ref) async {
  final notes = await ref.watch(notesProvider.future);
  return notes.where((note) => note.isDeleted).toList();
}
