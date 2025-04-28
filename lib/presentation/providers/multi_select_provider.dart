import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:keepit/domain/models/note.dart';

part 'multi_select_provider.g.dart';

/// Provider that manages the multi-select state for notes
@riverpod
class MultiSelectNotifier extends _$MultiSelectNotifier {
  @override
  MultiSelectState build() {
    return const MultiSelectState();
  }

  /// Toggle multi-select mode
  void toggleMultiSelectMode() {
    if (state.isMultiSelectMode) {
      // If already in multi-select mode, clear selections and exit
      clearSelections();
    } else {
      // Enter multi-select mode without selecting any notes
      state = state.copyWith(isMultiSelectMode: true);
    }
  }

  /// Toggle selection of a note
  void toggleNoteSelection(String noteId) {
    final selectedNotes = {...state.selectedNoteIds};

    if (selectedNotes.contains(noteId)) {
      selectedNotes.remove(noteId);
    } else {
      selectedNotes.add(noteId);
    }

    // If no notes are selected and we're in multi-select mode, exit multi-select mode
    if (selectedNotes.isEmpty && state.isMultiSelectMode) {
      state = const MultiSelectState();
    } else {
      state = state.copyWith(
        selectedNoteIds: selectedNotes,
        isMultiSelectMode: true,
      );
    }
  }

  /// Select a note (entering multi-select mode if not already)
  void selectNote(String noteId) {
    final selectedNotes = {...state.selectedNoteIds};
    selectedNotes.add(noteId);

    state = state.copyWith(
      selectedNoteIds: selectedNotes,
      isMultiSelectMode: true,
    );
  }

  /// Deselect a note
  void deselectNote(String noteId) {
    final selectedNotes = {...state.selectedNoteIds};
    selectedNotes.remove(noteId);

    // If no notes are selected and we're in multi-select mode, exit multi-select mode
    if (selectedNotes.isEmpty) {
      state = const MultiSelectState();
    } else {
      state = state.copyWith(selectedNoteIds: selectedNotes);
    }
  }

  /// Clear all selections and exit multi-select mode
  void clearSelections() {
    state = const MultiSelectState();
  }

  /// Select all notes from a list
  void selectAll(List<Note> notes) {
    final selectedNotes = <String>{};
    for (final note in notes) {
      selectedNotes.add(note.id);
    }

    state = state.copyWith(
      selectedNoteIds: selectedNotes,
      isMultiSelectMode: true,
    );
  }
}

/// State class for multi-select functionality
class MultiSelectState {
  final bool isMultiSelectMode;
  final Set<String> selectedNoteIds;

  const MultiSelectState({
    this.isMultiSelectMode = false,
    this.selectedNoteIds = const {},
  });

  /// Create a copy of this state with the given fields replaced
  MultiSelectState copyWith({
    bool? isMultiSelectMode,
    Set<String>? selectedNoteIds,
  }) {
    return MultiSelectState(
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
      selectedNoteIds: selectedNoteIds ?? this.selectedNoteIds,
    );
  }
}
