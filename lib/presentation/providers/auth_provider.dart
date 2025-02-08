import 'package:keepit/data/providers/storage_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/user.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  Stream<AppUser?> build() {
    return ref.watch(authServiceProvider).authStateChanges;
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(authServiceProvider).signInWithGoogle());
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
  }
}
