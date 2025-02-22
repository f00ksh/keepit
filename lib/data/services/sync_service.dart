import 'package:flutter/foundation.dart';
import 'package:keepit/domain/models/note.dart';

import 'hive_stoarge_service.dart';
import 'supabase_stoarge_service.dart';

class SyncService {
  final StorageService _localStorage;
  final SupabaseService _cloudStorage;

  SyncService(this._localStorage, this._cloudStorage);

  Future<void> syncNotes() async {
    try {
      // Get local notes
      final localNotes = await _localStorage.getAllNotes();

      // Try to get remote notes
      List<Note> remoteNotes = [];
      try {
        remoteNotes = await _cloudStorage.getNotes();
      } catch (e) {
        if (kDebugMode) {
          print('Failed to fetch remote notes: $e');
        }
        return; // Exit if we can't get remote notes
      }

      // Upload local changes
      for (final localNote in localNotes) {
        try {
          final remoteNote = remoteNotes.firstWhere(
            (note) => note.id == localNote.id,
            orElse: () => localNote,
          );

          if (localNote.updatedAt.isAfter(remoteNote.updatedAt)) {
            // Local note is newer, upload it
            await _cloudStorage.updateNote(localNote);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync note ${localNote.id}: $e');
          }
          continue; // Continue with next note
        }
      }

      // Download remote changes
      for (final remoteNote in remoteNotes) {
        try {
          final localNote = await _localStorage.getNoteById(remoteNote.id);
          if (localNote == null ||
              remoteNote.updatedAt.isAfter(localNote.updatedAt)) {
            // Remote note is newer or doesn't exist locally
            await _localStorage.updateNote(remoteNote);
          }
        } catch (e) {
          if (kDebugMode) {
            print('Failed to sync note ${remoteNote.id}: $e');
          }
          continue; // Continue with next note
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Sync failed: $e');
      }
      // Don't rethrow to prevent app crashes
    }
  }
}
