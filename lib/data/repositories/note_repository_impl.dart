import '../../domain/models/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../services/hive_stoarge_service.dart';

class NoteRepositoryImpl implements NoteRepository {
  final StorageService _storageService;

  NoteRepositoryImpl(this._storageService);

  @override
  Future<List<Note>> getAllNotes() async {
    return await _storageService.getAllNotes();
  }

  @override
  Future<void> addNote(Note note) async {
    await _storageService.addNote(note);
  }

  @override
  Future<void> updateNote(Note note) async {
    await _storageService.updateNote(note);
  }

  @override
  Future<void> deleteNote(String id) async {
    await _storageService.deleteNote(id);
  }

  @override
  Future<Note?> getNoteById(String id) async {
    return await _storageService.getNoteById(id);
  }
}
