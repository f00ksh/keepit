import 'package:flutter/foundation.dart';
import 'package:keepit/data/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/note.dart';
import 'supabase_providers.dart';
import 'dart:async';

part 'notes_provider.g.dart';

@riverpod
class Notes extends _$Notes {
  static const String _tag = 'NotesProvider';
  Timer? _syncTimer;

  @override
  Future<List<Note>> build() async {
    debugPrint('$_tag: Building provider');
    // Get local notes first
    final notes = await ref.watch(storageServiceProvider).getAllNotes();

    // Start sync timer only if user is authenticated and sync is enabled
    _syncTimer?.cancel();
    final user = ref.watch(authProvider).valueOrNull;
    if (user != null && !user.isAnonymous) {
      _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
        _syncNotes();
      });
    }

    return notes;
  }

  Future<void> reorderNotesAndSync(List<Note> reorderedNotes) async {
    if (!state.hasValue) {
      debugPrint('$_tag: Cannot reorder - no current state');
      return;
    }

    try {
      debugPrint('$_tag: Syncing reordered notes');
      state = AsyncData(reorderedNotes);

      // Update local storage
      await ref.read(storageServiceProvider).updateBatchNotes(reorderedNotes);

      final user = ref.read(authProvider).valueOrNull;
      if (user != null && !user.isAnonymous) {
        debugPrint('$_tag: Syncing updates to Supabase');
        await Future.wait(reorderedNotes
            .map((note) => ref.read(supabaseServiceProvider).updateNote(note)));
        debugPrint('$_tag: Supabase sync completed');
      }
    } catch (e) {
      debugPrint('$_tag: Error during reordering sync: $e');
      ref.invalidateSelf();
    }
  }

  Future<void> _syncNotes() async {
    try {
      final user = ref.read(authProvider).valueOrNull;
      if (user == null || user.isAnonymous) return;

      await ref.read(syncServiceProvider).syncNotes();
      ref.invalidateSelf();
    } catch (e) {
      if (kDebugMode) {
        print('Sync error: $e');
      }
    }
  }

  Future<void> addNote(Note note) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Always save locally first
      await ref.read(storageServiceProvider).addNote(note);

      // Try to sync if user is authenticated
      final user = ref.read(authProvider).valueOrNull;
      if (user != null && !user.isAnonymous) {
        try {
          await ref.read(supabaseServiceProvider).createNote(note);
        } catch (e) {
          // Continue anyway as we have local copy
        }
      }

      // Return local notes
      return ref.read(storageServiceProvider).getAllNotes();
    });
  }

  Future<void> updateNote(String id, Note updatedNote) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Update locally first
      await ref.read(storageServiceProvider).updateNote(updatedNote);

      // Try to sync if user is authenticated
      final user = ref.read(authProvider).valueOrNull;
      if (user != null && !user.isAnonymous) {
        try {
          await ref.read(supabaseServiceProvider).updateNote(updatedNote);
        } catch (e) {
          // Continue anyway as we have local copy
        }
      }

      return ref.read(storageServiceProvider).getAllNotes();
    });
  }

  Future<void> deleteNote(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Delete locally first
      await ref.read(storageServiceProvider).deleteNote(id);

      // Try to sync if user is authenticated
      final user = ref.read(authProvider).valueOrNull;
      if (user != null && !user.isAnonymous) {
        try {
          await ref.read(supabaseServiceProvider).deleteNotePermanently(id);
        } catch (e) {
          // Continue anyway as we have local copy
        }
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
      // Soft delete locally
      await ref.read(storageServiceProvider).moveToTrash(id);

      // Try to update in Supabase if authenticated
      final user = ref.read(authProvider).valueOrNull;
      if (user != null && !user.isAnonymous) {
        try {
          await ref.read(supabaseServiceProvider).updateNoteStatus(
                id,
                isDeleted: true,
              );
        } catch (e) {
          // Continue anyway as we have local copy
        }
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
      // Delete from local storage
      await ref.read(storageServiceProvider).deleteNote(id);

      // Try to delete from Supabase if authenticated
      final user = ref.read(authProvider).valueOrNull;
      if (user != null && !user.isAnonymous) {
        try {
          await ref.read(supabaseServiceProvider).deleteNotePermanently(id);
        } catch (e) {
          // Continue anyway as we deleted locally
        }
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
    final notes = await future; // Access the fetched notes
    return notes.firstWhere((note) => note.id == noteId);
  }

  Future<void> updateBatchNotes(List<Note> updates) async {
    final currentState = state;
    if (!currentState.hasValue) {
      debugPrint('$_tag: Cannot update batch - no current state');
      return;
    }

    debugPrint('$_tag: Processing ${updates.length} batch updates');
    final notes = List<Note>.from(currentState.value!);

    for (final update in updates) {
      final index = notes.indexWhere((note) => note.id == update.id);
      if (index != -1) {
        debugPrint('$_tag: Updating note ${update.id} at index $index');
        notes[index] = update;
      } else {
        debugPrint('$_tag: Note ${update.id} not found in current state');
      }
    }

    debugPrint('$_tag: Updating state with ${notes.length} notes');
    state = AsyncData(notes);

    try {
      debugPrint('$_tag: Starting batch storage update');
      await Future.wait(updates.map((note) async {
        await ref.read(storageServiceProvider).updateNote(note);
        debugPrint('$_tag: Updated note ${note.id} in local storage');

        final user = ref.read(authProvider).valueOrNull;
        if (user != null && !user.isAnonymous) {
          debugPrint('$_tag: Syncing note ${note.id} to Supabase');
          await ref.read(supabaseServiceProvider).updateNote(note);
        }
      }));
      debugPrint('$_tag: Batch update completed successfully');
    } catch (e) {
      debugPrint('$_tag: Batch update failed: $e');
      state = currentState;
      rethrow;
    }
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}
