import 'package:flutter/material.dart';

/// Defines the typography for the app using Material 3 guidelines
class AppTypography {
  /// Light theme typography
  static TextTheme get lightTextTheme => _createTextTheme(Colors.black);

  /// Dark theme typography
  static TextTheme get darkTextTheme => _createTextTheme(Colors.white);

  static TextTheme _createTextTheme(Color textColor) {
    // Use Typography.material2021() as the foundation for MD3 typography
    final baseTextTheme = Typography.material2021(
      platform: TargetPlatform.android,
    ).black;

    return baseTextTheme.copyWith(
      // Display styles
      displayLarge: baseTextTheme.displayLarge!.copyWith(
        color: textColor,
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: baseTextTheme.displayMedium!.copyWith(
        color: textColor,
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: baseTextTheme.displaySmall!.copyWith(
        color: textColor,
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles
      headlineLarge: baseTextTheme.headlineLarge!.copyWith(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: baseTextTheme.headlineMedium!.copyWith(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: baseTextTheme.headlineSmall!.copyWith(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleSmall: baseTextTheme.titleSmall!.copyWith(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body styles
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: baseTextTheme.bodySmall!.copyWith(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label styles
      labelLarge: baseTextTheme.labelLarge!.copyWith(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: baseTextTheme.labelMedium!.copyWith(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: baseTextTheme.labelSmall!.copyWith(
        color: textColor,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  /// Apply semantic emphasis to text
  static TextStyle applyEmphasis(
    TextStyle style, {
    bool strong = false,
    bool medium = false,
    bool light = false,
  }) {
    TextStyle resultStyle = style;

    if (strong) {
      resultStyle = resultStyle.copyWith(fontWeight: FontWeight.w700);
    } else if (medium) {
      resultStyle = resultStyle.copyWith(fontWeight: FontWeight.w500);
    } else if (light) {
      resultStyle = resultStyle.copyWith(fontWeight: FontWeight.w300);
    }

    return resultStyle;
  }

  static TextTheme withTextScaling(
      TextTheme textTheme, double textScaleFactor) {
    return textTheme.copyWith(
      displayLarge: textTheme.displayLarge!.copyWith(
        fontSize: textTheme.displayLarge!.fontSize! * textScaleFactor,
      ),
      displayMedium: textTheme.displayMedium!.copyWith(
        fontSize: textTheme.displayMedium!.fontSize! * textScaleFactor,
      ),
      displaySmall: textTheme.displaySmall!.copyWith(
        fontSize: textTheme.displaySmall!.fontSize! * textScaleFactor,
      ),
      headlineLarge: textTheme.headlineLarge!.copyWith(
        fontSize: textTheme.headlineLarge!.fontSize! * textScaleFactor,
      ),
      headlineMedium: textTheme.headlineMedium!.copyWith(
        fontSize: textTheme.headlineMedium!.fontSize! * textScaleFactor,
      ),
      headlineSmall: textTheme.headlineSmall!.copyWith(
        fontSize: textTheme.headlineSmall!.fontSize! * textScaleFactor,
      ),
      titleLarge: textTheme.titleLarge!.copyWith(
        fontSize: textTheme.titleLarge!.fontSize! * textScaleFactor,
      ),
      titleMedium: textTheme.titleMedium!.copyWith(
        fontSize: textTheme.titleMedium!.fontSize! * textScaleFactor,
      ),
      titleSmall: textTheme.titleSmall!.copyWith(
        fontSize: textTheme.titleSmall!.fontSize! * textScaleFactor,
      ),
      bodyLarge: textTheme.bodyLarge!.copyWith(
        fontSize: textTheme.bodyLarge!.fontSize! * textScaleFactor,
      ),
      bodyMedium: textTheme.bodyMedium!.copyWith(
        fontSize: textTheme.bodyMedium!.fontSize! * textScaleFactor,
      ),
      bodySmall: textTheme.bodySmall!.copyWith(
        fontSize: textTheme.bodySmall!.fontSize! * textScaleFactor,
      ),
      labelLarge: textTheme.labelLarge!.copyWith(
        fontSize: textTheme.labelLarge!.fontSize! * textScaleFactor,
      ),
      labelMedium: textTheme.labelMedium!.copyWith(
        fontSize: textTheme.labelMedium!.fontSize! * textScaleFactor,
      ),
      labelSmall: textTheme.labelSmall!.copyWith(
        fontSize: textTheme.labelSmall!.fontSize! * textScaleFactor,
      ),
    );
  }
}
