import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/widgets/label_chip.dart';
import 'package:keepit/presentation/widgets/color_indicator.dart';
import 'package:keepit/core/theme/text_styles.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final Function(DismissDirection)? onDismissed;

  final bool enableDismiss;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onDismissed,
    this.enableDismiss = false,
  });

  @override
  Widget build(BuildContext context) {
    // debugPrint('NoteCard Build : ${note.id}');
    final noteColor = getNoteColor(context, note.colorIndex);
    final wallpaperPath =
        AppTheme.getNoteWallpaperAssetPath(context, note.wallpaperIndex);
    final heroTag = 'note_${note.id}';

    // Create the image provider directly in build if path exists
    final wallpaperImage = wallpaperPath != null
        ? ResizeImage(
            AssetImage(wallpaperPath),
            width: 600,
            height: 800,
          )
        : null;

    // Precache the image if it exists
    if (wallpaperImage != null) {
      precacheImage(wallpaperImage, context);
    }

    Widget cardContent = Card(
      elevation: 0,
      color: noteColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        // Add border when there's no wallpaper and no color (or color is surface color)
        side: (wallpaperPath == null &&
                (note.colorIndex == AppTheme.noColorIndex ||
                    noteColor == Theme.of(context).colorScheme.surface))
            ? BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50),
          child: Container(
            decoration: wallpaperImage != null
                ? BoxDecoration(
                    image: DecorationImage(
                      image: wallpaperImage,
                      fit: BoxFit.fill,
                      alignment: Alignment.center,
                    ),
                  )
                : null,
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(child: _buildNoteContent(context)),
                  if (note.labelIds.isNotEmpty ||
                      note.colorIndex != AppTheme.noColorIndex)
                    Row(
                      children: [
                        NoteLabelsSection(
                          note: note,
                          onTap: onTap,
                          maxLabelsToShow: 2,
                        ),
                        if (note.wallpaperIndex != 0 &&
                            note.colorIndex != AppTheme.noColorIndex)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: ColorIndicator(
                              colorIndex: note.colorIndex,
                              size: 26,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Wrap with Dismissible if enabled
    if (enableDismiss && onDismissed != null) {
      return Hero(
        tag: heroTag,
        child: Dismissible(
          key: ValueKey('dismiss_${note.id}'),
          onDismissed: onDismissed,
          child: cardContent,
        ),
      );
    }

    // Return regular Hero wrapped card if dismiss not enabled
    return Hero(
      tag: heroTag,
      child: cardContent,
    );
  }

  /// Builds the note content (title and body).
  Widget _buildNoteContent(BuildContext context) {
    if (note.title.isEmpty && note.content.isEmpty && note.todos.isEmpty) {
      return const SizedBox(height: 25);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (note.title.isNotEmpty) ...[
          AutoSizeText(
            note.title,
            style: AppTextStyles.notecardTitleStyle(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
        ],
        if (note.content.isNotEmpty &&
            (note.noteType == NoteType.text || note.todos.isEmpty))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AutoSizeText(
              note.content,
              style: AppTextStyles.notecardContentStyle(context),
              maxLines: 20,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        if (note.todos.isNotEmpty) ...[
          ...note.todos.take(6).map((todo) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      todo.isDone
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurface.withValues(
                            alpha: todo.isDone ? 0.7 : 1,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        todo.content,
                        style: TextStyle(
                          fontSize: 14,
                          decoration:
                              todo.isDone ? TextDecoration.lineThrough : null,
                          color: todo.isDone
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7)
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
          if (note.todos.length > 6) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                '${note.todos.length - 6} more tasks',
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}
