import 'dart:developer' as developer;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/note.dart';
import 'auth_provider.dart';
import 'service_providers.dart';
import 'package:flutter/foundation.dart';

part 'notes_provider.g.dart';

@riverpod
class Notes extends _$Notes {
  @override
  List<Note> build() {
    _loadNotes();
    return [];
  }

  Future<void> _loadNotes() async {
    final notes = await ref.read(storageServiceProvider).getAllNotes();
    state = notes;
  }

  Future<void> addNote(Note note) async {
    final currentNotes = List<Note>.from(state);
    state = [note, ...currentNotes];

    await ref.read(storageServiceProvider).addNote(note);

    _syncWithCloud((service) => service.createNote(note)).catchError(
        (e) => developer.log('Sync failed: $e', name: 'NotesProvider'));
  }

  Future<void> updateNote(String id, Note updatedNote) async {
    final currentNotes = List<Note>.from(state);
    final index = currentNotes.indexWhere((note) => note.id == id);

    if (index == -1) return;

    currentNotes[index] = updatedNote;
    state = currentNotes;

    await ref.read(storageServiceProvider).updateNote(updatedNote);
    _syncWithCloud((service) => service.updateNote(updatedNote)).catchError(
        (e) => developer.log('Sync failed: $e', name: 'NotesProvider'));
  }

  Future<void> updateNoteStatus(
    String id, {
    bool? isFavorite,
    bool? isArchived,
    bool? isDeleted,
    bool? isPinned,
  }) async {
    final currentNotes = List<Note>.from(state);
    final index = currentNotes.indexWhere((note) => note.id == id);

    if (index == -1) return;

    final oldNote = currentNotes[index];
    final updatedNote = oldNote.copyWith(
      isFavorite: isFavorite ?? oldNote.isFavorite,
      isArchived: isArchived ?? oldNote.isArchived,
      isDeleted: isDeleted ?? oldNote.isDeleted,
      isPinned: isPinned ?? oldNote.isPinned,
      updatedAt: DateTime.now(),
    );

    currentNotes[index] = updatedNote;
    state = currentNotes;

    await ref.read(storageServiceProvider).updateNote(updatedNote);
    _syncWithCloud((service) => service.updateNote(updatedNote)).catchError(
        (e) => developer.log('Sync failed: $e', name: 'NotesProvider'));
  }

  Future<void> deletePermanently(String id) async {
    final currentNotes = List<Note>.from(state);
    currentNotes.removeWhere((note) => note.id == id);
    state = currentNotes;

    await ref.read(storageServiceProvider).deleteNote(id);
    _syncWithCloud((service) => service.deleteNotePermanently(id)).catchError(
        (e) => developer.log('Sync failed: $e', name: 'NotesProvider'));
  }

  Future<void> updateBatchNotes(List<Note> updates) async {
    if (updates.isEmpty) return;

    final updatedNotes = _updateIndices(updates);
    state = updatedNotes;

    await ref.read(storageServiceProvider).updateBatchNotes(updatedNotes);
    _syncWithCloud((service) =>
            Future.wait(updatedNotes.map((note) => service.updateNote(note))))
        .catchError(
            (e) => developer.log('Sync failed: $e', name: 'NotesProvider'));
  }

  Future<void> _syncWithCloud(
      Future<void> Function(dynamic service) operation) async {
    final user = ref.read(authProvider).valueOrNull;
    if (user != null && !user.isAnonymous) {
      await operation(ref.read(supabaseServiceProvider));
    }
  }

  List<Note> _updateIndices(List<Note> notes) {
    return notes.asMap().entries.map((entry) {
      return entry.value.copyWith(
        index: entry.key,
      );
    }).toList();
  }

  Future<void> addLabelToNote(String noteId, String labelId) async {
    debugPrint('NotesProvider: Adding label $labelId to note $noteId');
    final currentNotes = List<Note>.from(state);
    final index = currentNotes.indexWhere((note) => note.id == noteId);

    if (index == -1) {
      debugPrint('NotesProvider: Note not found!');
      return;
    }

    final note = currentNotes[index];
    if (note.labelIds.contains(labelId)) {
      debugPrint('NotesProvider: Note already has this label');
      return; // Already has this label
    }

    final updatedLabels = List<String>.from(note.labelIds)..add(labelId);
    debugPrint('NotesProvider: Updated label IDs: $updatedLabels');

    final updatedNote = note.copyWith(
      labelIds: updatedLabels,
      updatedAt: DateTime.now(),
    );

    currentNotes[index] = updatedNote;
    state = currentNotes;
    debugPrint('NotesProvider: State updated with new labels');

    await ref.read(storageServiceProvider).updateNote(updatedNote);
    debugPrint('NotesProvider: Note saved to storage');

    _syncWithCloud((service) => service.updateNote(updatedNote)).catchError(
        (e) => developer.log('Sync failed: $e', name: 'NotesProvider'));
  }

  Future<void> removeLabelFromNote(String noteId, String labelId) async {
    final currentNotes = List<Note>.from(state);
    final index = currentNotes.indexWhere((note) => note.id == noteId);

    if (index == -1) return;

    final note = currentNotes[index];
    if (!note.labelIds.contains(labelId)) return; // Doesn't have this label

    final updatedLabels = List<String>.from(note.labelIds)..remove(labelId);
    final updatedNote = note.copyWith(
      labelIds: updatedLabels,
      updatedAt: DateTime.now(),
    );

    currentNotes[index] = updatedNote;
    state = currentNotes;

    await ref.read(storageServiceProvider).updateNote(updatedNote);
    _syncWithCloud((service) => service.updateNote(updatedNote)).catchError(
        (e) => developer.log('Sync failed: $e', name: 'NotesProvider'));
  }

  Future<void> updateNotesOnLabelDelete(String labelId) async {
    final currentNotes = List<Note>.from(state);
    bool hasChanges = false;

    // Find all notes with this label and remove the label
    for (int i = 0; i < currentNotes.length; i++) {
      final note = currentNotes[i];
      if (note.labelIds.contains(labelId)) {
        final updatedLabels = List<String>.from(note.labelIds)..remove(labelId);
        final updatedNote = note.copyWith(
          labelIds: updatedLabels,
          updatedAt: DateTime.now(),
        );

        currentNotes[i] = updatedNote;
        hasChanges = true;

        // Update storage immediately for each note
        await ref.read(storageServiceProvider).updateNote(updatedNote);
        _syncWithCloud((service) => service.updateNote(updatedNote)).catchError(
            (e) => developer.log('Sync failed: $e', name: 'NotesProvider'));
      }
    }

    if (hasChanges) {
      state = currentNotes;
    }
  }
}
