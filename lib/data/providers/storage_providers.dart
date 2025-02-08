import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../services/sync_service.dart';
import '../repositories/note_repository_impl.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/services/auth_service.dart';

part 'storage_providers.g.dart';

@riverpod
StorageService storageService(ref) {
  throw UnimplementedError('Should be overridden in main');
}

@riverpod
SupabaseService supabaseService(ref) {
  throw UnimplementedError('Should be overridden in main');
}

@riverpod
SyncService syncService(ref) {
  return SyncService(
    ref.watch(storageServiceProvider),
    ref.watch(supabaseServiceProvider),
  );
}

@Riverpod(keepAlive: true)
NoteRepository noteRepository(ref) {
  final storageService = ref.watch(storageServiceProvider);
  return NoteRepositoryImpl(storageService);
}

@riverpod
AuthService authService(ref) {
  throw UnimplementedError('Should be overridden in main');
}
