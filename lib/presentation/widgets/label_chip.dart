import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/data/providers/labels_provider.dart';
import 'package:keepit/domain/models/note.dart';
import '../../domain/models/label.dart';
import '../../core/theme/app_theme.dart';

class LabelChip extends StatelessWidget {
  final Label? label;
  final int? noteColorIndex;
  final int? wallpaperIndex;
  final bool isSelected;
  final bool removable;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const LabelChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.removable = false,
    this.onTap,
    this.onRemove,
    this.noteColorIndex,
    this.wallpaperIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (label == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    // Prioritize wallpaper color over note color
    Color? baseColor;
    if (wallpaperIndex != 0 && wallpaperIndex != AppTheme.noWallpaperIndex) {
      // Use wallpaper color if available
      baseColor = getNoteWallpaperColor(context, wallpaperIndex!);
    } else {
      // Fallback to note color
      baseColor =
          getNoteColor(context, noteColorIndex ?? AppTheme.noColorIndex);
    }

    // Surface colors from MD3 design system
    final surfaceColor = baseColor ?? colorScheme.surface;

    // Calculate a tonal variation for the surface container
    final surfaceContainerColor = Color.alphaBlend(
      colorScheme.onSurface.withOpacity(0.08),
      surfaceColor,
    );

    // Determine text and icon colors - adjust for wallpaper colors that might need higher contrast
    final isBrightColor = surfaceColor.computeLuminance() > 0.5;
    final textColor =
        isBrightColor ? colorScheme.onSurface : Colors.white.withOpacity(0.9);

    final borderColor = Color.alphaBlend(
        colorScheme.primary.withOpacity(0.2), surfaceContainerColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: removable ? onTap : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? surfaceContainerColor.withOpacity(0.9)
                      : surfaceContainerColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? colorScheme.primary : borderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label!.name,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: isSelected ? colorScheme.primary : textColor,
                            fontWeight: isSelected ? FontWeight.w500 : null,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NoteLabelsSection extends ConsumerWidget {
  final Note note;
  final bool isEditable;

  const NoteLabelsSection({
    super.key,
    required this.note,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (note.labelIds.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: note.labelIds.map((labelId) {
        return LabelChip(
          noteColorIndex: note.colorIndex,
          wallpaperIndex: note.wallpaperIndex,
          label: ref.watch(labelByIdProvider(labelId)),
          isSelected: false,
          removable: false,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/labels',
              arguments: {
                'noteId': note.id,
                'selectedLabelIds': note.labelIds,
              },
            );
          },
          onRemove: null,
        );
      }).toList(),
    );
  }
}
