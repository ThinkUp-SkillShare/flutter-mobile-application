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

  @override
  int get hashCode {
    return userId.hashCode ^
    email.hashCode ^
    password.hashCode ^
    profileImage.hashCode ^
    createdAt.hashCode;
  }
}