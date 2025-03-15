import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/data/providers/labels_provider.dart';
import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/domain/models/label.dart';

class LabelScreen extends ConsumerStatefulWidget {
  final String? noteId; // Optional - if provided, we're in selection mode
  final List<String>? selectedLabelIds; // Optional - initial selected labels

  const LabelScreen({
    super.key,
    this.noteId,
    this.selectedLabelIds,
  });

  @override
  ConsumerState<LabelScreen> createState() => _LabelScreenState();
}

class _LabelScreenState extends ConsumerState<LabelScreen> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _editingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late List<String> _selectedIds;
  bool get isSelectionMode => widget.noteId != null;
  String? _editingLabelId;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.selectedLabelIds ?? []);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _labelController.dispose();
    _editingController.dispose();

    super.dispose();
  }

  void _toggleLabel(String labelId) {
    setState(() {
      if (_selectedIds.contains(labelId)) {
        _selectedIds.remove(labelId);
      } else {
        _selectedIds.add(labelId);
      }
    });
  }

  Future<void> _createLabel() async {
    final name = _labelController.text.trim();
    if (name.isEmpty) return;

    final newLabel = Label(name: name);
    await ref.read(labelsProvider.notifier).addLabel(newLabel);
    _labelController.clear();

    if (mounted) {
      FocusScope.of(context).unfocus();

      if (isSelectionMode) {
        setState(() {
          _selectedIds.add(newLabel.id);
        });
      }
    }
  }

  Future<void> _saveLabels() async {
    if (!isSelectionMode) return;

    final notesNotifier = ref.read(notesProvider.notifier);
    final previousLabelIds = widget.selectedLabelIds ?? [];

    // Remove deselected labels
    for (final labelId in previousLabelIds) {
      if (!_selectedIds.contains(labelId)) {
        await notesNotifier.removeLabelFromNote(widget.noteId!, labelId);
      }
    }

    // Add newly selected labels
    for (final labelId in _selectedIds) {
      if (!previousLabelIds.contains(labelId)) {
        await notesNotifier.addLabelToNote(widget.noteId!, labelId);
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _startEditing(Label label) {
    if (_editingLabelId == label.id) return;

    _editingController.text = label.name;
    setState(() {
      _editingLabelId = label.id;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _finishEditing(Label label) {
    final newName = _editingController.text.trim();
    if (newName.isNotEmpty && newName != label.name) {
      ref.read(labelsProvider.notifier).updateLabel(
            label.id,
            label.copyWith(
              name: newName,
              updatedAt: DateTime.now(),
            ),
          );
    }
    setState(() => _editingLabelId = null);
  }

  @override
  Widget build(BuildContext context) {
    final labels = ref.watch(labelsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final InputBorder textFieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: colorScheme.primary,
        width: 2,
      ),
    );

    final InputBorder transparentBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Colors.transparent,
      ),
    );

    return GestureDetector(
      onTap: () {
        // unfocus all text fields when tapping outside
        FocusScope.of(context).unfocus();
        // reset editing state
        setState(() => _editingLabelId = null);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isSelectionMode ? 'Select Labels' : 'Manage Labels',
            style: textTheme.titleMedium,
          ),
          actions: [
            if (isSelectionMode)
              TextButton(
                onPressed: _saveLabels,
                child: const Text('SAVE'),
              ),
          ],
        ),
        body: Column(
          children: [
            if (!isSelectionMode) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    hintText: 'Create new label',
                    hintStyle: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _labelController.clear();
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: _createLabel,
                    ),
                    border: transparentBorder,
                    enabledBorder: transparentBorder,
                    focusedBorder: textFieldBorder,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: labels.length,
                itemBuilder: (context, index) {
                  final label = labels[index];
                  final isSelected = _selectedIds.contains(label.id);
                  final isEditing = _editingLabelId == label.id;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Material(
                      child: InkWell(
                        onTap: isSelectionMode
                            ? () => _toggleLabel(label.id)
                            : () => _startEditing(label),
                        child: TextField(
                          controller: isEditing
                              ? _editingController
                              : TextEditingController(text: label.name),
                          focusNode: isEditing ? _focusNode : null,
                          decoration: InputDecoration(
                            prefixIcon: IconButton(
                              icon: Icon(isEditing
                                  ? Icons.delete_forever_outlined
                                  : Icons.label_outline),
                              onPressed: isEditing
                                  ? () {
                                      ref
                                          .read(labelsProvider.notifier)
                                          .deleteLabel(label.id);
                                      setState(() => _editingLabelId = null);
                                    }
                                  : null,
                            ),
                            suffixIcon: isSelectionMode
                                ? Checkbox(
                                    value: isSelected,
                                    onChanged: (_) => _toggleLabel(label.id),
                                  )
                                : IconButton(
                                    icon: Icon(
                                        isEditing ? Icons.check : Icons.edit),
                                    color:
                                        isEditing ? colorScheme.primary : null,
                                    onPressed: isEditing
                                        ? () => _finishEditing(label)
                                        : () => _startEditing(label),
                                  ),
                            border: transparentBorder,
                            enabledBorder: transparentBorder,
                            focusedBorder: textFieldBorder,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          enabled: isEditing ||
                              isSelectionMode, // Enable only in edit or selection mode
                          readOnly:
                              !isEditing, // Allow editing only in edit mode
                          onSubmitted:
                              isEditing ? (_) => _finishEditing(label) : null,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
