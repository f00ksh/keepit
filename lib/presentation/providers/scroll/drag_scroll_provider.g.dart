// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drag_scroll_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dragScrollHash() => r'7919ecea0f8094c33cc596db8c8f33d17aa5c90f';

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

abstract class _$DragScroll
    extends BuildlessAutoDisposeNotifier<DragScrollState> {
  late final ScrollController scrollController;

  DragScrollState build(
    ScrollController scrollController,
  );
}

/// See also [DragScroll].
@ProviderFor(DragScroll)
const dragScrollProvider = DragScrollFamily();

/// See also [DragScroll].
class DragScrollFamily extends Family<DragScrollState> {
  /// See also [DragScroll].
  const DragScrollFamily();

  /// See also [DragScroll].
  DragScrollProvider call(
    ScrollController scrollController,
  ) {
    return DragScrollProvider(
      scrollController,
    );
  }

  @override
  DragScrollProvider getProviderOverride(
    covariant DragScrollProvider provider,
  ) {
    return call(
      provider.scrollController,
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
  String? get name => r'dragScrollProvider';
}

/// See also [DragScroll].
class DragScrollProvider
    extends AutoDisposeNotifierProviderImpl<DragScroll, DragScrollState> {
  /// See also [DragScroll].
  DragScrollProvider(
    ScrollController scrollController,
  ) : this._internal(
          () => DragScroll()..scrollController = scrollController,
          from: dragScrollProvider,
          name: r'dragScrollProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dragScrollHash,
          dependencies: DragScrollFamily._dependencies,
          allTransitiveDependencies:
              DragScrollFamily._allTransitiveDependencies,
          scrollController: scrollController,
        );

  DragScrollProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.scrollController,
  }) : super.internal();

  final ScrollController scrollController;

  @override
  DragScrollState runNotifierBuild(
    covariant DragScroll notifier,
  ) {
    return notifier.build(
      scrollController,
    );
  }

  @override
  Override overrideWith(DragScroll Function() create) {
    return ProviderOverride(
      origin: this,
      override: DragScrollProvider._internal(
        () => create()..scrollController = scrollController,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        scrollController: scrollController,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<DragScroll, DragScrollState>
      createElement() {
    return _DragScrollProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DragScrollProvider &&
        other.scrollController == scrollController;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, scrollController.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DragScrollRef on AutoDisposeNotifierProviderRef<DragScrollState> {
  /// The parameter `scrollController` of this provider.
  ScrollController get scrollController;
}

class _DragScrollProviderElement
    extends AutoDisposeNotifierProviderElement<DragScroll, DragScrollState>
    with DragScrollRef {
  _DragScrollProviderElement(super.provider);

  @override
  ScrollController get scrollController =>
      (origin as DragScrollProvider).scrollController;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
