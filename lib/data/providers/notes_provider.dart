import 'package:flutter/foundation.dart';
import 'package:keepit/data/providers/auth_provider.dart';
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
    // Get local notes first
    final notes = await ref.watch(storageServiceProvider).getAllNotes();

    // Sort notes by order and other criteria
    notes.sort((a, b) {
      // Then by order
      if (a.order != b.order) {
        return a.order.compareTo(b.order);
      }
      // Finally by updated date
      return b.updatedAt.compareTo(a.updatedAt);
    });

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

  Future<void> reorderNotes(int oldIndex, int newIndex) async {
    final currentState = state;
    if (!currentState.hasValue) return;

    final notes = List<Note>.from(currentState.value!);
    final movedNote = notes[oldIndex];

    // Remove and insert at new position
    notes.removeAt(oldIndex);
    if (oldIndex < newIndex) newIndex--;
    notes.insert(newIndex, movedNote);

    // Update orders efficiently
    final updates = <Note>[];
    for (var i = 0; i < notes.length; i++) {
      if (notes[i].order != i) {
        final updatedNote = notes[i].copyWith(
          order: i,
          updatedAt: DateTime.now(),
        );
        updates.add(updatedNote);
        notes[i] = updatedNote;
      }
    }

    // Optimistically update state
    state = AsyncData(notes);

    // Batch update storage
    try {
      await Future.wait(updates.map((note) async {
        await ref.read(storageServiceProvider).updateNote(note);

        final user = ref.read(authProvider).valueOrNull;
        if (user != null && !user.isAnonymous) {
          await ref.read(supabaseServiceProvider).updateNote(note);
        }
      }));
    } catch (e) {
      // Revert on error
      state = currentState;
      rethrow;
    }
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

  // Add method to fix order if needed
  Future<void> fixNoteOrder() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final notes = await future;
      final sortedNotes = List<Note>.from(notes)
        ..sort((a, b) => a.order.compareTo(b.order));

      for (var i = 0; i < sortedNotes.length; i++) {
        final note = sortedNotes[i];
        if (note.order != i) {
          final updatedNote = note.copyWith(order: i);
          await ref.read(storageServiceProvider).updateNote(updatedNote);
        }
      }

      return ref.read(storageServiceProvider).getAllNotes();
    });
  }

  Future<void> updateBatchNotes(List<Note> updates) async {
    final currentState = state;
    if (!currentState.hasValue) return;

    final notes = List<Note>.from(currentState.value!);

    // Update notes in current state
    for (final update in updates) {
      final index = notes.indexWhere((note) => note.id == update.id);
      if (index != -1) {
        notes[index] = update;
      }
    }

    // Optimistically update state
    state = AsyncData(notes);

    try {
      // Batch update storage
      await Future.wait(updates.map((note) async {
        await ref.read(storageServiceProvider).updateNote(note);

        final user = ref.read(authProvider).valueOrNull;
        if (user != null && !user.isAnonymous) {
          await ref.read(supabaseServiceProvider).updateNote(note);
        }
      }));
    } catch (e) {
      // Revert on error
      state = currentState;
      rethrow;
    }
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}
