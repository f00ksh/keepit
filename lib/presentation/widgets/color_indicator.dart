import 'package:flutter/material.dart';
import 'package:keepit/core/theme/app_theme.dart';

class ColorIndicator extends StatelessWidget {
  final int colorIndex;
  final double size;

  const ColorIndicator({
    super.key,
    required this.colorIndex,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show for default color
    if (colorIndex == AppTheme.noColorIndex) {
      return const SizedBox.shrink();
    }

    final noteColor = getNoteColor(context, colorIndex);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: noteColor,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
