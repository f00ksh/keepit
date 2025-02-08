import 'hive_stoarge_service.dart';
import 'supabase_stoarge_service.dart';

class SyncService {
  final StorageService _localStorage;
  final SupabaseService _cloudStorage;

  SyncService(this._localStorage, this._cloudStorage);

  Future<void> syncNotes() async {
    try {
      // Get local and remote notes
      final localNotes = await _localStorage.getAllNotes();
      final remoteNotes = await _cloudStorage.getNotes();

      // Implement sync logic
      // This is a simple example - you might want to implement more sophisticated
      // conflict resolution based on timestamps or other criteria
      for (final remoteNote in remoteNotes) {
        final localNote = localNotes.firstWhere(
          (note) => note.id == remoteNote.id,
          orElse: () => remoteNote,
        );

        if (localNote != remoteNote) {
          await _localStorage.updateNote(remoteNote);
        }
      }

      // Upload local notes that don't exist in remote
      for (final localNote in localNotes) {
        if (!remoteNotes.any((note) => note.id == localNote.id)) {
          await _cloudStorage.createNote(localNote);
        }
      }
    } catch (e) {
      // Handle sync errors
      rethrow;
    }
  }
}
