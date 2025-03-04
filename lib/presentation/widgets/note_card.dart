import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/core/utils/error_handler.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/widgets/label_chip.dart';
import 'package:keepit/presentation/widgets/note_hero.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  const NoteCard({super.key, required this.note, this.onTap});

  @override
  Widget build(BuildContext context) {
    final noteColor = getNoteColor(context, note.colorIndex);
    final cardContent = Padding(
      padding: const EdgeInsets.all(12),
      child: _buildNoteContent(),
    );

    final heroTag = 'note_${note.id}';

    return NoteHeroWidget(
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
                    onTap?.call();
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
                                  left: 10,
                                  right: 10,
                                  bottom: 10,
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
  Widget _buildNoteContent() {
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
        if (note.content.isNotEmpty)
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
      ],
    );
  }
}
