import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/data/providers/notes_provider.dart';

part 'local_notes_provider.g.dart';

@riverpod
class LocalNotes extends _$LocalNotes {
  @override
  List<Note> build() {
    // Watch the main notes provider only for initial data
    final notesAsync = ref.watch(notesProvider);
    return notesAsync.when(
      data: (notes) =>
          List.from(notes)..sort((a, b) => a.order.compareTo(b.order)),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  void reorderNotes(int oldIndex, int newIndex) {
    final List<Note> oldList = [...state];
    final movedNote = oldList.removeAt(oldIndex);
    oldList.insert(newIndex, movedNote);

    // Update each note's order property based on its new position.
    final updatedNotes = List<Note>.generate(oldList.length, (index) {
      final note = oldList[index];
      // Assuming your Note has a copyWith method.
      return note.copyWith(order: index);
    });

    state = updatedNotes;

    // Optionally, persist the updated order.
    _persistChanges(updatedNotes);
  }

  Future<void> _persistChanges(List<Note> updates) async {
    try {
      await ref.read(notesProvider.notifier).updateBatchNotes(updates);
    } catch (e) {
      // Handle error if needed
    }
  }
}
