// add_note_provider.dart
import 'package:keepit/core/constants/app_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/note.dart';

part 'add_note_provider.g.dart';

@riverpod
class AddNote extends _$AddNote {
  @override
  Note build() {
    return Note(
      id: const Uuid().v4(),
      title: '',
      content: '',
      colorIndex: AppConstants.defaultNoteColorIndex,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPinned: false,
      isFavorite: false,
      isArchived: false,
      isDeleted: false,
    );
  }

  void updateTitle(String title) {
    state = state.copyWith(
      title: title,
      updatedAt: DateTime.now(),
    );
  }

  void updateContent(String content) {
    state = state.copyWith(
      content: content,
      updatedAt: DateTime.now(),
    );
  }

  void togglePinned() {
    state = state.copyWith(
      isPinned: !state.isPinned,
      updatedAt: DateTime.now(),
    );
  }

  void toggleFavorite() {
    state = state.copyWith(
      isFavorite: !state.isFavorite,
      updatedAt: DateTime.now(),
    );
  }

  void updateColor(int colorIndex) {
    state = state.copyWith(
      colorIndex: colorIndex,
      updatedAt: DateTime.now(),
    );
  }
}
