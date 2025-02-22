import 'package:keepit/data/providers/service_providers.dart';
import 'package:keepit/domain/models/note.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive/hive.dart';
import '../../domain/models/user.dart';
part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  static const String _boxName = 'auth';
  late Box<AppUser> _box;

  @override
  Stream<AppUser?> build() async* {
    _box = await Hive.openBox<AppUser>(_boxName);

    // First check Supabase auth state
    final supabaseUser = await ref.read(authServiceProvider).getCurrentUser();
    if (supabaseUser != null) {
      // User is authenticated with Supabase
      final user = AppUser.fromJson(supabaseUser.toJson());
      await _box.put('current_user', user);
      yield user;
      return;
    }

    // Check for stored anonymous user
    final storedUser = _box.get('current_user');
    if (storedUser != null) {
      yield storedUser;
      return;
    }

    yield null;
  }

  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    try {
      final anonymousUser = AppUser.anonymous();
      await _box.put('current_user', anonymousUser);
      state = AsyncData(anonymousUser);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final currentUser = state.valueOrNull;
      final authData = await ref.read(authServiceProvider).signInWithGoogle();

      // If user was anonymous, keep their ID for data migration
      final user = currentUser?.isAnonymous == true
          ? currentUser!.copyWithAuthData(authData.toJson())
          : AppUser.fromJson(authData.toJson());

      await _box.put('current_user', user);

      // If we have a previous anonymous ID, migrate the data
      if (user.previousAnonymousId != null) {
        await _migrateAnonymousData(user.previousAnonymousId!, user.id);
      }

      state = AsyncData(user);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).signInWithEmail(email, password),
    );
  }

  Future<void> signUpWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).signUpWithEmail(email, password),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      final currentUser = state.valueOrNull;
      if (currentUser != null && !currentUser.isAnonymous) {
        await ref.read(authServiceProvider).signOut();
      }
      await _box.delete('current_user');
      state = const AsyncData(null);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> _migrateAnonymousData(String oldId, String newId) async {
    // Migrate notes from anonymous user to authenticated user
    final notesBox = await Hive.openBox<Note>('notes');
    final notes = notesBox.values.where((note) => note.id == oldId);

    for (final note in notes) {
      final updatedNote = note.copyWith(id: newId);
      await notesBox.put(updatedNote.id, updatedNote);
    }
  }

  // Convenience getters
  AppUser? get currentUser => state.valueOrNull;
}

@riverpod
AppUser? currentUser(ref) {
  return ref.watch(authProvider).valueOrNull;
}

@riverpod
String? authError(ref) {
  return ref.watch(authProvider).whenOrNull(
        error: (error, _) => error.toString(),
      );
}
