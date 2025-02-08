import 'package:keepit/data/providers/supabase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/user.dart';
part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  Stream<AppUser?> build() {
    // Initialize by getting current user
    _initCurrentUser();
    // Listen to auth state changes
    return ref.watch(authServiceProvider).authStateChanges;
  }

  Future<void> _initCurrentUser() async {
    // Get initial user state
    final currentUser = await ref.read(authServiceProvider).getCurrentUser();
    if (currentUser != null) {
      state = AsyncData(currentUser);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).signInWithGoogle(),
    );
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
    state = await AsyncValue.guard<AppUser?>(
      () async {
        await ref.read(authServiceProvider).signOut();
        return null;
      },
    );
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
