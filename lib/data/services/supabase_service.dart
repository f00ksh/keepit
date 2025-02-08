import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/note.dart';

class SupabaseService {
  final SupabaseClient _client;
  SupabaseService(this._client);

  Future<void> init() async {
    // Initialize any required setup
  }

  Future<List<Note>> getNotes() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await _client
          .from('notes')
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .order('updated_at', ascending: false);

      print('Fetched notes from Supabase: $response');
      return (response as List)
          .map((note) => Note.fromJson({
                ...note,
                'color_index':
                    note['color_index'] ?? 0, // Provide default value
              }))
          .toList();
    } catch (e) {
      print('Error fetching notes: $e');
      rethrow;
    }
  }

  Future<void> updateNoteStatus(
    String noteId, {
    bool? isFavorite,
    bool? isArchived,
    bool? isDeleted,
  }) async {
    try {
      final updates = {
        if (isFavorite != null) 'is_favorite': isFavorite,
        if (isArchived != null) 'is_archived': isArchived,
        if (isDeleted != null) 'is_deleted': isDeleted,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client.from('notes').update(updates).eq('id', noteId);
    } catch (e) {
      rethrow;
    }
  }

  Future<Note> createNote(Note note) async {
    try {
      print('Creating note with color index: ${note.colorIndex}');
      final response = await _client
          .from('notes')
          .insert({
            'id': note.id,
            'title': note.title,
            'content': note.content,
            'is_pinned': note.isPinned,
            'is_favorite': note.isFavorite,
            'color_index': note.colorIndex,
            'created_at': note.createdAt.toIso8601String(),
            'updated_at': note.updatedAt.toIso8601String(),
            'is_archived': note.isArchived,
            'is_deleted': note.isDeleted,
            'user_id': _client.auth.currentUser?.id,
          })
          .select()
          .single();

      print('Note created in Supabase: $response');
      return Note.fromJson(response);
    } catch (e) {
      print('Error creating note: $e');
      rethrow;
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      print('Updating note with color index: ${note.colorIndex}');
      await _client.from('notes').update({
        'title': note.title,
        'content': note.content,
        'is_pinned': note.isPinned,
        'is_favorite': note.isFavorite,
        'color_index': note.colorIndex,
        'updated_at': note.updatedAt.toIso8601String(),
        'is_archived': note.isArchived,
        'is_deleted': note.isDeleted,
      }).eq('id', note.id);
    } catch (e) {
      print('Error updating note: $e');
      rethrow;
    }
  }

  Future<void> deleteNotePermanently(String noteId) async {
    try {
      await _client.from('notes').delete().eq('id', noteId);
    } catch (e) {
      rethrow;
    }
  }

  // New methods for filtered queries
  Future<List<Note>> getFavoriteNotes() async {
    try {
      final response = await _client
          .from('notes')
          .select()
          .eq('is_favorite', true)
          .eq('is_deleted', false)
          .eq('is_archived', false)
          .order('updated_at', ascending: false);

      return (response as List).map((note) => Note.fromJson(note)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Note>> getArchivedNotes() async {
    try {
      final response = await _client
          .from('notes')
          .select()
          .eq('is_archived', true)
          .eq('is_deleted', false)
          .order('updated_at', ascending: false);

      return (response as List).map((note) => Note.fromJson(note)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Note>> getTrashedNotes() async {
    try {
      final response = await _client
          .from('notes')
          .select()
          .eq('is_deleted', true)
          .order('updated_at', ascending: false);

      return (response as List).map((note) => Note.fromJson(note)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
