import '../../../auth/domain/entities/user_entity.dart';

class UserModel {
  final int? userId;
  final String email;
  final String password;
  final String? profileImage;
  final String? createdAt;

  UserModel({
    this.userId,
    required this.email,
    required this.password,
    this.profileImage,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as int?,
      email: json['email'] as String,
      password: '',
      profileImage: json['profileImage'] as String?,
      createdAt: json['createdAt'] as String?,
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

  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      email: email,
      password: password,
      profileImage: profileImage,
      createdAt: createdAt,
    );
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
}