import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/data/providers/notes_provider.dart';
part 'note_view_provider.g.dart';

/// Provider for managing the state and operations of a single note view
@riverpod
class NoteView extends _$NoteView {
  @override
  Future<Note> build(String noteId) async {
    // Watch notesProvider to keep note in sync with the main notes list
    final notes = await ref.watch(notesProvider.future);
    // Find and return the specific note by ID
    return notes.firstWhere((note) => note.id == noteId);
  }

  /// Updates the title of the current note optimistically
  Future<void> updateTitle(String title) async {
    final currentNote = state.value;
    if (currentNote == null) return;
    final updatedNote = currentNote.copyWith(
      title: title,
      updatedAt: DateTime.now(),
    );
    await _updateNote(updatedNote);
  }

  /// Updates the content of the current note optimistically
  Future<void> updateContent(String content) async {
    final currentNote = state.value;
    if (currentNote == null) return;
    final updatedNote = currentNote.copyWith(
      content: content,
      updatedAt: DateTime.now(),
    );
    await _updateNote(updatedNote);
  }

  /// Toggles the pinned state of the current note optimistically
  Future<void> togglePin() async {
    final currentNote = state.value;
    if (currentNote == null) return;
    final updatedNote = currentNote.copyWith(
      isPinned: !currentNote.isPinned,
      updatedAt: DateTime.now(),
    );
    await _updateNote(updatedNote);
  }

  /// Toggles the favorite state of the current note optimistically
  Future<void> toggleFavorite() async {
    final currentNote = state.value;
    if (currentNote == null) return;
    final updatedNote = currentNote.copyWith(
      isFavorite: !currentNote.isFavorite,
      updatedAt: DateTime.now(),
    );
    await _updateNote(updatedNote);
  }

  /// Updates the color of the current note optimistically
  Future<void> updateColor(int colorIndex) async {
    final currentNote = state.value;
    if (currentNote == null) return;
    final updatedNote = currentNote.copyWith(
      colorIndex: colorIndex,
      updatedAt: DateTime.now(),
    );
    await _updateNote(updatedNote);
  }

  /// Private helper that updates the note optimistically.
  Future<void> _updateNote(Note updatedNote) async {
    // Update local state to keep UI in data mode.
    state = AsyncData(updatedNote);
    try {
      await ref.read(notesProvider.notifier).updateNote(updatedNote.id, updatedNote);
      // Optionally, you might re-read and update state here upon successful persistence.
    } catch (e, stack) {
      state = AsyncError(e, stack);
      // Optionally, restore previous note if needed.
    }
  }
}
