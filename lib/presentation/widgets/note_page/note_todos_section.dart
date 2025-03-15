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
  bool _todoListExpanded = true;

  @override
  Widget build(BuildContext context) {
    if (widget.note.todos.isEmpty) return const SizedBox.shrink();

    final sortedTodos = List<TodoItem>.from(widget.note.todos)
      ..sort((a, b) => a.index.compareTo(b.index));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
          shadowColor: Colors.transparent,
          colorScheme: Theme.of(context).colorScheme.copyWith(
                surface: Colors.transparent,
              ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(sortedTodos),
            if (_todoListExpanded) ...[
              _buildTodoList(sortedTodos),
              _buildAddTodoButton(),
            ] else
              const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(List<TodoItem> todos) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () => setState(() => _todoListExpanded = !_todoListExpanded),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 4.0,
          top: 16.0,
          bottom: 8.0,
          right: 4.0,
        ),
        child: Row(
          children: [
            Text(
              'Tasks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.15,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const Spacer(),
            AnimatedRotation(
              turns: _todoListExpanded ? 0 : -0.25,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Icon(
                Icons.expand_more,
                size: 24,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              '${todos.where((todo) => todo.isDone).length}/${todos.length}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoList(List<TodoItem> todos) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return Container(
            key: ValueKey(todo.id),
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
          );
        },
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          ref
              .read(notesProvider.notifier)
              .reorderTodos(widget.note.id, oldIndex, newIndex);
          widget.onChanged();
        },
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return Material(
                elevation: animation.value * 6.0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: child,
              );
            },
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildAddTodoButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          ref.read(notesProvider.notifier).addTodo(widget.note.id, '');
          widget.onChanged();
        },
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Add item',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
