import 'package:flutter/foundation.dart';
import 'package:keepit/data/providers/auth_provider.dart';
import 'package:keepit/data/seed/initial_notes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/note.dart';
import 'supabase_providers.dart';
import 'dart:async';

part 'notes_provider.g.dart';

@riverpod
class Notes extends _$Notes {
  static const String _tag = 'NotesProvider';

  @override
  Future<List<Note>> build() async {
    debugPrint('$_tag: Building notes provider');

    try {
      // Check if notes already exist
      final existingNotes =
          await ref.read(storageServiceProvider).getAllNotes();

      if (existingNotes.isEmpty) {
        debugPrint('$_tag: No notes found, seeding initial data');
        final initialNotes = NotesSeeder.generateInitialNotes();

        // Save each note
        await Future.wait(initialNotes
            .map((note) => ref.read(storageServiceProvider).addNote(note)));

        return initialNotes;
      }

      return existingNotes;
    } catch (e, stack) {
      debugPrint('$_tag: Error initializing notes: $e\n$stack');
      rethrow;
    }
  }

  Future<void> reorderNotes({
    required int oldIndex,
    required int newIndex,
    required List<Note> notes,
  }) async {
    debugPrint('$_tag: Reordering notes from $oldIndex to $newIndex');

    try {
      final updates = _updateIndices(notes);

      // Update local storage first
      await _persistUpdates(updates);

      // Then update provider state
      state = AsyncData(updates);
    } catch (e) {
      debugPrint('$_tag: Reorder error: $e');
      ref.invalidateSelf();
    }
  }

  List<Note> _updateIndices(List<Note> notes) {
    debugPrint('$_tag: Current note indices:');
    for (var note in notes) {
      debugPrint(
          '$_tag: Note ${note.id.substring(0, 5)} - index: ${note.index}');
    }

    final updatedNotes = notes.asMap().entries.map((entry) {
      final note = entry.value;
      final newIndex = entry.key;
      debugPrint(
          '$_tag: Updating ${note.id.substring(0, 5)} index from ${note.index} to $newIndex');
      return note.copyWith(
        index: entry.key,
        updatedAt: DateTime.now(),
      );
    }).toList();

    debugPrint('$_tag: Updated note indices:');
    for (var note in updatedNotes) {
      debugPrint(
          '$_tag: Note ${note.id.substring(0, 5)} - new index: ${note.index}');
    }

    return updatedNotes;
  }

  Future<void> _persistUpdates(List<Note> updates) async {
    await ref.read(storageServiceProvider).updateBatchNotes(updates);

    final user = ref.read(authProvider).valueOrNull;
    if (user != null && !user.isAnonymous) {
      await Future.wait(updates
          .map((note) => ref.read(supabaseServiceProvider).updateNote(note)));
    }
  }

  Future<void> addNote(Note note) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(storageServiceProvider).addNote(note);

      final user = ref.read(authProvider).valueOrNull;
      if (user != null && !user.isAnonymous) {
        await ref.read(supabaseServiceProvider).createNote(note);
      }

      return ref.read(storageServiceProvider).getAllNotes();
    });
  }

  Future<void> updateNote(String id, Note updatedNote) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(storageServiceProvider).updateNote(updatedNote);

      final user = ref.read(authProvider).valueOrNull;
      if (user != null && !user.isAnonymous) {
        await ref.read(supabaseServiceProvider).updateNote(updatedNote);
      }

      return ref.read(storageServiceProvider).getAllNotes();
    });
  }

  Future<void> deleteNote(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(storageServiceProvider).deleteNote(id);

      final user = ref.read(authProvider).valueOrNull;
      if (user != null && !user.isAnonymous) {
        await ref.read(supabaseServiceProvider).deleteNotePermanently(id);
      }

      return ref.read(storageServiceProvider).getAllNotes();
    });
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

  Future<void> moveToTrash(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(storageServiceProvider).moveToTrash(id);

      final user = ref.read(authProvider).valueOrNull;
      if (user != null && !user.isAnonymous) {
        await ref.read(supabaseServiceProvider).updateNoteStatus(
              id,
              isDeleted: true,
            );
      }

      return ref.read(storageServiceProvider).getAllNotes();
    });
  }

  Future<void> restoreFromTrash(String noteId) async {
    await ref.read(supabaseServiceProvider).updateNoteStatus(
          noteId,
          isDeleted: false,
        );
    ref.invalidateSelf();
  }

  Future<void> deletePermanently(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(storageServiceProvider).deleteNote(id);

      final user = ref.read(authProvider).valueOrNull;
      if (user != null && !user.isAnonymous) {
        await ref.read(supabaseServiceProvider).deleteNotePermanently(id);
      }

      return ref.read(storageServiceProvider).getAllNotes();
    });
  }

  Future<void> togglePin(String noteId, bool isPinned) async {
    final note = (await future).firstWhere((note) => note.id == noteId);
    final updatedNote = note.copyWith(isPinned: isPinned);
    await ref.read(noteRepositoryProvider).updateNote(updatedNote);
    ref.invalidateSelf();
  }

  Future<Note?> getNoteById(String noteId) async {
    final notes = await future;
    return notes.firstWhere((note) => note.id == noteId);
  }

  Future<void> updateBatchNotes(List<Note> updates) async {
    if (updates.isEmpty) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Update indices
      final updatedNotes = _updateIndices(updates);

      // Persist changes
      await _persistUpdates(updatedNotes);

      return updatedNotes;
    });
  }
}
