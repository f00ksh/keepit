import 'package:flutter/material.dart';
import 'package:keepit/core/routes/app_router.dart';

class AddNoteButton extends StatelessWidget {
  final String? heroTag;

  const AddNoteButton({super.key, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: () {
        Navigator.pushNamed(context, AppRoutes.addNote);
      },
      child: const Icon(Icons.add),
    );
  }
}
