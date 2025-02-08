// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$noteHash() => r'6fbba3898da39e9ffd07a61ff892e9c116e3ce6f';

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

/// See also [note].
@ProviderFor(note)
const noteProvider = NoteFamily();

/// See also [note].
class NoteFamily extends Family<AsyncValue<Note>> {
  /// See also [note].
  const NoteFamily();

  /// See also [note].
  NoteProvider call(
    String id,
  ) {
    return NoteProvider(
      id,
    );
  }

  @override
  NoteProvider getProviderOverride(
    covariant NoteProvider provider,
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
  String? get name => r'noteProvider';
}

/// See also [note].
class NoteProvider extends AutoDisposeFutureProvider<Note> {
  /// See also [note].
  NoteProvider(
    String id,
  ) : this._internal(
          (ref) => note(
            ref as NoteRef,
            id,
          ),
          from: noteProvider,
          name: r'noteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product') ? null : _$noteHash,
          dependencies: NoteFamily._dependencies,
          allTransitiveDependencies: NoteFamily._allTransitiveDependencies,
          id: id,
        );

  NoteProvider._internal(
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
    FutureOr<Note> Function(NoteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NoteProvider._internal(
        (ref) => create(ref as NoteRef),
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
  AutoDisposeFutureProviderElement<Note> createElement() {
    return _NoteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NoteProvider && other.id == id;
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
mixin NoteRef on AutoDisposeFutureProviderRef<Note> {
  /// The parameter `id` of this provider.
  String get id;
}

class _NoteProviderElement extends AutoDisposeFutureProviderElement<Note>
    with NoteRef {
  _NoteProviderElement(super.provider);

  @override
  String get id => (origin as NoteProvider).id;
}

String _$notesHash() => r'31858a47001fa749bd443118b90f86d68e46de2e';

/// See also [Notes].
@ProviderFor(Notes)
final notesProvider =
    AutoDisposeAsyncNotifierProvider<Notes, List<Note>>.internal(
  Notes.new,
  name: r'notesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$notesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Notes = AutoDisposeAsyncNotifier<List<Note>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
