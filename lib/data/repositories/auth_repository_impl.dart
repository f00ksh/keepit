// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:keepit/domain/models/user.dart';
import 'package:keepit/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';

class AuthRepositoryImpl implements AuthServiceRepository {
  final SupabaseClient _client;
  bool _isOfflineMode =
      false; // Changed to false to enable online features by default

  AuthRepositoryImpl(this._client);

  @override
  Future<AppUser?> getCurrentUser() async {
    if (_isOfflineMode) {
      // Return null to indicate no authenticated user in offline mode
      return null;
    }
    try {
      final user = _client.auth.currentUser;
      return user == null ? null : AppUser.fromJson(user.toJson());
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  // signIn Annyomous
  @override
  Future<AppUser> signInAnonymously() async {
    try {
      if (_isOfflineMode) {
        // Create a local anonymous user
        return AppUser(
          id: const Uuid().v4(),
          email: null,
          isAnonymous: true,
        );
      }

      final response = await _client.auth.signInAnonymously();
      final user = response.user;

      if (user == null) {
        throw Exception('Failed to create anonymous user');
      }

      final appUser = AppUser.fromJson(user.toJson());
      await _createOrUpdateUserProfile(appUser);
      return appUser;
    } catch (e) {
      print('Anonymous sign in error: $e');
      throw Exception('Failed to sign in anonymously: $e');
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      debugPrint('Starting Google sign in...');
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AppConstants.redirectUrl,
      );

      if (!response) throw Exception('Google sign in failed');

      // Wait for session to be available - increase timeout and add retry logic
      int attempts = 0;
      AppUser? appUser;

      while (attempts < 3 && appUser == null) {
        await Future.delayed(const Duration(seconds: 2));
        final user = _client.auth.currentUser;

        if (user != null) {
          debugPrint(
              'Google sign in successful. Metadata: ${user.userMetadata}');

          appUser = AppUser.fromJson({
            'id': user.id,
            'email': user.email,
            'user_metadata': user.userMetadata,
            'is_anonymous': false,
          });

          // Create or update user profile
          await _createOrUpdateUserProfile(appUser);
          debugPrint('Created AppUser with photo: ${appUser.photoUrl}');
          return appUser;
        }

        attempts++;
        debugPrint('Attempt $attempts: Waiting for Google auth to complete...');
      }

      throw Exception('No user after Google sign in after multiple attempts');
    } catch (e) {
      debugPrint('Google sign in error: $e');
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  Future<void> _createOrUpdateUserProfile(AppUser user) async {
    try {
      debugPrint('Updating profile for user: ${user.id}');
      debugPrint('Profile data: ${user.toJson()}');

      await _client.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        'full_name': user.name,
        'avatar_url': user.photoUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      debugPrint('Profile updated successfully');
    } catch (e) {
      debugPrint('Error updating profile: $e');
      // Don't throw the error as profile update is not critical
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
    if (_isOfflineMode) return Stream.value(null);

    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      debugPrint('Auth state changed: ${event.event}, User: ${user?.email}');

      if (user != null) {
        // Get full user data including metadata
        final metadata = user.userMetadata;
        debugPrint('User metadata: $metadata');

        final appUser = AppUser.fromJson({
          'id': user.id,
          'email': user.email,
          'user_metadata': metadata,
          'is_anonymous': false,
        });

        // Try to update profile but don't wait for it
        _createOrUpdateUserProfile(appUser);

        return appUser;
      }
      return null;
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

      final appUser = AppUser.fromJson(user.toJson());
      await _createOrUpdateUserProfile(appUser);
      return appUser;
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

      final appUser = AppUser.fromJson(user.toJson());
      await _createOrUpdateUserProfile(appUser);
      return appUser;
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

  // Method to toggle offline mode
  @override
  Future<void> setOfflineMode(bool enabled) async {
    _isOfflineMode = enabled;
    if (enabled) {
      // Sign out from Supabase if we're switching to offline mode
      await signOut();
    }
  }
}
