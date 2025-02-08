import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/hive_stoarge_service.dart';
import '../services/supabase_stoarge_service.dart';
import '../services/sync_service.dart';
import '../repositories/note_repository_impl.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/repositories/auth_service_repository.dart';

part 'supabase_providers.g.dart';

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
AuthServiceRepository authService(ref) {
  throw UnimplementedError('Should be overridden in main');
}
