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
  bool _contentChanged = false;

  @override
  void initState() {
    super.initState();
    _localContent = widget.todo.content;
    _controller = TextEditingController(text: _localContent);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final hadFocus = _hasFocus;
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });

    // Only save content when focus is lost and content has changed
    if (hadFocus && !_focusNode.hasFocus && _contentChanged) {
      _contentChanged = false;
      widget.onContentChanged(_localContent.trim());
    }
  }

  @override
  void didUpdateWidget(TodoItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controller if content changed externally
    if (oldWidget.todo.content != widget.todo.content &&
        widget.todo.content != _localContent &&
        !_hasFocus) {
      // Don't update while editing
      _localContent = widget.todo.content;
      _controller.text = _localContent;
    }
  }

  @override
  void dispose() {
    // Save content if it has changed before disposing
    if (_contentChanged) {
      widget.onContentChanged(_localContent.trim());
    }
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _unfocusAndSave() {
    if (_hasFocus) {
      // Save any changes before unfocusing
      if (_contentChanged) {
        _contentChanged = false;
        widget.onContentChanged(_localContent.trim());
      }
      // Unfocus the text field
      _focusNode.unfocus();
      // Ensure the unfocus is processed immediately
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = widget.todo.isDone;

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        // Unfocus when any drag starts in the parent ReorderableListView
        _unfocusAndSave();
        return false; // Allow the notification to continue
      },
      child: Card(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: _hasFocus
              ? BorderSide(
                  color: colorScheme.primary.withValues(alpha: .9),
                  width: 2,
                )
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Drag handle
              ReorderableDragStartListener(
                index: widget.index,
                child: MouseRegion(
                  cursor: SystemMouseCursors.grab,
                  child: Icon(
                    Icons.drag_indicator,
                    size: 22,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                  ),
                ),
              ),

              // Checkbox
              SizedBox(
                height: 48,
                width: 40, // Fixed width for better layout stability
                child: Center(
                  child: Checkbox(
                    value: isDone,
                    onChanged: (checked) {
                      _unfocusAndSave();
                      widget.onCheckboxChanged(checked);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              // Text field
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
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                    onChanged: (value) {
                      _localContent = value;
                      _contentChanged = true;
                    },
                    onSubmitted: (value) {
                      _localContent = value;
                      _contentChanged = false;
                      widget.onContentChanged(value.trim());
                      _focusNode.requestFocus();
                    },
                  ),
                ),
              ),

              // Delete button - only show when focused
              if (_hasFocus)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                  ),
                  onPressed: () {
                    _unfocusAndSave();
                    widget.onDelete();
                  },
                  tooltip: 'Delete task',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
