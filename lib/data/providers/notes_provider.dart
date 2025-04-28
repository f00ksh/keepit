import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/domain/models/todo_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/note.dart';
import 'auth_provider.dart';
import 'service_providers.dart';

part 'notes_provider.g.dart';

@riverpod
class Notes extends _$Notes {
  // Track temporary note IDs
  final Set<String> _temporaryNotes = {};

  @override
  List<Note> build() {
    _loadNotes();
    return [];
  }

  // Loads all notes from storage and updates state
  Future<void> _loadNotes() async {
    final notes = await ref.read(storageServiceProvider).getAllNotes();
    state = notes;
  }

  // Gets a note by ID or returns null if not found
  Note? getNote(String id) {
    return state.firstWhereOrNull((note) => note.id == id);
  }

  // Adds a new note to the state and storage
  Future<void> addNote(Note note) async {
    // If it's a todo note, add an initial empty todo
    final noteToAdd = note.noteType == NoteType.todo
        ? note.copyWith(todos: [
            TodoItem(
              content: '',
              index: 0,
            )
          ])
        : note;

    final currentNotes = List<Note>.from(state);
    state = [noteToAdd, ...currentNotes];

    await ref.read(storageServiceProvider).addNote(noteToAdd);

    _syncWithCloud((service) => service.createNote(noteToAdd))
        .catchError((e) {});
  }

  // Updates an existing note with new content
  Future<void> updateNote(String id, Note updatedNote) async {
    // First save to storage
    await ref.read(storageServiceProvider).updateNote(updatedNote);
    // Then update state
    final currentNotes = List<Note>.from(state);
    final index = currentNotes.indexWhere((note) => note.id == id);
    if (index == -1) return;
    currentNotes[index] = updatedNote;
    state = currentNotes;
    // Finally sync with cloud if needed
    await _syncWithCloud((service) => service.updateNote(updatedNote));
  }

