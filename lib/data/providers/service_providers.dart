import 'package:keepit/data/services/hive_stoarge_service.dart';
import 'package:keepit/domain/repositories/auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/supabase_stoarge_service.dart';
import '../services/sync_service.dart';
import '../repositories/note_repository_impl.dart';

part 'service_providers.g.dart';

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
NoteRepositoryImpl noteRepository(ref) {
  final storageService = ref.watch(storageServiceProvider);
  return NoteRepositoryImpl(storageService);
}

@Riverpod(keepAlive: true)
AuthServiceRepository authService(ref) {
  throw UnimplementedError('Should be overridden in main');
}
