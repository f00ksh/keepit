// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'labels_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$labelByIdHash() => r'b5d2fd74af50da5ad1c85511d617bf7e35ffcc93';

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

/// See also [labelById].
@ProviderFor(labelById)
const labelByIdProvider = LabelByIdFamily();

/// See also [labelById].
class LabelByIdFamily extends Family<Label?> {
  /// See also [labelById].
  const LabelByIdFamily();

  /// See also [labelById].
  LabelByIdProvider call(
    String id,
  ) {
    return LabelByIdProvider(
      id,
    );
  }

  @override
  LabelByIdProvider getProviderOverride(
    covariant LabelByIdProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'labelByIdProvider';
}

/// See also [labelById].
class LabelByIdProvider extends AutoDisposeProvider<Label?> {
  /// See also [labelById].
  LabelByIdProvider(
    String id,
  ) : this._internal(
          (ref) => labelById(
            ref as LabelByIdRef,
            id,
          ),
          from: labelByIdProvider,
          name: r'labelByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$labelByIdHash,
          dependencies: LabelByIdFamily._dependencies,
          allTransitiveDependencies: LabelByIdFamily._allTransitiveDependencies,
          id: id,
        );

  LabelByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    Label? Function(LabelByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LabelByIdProvider._internal(
        (ref) => create(ref as LabelByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Label?> createElement() {
    return _LabelByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LabelByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LabelByIdRef on AutoDisposeProviderRef<Label?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _LabelByIdProviderElement extends AutoDisposeProviderElement<Label?>
    with LabelByIdRef {
  _LabelByIdProviderElement(super.provider);

  @override
  String get id => (origin as LabelByIdProvider).id;
}

String _$notesByLabelIdHash() => r'01a2ce2fcbbfef6b61ab2ee55ca817fd507cbde5';

/// See also [notesByLabelId].
@ProviderFor(notesByLabelId)
const notesByLabelIdProvider = NotesByLabelIdFamily();

/// See also [notesByLabelId].
class NotesByLabelIdFamily extends Family<List<Note>> {
  /// See also [notesByLabelId].
  const NotesByLabelIdFamily();

  /// See also [notesByLabelId].
  NotesByLabelIdProvider call(
    String labelId,
  ) {
    return NotesByLabelIdProvider(
      labelId,
    );
  }

  @override
  NotesByLabelIdProvider getProviderOverride(
    covariant NotesByLabelIdProvider provider,
  ) {
    return call(
      provider.labelId,
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
  String? get name => r'notesByLabelIdProvider';
}

/// See also [notesByLabelId].
class NotesByLabelIdProvider extends AutoDisposeProvider<List<Note>> {
  /// See also [notesByLabelId].
  NotesByLabelIdProvider(
    String labelId,
  ) : this._internal(
          (ref) => notesByLabelId(
            ref as NotesByLabelIdRef,
            labelId,
          ),
          from: notesByLabelIdProvider,
          name: r'notesByLabelIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$notesByLabelIdHash,
          dependencies: NotesByLabelIdFamily._dependencies,
          allTransitiveDependencies:
              NotesByLabelIdFamily._allTransitiveDependencies,
          labelId: labelId,
        );

  NotesByLabelIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.labelId,
  }) : super.internal();

  final String labelId;

  @override
  Override overrideWith(
    List<Note> Function(NotesByLabelIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NotesByLabelIdProvider._internal(
        (ref) => create(ref as NotesByLabelIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        labelId: labelId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Note>> createElement() {
    return _NotesByLabelIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotesByLabelIdProvider && other.labelId == labelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, labelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NotesByLabelIdRef on AutoDisposeProviderRef<List<Note>> {
  /// The parameter `labelId` of this provider.
  String get labelId;
}

class _NotesByLabelIdProviderElement
    extends AutoDisposeProviderElement<List<Note>> with NotesByLabelIdRef {
  _NotesByLabelIdProviderElement(super.provider);

  @override
  String get labelId => (origin as NotesByLabelIdProvider).labelId;
}

String _$labelsHash() => r'8e7a76b8c285c0483f697d6c03f030f829046806';

/// See also [Labels].
@ProviderFor(Labels)
final labelsProvider =
    AutoDisposeNotifierProvider<Labels, List<Label>>.internal(
  Labels.new,
  name: r'labelsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$labelsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Labels = AutoDisposeNotifier<List<Label>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
