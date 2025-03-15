import 'package:flutter/material.dart';

class NoteContentSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final Function(String) onTitleChanged;
  final Function(String) onContentChanged;

  const NoteContentSection({
    super.key,
    required this.titleController,
    required this.contentController,
    required this.onTitleChanged,
    required this.onContentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: 'Title',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          style: Theme.of(context).textTheme.titleLarge,
          onChanged: onTitleChanged,
        ),
        TextField(
          controller: contentController,
          decoration: const InputDecoration(
            hintText: 'Start writing...',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          onChanged: onContentChanged,
        ),
      ],
    );
  }
}
