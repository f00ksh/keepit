import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/routes/app_router.dart';
import 'package:keepit/presentation/providers/local_notes_provider.dart';
import 'package:keepit/presentation/widgets/note_card.dart';
import 'package:keepit/src/drag_callbacks.dart';
import 'package:keepit/src/drag_masonryview.dart';
import 'package:keepit/src/models.dart';

class ReorderableGrid extends ConsumerWidget {
  const ReorderableGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(localNotesProvider);

    return SliverToBoxAdapter(
      child: DragMasonryGrid(
        dragCallbacks: DragCallbacks(
          onAccept: (moveData, data, isFront, {acceptDetails}) {
            if (moveData != null && acceptDetails != null) {
              ref.read(localNotesProvider.notifier).reorderNotes(
                    acceptDetails.oldIndex,
                    acceptDetails.newIndex,
                  );
            }
          },
        ),
        isDragNotification: true,
        isLongPressDraggable: true,
        draggingWidgetOpacity: 0,
        enableReordering: true,
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        animationDuration: const Duration(milliseconds: 300),
        children: notes
            .map(
              (note) => DragGridExtentItem(
                widget: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: NoteCard(
                    note: note,
                    key: ValueKey(note.id),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.note,
                      arguments: note.id,
                    ),
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
