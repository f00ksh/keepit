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

  void dispose() {
    _syncTimer?.cancel();
  }
}
