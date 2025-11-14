import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    super.userId,
    required super.email,
    required super.password,
    super.profileImage,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      email: json['email'],
      password: json['password'] ?? '',
      profileImage: json['profileImage'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'password': password,
      'profileImage': profileImage,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      userId: entity.userId,
      email: entity.email,
      password: entity.password,
      profileImage: entity.profileImage,
      createdAt: entity.createdAt,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      email: email,
      password: password,
      profileImage: profileImage,
      createdAt: createdAt,
    );
  }
}