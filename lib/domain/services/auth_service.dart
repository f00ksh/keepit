import '../models/user.dart';

abstract class AuthService {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> signInWithGoogle();
  Future<void> signOut();
  Stream<AppUser?> get authStateChanges;
}
