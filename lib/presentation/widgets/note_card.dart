import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/core/utils/error_handler.dart';
import 'package:keepit/domain/models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  const NoteCard({super.key, required this.note, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          try {
            onTap?.call();
          } catch (e) {
            ErrorHandler.showError(
              context,
              ErrorHandler.getErrorMessage(e),
            );
          }
        },
        child: SizedBox(
          width: double.infinity,
          child: Card(
            elevation: 0,
            color: getNoteColor(context, note.colorIndex),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _buildNoteContent(),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the note content (title and body).
  Widget _buildNoteContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (note.title.isNotEmpty)
          AutoSizeText(
            note.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: note.content.isNotEmpty ? 1 : 3,
          ),
        if (note.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: AutoSizeText(
              note.content,
              style: const TextStyle(
                fontSize: 16,
              ),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
