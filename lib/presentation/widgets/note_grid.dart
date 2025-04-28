import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/providers/multi_select_provider.dart';
import 'package:keepit/presentation/widgets/note_card.dart';
import 'package:keepit/core/routes/app_router.dart';

class NoteGrid extends ConsumerWidget {
  final List<Note> notes;

  const NoteGrid({
    super.key,
    required this.notes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: MasonryGridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteCard(
              key: ValueKey(note.id),
              note: note,
              isSelected: ref
                  .watch(multiSelectNotifierProvider)
                  .selectedNoteIds
                  .contains(note.id),
              onTap: () {
                // Check if in multi-select mode
                final multiSelectState = ref.read(multiSelectNotifierProvider);
                if (multiSelectState.isMultiSelectMode) {
                  // Toggle selection of this note
                  ref
                      .read(multiSelectNotifierProvider.notifier)
                      .toggleNoteSelection(note.id);
                } else {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.note,
                    arguments: {
                      'noteId': note.id,
                      'heroTag': 'note_${note.id}',
                    },
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }
}
