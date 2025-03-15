import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/core/transitions/transition_utils.dart';
import 'package:keepit/core/utils/error_handler.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/widgets/label_chip.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  const NoteCard({super.key, required this.note, this.onTap});

  @override
  Widget build(BuildContext context) {
    final noteColor = getNoteColor(context, note.colorIndex);
    final cardContent = Padding(
      padding: const EdgeInsets.all(12),
      child: _buildNoteContent(context),
    );

    final heroTag = 'note_${note.id}';
    final cardKey = GlobalKey();

    return Hero(
        tag: heroTag,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  try {
                    if (onTap != null) {
                      onTap!();
                    } else {
                      TransitionUtils.navigateToNoteFromCard(
                        context,
                        note.id,
                        'note_${note.id}',
                        note.noteType,
                        cardKey,
                        this,
                      );
                    }
                  } catch (e) {
                    ErrorHandler.showError(
                      context,
                      ErrorHandler.getErrorMessage(e),
                    );
                  }
                },
                child: noteColor == Theme.of(context).colorScheme.surface
                    ? Card.outlined(
                        elevation: 0,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            cardContent,
                            if (note.labelIds.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  left: 12,
                                  right: 10,
                                  bottom: 15,
                                ),
                                child: NoteLabelsSection(note: note),
                              ),
                          ],
                        ),
                      )
                    : Card(
                        elevation: 0,
                        color: noteColor,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            cardContent,
                            if (note.labelIds.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  left: 10,
                                  right: 10,
                                  bottom: 10,
                                ),
                                child: NoteLabelsSection(note: note),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ));
  }

  /// Builds the note content (title and body).
  Widget _buildNoteContent(BuildContext context) {
    // If note is completely empty (no title, content, or todos)
    if (note.title.isEmpty && note.content.isEmpty && note.todos.isEmpty) {
      return const SizedBox(height: 25);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (note.title.isNotEmpty)
          AutoSizeText(
            note.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: note.content.isNotEmpty ? 1 : 3,
          ),
        if (note.content.isNotEmpty &&
            (note.noteType == NoteType.text || note.todos.isEmpty))
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: AutoSizeText(
              note.content,
              style: const TextStyle(
                fontSize: 14,
              ),
              maxLines: 20,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        // Add static todos section
        if (note.todos.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
          ),
          ...note.todos.take(2).map((todo) => Row(
                children: [
                  Icon(
                    todo.isDone
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      todo.content,
                      style: TextStyle(
                        fontSize: 14,
                        decoration:
                            todo.isDone ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )),
          if (note.todos.length > 2)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                '${note.todos.where((todo) => todo.isDone).length}/${note.todos.length} tasks',
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
