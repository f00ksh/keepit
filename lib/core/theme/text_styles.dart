import 'package:flutter/material.dart';
import 'package:keepit/core/theme/app_typography.dart';

/// App text style extensions for consistent typography
extension TextStyleExtensions on BuildContext {
  /// Get the app's text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Apply semantic emphasis to a text style
  TextStyle emphasize(
    TextStyle style, {
    bool strong = false,
    bool medium = false,
    bool light = false,
  }) =>
      AppTypography.applyEmphasis(
        style,
        strong: strong,
        medium: medium,
        light: light,
      );

  /// Convenience method for bold style
  TextStyle get titleLargeBold =>
      emphasize(textTheme.titleLarge!, strong: true);

  /// Convenience method for medium weight title
  TextStyle get titleMediumEmphasized =>
      emphasize(textTheme.titleMedium!, medium: true);
}

/// Semantic text style constants to use throughout the app
class AppTextStyles {
  // Note title styles
  static TextStyle noteTitleStyle(BuildContext context) =>
      context.textTheme.titleLarge!;
  // Note Card Title
  static TextStyle notecardTitleStyle(BuildContext context) =>
      context.textTheme.titleMedium!;

  // Note content styles
  static TextStyle noteContentStyle(BuildContext context) =>
      context.textTheme.bodyLarge!;

  // Note Card Content
  static TextStyle notecardContentStyle(BuildContext context) =>
      context.textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
      );

  // Section title styles
  static TextStyle sectionTitleStyle(BuildContext context) =>
      context.emphasize(context.textTheme.titleMedium!, strong: true);

  // Label styles
  static TextStyle labelStyle(BuildContext context) =>
      context.textTheme.labelMedium!;

  // Empty state message style
  static TextStyle emptyStateStyle(BuildContext context) =>
      context.textTheme.bodyMedium!.copyWith(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      );
}
