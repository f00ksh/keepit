import 'package:keepit/data/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_profile_provider.g.dart';

@riverpod
class UserProfile extends _$UserProfile {
  @override
  Future<UserProfile?> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return null;

    // Fetch additional user profile data from your backend
    // This could be from Supabase or any other source
    return _fetchUserProfile(user.id);
  }

  Future<UserProfile?> _fetchUserProfile(String userId) async {
    return null;

    // Implement your profile fetching logic
    // Return null if no profile exists
  }

  Future<void> updateProfile(UserProfile profile) async {
    // Implement profile update logic
  }
}
