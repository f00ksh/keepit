import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

part 'user.g.dart';

@HiveType(typeId: 3)
class AppUser extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String? email;

  @HiveField(2)
  final bool isAnonymous;

  @HiveField(3)
  final String? name;

  @HiveField(4)
  final String? photoUrl;

  @HiveField(5)
  final String? previousAnonymousId; // To handle migration of anonymous data

  AppUser({
    required this.id,
    this.email,
    this.isAnonymous = false,
    this.name,
    this.photoUrl,
    this.previousAnonymousId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final metadata =
        json['user_metadata'] ?? json['identities']?[0]?['identity_data'];
    final avatarUrl = metadata?['avatar_url'] ??
        metadata?['picture'] ??
        json['user_metadata']?['avatar_url'] ??
        json['user_metadata']?['picture'];

    debugPrint('Creating AppUser from JSON with metadata: $metadata');
    debugPrint('Avatar URL found: $avatarUrl');

    return AppUser(
      id: json['id'],
      email: json['email'] ?? metadata?['email'],
      isAnonymous: json['is_anonymous'] ?? false,
      name: metadata?['full_name'] ?? metadata?['name'],
      photoUrl: avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'is_anonymous': isAnonymous,
      'user_metadata': {
        'full_name': name,
        'avatar_url': photoUrl,
      },
    };
  }

  factory AppUser.anonymous() {
    return AppUser(
      id: const Uuid().v4(),
      isAnonymous: true,
    );
  }

  AppUser copyWithAuthData(Map<String, dynamic> authData) {
    return AppUser(
      id: authData['id'],
      email: authData['email'],
      isAnonymous: false,
      name: authData['user_metadata']?['full_name'],
      photoUrl: authData['user_metadata']?['avatar_url'],
      previousAnonymousId: isAnonymous ? id : null,
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    bool? isAnonymous,
    String? name,
    String? photoUrl,
    String? previousAnonymousId,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      previousAnonymousId: previousAnonymousId ?? this.previousAnonymousId,
    );
  }

  // Method to update with previous anonymous ID
  AppUser withPreviousAnonymousId(String anonymousId) {
    return copyWith(
      previousAnonymousId: anonymousId,
    );
  }
}
