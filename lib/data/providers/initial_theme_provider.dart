import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'initial_theme_provider.g.dart';

/// A provider that loads the theme mode synchronously from Hive storage
/// This is used to set the initial theme before the main settings finish loading
@riverpod
ThemeMode? initialThemeMode(Ref ref) {
  try {
    // Try to open the settings box synchronously
    final settingsBox = Hive.box('settings');
    final settings = settingsBox.get('app_settings');

    if (settings != null) {
      final themeModeString = settings.themeMode;

      switch (themeModeString) {
        case 'light':
          return ThemeMode.light;
        case 'dark':
          return ThemeMode.dark;
        case 'system':
          return ThemeMode.system;
        default:
          return null;
      }
    }
  } catch (e) {
    // If we can't access the box yet, just return null
    return null;
  }

  return null; // Fallback to null (use system)
}
