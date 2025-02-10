import 'package:flutter/material.dart';

class AppTheme {
  static const noColorIndex = -1;

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
  ];

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      );
}

Color? getNoteColor(BuildContext context, int colorIndex) {
  if (colorIndex == AppTheme.noColorIndex) return null;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final colors = isDark ? AppTheme.darkColors : AppTheme.lightColors;
  return colors[colorIndex];
}
