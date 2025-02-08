import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/note.dart';

class StorageService {
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
    return _notesBox.values.toList();
  }

  Future<void> addNote(Note note) async {
    await _notesBox.put(note.id, note);
  }

  Future<void> updateNote(Note note) async {
    await _notesBox.put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  Future<Note?> getNoteById(String id) async {
    return _notesBox.get(id);
  }

  Future<void> reorderNotes(List<Note> notes) async {
    // Implementation for reordering if needed
  }

  Future<void> clearAll() async {
    await _notesBox.clear();
  }
}
