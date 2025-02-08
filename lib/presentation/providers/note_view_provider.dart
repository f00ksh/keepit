import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/data/providers/notes_provider.dart';
part 'note_view_provider.g.dart';

@riverpod
class NoteView extends _$NoteView {
  @override
  AsyncValue<Note> build(String noteId) {
    return const AsyncValue.loading();
  }

  Future<void> loadNote() async {
    state = const AsyncValue.loading();
    try {
      final notes = await ref.read(notesProvider.future);
      final note = notes.firstWhere((note) => note.id == noteId);
      state = AsyncValue.data(note);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateTitle(String title) async {
    final currentNote = state.valueOrNull;
    if (currentNote == null) return;

    final updatedNote = currentNote.copyWith(
      title: title,
      updatedAt: DateTime.now(),
    );

    await _updateNote(updatedNote);
  }

  Future<void> updateContent(String content) async {
    final currentNote = state.valueOrNull;
    if (currentNote == null) return;

    final updatedNote = currentNote.copyWith(
      content: content,
      updatedAt: DateTime.now(),
    );

    await _updateNote(updatedNote);
  }

  Future<void> togglePin() async {
    final currentNote = state.valueOrNull;
    if (currentNote == null) return;

    final updatedNote = currentNote.copyWith(
      isPinned: !currentNote.isPinned,
      updatedAt: DateTime.now(),
    );

    await _updateNote(updatedNote);
  }

  Future<void> toggleFavorite() async {
    final currentNote = state.valueOrNull;
    if (currentNote == null) return;

    final updatedNote = currentNote.copyWith(
      isFavorite: !currentNote.isFavorite,
      updatedAt: DateTime.now(),
    );

    await _updateNote(updatedNote);
  }

  Future<void> updateColor(int colorIndex) async {
    final currentNote = state.valueOrNull;
    if (currentNote == null) return;

    final updatedNote = currentNote.copyWith(
      colorIndex: colorIndex,
      updatedAt: DateTime.now(),
    );

    await _updateNote(updatedNote);
  }

  Future<void> _updateNote(Note updatedNote) async {
    try {
      await ref
          .read(notesProvider.notifier)
          .updateNote(updatedNote.id, updatedNote);
      state = AsyncValue.data(updatedNote);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
