import 'package:flutter/material.dart';
import 'package:keepit/core/theme/app_theme.dart';

class ThemeColorPicker extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onColorSelected;

  const ThemeColorPicker({
    super.key,
    required this.selectedIndex,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppTheme.darkColors : AppTheme.lightColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Note Color',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return GestureDetector(
                onTap: () => onColorSelected(index),
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: color ?? colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selectedIndex == index
                          ? colorScheme.primary
                          : color == null
                              ? colorScheme.outline.withOpacity(0.12)
                              : Colors.transparent,
                      width: selectedIndex == index ? 2 : 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
