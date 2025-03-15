import 'package:flutter/material.dart';
import 'package:keepit/core/routes/app_router.dart';
import 'package:keepit/core/transitions/container_transition.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/presentation/pages/note_page.dart';

class TransitionUtils {
  // Navigate from FAB to note page with container transition
  static void navigateToNoteFromFab(BuildContext context, String noteId,
      NoteType noteType, GlobalKey fabKey) {
    final RenderBox? renderBox =
        fabKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      // Fallback to regular navigation
      Navigator.pushNamed(
        context,
        AppRoutes.addNote,
        arguments: {
          'noteId': noteId,
          'initialNoteType': noteType,
        },
      );
      return;
    }

    final fabPosition = renderBox.localToGlobal(Offset.zero);
    final fabSize = renderBox.size;
    final fabRect = Rect.fromLTWH(
        fabPosition.dx, fabPosition.dy, fabSize.width, fabSize.height);

    final fabWidget = FloatingActionButton(
      heroTag: 'add_note_fab',
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
      onPressed: () {},
      child: const Icon(Icons.add),
    );

    Navigator.push(
      context,
      ContainerTransitionRoute(
        backgroundColor: Theme.of(context).colorScheme.surface,
        openingWidget: fabWidget,
        openingRect: fabRect,
        builder: (context) => NotePage(
          noteId: noteId,
          heroTag: 'add_note_fab',
          initialNoteType: noteType,
        ),
      ),
    );
  }

  // Navigate from note card to note page with container transition
  static void navigateToNoteFromCard(BuildContext context, String noteId,
      String heroTag, NoteType noteType, GlobalKey cardKey, Widget cardWidget) {
    final RenderBox? renderBox =
        cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      // Fallback to regular navigation
      Navigator.pushNamed(
        context,
        AppRoutes.note,
        arguments: {
          'noteId': noteId,
          'initialNoteType': noteType,
        },
      );
      return;
    }

    final cardPosition = renderBox.localToGlobal(Offset.zero);
    final cardSize = renderBox.size;
    final cardRect = Rect.fromLTWH(
        cardPosition.dx, cardPosition.dy, cardSize.width, cardSize.height);

    Navigator.push(
      context,
      ContainerTransitionRoute(
        backgroundColor: Theme.of(context).colorScheme.surface,
        openingWidget: cardWidget,
        openingRect: cardRect,
        builder: (context) => NotePage(
          noteId: noteId,
          heroTag: heroTag,
          initialNoteType: noteType,
        ),
      ),
    );
  }
}
