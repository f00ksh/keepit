import 'package:flutter/material.dart';
import 'package:keepit/core/theme/app_typography.dart';

class AppTheme {
  static const noColorIndex = -1;
  static const noWallpaperIndex = -1;

  // Add color names that match the color indices
  static final colorNames = [
    'Default',
    'Red',
    'Orange',
    'Yellow',
    'Green',
    'Teal',
    'Light Blue',
    'Blue',
    'Purple',
    'Pink',
    'Brown',
    'Gray',
  ];

  // Add wallpaper names for selection
  static final wallpaperNames = [
    'None',
    'Wallpaper 1',
    'Wallpaper 2',
    'Wallpaper 3',
    'Wallpaper 4',
    'Wallpaper 5',
    'Wallpaper 6',
    'Wallpaper 7',
  ];

  // Define wallpaper assets for light theme
  static final lightWallpaperAssets = [
    null, // No wallpaper option
    'assets/wallpapers/light/1.webp',
    'assets/wallpapers/light/2.webp',
    'assets/wallpapers/light/3.webp',
    'assets/wallpapers/light/4.webp',
    'assets/wallpapers/light/5.webp',
    'assets/wallpapers/light/6.webp',
    'assets/wallpapers/light/7.webp',
  ];

  // Define wallpaper assets for dark theme
  static final darkWallpaperAssets = [
    null, // No wallpaper option
    'assets/wallpapers/dark/1.webp',
    'assets/wallpapers/dark/2.webp',
    'assets/wallpapers/dark/3.webp',
    'assets/wallpapers/dark/4.webp',
    'assets/wallpapers/dark/5.webp',
    'assets/wallpapers/dark/6.webp',
    'assets/wallpapers/dark/7.webp',
  ];

  // Define accent colors that match your app's style
  static final accentColors = [
    Colors.blueAccent,
    Colors.amberAccent,
    Colors.greenAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
  ];

  static final lightColors = [
    null, // No color option
    const Color(0xfffaafa9),
    const Color(0xfff29f75),
    const Color(0xfffff8b8),
    const Color(0xffe2f6d3),
    const Color(0xffb4ded3),
    const Color(0xffd3e4ec),
    const Color(0xffafccdc),
    const Color(0xffd3bedb),
    const Color(0xfff5e2dc),
    const Color(0xffe9e3d3),
    const Color(0xffe0e0e0),
  ];

  static final darkColors = [
    null, // No color option
    const Color(0xff76172d),
    const Color(0xff692917),
    const Color(0xff7c4a03),
    const Color(0xff264d3b),
    const Color(0xff0c635d),
    const Color(0xff256476),
    const Color(0xff274255),
    const Color(0xff482e5b),
    const Color(0xff6d394f),
    const Color(0xff4b443a),
    const Color(0xff424242),
  ];

  // Light theme wallpaper colors
  static final lightWallpaperColors = [
    null, // No wallpaper
    const Color.fromARGB(255, 148, 71, 94),
    const Color.fromARGB(255, 44, 83, 155),
    const Color.fromARGB(235, 83, 86, 88),
    const Color.fromARGB(242, 38, 66, 110),
    const Color.fromARGB(255, 119, 27, 27),
    const Color.fromARGB(255, 77, 57, 170),
    const Color.fromARGB(255, 55, 31, 94),
  ];

  // Dark theme wallpaper colors
  static final darkWallpaperColors = [
    null, // No wallpaper
    const Color.fromARGB(223, 218, 224, 213),
    const Color.fromARGB(255, 198, 202, 174),
    const Color.fromARGB(255, 158, 190, 202),
    const Color.fromARGB(240, 99, 196, 252),
    const Color.fromARGB(255, 228, 125, 84),
    const Color.fromARGB(255, 238, 213, 101),
    const Color.fromARGB(255, 216, 72, 72),
  ];

  static ThemeData light({int accentColorIndex = 0}) {
    final seedColor =
        accentColorIndex >= 0 && accentColorIndex < accentColors.length
            ? accentColors[accentColorIndex]
            : Colors.blueAccent;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      textTheme: AppTypography.lightTextTheme,
      primaryTextTheme: AppTypography.lightTextTheme,
    );
  }

  static ThemeData dark({int accentColorIndex = 0}) {
    final seedColor =
        accentColorIndex >= 0 && accentColorIndex < accentColors.length
            ? accentColors[accentColorIndex]
            : Colors.blueAccent;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      textTheme: AppTypography.darkTextTheme,
      primaryTextTheme: AppTypography.darkTextTheme,
    );
  }

// get color for the wallpaper
  static Color getWallpaperColor(int index, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? darkWallpaperColors : lightWallpaperColors;

    if (index <= 0 || index >= colors.length) {
      return Theme.of(context).colorScheme.surface;
    }
    // Add null check to ensure we always return a non-null Color
    return colors[index] ?? Theme.of(context).colorScheme.surface;
  }

  // return the asset path string
  static String? getNoteWallpaperAssetPath(
      BuildContext context, int wallpaperIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wallpaperAssets = isDark ? darkWallpaperAssets : lightWallpaperAssets;
    if (wallpaperIndex <= 0 || wallpaperIndex >= wallpaperAssets.length) {
      return null;
    }
    return wallpaperAssets[wallpaperIndex];
  }
}

// Add a utility method to get wallpaper name
String getWallpaperName(int? wallpaperIndex) {
  if (wallpaperIndex == null || wallpaperIndex == AppTheme.noWallpaperIndex) {
    return 'None';
  }
  if (wallpaperIndex >= 0 && wallpaperIndex < AppTheme.wallpaperNames.length) {
    return AppTheme.wallpaperNames[wallpaperIndex];
  }
  return 'Unknown';
}

// Keep existing utility methods
String getColorName(int? colorIndex) {
  if (colorIndex == null || colorIndex == AppTheme.noColorIndex) {
    return 'Default';
  }
  if (colorIndex >= 0 && colorIndex < AppTheme.colorNames.length) {
    return AppTheme.colorNames[colorIndex];
  }
  return 'Unknown';
}

Color? getNoteColor(BuildContext context, int colorIndex) {
  if (colorIndex == AppTheme.noColorIndex) return null;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final colors = isDark ? AppTheme.darkColors : AppTheme.lightColors;
  final color = colors[colorIndex];
  // Return surface color if the color is null (first item in the list)
  return color ?? Theme.of(context).colorScheme.surface;
}

// Refactored to use theme-specific wallpaper colors
Color? getNoteWallpaperColor(BuildContext context, int wallpaperIndex) {
  if (wallpaperIndex == AppTheme.noWallpaperIndex) return null;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final colors =
      isDark ? AppTheme.lightWallpaperColors : AppTheme.darkWallpaperColors;
  if (wallpaperIndex >= colors.length) {
    return Theme.of(context).colorScheme.surface;
  }
  final color = colors[wallpaperIndex];
  // Return surface color if the color is null (first item in the list)
  return color;
}
