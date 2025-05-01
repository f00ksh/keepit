// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$storageServiceHash() => r'e30443dddbc92b9334752302cbc4b11b941ed2c7';

/// See also [storageService].
@ProviderFor(storageService)
final storageServiceProvider = AutoDisposeProvider<StorageService>.internal(
  storageService,
  name: r'storageServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$storageServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StorageServiceRef = AutoDisposeProviderRef<StorageService>;
String _$supabaseServiceHash() => r'db134a6f26ee4542c8fe2a97a931221a08c9e980';

/// See also [supabaseService].
@ProviderFor(supabaseService)
final supabaseServiceProvider = AutoDisposeProvider<SupabaseService>.internal(
  supabaseService,
  name: r'supabaseServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supabaseServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupabaseServiceRef = AutoDisposeProviderRef<SupabaseService>;
String _$syncServiceHash() => r'4292d19f46c93157fcbf8eec2cef75fce13490c1';

/// See also [syncService].
@ProviderFor(syncService)
final syncServiceProvider = AutoDisposeProvider<SyncService>.internal(
  syncService,
  name: r'syncServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncServiceRef = AutoDisposeProviderRef<SyncService>;
String _$noteRepositoryHash() => r'eb93b0ea9d1d4a52a7c76ad4238b7ca96945929e';

/// See also [noteRepository].
@ProviderFor(noteRepository)
final noteRepositoryProvider = Provider<NoteRepositoryImpl>.internal(
  noteRepository,
  name: r'noteRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$noteRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NoteRepositoryRef = ProviderRef<NoteRepositoryImpl>;
String _$authServiceHash() => r'c04e89e0fb849b79be38a2980fbc8a979ee4d6cd';

/// See also [authService].
@ProviderFor(authService)
final authServiceProvider = Provider<AuthServiceRepository>.internal(
  authService,
  name: r'authServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthServiceRef = ProviderRef<AuthServiceRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
