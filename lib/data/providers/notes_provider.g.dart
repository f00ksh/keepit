// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$singleNoteHash() => r'7defcaae101d0d6b9299a48d92afb8d821a227b8';

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

/// Provider for a single note by ID, automatically updates when the note changes
///
/// Copied from [singleNote].
@ProviderFor(singleNote)
const singleNoteProvider = SingleNoteFamily();

/// Provider for a single note by ID, automatically updates when the note changes
///
/// Copied from [singleNote].
class SingleNoteFamily extends Family<Note> {
  /// Provider for a single note by ID, automatically updates when the note changes
  ///
  /// Copied from [singleNote].
  const SingleNoteFamily();

  /// Provider for a single note by ID, automatically updates when the note changes
  ///
  /// Copied from [singleNote].
  SingleNoteProvider call(
    String noteId,
    NoteType noteType,
  ) {
    return SingleNoteProvider(
      noteId,
      noteType,
    );
  }

  @override
  SingleNoteProvider getProviderOverride(
    covariant SingleNoteProvider provider,
  ) {
    return call(
      provider.noteId,
      provider.noteType,
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
  String? get name => r'singleNoteProvider';
}

/// Provider for a single note by ID, automatically updates when the note changes
///
/// Copied from [singleNote].
class SingleNoteProvider extends AutoDisposeProvider<Note> {
  /// Provider for a single note by ID, automatically updates when the note changes
  ///
  /// Copied from [singleNote].
  SingleNoteProvider(
    String noteId,
    NoteType noteType,
  ) : this._internal(
          (ref) => singleNote(
            ref as SingleNoteRef,
            noteId,
            noteType,
          ),
          from: singleNoteProvider,
          name: r'singleNoteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$singleNoteHash,
          dependencies: SingleNoteFamily._dependencies,
          allTransitiveDependencies:
              SingleNoteFamily._allTransitiveDependencies,
          noteId: noteId,
          noteType: noteType,
        );

  SingleNoteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.noteId,
    required this.noteType,
  }) : super.internal();

  final String noteId;
  final NoteType noteType;

  @override
  Override overrideWith(
    Note Function(SingleNoteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SingleNoteProvider._internal(
        (ref) => create(ref as SingleNoteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        noteId: noteId,
        noteType: noteType,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Note> createElement() {
    return _SingleNoteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SingleNoteProvider &&
        other.noteId == noteId &&
        other.noteType == noteType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, noteId.hashCode);
    hash = _SystemHash.combine(hash, noteType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SingleNoteRef on AutoDisposeProviderRef<Note> {
  /// The parameter `noteId` of this provider.
  String get noteId;

  /// The parameter `noteType` of this provider.
  NoteType get noteType;
}

class _SingleNoteProviderElement extends AutoDisposeProviderElement<Note>
    with SingleNoteRef {
  _SingleNoteProviderElement(super.provider);

  @override
  String get noteId => (origin as SingleNoteProvider).noteId;
  @override
  NoteType get noteType => (origin as SingleNoteProvider).noteType;
}

String _$notesHash() => r'b3cb34a26407ae06aad98d92711281647d5d9336';

/// See also [Notes].
@ProviderFor(Notes)
final notesProvider = AutoDisposeNotifierProvider<Notes, List<Note>>.internal(
  Notes.new,
  name: r'notesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$notesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Notes = AutoDisposeNotifier<List<Note>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
