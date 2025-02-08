// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notesHash() => r'5f2a2d5c92dcf38dc055707b54be04413f33370d';

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
String _$pinnedNotesHash() => r'3080b13c168e619e963c1f12ae7950eb04be1996';

/// See also [PinnedNotes].
@ProviderFor(PinnedNotes)
final pinnedNotesProvider =
    AutoDisposeAsyncNotifierProvider<PinnedNotes, List<Note>>.internal(
  PinnedNotes.new,
  name: r'pinnedNotesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$pinnedNotesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PinnedNotes = AutoDisposeAsyncNotifier<List<Note>>;
String _$unpinnedNotesHash() => r'd7c5b7cedda2ef3d815f872d32da5edf4e10e780';

/// See also [UnpinnedNotes].
@ProviderFor(UnpinnedNotes)
final unpinnedNotesProvider =
    AutoDisposeAsyncNotifierProvider<UnpinnedNotes, List<Note>>.internal(
  UnpinnedNotes.new,
  name: r'unpinnedNotesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unpinnedNotesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UnpinnedNotes = AutoDisposeAsyncNotifier<List<Note>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
