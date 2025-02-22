import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'theme_provider.g.dart';

@riverpod
class AppThemeMode extends _$AppThemeMode {
  @override
  ThemeMode build() => ThemeMode.system;

  void setThemeMode(ThemeMode mode) => state = mode;
}

@riverpod
class SelectedColor extends _$SelectedColor {
  @override
  int build() => 0;
  // update
  void update(int index) {
    state = index;
  }
}
