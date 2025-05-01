import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/data/providers/notes_provider.dart';
import 'package:keepit/core/constants/ui_constants.dart';

class WallpaperPickerContent extends ConsumerStatefulWidget {
  final String noteId;
  final int initialWallpaperIndex;

  const WallpaperPickerContent({
    super.key,
    required this.noteId,
    required this.initialWallpaperIndex,
  });

  @override
  ConsumerState<WallpaperPickerContent> createState() =>
      _WallpaperPickerContentState();
}

class _WallpaperPickerContentState
    extends ConsumerState<WallpaperPickerContent> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
    if (widget.initialWallpaperIndex <= 0) {
      return; // Don't scroll for default selection
    }

    // Calculate scroll position based on item index
    final selectedIndex = widget.initialWallpaperIndex;
    final sizeConstants = UIConstants.of(context);
    final scrollOffset = (selectedIndex *
            (sizeConstants.wallpaperItemSize +
                sizeConstants.wallpaperItemSpacing)) -
        sizeConstants.wallpaperPickerHorizontalPadding;

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
    final note = ref.watch(singleNoteProvider(
      widget.noteId,
    ));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wallpaperAssets =
        isDark ? AppTheme.darkWallpaperAssets : AppTheme.lightWallpaperAssets;
    final colorScheme = Theme.of(context).colorScheme;
    final sizeConstants = UIConstants.of(context);

    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: sizeConstants.standardVerticalPadding),
      child: SizedBox(
        height: sizeConstants.wallpaperPickerHeight,
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
              horizontal: sizeConstants.wallpaperPickerHorizontalPadding),
          itemCount: AppTheme.wallpaperNames.length,
          separatorBuilder: (context, index) =>
              SizedBox(width: sizeConstants.wallpaperItemSpacing),
          itemBuilder: (context, index) {
            final isSelected = note.wallpaperIndex == index;
            final wallpaperAsset =
                index < wallpaperAssets.length ? wallpaperAssets[index] : null;
            final wallpaperImage = wallpaperAsset != null
                ? ResizeImage(
                    AssetImage(wallpaperAsset),
                    width: 100,
                  )
                : null;
            // Precache the image if it exists
            if (wallpaperImage != null) {
              precacheImage(wallpaperImage, context);
            }

            return GestureDetector(
              onTap: () async {
                final updatedNote = note.copyWith(
                  wallpaperIndex: index,
                  updatedAt: DateTime.now(),
                );
                await ref.read(notesProvider.notifier).updateNote(
                      widget.noteId,
                      updatedNote,
                    );
              },
              child: Container(
                width: sizeConstants.wallpaperItemSize,
                height: sizeConstants.wallpaperItemSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected ? colorScheme.primary : colorScheme.outline,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(sizeConstants.wallpaperItemPadding),
                  child: wallpaperAsset == null
                      ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Icon(
                            Icons.format_color_reset,
                            size: sizeConstants.wallpaperIconSize,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outline,
                          ),
                        )
                      : ClipOval(
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                alignment: Alignment.bottomRight,
                                image: wallpaperImage!,
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.low,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
