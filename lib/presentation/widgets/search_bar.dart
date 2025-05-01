import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/data/providers/auth_provider.dart';
import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/presentation/providers/multi_select_provider.dart';

class AppSearchBar extends ConsumerWidget {
  const AppSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final colorScheme = Theme.of(context).colorScheme;
    final multiSelectState = ref.watch(multiSelectNotifierProvider);

    // Create the action bar content
    var actionBarContent = Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(multiSelectNotifierProvider.notifier).clearSelections();
            },
          ),

          // Selected count
          Expanded(
            child: Text('${multiSelectState.selectedNoteIds.length}',
                style: Theme.of(context).textTheme.bodyLarge),
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
                      content:
                          Text('${selectedIds.length} notes moved to trash'),
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
          ])
        ],
      ),
    );

    // Create the search bar content
    var searchBarContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Hero(
            tag: 'search_bar',
            child: Material(
              elevation: 5,
              shadowColor: Colors.transparent,
              borderRadius: BorderRadius.circular(28),
              surfaceTintColor: colorScheme.surfaceTint,
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/search'),
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  height: 47,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  child: Row(
                    children: [
                      // Menu Icon
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),

                      // Search Hint Text
                      Expanded(
                        child: Text(
                          'Search notes...',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),

                      // Profile Picture
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed('/settings');
                          },
                          customBorder: const CircleBorder(),
                          child: user?.photoUrl != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(user!.photoUrl!),
                                  radius: 16,
                                )
                              : CircleAvatar(
                                  backgroundColor:
                                      colorScheme.tertiaryContainer,
                                  radius: 16,
                                  child: Text(
                                    user?.name?.substring(0, 1).toUpperCase() ??
                                        'G',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    // Return a SliverAppBar with AnimatedSwitcher for animation
    return SliverAppBar(
      floating: true,
      snap: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 250),
            color: multiSelectState.isMultiSelectMode
                ? colorScheme.secondaryContainer
                : Colors.transparent,
          ),
          AnimatedSize(
            alignment: Alignment.bottomCenter,
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: 300),
            child: multiSelectState.isMultiSelectMode
                ? actionBarContent
                : searchBarContent,
          ),
        ],
      ),
    );
  }
}
