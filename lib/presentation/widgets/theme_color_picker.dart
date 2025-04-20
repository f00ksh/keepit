import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/core/constants/ui_constants.dart';
import 'package:keepit/data/providers/notes_provider.dart';

class ColorPickerContent extends ConsumerStatefulWidget {
  final String noteId;
  final int initialColorIndex;

  const ColorPickerContent({
    super.key,
    required this.noteId,
    required this.initialColorIndex,
  });

  @override
  ConsumerState<ColorPickerContent> createState() => _ColorPickerContentState();
}

class _ColorPickerContentState extends ConsumerState<ColorPickerContent> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Scroll to selected item after layout is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedItem();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedItem() {
    if (widget.initialColorIndex <= 0) {
      return; // Don't scroll for default selection
    }

    // Calculate scroll position based on item index
    final selectedIndex = widget.initialColorIndex;
    final sizeConstants = UIConstants.of(context);
    final scrollOffset = (selectedIndex *
            (sizeConstants.colorItemSize + sizeConstants.colorItemSpacing)) -
        sizeConstants.colorPickerHorizontalPadding;

    // Ensure we don't scroll beyond bounds
    if (scrollOffset > 0) {
      // Add small delay to ensure ListView is properly laid out
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            scrollOffset,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppTheme.darkColors : AppTheme.lightColors;
    final colorScheme = Theme.of(context).colorScheme;
    final sizeConstants = UIConstants.of(context);

    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: sizeConstants.standardVerticalPadding),
      child: SizedBox(
        height: sizeConstants.colorPickerHeight,
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
              horizontal: sizeConstants.colorPickerHorizontalPadding),
          itemCount: colors.length,
          separatorBuilder: (context, index) =>
              SizedBox(width: sizeConstants.colorItemSpacing),
          itemBuilder: (context, index) {
            final note = ref.read(notesProvider).firstWhere(
                  (note) => note.id == widget.noteId,
                );
            final isSelected = note.colorIndex == index;
            final color = colors[index];

            return _ColorCircle(
              color: color ?? colorScheme.surface,
              isSelected: isSelected,
              isNoColor: color == null,
              onTap: () {
                ref.read(notesProvider.notifier).updateNote(
                      widget.noteId,
                      note.copyWith(colorIndex: index),
                    );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isNoColor;

  const _ColorCircle({
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.isNoColor = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sizeConstants = UIConstants.of(context);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: sizeConstants.colorItemSize,
          height: sizeConstants.colorItemSize,
          margin: EdgeInsets.all(sizeConstants.colorItemMargin),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? colorScheme.primary : colorScheme.outline,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: colorScheme.primary,
                    size: sizeConstants.colorIconSize,
                  )
                : isNoColor
                    ? Icon(
                        Icons.format_color_reset,
                        color: colorScheme.outline,
                        size: sizeConstants.colorIconSize,
                      )
                    : null,
          ),
        ),
      ),
    );
  }
}
