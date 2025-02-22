import '../models/note.dart';

abstract class NoteServiceRepository {
  Future<List<Note>> getAllNotes();
  Future<void> addNote(Note note);
  Future<void> updateNote(Note note);
  Future<void> deleteNote(String id);
  Future<Note?> getNoteById(String id);
}
