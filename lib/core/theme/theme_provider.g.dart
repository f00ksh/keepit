// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$noteColorHash() => r'964f6bd9bfabd0f325d89dcea3e7ab2dd463d30d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [noteColor].
@ProviderFor(noteColor)
const noteColorProvider = NoteColorFamily();

/// See also [noteColor].
class NoteColorFamily extends Family<Color?> {
  /// See also [noteColor].
  const NoteColorFamily();

  /// See also [noteColor].
  NoteColorProvider call(
    int colorIndex,
  ) {
    return NoteColorProvider(
      colorIndex,
    );
  }

  @override
  NoteColorProvider getProviderOverride(
    covariant NoteColorProvider provider,
  ) {
    return call(
      provider.colorIndex,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'noteColorProvider';
}

/// See also [noteColor].
class NoteColorProvider extends AutoDisposeProvider<Color?> {
  /// See also [noteColor].
  NoteColorProvider(
    int colorIndex,
  ) : this._internal(
          (ref) => noteColor(
            ref as NoteColorRef,
            colorIndex,
          ),
          from: noteColorProvider,
          name: r'noteColorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$noteColorHash,
          dependencies: NoteColorFamily._dependencies,
          allTransitiveDependencies: NoteColorFamily._allTransitiveDependencies,
          colorIndex: colorIndex,
        );

  NoteColorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.colorIndex,
  }) : super.internal();

  final int colorIndex;

  @override
  Override overrideWith(
    Color? Function(NoteColorRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NoteColorProvider._internal(
        (ref) => create(ref as NoteColorRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        colorIndex: colorIndex,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Color?> createElement() {
    return _NoteColorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NoteColorProvider && other.colorIndex == colorIndex;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, colorIndex.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NoteColorRef on AutoDisposeProviderRef<Color?> {
  /// The parameter `colorIndex` of this provider.
  int get colorIndex;
}

class _NoteColorProviderElement extends AutoDisposeProviderElement<Color?>
    with NoteColorRef {
  _NoteColorProviderElement(super.provider);

  @override
  int get colorIndex => (origin as NoteColorProvider).colorIndex;
}

String _$appThemeModeHash() => r'4fba1763b2d8dd4d798daec787ad269cae4ad6b5';

/// See also [AppThemeMode].
@ProviderFor(AppThemeMode)
final appThemeModeProvider =
    AutoDisposeNotifierProvider<AppThemeMode, ThemeMode>.internal(
  AppThemeMode.new,
  name: r'appThemeModeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appThemeModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AppThemeMode = AutoDisposeNotifier<ThemeMode>;
String _$noteColorsHash() => r'77bc13026c7f87a4ea42d5669938b80fb9a636c1';

/// See also [NoteColors].
@ProviderFor(NoteColors)
final noteColorsProvider =
    AutoDisposeNotifierProvider<NoteColors, List<Color?>>.internal(
  NoteColors.new,
  name: r'noteColorsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$noteColorsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NoteColors = AutoDisposeNotifier<List<Color?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
