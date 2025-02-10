import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:keepit/core/theme/app_theme.dart';

part 'theme_provider.g.dart';

@riverpod
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;
}

@riverpod
class NoteColors extends _$NoteColors {
  @override
  List<Color?> build() {
    final isDark = switch (ref.watch(appThemeModeProvider)) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark,
    };

    return isDark ? AppTheme.darkColors : AppTheme.lightColors;
  }

  Color? getNoteColor(int colorIndex) {
    if (colorIndex == AppTheme.noColorIndex) return null;
    if (colorIndex < 0 || colorIndex >= state.length) return null;
    return state[colorIndex];
  }
}

// Add a convenience provider for getting note colors
@riverpod
Color? noteColor(ref, int colorIndex) {
  return ref.watch(noteColorsProvider.notifier).getNoteColor(colorIndex);
}
