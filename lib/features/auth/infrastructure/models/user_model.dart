import '../../domain/entities/user_entity.dart';

/// Data model representing a user, extending [UserEntity].
///
/// This class is mainly used for data transfer and JSON serialization.
class UserModel extends UserEntity {
  UserModel({
    super.userId,
    required super.email,
    required super.password,
    super.profileImage,
    super.createdAt,
  });

  /// Creates a [UserModel] instance from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      email: json['email'],
      password: json['password'] ?? '',
      profileImage: json['profileImage'],
      createdAt: json['createdAt'],
    );
  }

  /// Converts this model into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'password': password,
      'profileImage': profileImage,
      'createdAt': createdAt,
    };
  }

  /// Converts a [UserEntity] into a [UserModel].
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      userId: entity.userId,
      email: entity.email,
      password: entity.password,
      profileImage: entity.profileImage,
      createdAt: entity.createdAt,
    );
  }

  /// Converts this [UserModel] back to a [UserEntity].
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
