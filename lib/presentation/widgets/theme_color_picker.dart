import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/presentation/providers/note_view_provider.dart';

class ColorPickerContent extends ConsumerWidget {
  final String noteId;
  final int initialColorIndex;

  const ColorPickerContent({
    super.key,
    required this.noteId,
    required this.initialColorIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppTheme.darkColors : AppTheme.lightColors;
    final colorScheme = Theme.of(context).colorScheme;

    debugPrint('ColorPickerContent rebuild with index: $initialColorIndex');
    return _buildColorGrid(ref, colorScheme, colors, initialColorIndex);
  }

  Widget _buildColorGrid(WidgetRef ref, ColorScheme colorScheme,
      List<Color?> colors, int noteColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: colors.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final color = colors[index];
            if (color == null) {
              return _ColorCircle(
                color: colorScheme.surface,
                isSelected: index == noteColor,
                onTap: () {
                  debugPrint('Tapped no color option, index: $index');
                  ref
                      .read(noteViewProvider(noteId).notifier)
                      .updateColorIndex(index);
                },
                isNoColor: true,
              );
            }

            return _ColorCircle(
              color: color,
              isSelected: index == noteColor,
              onTap: () {
                debugPrint('Tapped color option, index: $index');
                ref
                    .read(noteViewProvider(noteId).notifier)
                    .updateColorIndex(index);
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
    // Calculate the icon color based on background contrast
    final Color iconColor = isNoColor
        ? colorScheme.onSurface
        : Color.lerp(Colors.white, Colors.black, color.computeLuminance())!
            .withOpacity(0.9);

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 64,
          height: 64,
          margin: const EdgeInsets.all(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? iconColor
                    : isNoColor
                        ? colorScheme.outline
                        : Colors.transparent,
                width: 2,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: iconColor,
                    size: 24,
                  )
                : isNoColor
                    ? Icon(
                        Icons.format_color_reset,
                        color: colorScheme.outline,
                        size: 24,
                      )
                    : null,
          ),
        ),
      ),
    );
  }
}
