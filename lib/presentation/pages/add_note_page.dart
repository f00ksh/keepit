// add_note_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/data/providers/storage_providers.dart';
import 'package:keepit/presentation/providers/add_note_provider.dart';
import 'package:keepit/presentation/providers/notes_provider.dart';
import 'package:keepit/presentation/widgets/theme_color_picker.dart';

class AddNotePage extends ConsumerWidget {
  const AddNotePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(addNoteProvider);
    final color = _getNoteColor(context, note.colorIndex);

    return Scaffold(
      backgroundColor: color,
      appBar: _buildAppBar(context, ref),
      body: _buildContent(context, ref),
      bottomNavigationBar: _buildColorPicker(context, ref),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _saveAndExit(context, ref),
      ),
      actions: [
        IconButton(
          icon: Icon(ref.watch(addNoteProvider).isPinned
              ? Icons.push_pin
              : Icons.push_pin_outlined),
          onPressed: () => ref.read(addNoteProvider.notifier).togglePinned(),
        ),
        IconButton(
          icon: Icon(ref.watch(addNoteProvider).isFavorite
              ? Icons.favorite
              : Icons.favorite_border),
          onPressed: () => ref.read(addNoteProvider.notifier).toggleFavorite(),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            autofocus: true,
            decoration: const InputDecoration.collapsed(
              hintText: 'Title',
            ),
            style: Theme.of(context).textTheme.headlineSmall,
            maxLines: 1,
            onChanged: (value) =>
                ref.read(addNoteProvider.notifier).updateTitle(value),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              decoration: const InputDecoration.collapsed(
                hintText: 'Start writing...',
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: null,
              expands: true,
              onChanged: (value) =>
                  ref.read(addNoteProvider.notifier).updateContent(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ThemeColorPicker(
        selectedIndex: ref.watch(addNoteProvider).colorIndex,
        onColorSelected: (index) =>
            ref.read(addNoteProvider.notifier).updateColor(index),
      ),
    );
  }

  Color _getNoteColor(BuildContext context, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppTheme.darkColors : AppTheme.lightColors;
    return colors[index];
  }

  void _saveAndExit(BuildContext context, WidgetRef ref) async {
    final note = ref.read(addNoteProvider);

    // Only save if there's actual content
    if (note.title.isNotEmpty || note.content.isNotEmpty) {
      try {
        // First, save to Supabase
        final savedNote =
            await ref.read(supabaseServiceProvider).createNote(note);

        // Then save locally
        await ref.read(storageServiceProvider).addNote(savedNote);

        // Invalidate the notes provider to refresh the list
        ref.invalidate(notesProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note saved successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving note: $e')),
          );
        }
      }
    }

    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}
