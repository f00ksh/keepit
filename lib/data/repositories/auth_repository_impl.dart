// ignore_for_file: avoid_print

import 'package:keepit/domain/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_service_repository.dart';
import '../../core/constants/app_constants.dart';

class AuthRepositoryImpl implements AuthServiceRepository {
  final SupabaseClient _client;

  AuthRepositoryImpl(this._client);

  @override
  Future<AppUser?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;
      return AppUser.fromJson(user.toJson());
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      print('Starting Google sign in...');

      // Clear any existing sessions before starting new sign in
      if (_client.auth.currentSession != null) {
        await _client.auth.signOut();
      }

      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AppConstants.redirectUrl,
        queryParams: {
          'access_type': 'offline',
          'prompt': 'select_account',
        },
        authScreenLaunchMode: LaunchMode.platformDefault,
      );

      print('OAuth response: $response');

      if (!response) {
        throw Exception('Google sign in failed: No response');
      }

      // Wait for auth state change with timeout
      print('Waiting for auth state change...');
      final authResponse = await _client.auth.onAuthStateChange
          .where((state) => state.event == AuthChangeEvent.signedIn)
          .first
          .timeout(
            const Duration(minutes: 1),
            onTimeout: () => throw Exception('Sign in timeout'),
          );

      final user = authResponse.session?.user;
      if (user == null) {
        throw Exception('User not found after sign in');
      }

      print('User signed in successfully: ${user.email}');

      // Create or update user profile
      await _createOrUpdateUserProfile(user);

      return AppUser.fromJson(user.toJson());
    } on AuthException catch (e) {
      print('Auth Exception: ${e.message}, Status: ${e.statusCode}');
      throw Exception('Authentication failed: ${e.message}');
    } catch (e) {
      print('Sign in error: $e');
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }

  Future<void> _createOrUpdateUserProfile(user) async {
    try {
      print('Updating user profile...');
      await _client.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'],
        'avatar_url': user.userMetadata?['avatar_url'],
        'updated_at': DateTime.now().toIso8601String(),
      });
      print('Profile updated successfully');
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      print('Auth state changed: ${event.event}, User: ${user?.email}');
      return user == null ? null : AppUser.fromJson(user.toJson());
    });
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception('User not found after sign in');

      await _createOrUpdateUserProfile(user);
      return AppUser.fromJson(user.toJson());
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  @override
  Future<AppUser> signUpWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception('User not found after sign up');

      await _createOrUpdateUserProfile(user);
      return AppUser.fromJson(user.toJson());
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Exception _handleAuthError(dynamic error) {
    if (error is AuthException) {
      return Exception('Authentication failed: ${error.message}');
    }
    return Exception('Authentication failed: ${error.toString()}');
  }
}
