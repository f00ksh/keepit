import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:keepit/data/providers/settings_provider.dart';

part 'theme_provider.g.dart';

@riverpod
ThemeMode appThemeMode(Ref ref) {
  // Read theme mode from settings
  final settings = ref.watch(settingsProvider);
  return settings.getThemeMode();
}

@riverpod
bool useDynamicColors(Ref ref) {
  final settings = ref.watch(settingsProvider);
  return settings.useDynamicColors;
}

@riverpod
int accentColorIndex(Ref ref) {
  final settings = ref.watch(settingsProvider);
  return settings.accentColorIndex;
}
