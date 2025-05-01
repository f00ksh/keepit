import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/routes/app_router.dart';
import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/providers/filtered_notes_provider.dart';
import 'package:keepit/presentation/providers/multi_select_provider.dart';
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

    // Track position changes
    bool positionChanged = false;
    bool leftPosition = false;

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
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 4.0),
            child: Text(
              'Pinned',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          // Pinned notes grid
          _buildGrid(
            context,
            ref,
            pinnedNotes,
            crossAxisCount,
            true,
            positionChanged,
            leftPosition,
          ),
        ],

        // Only show unpinned section header if there are pinned notes
        if (pinnedNotes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 4.0),
            child: Text(
              'All',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

        // Unpinned notes grid
        _buildGrid(
            context, ref, unpinnedNotes, crossAxisCount, false, positionChanged)
      ]),
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, List<Note> notes,
      int crossAxisCount, bool isPinned,
      [bool positionChanged = false, bool leftPosition = false]) {
    return DragMasonryGrid(
      dragChildBoxDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).colorScheme.primary,
      ),
      dragCallbacks: DragCallbacks(
        onLeave: (moveData, data, isFront) {
          leftPosition = true;
        },
        onAccept: (moveData, data, isFront, {acceptDetails}) {
          if (moveData == null || acceptDetails == null) return;
          final oldIndex = acceptDetails.oldIndex;
          final newIndex = acceptDetails.newIndex;

          if (oldIndex != newIndex) {
            // Position has changed
            positionChanged = true;

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
        onDragEnd: (details, data) {
          // Check if position changed or left position
          if (positionChanged || leftPosition) {
            // Position was changed, do something
            return;
          } else {
            // Get the note ID from the key
            final noteId = (data.key as ValueKey).value.toString();

            // Toggle multi-select mode and select this note
            final multiSelectNotifier =
                ref.read(multiSelectNotifierProvider.notifier);
            if (!ref.read(multiSelectNotifierProvider).isMultiSelectMode) {
              multiSelectNotifier.toggleMultiSelectMode();
            }
            multiSelectNotifier.toggleNoteSelection(noteId);
          }
          // Reset the flag
          positionChanged = false;
          leftPosition = false;
        },
      ),
      edgeScrollSpeedMilliseconds: 300,
      edgeScroll: .3,
      isDragNotification: true,
      draggingWidgetOpacity: 0,
      enableReordering:
          (!ref.read(multiSelectNotifierProvider).isMultiSelectMode),
      crossAxisCount: crossAxisCount,
      children: notes.asMap().entries.map(
        (entry) {
          final note = entry.value;
          return DragMasonryItem(
            key: ValueKey(note.id),
            widget: NoteCard(
              note: note,
              onTap: () {
                // Check if in multi-select mode
                final multiSelectState = ref.read(multiSelectNotifierProvider);
                if (multiSelectState.isMultiSelectMode) {
                  // Toggle selection of this note
                  ref
                      .read(multiSelectNotifierProvider.notifier)
                      .toggleNoteSelection(note.id);
                } else {
                  // Force close any existing snackbars
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  Navigator.pushNamed(
                    context,
                    AppRoutes.note,
                    arguments: note.id,
                  );
                }
              },
              isSelected: ref
                  .watch(multiSelectNotifierProvider)
                  .selectedNoteIds
                  .contains(note.id),
              enableDismiss:
                  (!ref.read(multiSelectNotifierProvider).isMultiSelectMode),
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
