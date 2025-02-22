import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/routes/app_router.dart';
import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/providers/filtered_notes_provider.dart';
import 'package:keepit/presentation/widgets/note_card.dart';
import 'package:keepit/src/drag_callbacks.dart';
import 'package:keepit/src/drag_masonryview.dart';
import 'package:keepit/src/models.dart';

class ReorderableGrid extends ConsumerWidget {
  const ReorderableGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(mainNotesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount =
        screenWidth < 600 ? 2 : max(3, (screenWidth / 200).floor());

    return SliverToBoxAdapter(
        child: DragMasonryGrid(
      dragCallbacks: DragCallbacks(
        onAccept: (moveData, data, isFront, {acceptDetails}) {
          if (moveData == null || acceptDetails == null) return;
          final oldIndex = acceptDetails.oldIndex;
          final newIndex = acceptDetails.newIndex;

          if (oldIndex != newIndex) {
            final updatedNotes = List<Note>.from(notes);
            final item = updatedNotes.removeAt(oldIndex);
            // Adjust newIndex if moving item forward
            final adjustedNewIndex =
                newIndex > oldIndex ? newIndex - 1 : newIndex;
            updatedNotes.insert(adjustedNewIndex, item);

            // Update indices and persist changes directly
            final notesToUpdate = updatedNotes.asMap().entries.map((entry) {
              return entry.value.copyWith(
                index: entry.key,
              );
            }).toList();

            ref.read(notesProvider.notifier).updateBatchNotes(notesToUpdate);
          }
        },
      ),
      edgeScrollSpeedMilliseconds: 200,
      edgeScroll: .35,
      isDragNotification: true,
      isLongPressDraggable: true,
      draggingWidgetOpacity: 0,
      enableReordering: true,
      crossAxisCount: crossAxisCount,
      children: notes.asMap().entries.map(
        (entry) {
          final note = entry.value;
          return DragMasonryItem(
            key: ValueKey('${note.id}_${note.index}'),
            widget: NoteCard(
              note: note,
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.note,
                arguments: note.id,
              ),
            ),
            crossAxisCellCount: 1,
          );
        },
      ).toList(),
    ));
  }
}
