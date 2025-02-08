import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/presentation/providers/filtered_notes_provider.dart';
import 'package:keepit/presentation/widgets/base_notes_page.dart';
import 'package:keepit/presentation/widgets/note_grid.dart';
import 'package:keepit/presentation/widgets/sliver_empty_state.dart';

class ArchivePage extends ConsumerWidget {
  const ArchivePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedNotes = ref.watch(archivedNotesProvider);

    return BaseNotesPage(
      title: 'Archive',
      content: archivedNotes.when(
        data: (notes) => notes.isEmpty
            ? const SliverEmptyState(
                message: 'No archived notes',
                icon: Icons.archive_outlined,
              )
            : NoteGrid(notes: notes),
        loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => SliverToBoxAdapter(
          child: Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
