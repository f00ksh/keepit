import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/note.dart';
import '../../domain/models/label.dart';

class StorageService {
  static const String _tag = 'StorageService';
  static const String notesBoxName = 'notes';
  static const String labelsBoxName = 'labels';

  late Box<Note> _notesBox;
  late Box<Label> _labelsBox;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();

    // Register all adapters in one place
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }

    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(LabelAdapter());
    }

    try {
      _notesBox = await Hive.openBox<Note>(notesBoxName);
      _labelsBox = await Hive.openBox<Label>(labelsBoxName);
      _isInitialized = true;
      debugPrint(
          '$_tag: Storage service initialized with notes and labels boxes');
    } catch (e) {
      debugPrint('$_tag: Error initializing storage - $e');
      // Try to recover from corruption
      await _recoverFromError();
    }
  }

  Future<void> _recoverFromError() async {
    try {
      await Hive.deleteBoxFromDisk(notesBoxName);
      await Hive.deleteBoxFromDisk(labelsBoxName);
      debugPrint('$_tag: Recovering corrupted boxes');

      _notesBox = await Hive.openBox<Note>(notesBoxName);
      _labelsBox = await Hive.openBox<Label>(labelsBoxName);
      _isInitialized = true;
    } catch (e) {
      debugPrint('$_tag: Failed to recover from error - $e');
      rethrow;
    }
  }

  // Note operations
  Future<List<Note>> getAllNotes() async {
    if (!_isInitialized) {
      await init();
    }
    final notes = _notesBox.values.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    return notes;
  }

  Future<void> addNote(Note note) async {
    if (!_isInitialized) {
      await init();
    }
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
    if (!_isInitialized) {
      await init();
    }
    await _notesBox.put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    if (!_isInitialized) {
      await init();
    }
    await _notesBox.delete(id);
  }

  Future<Note?> getNoteById(String id) async {
    if (!_isInitialized) {
      await init();
    }
    return _notesBox.get(id);
  }

  Future<void> moveToTrash(String id) async {
    if (!_isInitialized) {
      await init();
    }
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
    }
  }

  Future<void> updateBatchNotes(List<Note> notes) async {
    if (!_isInitialized) {
      await init();
    }
    debugPrint('$_tag: Updating batch of ${notes.length} notes');
    await _notesBox.putAll({for (var note in notes) note.id: note});
    debugPrint('$_tag: Successfully saved batch updates');
  }

  Future<void> clearAllNotes() async {
    if (!_isInitialized) {
      await init();
    }
    await _notesBox.clear();
  }

  // Label operations
  Future<List<Label>> getAllLabels() async {
    if (!_isInitialized) {
      await init();
    }
    debugPrint('$_tag: Getting all labels');
    final labels = _labelsBox.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    debugPrint('$_tag: Found ${labels.length} labels');
    return labels;
  }

  Future<void> addLabel(Label label) async {
    if (!_isInitialized) {
      await init();
    }
    debugPrint('$_tag: Adding label: ${label.name} (${label.id})');
    await _labelsBox.put(label.id, label);
    debugPrint('$_tag: Label saved to box');
  }

  Future<void> updateLabel(Label label) async {
    if (!_isInitialized) {
      await init();
    }
    await _labelsBox.put(label.id, label.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> deleteLabel(String id) async {
    if (!_isInitialized) {
      await init();
    }
    await _labelsBox.delete(id);
  }

  Future<Label?> getLabelById(String id) async {
    if (!_isInitialized) {
      await init();
    }
    return _labelsBox.get(id);
  }

  Future<void> clearAllLabels() async {
    if (!_isInitialized) {
      await init();
    }
    await _labelsBox.clear();
  }
}
