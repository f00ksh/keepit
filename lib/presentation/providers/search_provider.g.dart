// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchFilteredNotesHash() =>
    r'5dab8e61aa93dd892a336c3fb5fdb1f7700df8aa';

/// See also [searchFilteredNotes].
@ProviderFor(searchFilteredNotes)
final searchFilteredNotesProvider = AutoDisposeProvider<List<Note>>.internal(
  searchFilteredNotes,
  name: r'searchFilteredNotesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchFilteredNotesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SearchFilteredNotesRef = AutoDisposeProviderRef<List<Note>>;
String _$searchQueryHash() => r'3c36752ee11b18a9f1e545eb1a7209a7222d91c9';

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
String _$showSearchResultsHash() => r'a9948ca63f93670867f31bcc1dfbc02af5422135';

/// See also [ShowSearchResults].
@ProviderFor(ShowSearchResults)
final showSearchResultsProvider =
    AutoDisposeNotifierProvider<ShowSearchResults, bool>.internal(
  ShowSearchResults.new,
  name: r'showSearchResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$showSearchResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShowSearchResults = AutoDisposeNotifier<bool>;
String _$selectedSearchLabelsHash() =>
    r'483fc3480382d83d3c87da84816e4934f2428587';

/// See also [SelectedSearchLabels].
@ProviderFor(SelectedSearchLabels)
final selectedSearchLabelsProvider =
    AutoDisposeNotifierProvider<SelectedSearchLabels, List<String>>.internal(
  SelectedSearchLabels.new,
  name: r'selectedSearchLabelsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSearchLabelsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSearchLabels = AutoDisposeNotifier<List<String>>;
String _$selectedSearchColorHash() =>
    r'bb63e441b489dd34daa36a9dfa4f0b2f65a086ee';

/// See also [SelectedSearchColor].
@ProviderFor(SelectedSearchColor)
final selectedSearchColorProvider =
    AutoDisposeNotifierProvider<SelectedSearchColor, int?>.internal(
  SelectedSearchColor.new,
  name: r'selectedSearchColorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedSearchColorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedSearchColor = AutoDisposeNotifier<int?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
