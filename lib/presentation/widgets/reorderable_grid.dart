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
    // Use select to only watch the notes we need
    final notes = ref.watch(mainNotesProvider.select((notes) => notes));

    // Separate pinned and unpinned notes
    final pinnedNotes = notes.where((note) => note.isPinned).toList();
    final unpinnedNotes = notes.where((note) => !note.isPinned).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount =
        screenWidth < 600 ? 2 : max(3, (screenWidth / 200).floor());

    return SliverList(
      delegate: SliverChildListDelegate([
        // Only show pinned section if there are pinned notes
        if (pinnedNotes.isNotEmpty) ...[
          // Pinned section header
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
            child: Text(
              'Pinned',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          // Pinned notes grid
          _buildGrid(context, ref, pinnedNotes, crossAxisCount, true),
        ],

        // Only show unpinned section header if there are pinned notes
        if (pinnedNotes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 4.0),
            child: Text(
              'All',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

        // Unpinned notes grid
        _buildGrid(context, ref, unpinnedNotes, crossAxisCount, false),
      ]),
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, List<Note> notes,
      int crossAxisCount, bool isPinned) {
    return DragMasonryGrid(
      dragCallbacks: DragCallbacks(
        onAccept: (moveData, data, isFront, {acceptDetails}) {
          if (moveData == null || acceptDetails == null) return;
          final oldIndex = acceptDetails.oldIndex;
          final newIndex = acceptDetails.newIndex;

          if (oldIndex != newIndex) {
            // Get all main notes to ensure we update both sections properly
            final allNotes = ref.read(mainNotesProvider);
            final pinnedNotes =
                allNotes.where((note) => note.isPinned).toList();
            final unpinnedNotes =
                allNotes.where((note) => !note.isPinned).toList();

            // Update the specific section being reordered
            final updatedSectionNotes = List<Note>.from(notes);
            final item = updatedSectionNotes.removeAt(oldIndex);
            updatedSectionNotes.insert(newIndex, item);

            // Create a list to hold all notes that need updating
            final List<Note> notesToUpdate = [];

            // Update indices for the section being reordered
            notesToUpdate
                .addAll(updatedSectionNotes.asMap().entries.map((entry) {
              return entry.value.copyWith(
                index: entry.key,
                isPinned: isPinned, // Ensure pinned status is maintained
              );
            }));

            // Add the other section's notes without changing their indices
            if (isPinned) {
              // We're reordering pinned notes, so add unpinned notes unchanged
              notesToUpdate.addAll(unpinnedNotes);
            } else {
              // We're reordering unpinned notes, so add pinned notes unchanged
              notesToUpdate.addAll(pinnedNotes);
            }

            // Update all notes at once
            ref.read(notesProvider.notifier).updateBatchNotes(notesToUpdate);
          }
        },
      ),
      edgeScrollSpeedMilliseconds: 300,
      edgeScroll: .3,
      isDragNotification: true,
      draggingWidgetOpacity: 0,
      enableReordering: true,
      crossAxisCount: crossAxisCount,
      buildFeedback: (listItem, data, size) {
        return Material(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              width: 3,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: data,
        );
      },
      children: notes.asMap().entries.map(
        (entry) {
          final note = entry.value;
          return DragMasonryItem(
            key: ValueKey(note.id),
            widget: NoteCard(
              note: note,
              onTap: () {
                // Force close any existing snackbars
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
                Navigator.pushNamed(
                  context,
                  AppRoutes.note,
                  arguments: note.id,
                );
              },
              enableDismiss: true,
              onDismissed: (direction) {
                ref.read(notesProvider.notifier).updateNoteStatus(
                      note.id,
                      isDeleted: true,
                    );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Note moved to trash'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        ref.read(notesProvider.notifier).updateNoteStatus(
                              note.id,
                              isDeleted: false,
                            );
                      },
                    ),
                  ),
                );
              },
            ),
            crossAxisCellCount: 1,
          );
        },
      ).toList(),
    );
  }
}
