import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/note.dart';
import 'supabase_providers.dart';
import 'dart:async';

part 'notes_provider.g.dart';

@riverpod
class Notes extends _$Notes {
  Timer? _syncTimer;

  @override
  Future<List<Note>> build() async {
    // Start periodic sync
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _syncNotes();
    });

    return ref.watch(supabaseServiceProvider).getNotes();
  }

  Future<void> _syncNotes() async {
    try {
      await ref.read(syncServiceProvider).syncNotes();
      ref.invalidateSelf();
    } catch (e) {
      // Handle sync errors
    }
  }

  Future<void> addNote(Note note) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Save to Supabase first
      final savedNote =
          await ref.read(supabaseServiceProvider).createNote(note);

      // Then save locally
      await ref.read(storageServiceProvider).addNote(savedNote);

      // Return updated list
      return ref.read(supabaseServiceProvider).getNotes();
    });
  }

  Future<void> updateNote(String id, Note updatedNote) async {
    await ref.read(noteRepositoryProvider).updateNote(updatedNote);
    ref.invalidateSelf();
  }

  Future<void> deleteNote(String id) async {
    await ref.read(noteRepositoryProvider).deleteNote(id);
    ref.invalidateSelf();
  }

  Future<void> reorderNotes(int oldIndex, int newIndex) async {
    final currentState = await future;
    final updatedNotes = List<Note>.from(currentState);
    if (oldIndex < newIndex) newIndex -= 1;
    final note = updatedNotes.removeAt(oldIndex);
    updatedNotes.insert(newIndex, note);

    await ref.read(noteRepositoryProvider).reorderNotes(updatedNotes);
    ref.invalidateSelf();
  }

  Future<void> toggleFavorite(String noteId, bool isFavorite) async {
    await ref.read(supabaseServiceProvider).updateNoteStatus(
          noteId,
          isFavorite: isFavorite,
        );
    ref.invalidateSelf();
  }

  Future<void> toggleArchive(String noteId, bool isArchived) async {
    await ref.read(supabaseServiceProvider).updateNoteStatus(
          noteId,
          isArchived: isArchived,
        );
    ref.invalidateSelf();
  }

  Future<void> moveToTrash(String noteId) async {
    await ref.read(supabaseServiceProvider).updateNoteStatus(
          noteId,
          isDeleted: true,
        );
    ref.invalidateSelf();
  }

  Future<void> restoreFromTrash(String noteId) async {
    await ref.read(supabaseServiceProvider).updateNoteStatus(
          noteId,
          isDeleted: false,
        );
    ref.invalidateSelf();
  }

  Future<void> deletePermanently(String noteId) async {
    await ref.read(supabaseServiceProvider).deleteNotePermanently(noteId);
    ref.invalidateSelf();
  }

  Future<void> togglePin(String noteId, bool isPinned) async {
    final note = (await future).firstWhere((note) => note.id == noteId);
    final updatedNote = note.copyWith(isPinned: isPinned);
    await ref.read(noteRepositoryProvider).updateNote(updatedNote);
    ref.invalidateSelf();
  }

  Future<Note?> getNoteById(String noteId) async {
    final notes = await future; // Access the fetched notes
    return notes.firstWhere((note) => note.id == noteId);
  }

  // Don't forget to cancel the timer when the provider is disposed

  void onDispose() {
    _syncTimer?.cancel();
  }
}

// Add a convenience provider for single note
@riverpod
Future<Note> note( ref, String id) {
  return ref.watch(notesProvider.notifier).getNote(id);
}
