import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:keepit/domain/models/note.dart';
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
    return SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: NoteCard(
            key: ValueKey(note.id),
            note: note,
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.note,
              arguments: note.id,
            ),
          ),
        );
      },
      childCount: notes.length,
    );
  }
}
