import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/routes/app_router.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/widgets/note_card.dart';
import 'package:keepit/src/drag_callbacks.dart';
import 'package:keepit/src/drag_masonryview.dart';
import 'package:keepit/src/models.dart';

class ReorderableGrid extends ConsumerWidget {
  final List<Note> notes;
  const ReorderableGrid({
    super.key,
    required this.notes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: DragMasonryGrid(
        dragCallbacks: const DragCallbacks(),
        draggingWidgetOpacity: 0,
        enableReordering: true,
        crossAxisCount: 2,
        children: notes
            .map(
              (note) => DragGridExtentItem(
                widget: NoteCard(
                  note: note,
                  key: ValueKey(note.id),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.note,
                    arguments: note,
                  ),
                ),
                key: ValueKey(note.id),
                mainAxisExtent: 200,
                crossAxisCellCount: 2,
              ),
            )
            .toList(),
      ),
    );
  }
}