  // Updates note status flags (favorite, archived, deleted, pinned)
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
    _syncWithCloud((service) => service.updateNote(updatedNote))
        .catchError((e) {});
  }

  // Permanently deletes a note from storage and state
  Future<void> deletePermanently(String id) async {
    final currentNotes = List<Note>.from(state);
    currentNotes.removeWhere((note) => note.id == id);
    state = currentNotes;

    await ref.read(storageServiceProvider).deleteNote(id);
    _syncWithCloud((service) => service.deleteNotePermanently(id))
        .catchError((e) {});
  }

  // Updates multiple notes at once, typically used for reordering
  Future<void> updateBatchNotes(List<Note> updates) async {
    if (updates.isEmpty) return;

    final updatedNotes = _updateIndices(updates);
    state = updatedNotes;

    await ref.read(storageServiceProvider).updateBatchNotes(updatedNotes);
    _syncWithCloud((service) =>
            Future.wait(updatedNotes.map((note) => service.updateNote(note))))
        .catchError((e) {});
  }

  // Syncs changes with cloud storage if user is logged in
  Future<void> _syncWithCloud(
      Future<void> Function(dynamic service) operation) async {
    final user = ref.read(authProvider).valueOrNull;
    if (user != null && !user.isAnonymous) {
      await operation(ref.read(supabaseServiceProvider));
    }
  }

  // Updates the index property of notes based on their position in the list
  List<Note> _updateIndices(List<Note> notes) {
    return notes.asMap().entries.map((entry) {
      return entry.value.copyWith(
        index: entry.key,
      );
    }).toList();
  }

  // Adds a label to a note
  Future<void> addLabelToNote(String noteId, String labelId) async {
    final currentNotes = List<Note>.from(state);
    final index = currentNotes.indexWhere((note) => note.id == noteId);

    if (index == -1) {
      return;
    }

    final note = currentNotes[index];
    if (note.labelIds.contains(labelId)) {
      return; // Already has this label
    }

    final updatedLabels = List<String>.from(note.labelIds)..add(labelId);

    final updatedNote = note.copyWith(
      labelIds: updatedLabels,
      updatedAt: DateTime.now(),
    );

    currentNotes[index] = updatedNote;
    state = currentNotes;

    await ref.read(storageServiceProvider).updateNote(updatedNote);

    _syncWithCloud((service) => service.updateNote(updatedNote))
        .catchError((e) {});
  }

  // Removes a label from a note
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
    _syncWithCloud((service) => service.updateNote(updatedNote))
        .catchError((e) {});
  }

  // Updates all notes when a label is deleted
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
        _syncWithCloud((service) => service.updateNote(updatedNote))
            .catchError((e) {});
      }
    }

    if (hasChanges) {
      state = currentNotes;
    }
  }

  // Adds a temporary empty note that can be deleted later if not modified
  Future<void> addEmptyNote(Note note) async {
    _temporaryNotes.add(note.id);

    final currentNotes = List<Note>.from(state);
    state = [note, ...currentNotes];

    // Save to storage but don't sync with cloud yet
    await ref.read(storageServiceProvider).addNote(note);
  }

  // Cleans up empty note with built-in animation delay
  Future<void> cleanupEmptyNote(String id) async {
    // Find the note or return early if not found
    final noteIndex = state.indexWhere((note) => note.id == id);
    if (noteIndex == -1) {
      _temporaryNotes.remove(id);
      return;
    }

    final note = state[noteIndex];
    if (note.title.isEmpty && note.content.isEmpty) {
      // Wait for hero animation to complete
      await Future.delayed(const Duration(milliseconds: 650));

      await deletePermanently(id);
      _temporaryNotes.remove(id);
    } else {
      _temporaryNotes.remove(id);
      await _syncWithCloud((service) => service.createNote(note))
          .catchError((e) {});
    }
  }

  // Helper method to update a note and sync with cloud
  Future<void> _updateAndSync(Note note) async {
    final currentNotes = List<Note>.from(state);
    final index = currentNotes.indexWhere((n) => n.id == note.id);

    if (index == -1) return;

    currentNotes[index] = note;
    state = currentNotes;

    await ref.read(storageServiceProvider).updateNote(note);
    _syncWithCloud((service) => service.updateNote(note)).catchError((e) {});
  }

  // Updates a todo item within a note
  Future<void> updateTodo(
    String noteId,
    String todoId, {
    String? content,
    bool? isDone,
    int? index,
  }) async {
    final note = getNote(noteId);
    if (note == null) {
      return;
    }

    final todoIndex = note.todos.indexWhere((todo) => todo.id == todoId);
    if (todoIndex == -1) {
      return;
    }

    final updatedTodos = List<TodoItem>.from(note.todos);
    updatedTodos[todoIndex] = updatedTodos[todoIndex].copyWith(
      content: content,
      isDone: isDone,
      index: index,
    );

    final updatedNote = note.copyWith(
      todos: updatedTodos,
      updatedAt: DateTime.now(),
    );

    await _updateAndSync(updatedNote);
  }

  // Adds a new todo item to a note
  Future<void> addTodo(String noteId, String content) async {
    final note = getNote(noteId);
    if (note == null) {
      return;
    }

    final newTodo = TodoItem(
      content: content,
      index: note.todos.length,
    );

    final updatedNote = note.copyWith(
      todos: [...note.todos, newTodo],
      updatedAt: DateTime.now(),
    );

    await _updateAndSync(updatedNote);
  }

  // Deletes a todo item from a note
  Future<void> deleteTodo(String noteId, String todoId) async {
    final note = getNote(noteId);
    if (note == null) return;

    final updatedTodos = note.todos
        .where((todo) => todo.id != todoId)
        .toList()
        .asMap()
        .entries
        .map((e) => e.value.copyWith(index: e.key))
        .toList();

    final updatedNote = note.copyWith(
      todos: updatedTodos,
      updatedAt: DateTime.now(),
    );

    await _updateAndSync(updatedNote);
  }

  // Reorders todo items within a note
  Future<void> reorderTodos(String noteId, int oldIndex, int newIndex) async {
    final note = getNote(noteId);
    if (note == null) return;

    final todos = List<TodoItem>.from(note.todos);
    final todo = todos.removeAt(oldIndex);
    todos.insert(newIndex, todo);

    final updatedTodos = todos
        .asMap()
        .entries
        .map((e) => e.value.copyWith(index: e.key))
        .toList();

    final updatedNote = note.copyWith(
      todos: updatedTodos,
      updatedAt: DateTime.now(),
    );

    await _updateAndSync(updatedNote);
  }
}

/// Provider for a single note by ID, automatically updates when the note changes
@riverpod
Note singleNote(Ref ref, String noteId, NoteType? noteType) {
  final allNotes = ref.watch(notesProvider);
  return allNotes.firstWhere(
    (note) => note.id == noteId,
    // If for some reason the note isn't found, create a sensible default
    // This eliminates the need for null checks in the UI
    orElse: () => Note(
      id: noteId,
      title: '',
      content: '',
      colorIndex: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      noteType: noteType ?? NoteType.text,
    ),
  );
}
