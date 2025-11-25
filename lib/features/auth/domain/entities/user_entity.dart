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

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      userId: json['user_id'] ?? json['userId'],
      email: json['email'],
      password: json['password'] ?? '',
      profileImage: json['profile_image'] ?? json['profileImage'],
      createdAt: json['created_at'] ?? json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      'email': email,
      'password': password,
      if (profileImage != null) 'profileImage': profileImage,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

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