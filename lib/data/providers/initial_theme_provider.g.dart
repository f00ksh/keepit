// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initial_theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$initialThemeModeHash() => r'0f001fade5f94096893742f1b8b581c17277e080';

/// A provider that loads the theme mode synchronously from Hive storage
/// This is used to set the initial theme before the main settings finish loading
///
/// Copied from [initialThemeMode].
@ProviderFor(initialThemeMode)
final initialThemeModeProvider = AutoDisposeProvider<ThemeMode?>.internal(
  initialThemeMode,
  name: r'initialThemeModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initialThemeModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InitialThemeModeRef = AutoDisposeProviderRef<ThemeMode?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
