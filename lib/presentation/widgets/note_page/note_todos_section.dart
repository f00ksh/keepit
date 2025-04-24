import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/domain/models/todo_item.dart';
import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/presentation/widgets/note_page/todo_item_widget.dart';

class NoteTodosSection extends ConsumerStatefulWidget {
  final Note note;
  final Function() onChanged;

  const NoteTodosSection({
    super.key,
    required this.note,
    required this.onChanged,
  });

  @override
  ConsumerState<NoteTodosSection> createState() => _NoteTodosSectionState();
}

class _NoteTodosSectionState extends ConsumerState<NoteTodosSection> {
  // Track if we're currently reordering to prevent focus issues
  // ignore: unused_field
  bool _isReordering = false;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint("todos rebuild");
    }

    // Only watch the todos list from the note
    final todos = ref.watch(notesProvider.select(
        (state) => state.firstWhere((n) => n.id == widget.note.id).todos));

    if (todos.isEmpty) return const SizedBox.shrink();

    final sortedTodos = List<TodoItem>.from(todos)
      ..sort((a, b) => a.index.compareTo(b.index));

    // Create the list of widgets for the ReorderableListView
    final List<Widget> todoWidgets = [];
    for (int index = 0; index < sortedTodos.length; index++) {
      final todo = sortedTodos[index];
      todoWidgets.add(
        SizedBox(
          key: ValueKey(todo.id), // Use ValueKey for more stable identification
          height: 56.0, // Fixed height for better performance
          child: TodoItemWidget(
            todo: todo,
            note: widget.note,
            index: index,
            onContentChanged: (newContent) {
              if (newContent != todo.content) {
                ref.read(notesProvider.notifier).updateTodo(
                      widget.note.id,
                      todo.id,
                      content: newContent,
                    );
                widget.onChanged();
              }
            },
            onCheckboxChanged: (checked) {
              ref.read(notesProvider.notifier).updateTodo(
                    widget.note.id,
                    todo.id,
                    isDone: checked,
                  );
              widget.onChanged();
            },
            onDelete: () {
              ref
                  .read(notesProvider.notifier)
                  .deleteTodo(widget.note.id, todo.id);
              widget.onChanged();
            },
          ),
        ),
      );
    }

    // Add the footer button
    todoWidgets.add(
      TextButton.icon(
        key: const ValueKey('add_todo_button'),
        onPressed: () {
          ref.read(notesProvider.notifier).addTodo(widget.note.id, '');
          widget.onChanged();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
    );

    // Use ReorderableListView with improved handling
    return ReorderableListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: todoWidgets,
      onReorderStart: (index) {
        // Set reordering flag to true when reordering starts
        setState(() {
          _isReordering = true;
        });
        // Unfocus any text fields
        FocusScope.of(context).unfocus();
      },
      onReorderEnd: (index) {
        // Set reordering flag to false when reordering ends
        setState(() {
          _isReordering = false;
        });
      },
      onReorder: (oldIndex, newIndex) {
        // Don't allow reordering the footer
        if (oldIndex >= sortedTodos.length || newIndex > sortedTodos.length) {
          return;
        }

        if (oldIndex < newIndex) {
          newIndex -= 1;
        }

        ref
            .read(notesProvider.notifier)
            .reorderTodos(widget.note.id, oldIndex, newIndex);
        widget.onChanged();
      },
      proxyDecorator: (child, index, animation) {
        // Simple proxy decorator that doesn't add complexity
        return child;
      },
    );
  }
}
