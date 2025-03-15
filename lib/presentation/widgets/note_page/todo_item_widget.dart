import 'package:flutter/material.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:keepit/domain/models/todo_item.dart';

class TodoItemWidget extends StatefulWidget {
  final TodoItem todo;
  final Note note;
  final ValueChanged<String> onContentChanged;
  final ValueChanged<bool?> onCheckboxChanged;
  final VoidCallback onDelete;
  final int index;

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.note,
    required this.onContentChanged,
    required this.onCheckboxChanged,
    required this.onDelete,
    required this.index,
  });

  @override
  State<TodoItemWidget> createState() => _TodoItemWidgetState();
}

class _TodoItemWidgetState extends State<TodoItemWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String _localContent = '';
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _localContent = widget.todo.content;
    _controller = TextEditingController(text: _localContent);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });

    // Always save content when focus is lost
    if (!_focusNode.hasFocus && _localContent != widget.todo.content) {
      widget.onContentChanged(_localContent.trim());
    }
  }

  @override
  void didUpdateWidget(TodoItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.todo.content != widget.todo.content &&
        widget.todo.content != _localContent) {
      _localContent = widget.todo.content;
      _controller.text = _localContent;
    }
  }

  @override
  void dispose() {
    // Save content if it has changed before disposing
    if (_localContent != widget.todo.content) {
      widget.onContentChanged(_localContent.trim());
    }
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Following Material 3 card with subtle elevation
    return Card(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: _hasFocus
            ? BorderSide(color: colorScheme.primary.withOpacity(0.3), width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag handle with improved animation
            ReorderableDragStartListener(
              index: widget.index,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _hasFocus ? 0.8 : 0.3,
                child: Icon(
                  Icons.drag_indicator,
                  size: 22,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            // Material 3 checkbox with animation
            SizedBox(
              height: 48,
              child: Center(
                child: Checkbox(
                  value: widget.todo.isDone,
                  onChanged: widget.onCheckboxChanged,
                  activeColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            // Expanded text field with material styling
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    hintText: 'Add task...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    decoration:
                        widget.todo.isDone ? TextDecoration.lineThrough : null,
                    color: widget.todo.isDone
                        ? colorScheme.onSurface.withOpacity(0.6)
                        : colorScheme.onSurface,
                  ),
                  onChanged: (value) {
                    _localContent = value;
                    // Save immediately on change
                    widget.onContentChanged(value.trim());
                  },
                  onSubmitted: (value) {
                    _localContent = value;
                    widget.onContentChanged(value.trim());
                    _focusNode.requestFocus();
                  },
                  // Add editing complete handler
                  onEditingComplete: () {
                    widget.onContentChanged(_localContent.trim());
                  },
                ),
              ),
            ),

            // Delete button with improved animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _hasFocus ? 36 : 0,
              curve: Curves.easeInOut,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(),
              child: _hasFocus
                  ? IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      onPressed: widget.onDelete,
                      tooltip: 'Delete task',
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
