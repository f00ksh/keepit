import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/note.dart';
import '../../data/providers/notes_provider.dart';

part 'reorder_cache_provider.g.dart';

@riverpod
class ReorderCache extends _$ReorderCache {
  static const String _tag = 'ReorderCacheProvider';

  @override
  List<Note>? build() {
    return null;
  }

  void handleReorder(int oldIndex, int newIndex) {
    debugPrint('$_tag: Handling reorder from $oldIndex to $newIndex');

    // Initialize state with current notes if null
    if (state == null) {
      final currentNotes = ref.read(notesProvider).value ?? [];
      state = List.from(currentNotes);
    }

    final updatedNotes = List<Note>.from(state!);
    final item = updatedNotes.removeAt(oldIndex);
    updatedNotes.insert(newIndex, item);

    // Update indices for all affected notes
    state = updatedNotes.asMap().entries.map((entry) {
      return entry.value.copyWith(
        index: entry.key,
        updatedAt: DateTime.now(),
      );
    }).toList();

    debugPrint('$_tag: Reorder completed: $oldIndex -> $newIndex');
  }

  Future<void> persistChanges() async {
    debugPrint('$_tag: Persisting reorder changes');
    if (state == null) return;

    try {
      await ref.read(notesProvider.notifier).updateBatchNotes(state!);
      clearCache();
    } catch (e) {
      debugPrint('$_tag: Error persisting changes: $e');
      rethrow;
    }
  }

  void clearCache() {
    debugPrint('$_tag: Clearing reorder cache');
    state = null;
  }

  bool get hasChanges => state != null;
}
