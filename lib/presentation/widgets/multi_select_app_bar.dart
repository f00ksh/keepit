import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/presentation/providers/multi_select_provider.dart';

class MultiSelectAppBar extends ConsumerWidget {
  const MultiSelectAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final multiSelectState = ref.watch(multiSelectNotifierProvider);

    return SliverAppBar(
      backgroundColor: Theme.of(context)
          .colorScheme
          .secondaryContainer
          .withValues(alpha: .5),
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: Hero(
        tag: 'search_bar',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                // Close button
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref
                        .read(multiSelectNotifierProvider.notifier)
                        .clearSelections();
                  },
                ),

                // Selected count
                Expanded(
                  child: Text(
                    '${multiSelectState.selectedNoteIds.length} selected',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),

                // Action buttons
                Row(children: [
                  IconButton(
                    icon: const Icon(Icons.push_pin_outlined),
                    onPressed: () {
                      final selectedIds = multiSelectState.selectedNoteIds;
                      if (selectedIds.isNotEmpty) {
                        // Toggle pin status for all selected notes
                        final notesNotifier = ref.read(notesProvider.notifier);
                        final allNotes = ref.read(notesProvider);
                        final selectedNotes = allNotes
                            .where((note) => selectedIds.contains(note.id))
                            .toList();

                        // Check if all selected notes are pinned
                        final allPinned =
                            selectedNotes.every((note) => note.isPinned);

                        // Toggle pin status based on current state
                        for (final note in selectedNotes) {
                          notesNotifier.updateNoteStatus(
                            note.id,
                            isPinned: !allPinned,
                          );
                        }

                        // Clear selections after action
                        ref
                            .read(multiSelectNotifierProvider.notifier)
                            .clearSelections();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      final selectedIds = multiSelectState.selectedNoteIds;
                      if (selectedIds.isNotEmpty) {
                        final notesNotifier = ref.read(notesProvider.notifier);

                        // Move all selected notes to trash
                        for (final id in selectedIds) {
                          notesNotifier.updateNoteStatus(id, isDeleted: true);
                        }

                        // Show snackbar with undo option
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${selectedIds.length} notes moved to trash'),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () {
                                for (final id in selectedIds) {
                                  notesNotifier.updateNoteStatus(id,
                                      isDeleted: false);
                                }
                              },
                            ),
                          ),
                        );

                        // Clear selections after action
                        ref
                            .read(multiSelectNotifierProvider.notifier)
                            .clearSelections();
                      }
                    },
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
