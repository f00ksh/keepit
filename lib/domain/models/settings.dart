import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'settings.g.dart';

@HiveType(typeId: 2)
class Setting extends HiveObject {
  @HiveField(0)
  String viewStyle;

  @HiveField(1)
  String sortBy;

  @HiveField(2)
  bool sortAscending;

  @HiveField(3)
  bool showPinnedSection;

  @HiveField(4)
  bool syncEnabled;

  @HiveField(5)
  bool useDynamicColors;

  @HiveField(6)
  int accentColorIndex;

  @HiveField(7)
  String themeMode;

  Setting({
    this.viewStyle = 'grid',
    this.sortBy = 'dateModified',
    this.sortAscending = false,
    this.showPinnedSection = true,
    this.syncEnabled = false,
    this.useDynamicColors = true,
    this.accentColorIndex = 0,
    this.themeMode = 'system',
  });

  Setting copyWith({
    String? viewStyle,
    String? sortBy,
    bool? sortAscending,
    bool? showPinnedSection,
    bool? syncEnabled,
    bool? useDynamicColors,
    int? accentColorIndex,
    String? themeMode,
  }) {
    return Setting(
      viewStyle: viewStyle ?? this.viewStyle,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      showPinnedSection: showPinnedSection ?? this.showPinnedSection,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      useDynamicColors: useDynamicColors ?? this.useDynamicColors,
      accentColorIndex: accentColorIndex ?? this.accentColorIndex,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  ThemeMode getThemeMode() {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
