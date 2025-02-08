import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/widgets/note_grid.dart';
import 'package:keepit/presentation/widgets/reorderable_grid.dart';
import 'package:keepit/presentation/widgets/sliver_empty_state.dart';

class AsyncNoteGrid extends ConsumerWidget {
  final AsyncValue<List<Note>> notes;
  final String emptyMessage;
  final IconData emptyIcon;
  final bool useReorderable;

  const AsyncNoteGrid({
    super.key,
    required this.notes,
    required this.emptyMessage,
    required this.emptyIcon,
    this.useReorderable = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return notes.when(
      data: (notes) => notes.isEmpty
          ? SliverEmptyState(
              message: emptyMessage,
              icon: emptyIcon,
            )
          : useReorderable
              ? ReorderableGrid(notes: notes)
              : NoteGrid(notes: notes),
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: Center(child: Text('Error: $error')),
      ),
    );
  }
}
