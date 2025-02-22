import '../models/user.dart';

abstract class AuthServiceRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signUpWithEmail(String email, String password);
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInAnonymously();
  Future<void> signOut();
  Stream<AppUser?> get authStateChanges;
  Future<void> setOfflineMode(bool enabled);
}
