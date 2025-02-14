import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/routes/app_router.dart';

import 'package:keepit/presentation/providers/filtered_notes_provider.dart';
import 'package:keepit/presentation/providers/reorder_cache_provider.dart';
import 'package:keepit/presentation/widgets/note_card.dart';
import 'package:keepit/src/drag_callbacks.dart';

import 'package:keepit/src/drag_masonryview.dart';
import 'package:keepit/src/models.dart';

class ReorderableGrid extends ConsumerWidget {
  static const String _tag = 'ReorderableGrid';
  const ReorderableGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(mainNotesProvider);
    final reorderedNotes = ref.watch(reorderCacheProvider);
    debugPrint('$_tag: Building widget with async notes');

    return SliverToBoxAdapter(
      child: notesAsync.when(
        loading: () {
          debugPrint('$_tag: Loading state');
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          debugPrint('$_tag: Error state: $error');
          return Center(child: Text('Error: $error'));
        },
        data: (notes) {
          debugPrint('$_tag: Received ${notes.length} notes');
          // Calculate dynamic crossAxisCount based on screen width
          final screenWidth = MediaQuery.of(context).size.width;
          final cardWidth =
              200; // Adjust this value based on your NoteCard width
          final crossAxisCount = (screenWidth / cardWidth).floor();
          debugPrint('$_tag: Calculated crossAxisCount: $crossAxisCount');

          // Use reordered notes if available, otherwise use original notes
          final displayNotes = reorderedNotes ?? notes;

          return DragMasonryGrid(
            dragCallbacks: DragCallbacks(
              onWillAccept: (moveData, data, isFront, {acceptDetails}) {
                return true;
              },
              onAccept: (moveData, data, isFront, {acceptDetails}) {
                if (moveData == null || acceptDetails == null) return;

                // Get the actual indices from the acceptDetails
                final oldIndex = acceptDetails.oldIndex;
                final newIndex = acceptDetails.newIndex;

                debugPrint('$_tag: Moving note from $oldIndex to $newIndex');

                if (oldIndex != newIndex) {
                  // Only update the cache, don't persist yet
                  ref.read(reorderCacheProvider.notifier).handleReorder(
                        oldIndex,
                        newIndex,
                      );
                }
              },
              onMove: (data, details, isFront) {
                debugPrint(
                    '$_tag: Moved over item: ${data.key}, isFront: $isFront');
              },
              onLeave: (moveData, data, isFront) {
                debugPrint(
                    '$_tag: Left item: ${data.key}, moved item: ${moveData?.key}, isFront: $isFront');
              },
              onDragStarted: (data) {
                debugPrint('$_tag: Drag started for item: ${data.key}');
              },
              onDragUpdate: (details, data) {
                debugPrint('$_tag: Drag updated item: ${data.key}');
              },
              onDragEnd: (details, item) {
                debugPrint(
                    '$_tag: Drag ended for item: ${item.key}, details: $details');
              },
              onDraggableCanceled: (velocity, offset, data) {
                debugPrint(
                    '$_tag: Drag cancelled for item: ${data.key}, velocity: $velocity, offset: $offset');
              },
            ),
            isDragNotification: true,
            isLongPressDraggable: true,
            draggingWidgetOpacity: 0,
            enableReordering: true,
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: displayNotes.asMap().entries.map((entry) {
              final note = entry.value;
              return DragGridExtentItem(
                key: ValueKey('${note.id}_${note.index}'),
                widget: NoteCard(
                  note: note,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.note,
                    arguments: note.id,
                  ),
                ),
                mainAxisExtent: 200,
                crossAxisCellCount: 1,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
