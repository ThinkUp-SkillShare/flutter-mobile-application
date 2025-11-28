/// Represents a user entity with identification, authentication,
/// and profile-related information.
///
/// This model supports flexible JSON parsing to handle both
/// snake_case and camelCase API responses.
class UserEntity {
  final int? userId;
  final String email;
  final String password;
  final String? profileImage;
  final String? createdAt;

  UserEntity({
    this.userId,
    required this.email,
    required this.password,
    this.profileImage,
    this.createdAt,
  });

  /// Creates an instance from a JSON map.
  /// Accepts both `snake_case` and `camelCase` conventions for flexibility.
  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      userId: json['user_id'] ?? json['userId'],
      email: json['email'],
      password: json['password'] ?? '',
      profileImage: json['profile_image'] ?? json['profileImage'],
      createdAt: json['created_at'] ?? json['createdAt'],
    );
  }

  /// Converts this entity into a JSON map.
  /// Only non-null properties are included to keep payloads clean.
  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      'email': email,
      'password': password,
      if (profileImage != null) 'profileImage': profileImage,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  /// Returns a new [UserEntity] with selectively updated fields.
  /// Useful for immutable state updates.
  UserEntity copyWith({
    int? userId,
    String? email,
    String? password,
    String? profileImage,
    String? createdAt,
  }) {
    return UserEntity(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      password: password ?? this.password,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Equality override to compare entity instances by value
  /// rather than memory reference.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity &&
        other.userId == userId &&
        other.email == email &&
        other.password == password &&
        other.profileImage == profileImage &&
        other.createdAt == createdAt;
  }

  /// Generates a combined hash code for this entity.
  @override
  int get hashCode {
    return userId.hashCode ^
    email.hashCode ^
    password.hashCode ^
    profileImage.hashCode ^
    createdAt.hashCode;
  }
}
