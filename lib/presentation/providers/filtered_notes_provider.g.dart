// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filtered_notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$favoriteNotesHash() => r'5451cc8f727c5c3bd3bdd5cd392663d5aee40991';

/// See also [favoriteNotes].
@ProviderFor(favoriteNotes)
final favoriteNotesProvider = AutoDisposeProvider<List<Note>>.internal(
  favoriteNotes,
  name: r'favoriteNotesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoriteNotesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FavoriteNotesRef = AutoDisposeProviderRef<List<Note>>;
String _$archivedNotesHash() => r'48cec73509cc8085472f2291f443f62118970e04';

/// See also [archivedNotes].
@ProviderFor(archivedNotes)
final archivedNotesProvider = AutoDisposeProvider<List<Note>>.internal(
  archivedNotes,
  name: r'archivedNotesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$archivedNotesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ArchivedNotesRef = AutoDisposeProviderRef<List<Note>>;
String _$trashedNotesHash() => r'86a92f4e3b7c2f8ff18acaed1022e0985fac3183';

/// See also [trashedNotes].
@ProviderFor(trashedNotes)
final trashedNotesProvider = AutoDisposeProvider<List<Note>>.internal(
  trashedNotes,
  name: r'trashedNotesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$trashedNotesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TrashedNotesRef = AutoDisposeProviderRef<List<Note>>;
String _$mainNotesHash() => r'26292691110cb4d81ada3b64021bc116df2531c8';

/// See also [mainNotes].
@ProviderFor(mainNotes)
final mainNotesProvider = AutoDisposeProvider<List<Note>>.internal(
  mainNotes,
  name: r'mainNotesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$mainNotesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MainNotesRef = AutoDisposeProviderRef<List<Note>>;
String _$filteredNotesHash() => r'564dceb44b0a5b7d205f58b28d926205018c1f55';

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

abstract class _$FilteredNotes
    extends BuildlessAutoDisposeNotifier<List<Note>> {
  late final String? searchQuery;
  late final bool? isFavorite;

  List<Note> build({
    String? searchQuery,
    bool? isFavorite,
  });
}

/// See also [FilteredNotes].
@ProviderFor(FilteredNotes)
const filteredNotesProvider = FilteredNotesFamily();

/// See also [FilteredNotes].
class FilteredNotesFamily extends Family<List<Note>> {
  /// See also [FilteredNotes].
  const FilteredNotesFamily();

  /// See also [FilteredNotes].
  FilteredNotesProvider call({
    String? searchQuery,
    bool? isFavorite,
  }) {
    return FilteredNotesProvider(
      searchQuery: searchQuery,
      isFavorite: isFavorite,
    );
  }

  @override
  FilteredNotesProvider getProviderOverride(
    covariant FilteredNotesProvider provider,
  ) {
    return call(
      searchQuery: provider.searchQuery,
      isFavorite: provider.isFavorite,
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
  String? get name => r'filteredNotesProvider';
}

/// See also [FilteredNotes].
class FilteredNotesProvider
    extends AutoDisposeNotifierProviderImpl<FilteredNotes, List<Note>> {
  /// See also [FilteredNotes].
  FilteredNotesProvider({
    String? searchQuery,
    bool? isFavorite,
  }) : this._internal(
          () => FilteredNotes()
            ..searchQuery = searchQuery
            ..isFavorite = isFavorite,
          from: filteredNotesProvider,
          name: r'filteredNotesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredNotesHash,
          dependencies: FilteredNotesFamily._dependencies,
          allTransitiveDependencies:
              FilteredNotesFamily._allTransitiveDependencies,
          searchQuery: searchQuery,
          isFavorite: isFavorite,
        );

  FilteredNotesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchQuery,
    required this.isFavorite,
  }) : super.internal();

  final String? searchQuery;
  final bool? isFavorite;

  @override
  List<Note> runNotifierBuild(
    covariant FilteredNotes notifier,
  ) {
    return notifier.build(
      searchQuery: searchQuery,
      isFavorite: isFavorite,
    );
  }

  @override
  Override overrideWith(FilteredNotes Function() create) {
    return ProviderOverride(
      origin: this,
      override: FilteredNotesProvider._internal(
        () => create()
          ..searchQuery = searchQuery
          ..isFavorite = isFavorite,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchQuery: searchQuery,
        isFavorite: isFavorite,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<FilteredNotes, List<Note>>
      createElement() {
    return _FilteredNotesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredNotesProvider &&
        other.searchQuery == searchQuery &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchQuery.hashCode);
    hash = _SystemHash.combine(hash, isFavorite.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredNotesRef on AutoDisposeNotifierProviderRef<List<Note>> {
  /// The parameter `searchQuery` of this provider.
  String? get searchQuery;

  /// The parameter `isFavorite` of this provider.
  bool? get isFavorite;
}

class _FilteredNotesProviderElement
    extends AutoDisposeNotifierProviderElement<FilteredNotes, List<Note>>
    with FilteredNotesRef {
  _FilteredNotesProviderElement(super.provider);

  @override
  String? get searchQuery => (origin as FilteredNotesProvider).searchQuery;
  @override
  bool? get isFavorite => (origin as FilteredNotesProvider).isFavorite;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
