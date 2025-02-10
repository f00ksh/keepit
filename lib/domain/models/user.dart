import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

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
    return AppUser(
      id: json['id'],
      email: json['email'],
      isAnonymous: json['is_anonymous'] ?? false,
      name: json['user_metadata']?['full_name'],
      photoUrl: json['user_metadata']?['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'is_anonymous': isAnonymous,
      'name': name,
      'photo_url': photoUrl,
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
}
