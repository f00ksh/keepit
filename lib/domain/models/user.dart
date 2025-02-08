class AppUser {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;

  AppUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      name: json['user_metadata']?['full_name'],
      photoUrl: json['user_metadata']?['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
    };
  }
}
