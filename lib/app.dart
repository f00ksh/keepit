import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:keepit/core/routes/app_router.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/core/theme/theme_provider.dart';

// Add this to your existing imports if not already there

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    final useDynamicColors = ref.watch(useDynamicColorsProvider);
    final accentColorIndex = ref.watch(accentColorIndexProvider);

    // Configure system UI overlay
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    // Enable edge-to-edge
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );

    // Fallback colors - using our existing AppTheme with accent color
    final lightTheme = AppTheme.light(accentColorIndex: accentColorIndex);
    final darkTheme = AppTheme.dark(accentColorIndex: accentColorIndex);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Get final color schemes (dynamic or fallback)
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (useDynamicColors && lightDynamic != null && darkDynamic != null) {
          // Dynamic color is available and enabled, use it
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // Use our fallback color schemes with accent color
          lightColorScheme = lightTheme.colorScheme;
          darkColorScheme = darkTheme.colorScheme;
        }

        return MaterialApp(
          // showPerformanceOverlay: true,
          debugShowCheckedModeBanner: false,
          title: 'Keepit',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
          ),
          themeMode: themeMode,
          routes: AppRouter.routes,
        );
      },
    );
  }
}
