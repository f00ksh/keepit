import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/data/providers/labels_provider.dart';
import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/domain/models/label.dart';
import 'package:keepit/core/theme/app_theme.dart';

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
  int _selectedColorIndex = 0;
  late List<String> _selectedIds;
  bool get isSelectionMode => widget.noteId != null;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.selectedLabelIds ?? []);
  }

  @override
  void dispose() {
    _labelController.dispose();
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

    final newLabel = Label(
      name: name,
      colorIndex: _selectedColorIndex,
    );

    await ref.read(labelsProvider.notifier).addLabel(newLabel);
    _labelController.clear();
    setState(() {
      _selectedColorIndex = 0;
      if (isSelectionMode) {
        _selectedIds.add(newLabel.id);
      }
    });
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

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final labels = ref.watch(labelsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectionMode ? 'Select Labels' : 'Manage Labels'),
        actions: [
          if (isSelectionMode)
            TextButton(
              onPressed: _saveLabels,
              child: const Text('SAVE'),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!isSelectionMode) ...[
              // Label creation section - only show in management mode
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showColorPicker(context),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: getNoteColor(context, _selectedColorIndex) ??
                            theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _labelController,
                      decoration: const InputDecoration(
                        hintText: 'Create new label',
                        border: InputBorder.none,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _createLabel,
                  ),
                ],
              ),
              const Divider(),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: labels.length,
                itemBuilder: (context, index) {
                  final label = labels[index];
                  final isSelected = _selectedIds.contains(label.id);

                  return ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: getNoteColor(context, label.colorIndex) ??
                            theme.colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.5)),
                      ),
                    ),
                    title: Text(label.name),
                    trailing: isSelectionMode
                        ? Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggleLabel(label.id),
                          )
                        : IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => ref
                                .read(labelsProvider.notifier)
                                .deleteLabel(label.id),
                          ),
                    onTap: isSelectionMode
                        ? () => _toggleLabel(label.id)
                        : () {
                            // Handle label edit in management mode
                            // TODO: Implement label editing
                          },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = isDark ? AppTheme.darkColors : AppTheme.lightColors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select color'),
        content: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: List.generate(
            colors.length,
            (index) => GestureDetector(
              onTap: () {
                setState(() => _selectedColorIndex = index);
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors[index] ?? theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                    width: _selectedColorIndex == index ? 2 : 1,
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }
}
