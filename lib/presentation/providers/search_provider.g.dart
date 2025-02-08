// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredNotesHash() => r'212ce9efe1c5567e68b21f07cae313a3a3285c60';

/// See also [filteredNotes].
@ProviderFor(filteredNotes)
final filteredNotesProvider = AutoDisposeFutureProvider<List<Note>>.internal(
  filteredNotes,
  name: r'filteredNotesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$filteredNotesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FilteredNotesRef = AutoDisposeFutureProviderRef<List<Note>>;
String _$searchNotesHash() => r'446071a70cd536796ccebdf624cd5c1cacb95829';

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

/// See also [searchNotes].
@ProviderFor(searchNotes)
const searchNotesProvider = SearchNotesFamily();

/// See also [searchNotes].
class SearchNotesFamily extends Family<AsyncValue<List<Note>>> {
  /// See also [searchNotes].
  const SearchNotesFamily();

  /// See also [searchNotes].
  SearchNotesProvider call(
    String query,
  ) {
    return SearchNotesProvider(
      query,
    );
  }

  @override
  SearchNotesProvider getProviderOverride(
    covariant SearchNotesProvider provider,
  ) {
    return call(
      provider.query,
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
  String? get name => r'searchNotesProvider';
}

/// See also [searchNotes].
class SearchNotesProvider extends AutoDisposeFutureProvider<List<Note>> {
  /// See also [searchNotes].
  SearchNotesProvider(
    String query,
  ) : this._internal(
          (ref) => searchNotes(
            ref as SearchNotesRef,
            query,
          ),
          from: searchNotesProvider,
          name: r'searchNotesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchNotesHash,
          dependencies: SearchNotesFamily._dependencies,
          allTransitiveDependencies:
              SearchNotesFamily._allTransitiveDependencies,
          query: query,
        );

  SearchNotesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<Note>> Function(SearchNotesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchNotesProvider._internal(
        (ref) => create(ref as SearchNotesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Note>> createElement() {
    return _SearchNotesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchNotesProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchNotesRef on AutoDisposeFutureProviderRef<List<Note>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _SearchNotesProviderElement
    extends AutoDisposeFutureProviderElement<List<Note>> with SearchNotesRef {
  _SearchNotesProviderElement(super.provider);

  @override
  String get query => (origin as SearchNotesProvider).query;
}

String _$searchActiveHash() => r'e1d7d2fe3afd0f0961c73efe1ac0d3f146c008eb';

/// See also [SearchActive].
@ProviderFor(SearchActive)
final searchActiveProvider =
    AutoDisposeNotifierProvider<SearchActive, bool>.internal(
  SearchActive.new,
  name: r'searchActiveProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchActiveHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchActive = AutoDisposeNotifier<bool>;
String _$searchQueryHash() => r'286abcff51dc844febe02639bb2e883ccab22cfd';

/// See also [SearchQuery].
@ProviderFor(SearchQuery)
final searchQueryProvider =
    AutoDisposeNotifierProvider<SearchQuery, String>.internal(
  SearchQuery.new,
  name: r'searchQueryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchQueryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchQuery = AutoDisposeNotifier<String>;
String _$searchHistoryHash() => r'e186d73fabd4a27fcc181e26fef8b402173e5c8d';

/// See also [SearchHistory].
@ProviderFor(SearchHistory)
final searchHistoryProvider =
    AutoDisposeNotifierProvider<SearchHistory, List<String>>.internal(
  SearchHistory.new,
  name: r'searchHistoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchHistory = AutoDisposeNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
