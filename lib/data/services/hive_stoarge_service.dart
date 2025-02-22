import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/note.dart';

class StorageService {
  static const String _tag = 'StorageService';
  static const String notesBoxName = 'notes';
  late Box<Note> _notesBox;

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }

    _notesBox = await Hive.openBox<Note>(notesBoxName);
  }

  Future<List<Note>> getAllNotes() async {
    final notes = _notesBox.values.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    return notes;
  }

  Future<void> addNote(Note note) async {
    // Get existing notes and shift their indices
    final existingNotes = await getAllNotes();
    final updatedNotes = existingNotes.map((existingNote) {
      return existingNote.copyWith(
        index: existingNote.index + 1,
        updatedAt: DateTime.now(),
      );
    }).toList();

    // Add new note with index 0
    await _notesBox.put(note.id, note.copyWith(index: 0));

    // Update existing notes with new indices
    await updateBatchNotes(updatedNotes);
  }

  Future<void> updateNote(Note note) async {
    await _notesBox.put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  Future<Note?> getNoteById(String id) async {
    final note = _notesBox.get(id);

    return note;
  }

  Future<void> clearAll() async {
    await _notesBox.clear();
  }

  Future<void> moveToTrash(String id) async {
    final note = await getNoteById(id);
    if (note != null) {
      final trashedNote = note.copyWith(
        isDeleted: true,
        isPinned: false,
        isFavorite: false,
        isArchived: false,
        updatedAt: DateTime.now(),
      );
      await updateNote(trashedNote);
    } else {}
  }

  Future<void> updateBatchNotes(List<Note> notes) async {
    debugPrint('$_tag: Updating batch of ${notes.length} notes');
    await _notesBox.putAll({for (var note in notes) note.id: note});
    debugPrint('$_tag: Successfully saved batch updates');
  }
}
