import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:keepit/core/routes/app_router.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/core/theme/theme_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);

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

    // Fallback colors - using our existing AppTheme
    final lightTheme = AppTheme.light();
    final darkTheme = AppTheme.dark();

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Get final color schemes (dynamic or fallback)
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          // Dynamic color is available, use it
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // Use our fallback color schemes
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
            platform: TargetPlatform.android,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            platform: TargetPlatform.android,
          ),
          themeMode: themeMode,
          routes: AppRouter.routes,
          onGenerateRoute: AppRouter.onGenerateRoute,
          onUnknownRoute: AppRouter.onUnknownRoute,
        );
      },
    );
  }
}
