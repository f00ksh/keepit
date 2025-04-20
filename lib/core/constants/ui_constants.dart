import 'package:flutter/material.dart';

/// UI constants that adapt to screen size
class UIConstants {
  // Private constructor to prevent instantiation
  UIConstants._();

  /// Returns responsive size constants based on screen size
  static UISizeConstants of(BuildContext context) {
    return UISizeConstants(context);
  }
}

/// Size constants that adapt to the screen dimensions
class UISizeConstants {
  final BuildContext context;
  final double screenWidth;
  final double screenHeight;

  UISizeConstants(this.context)
      : screenWidth = MediaQuery.of(context).size.width,
        screenHeight = MediaQuery.of(context).size.height;

  // Color picker constants
  double get colorItemSize => screenWidth * 0.12; // ~64dp on average phone
  double get colorItemSpacing => screenWidth * 0.02; // ~16dp on average phone
  double get colorPickerHorizontalPadding =>
      screenWidth * 0.05; // ~24dp on average phone
  double get colorPickerHeight => screenHeight * 0.1; // ~80dp on average phone
  double get colorItemMargin => screenWidth * 0.01; // ~4dp on average phone
  double get colorIconSize => screenWidth * 0.06; // ~24dp on average phone

  // Wallpaper picker constants
  double get wallpaperItemSize => screenWidth * 0.18; // ~80dp on average phone
  double get wallpaperItemSpacing =>
      screenWidth * 0.02; // ~16dp on average phone
  double get wallpaperPickerHorizontalPadding =>
      screenWidth * 0.05; // ~24dp on average phone
  double get wallpaperPickerHeight =>
      screenHeight * 0.1; // ~80dp on average phone
  double get wallpaperIconSize => screenWidth * 0.06; // ~24dp on average phone
  double get wallpaperItemPadding =>
      screenWidth * 0.005; // ~2dp on average phone
  double get wallpaperLoadingSize =>
      screenWidth * 0.03; // ~16dp on average phone

  // Vertical paddings
  double get standardVerticalPadding =>
      screenHeight * 0.02; // ~16dp on average phone
}
