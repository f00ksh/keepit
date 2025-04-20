import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:keepit/domain/models/settings.dart';
import 'package:keepit/data/providers/service_providers.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  @override
  Setting build() {
    _loadSettings();
    return Setting(); // Default settings while loading
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await ref.read(storageServiceProvider).getSettings();
      if (settings != null) {
        state = settings;
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // Continue with default settings
    }
  }

  Future<void> updateSetting({
    String? viewStyle,
    String? sortBy,
    bool? sortAscending,
    bool? showPinnedSection,
    bool? syncEnabled,
    bool? useDynamicColors,
    int? accentColorIndex,
    String? themeMode,
  }) async {
    try {
      final updatedSettings = state.copyWith(
        viewStyle: viewStyle,
        sortBy: sortBy,
        sortAscending: sortAscending,
        showPinnedSection: showPinnedSection,
        syncEnabled: syncEnabled,
        useDynamicColors: useDynamicColors,
        accentColorIndex: accentColorIndex,
        themeMode: themeMode,
      );

      state = updatedSettings;
      await ref.read(storageServiceProvider).saveSettings(updatedSettings);
    } catch (e) {
      debugPrint('Error updating settings: $e');
      // Error handling could be added here
    }
  }

  // Convenience methods
  Future<void> toggleDynamicColors() async {
    await updateSetting(useDynamicColors: !state.useDynamicColors);
  }

  Future<void> setAccentColor(int index) async {
    await updateSetting(accentColorIndex: index);
  }

  Future<void> setViewStyle(String style) async {
    await updateSetting(viewStyle: style);
  }

  Future<void> toggleSync() async {
    await updateSetting(syncEnabled: !state.syncEnabled);
  }

  // Add method to set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    String themeModeString;
    switch (mode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      default:
        themeModeString = 'system';
    }

    await updateSetting(themeMode: themeModeString);
  }
}
