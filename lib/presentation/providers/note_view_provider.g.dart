// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_view_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$noteViewHash() => r'db4e3bff3eda67c539dee04a2a879601e2033c4e';

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

abstract class _$NoteView extends BuildlessAutoDisposeNotifier<Note> {
  late final String noteId;

  Note build(
    String noteId,
  );
}

/// Provider for managing a single note's state while being viewed/edited
///
/// Copied from [NoteView].
@ProviderFor(NoteView)
const noteViewProvider = NoteViewFamily();

/// Provider for managing a single note's state while being viewed/edited
///
/// Copied from [NoteView].
class NoteViewFamily extends Family<Note> {
  /// Provider for managing a single note's state while being viewed/edited
  ///
  /// Copied from [NoteView].
  const NoteViewFamily();

  /// Provider for managing a single note's state while being viewed/edited
  ///
  /// Copied from [NoteView].
  NoteViewProvider call(
    String noteId,
  ) {
    return NoteViewProvider(
      noteId,
    );
  }

  @override
  NoteViewProvider getProviderOverride(
    covariant NoteViewProvider provider,
  ) {
    return call(
      provider.noteId,
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
  String? get name => r'noteViewProvider';
}

/// Provider for managing a single note's state while being viewed/edited
///
/// Copied from [NoteView].
class NoteViewProvider extends AutoDisposeNotifierProviderImpl<NoteView, Note> {
  /// Provider for managing a single note's state while being viewed/edited
  ///
  /// Copied from [NoteView].
  NoteViewProvider(
    String noteId,
  ) : this._internal(
          () => NoteView()..noteId = noteId,
          from: noteViewProvider,
          name: r'noteViewProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$noteViewHash,
          dependencies: NoteViewFamily._dependencies,
          allTransitiveDependencies: NoteViewFamily._allTransitiveDependencies,
          noteId: noteId,
        );

  NoteViewProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.noteId,
  }) : super.internal();

  final String noteId;

  @override
  Note runNotifierBuild(
    covariant NoteView notifier,
  ) {
    return notifier.build(
      noteId,
    );
  }

  @override
  Override overrideWith(NoteView Function() create) {
    return ProviderOverride(
      origin: this,
      override: NoteViewProvider._internal(
        () => create()..noteId = noteId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        noteId: noteId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<NoteView, Note> createElement() {
    return _NoteViewProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NoteViewProvider && other.noteId == noteId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, noteId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin NoteViewRef on AutoDisposeNotifierProviderRef<Note> {
  /// The parameter `noteId` of this provider.
  String get noteId;
}

class _NoteViewProviderElement
    extends AutoDisposeNotifierProviderElement<NoteView, Note>
    with NoteViewRef {
  _NoteViewProviderElement(super.provider);

  @override
  String get noteId => (origin as NoteViewProvider).noteId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
