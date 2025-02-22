import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/data/providers/notes_provider.dart';
part 'note_view_provider.g.dart';

/// Provider for managing a single note's state while being viewed/edited
@riverpod
class NoteView extends _$NoteView {
  bool _isDirty = false;

  @override
  Note build(String noteId) {
    final notes = ref.watch(notesProvider);
    return notes.firstWhere(
      (Note note) => note.id == noteId,
      orElse: () => _createNewNote(noteId),
    );
  }

  Note _createNewNote(String noteId) {
    return Note(
      id: noteId,
      title: '',
      content: '',
      colorIndex: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void updateTitle(String title) {
    if (state.title == title) return;
    state = state.copyWith(
      title: title,
      updatedAt: DateTime.now(),
    );
    _isDirty = true;
  }

  void updateContent(String content) {
    if (state.content == content) return;
    state = state.copyWith(
      content: content,
      updatedAt: DateTime.now(),
    );
    _isDirty = true;
  }

  void togglePin() {
    state = state.copyWith(
      isPinned: !state.isPinned,
      updatedAt: DateTime.now(),
    );
    _isDirty = true;
  }

  void toggleFavorite() {
    state = state.copyWith(
      isFavorite: !state.isFavorite,
      updatedAt: DateTime.now(),
    );
    _isDirty = true;
  }

  void updateColorIndex(int colorIndex) {
    state = state.copyWith(
      colorIndex: colorIndex,
      updatedAt: DateTime.now(),
    );

    _isDirty = true;
  }

  void toggleArchive() {
    state = state.copyWith(
      isArchived: !state.isArchived,
      isPinned: false, // Unpin when archiving
      updatedAt: DateTime.now(),
    );
    _isDirty = true;
  }

  void moveToTrash() {
    state = state.copyWith(
      isDeleted: !state.isDeleted,
      updatedAt: DateTime.now(),
    );
    _isDirty = true;
  }

  Future<void> saveNote() async {
    if (!_isDirty) return;

    final notesNotifier = ref.read(notesProvider.notifier);
    final notes = ref.read(notesProvider);

    try {
      if (notes.any((note) => note.id == state.id)) {
        await notesNotifier.updateNote(state.id, state);
      } else {
        await notesNotifier.addNote(state);
      }
      _isDirty = false;
    } catch (e) {
      debugPrint('Error saving note: $e');
    }
  }

  bool get hasUnsavedChanges => _isDirty;
}
