import 'package:keepit/domain/models/note.dart';

class ReorderState {
  final List<Note> notes;
  final List<ReorderOperation> operations;

  ReorderState({
    required this.notes,
    this.operations = const [],
  });

  ReorderState copyWith({
    List<Note>? notes,
    List<ReorderOperation>? operations,
  }) {
    return ReorderState(
      notes: notes ?? this.notes,
      operations: operations ?? this.operations,
    );
  }
}

class ReorderOperation {
  final int oldIndex;
  final int newIndex;

  ReorderOperation({required this.oldIndex, required this.newIndex});
}
