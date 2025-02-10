import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/presentation/widgets/theme_color_picker.dart';
import 'package:uuid/uuid.dart';

class AddNotePage extends ConsumerStatefulWidget {
  const AddNotePage({super.key});

  @override
  ConsumerState<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends ConsumerState<AddNotePage> {
  late Note _note;
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _note = Note(
      id: const Uuid().v4(),
      title: '',
      content: '',
      colorIndex: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getNoteColor(context, _note.colorIndex);

    return Scaffold(
      backgroundColor: color,
      appBar: _buildAppBar(context),
      body: _buildContent(context),
      bottomNavigationBar: _buildColorPicker(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => _saveAndExit(context),
      ),
      actions: [
        IconButton(
          icon: Icon(_note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
          onPressed: () => setState(() {
            _note = _note.copyWith(isPinned: !_note.isPinned);
          }),
        ),
        IconButton(
          icon: Icon(_note.isFavorite ? Icons.favorite : Icons.favorite_border),
          onPressed: () => setState(() {
            _note = _note.copyWith(isFavorite: !_note.isFavorite);
          }),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration.collapsed(
              hintText: 'Title',
            ),
            style: Theme.of(context).textTheme.headlineSmall,
            maxLines: 1,
            onChanged: (value) => setState(() {
              _note = _note.copyWith(
                title: value,
                updatedAt: DateTime.now(),
              );
            }),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _contentController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Start writing...',
              ),
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: null,
              expands: true,
              onChanged: (value) => setState(() {
                _note = _note.copyWith(
                  content: value,
                  updatedAt: DateTime.now(),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ThemeColorPicker(
        selectedIndex: _note.colorIndex,
        onColorSelected: (index) => setState(() {
          _note = _note.copyWith(
            colorIndex: index,
            updatedAt: DateTime.now(),
          );
        }),
      ),
    );
  }

  Color _getNoteColor(BuildContext context, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppTheme.darkColors : AppTheme.lightColors;
    return colors[index];
  }

  void _saveAndExit(BuildContext context) async {
    // Only save if there's actual content
    if (_note.title.isNotEmpty || _note.content.isNotEmpty) {
      try {
        await ref.read(notesProvider.notifier).addNote(_note);
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
