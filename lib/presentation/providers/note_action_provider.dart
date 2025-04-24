import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'note_action_provider.g.dart';

class NoteAction {
  final String noteId;
  final bool? isPinned;
  final bool? isFavorite;
  final bool? isArchived;
  final bool? isDeleted;

  NoteAction({
    required this.noteId,
    this.isPinned,
    this.isFavorite,
    this.isArchived,
    this.isDeleted,
  });
}

@riverpod
class NoteActionNotifier extends _$NoteActionNotifier {
  @override
  NoteAction? build() {
    return null;
  }

  void updateNoteAction(NoteAction? action) {
    state = action;
  }
}
