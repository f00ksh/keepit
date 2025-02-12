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
    final notes = _notesBox.values.toList();
    return notes;
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
    await _notesBox.putAll({for (var note in notes) note.id: note});
  }
}
