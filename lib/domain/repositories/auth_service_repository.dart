import '../models/user.dart';

abstract class AuthServiceRepository {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> signInAnonymously();
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signUpWithEmail(String email, String password);
  Future<void> signOut();
  Stream<AppUser?> get authStateChanges;
}
