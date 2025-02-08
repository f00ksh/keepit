// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:keepit/domain/models/note.dart';
// import 'package:keepit/presentation/providers/note_view_provider.dart';
// import 'package:keepit/presentation/providers/notes_provider.dart';

// class NoteViewAppBar extends ConsumerWidget {
//   final Note note;
//   final String noteId;

//   const NoteViewAppBar({
//     super.key,
//     required this.note,
//     required this.noteId,
//   });

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => Navigator.pop(context),
//           ),
//           actions: [
//             IconButton(
//               icon: Icon(
//                   note.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
//               onPressed: () =>
//                   ref.read(noteViewProvider(noteId).notifier).togglePinned(),
//             ),
//             IconButton(
//               icon: Icon(
//                   note.isFavorite ? Icons.favorite : Icons.favorite_border),
//               onPressed: () =>
//                   ref.read(noteViewProvider(noteId).notifier).toggleFavorite(),
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: () async {
//                 final confirmed = await _showDeleteDialog(context);
//                 if (confirmed) {
//                   ref.read(notesProvider.notifier).deleteNote(noteId);
//                   if (context.mounted) Navigator.pop(context);
//                 }
//               },
//             ),
//           ],
//         ));
//   }

//   Future<bool> _showDeleteDialog(BuildContext context) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Note?'),
//         content: const Text('This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );
//     return confirmed == true;
//   }
// }
