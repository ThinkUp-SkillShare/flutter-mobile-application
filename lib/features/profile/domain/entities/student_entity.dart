import 'package:flutter/material.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Represents a Student entity with personal information and user data.
/// Follows DDD principles by encapsulating business logic within the entity.
class Student {
  final int id;
  final String firstName;
  final String lastName;
  final String? nickname;
  final DateTime? dateBirth;
  final String? country;
  final String? educationalCenter;
  final String gender;
  final int? userType;
  final int? userId;
  final UserEntity? user;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.nickname,
    this.dateBirth,
    this.country,
    this.educationalCenter,
    required this.gender,
    this.userType,
    this.userId,
    this.user,
  });

  /// Creates a Student instance from JSON data.
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      nickname: json['nickname'],
      dateBirth: json['dateBirth'] != null ? DateTime.parse(json['dateBirth']) : null,
      country: json['country'],
      educationalCenter: json['educationalCenter'],
      gender: json['gender'],
      userType: json['userType'],
      userId: json['userId'],
      user: json['user'] != null ? UserEntity.fromJson(json['user']) : null,
    );
  }

  /// Converts the Student instance to JSON format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'nickname': nickname,
      'dateBirth': dateBirth?.toIso8601String(),
      'country': country,
      'educationalCenter': educationalCenter,
      'gender': gender,
      'userType': userType,
      'userId': userId,
      'user': user?.toJson(),
    };
  }

  /// Creates a copy of the Student with updated fields.
  Student copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? nickname,
    DateTime? dateBirth,
    String? country,
    String? educationalCenter,
    String? gender,
    int? userType,
    int? userId,
    UserEntity? user,
  }) {
    return Student(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nickname: nickname ?? this.nickname,
      dateBirth: dateBirth ?? this.dateBirth,
      country: country ?? this.country,
      educationalCenter: educationalCenter ?? this.educationalCenter,
      gender: gender ?? this.gender,
      userType: userType ?? this.userType,
      userId: userId ?? this.userId,
      user: user ?? this.user,
    );
  }

  /// Calculates the student's age based on date of birth.
  int? get age {
    if (dateBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateBirth!.year;
    if (now.month < dateBirth!.month ||
        (now.month == dateBirth!.month && now.day < dateBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Returns the flag emoji for the student's country.
  String get countryFlag {
    const countryFlags = {
      'Perú': '🇵🇪',
      'México': '🇲🇽',
      'Canada': '🇨🇦',
      'United States': '🇺🇸',
      'Spain': '🇪🇸',
      'Argentina': '🇦🇷',
      'Chile': '🇨🇱',
      'Colombia': '🇨🇴',
      'Brazil': '🇧🇷',
      'United Kingdom': '🇬🇧',
      'France': '🇫🇷',
      'Germany': '🇩🇪',
      'Italy': '🇮🇹',
      'Japan': '🇯🇵',
      'China': '🇨🇳',
      'India': '🇮🇳',
      'Australia': '🇦🇺',
    };
    return countryFlags[country] ?? '🏳️';
  }

  /// Returns the appropriate icon for the student's gender.
  IconData get genderIcon {
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      case 'other':
        return Icons.transgender;
      case 'prefer_not_to_say':
        return Icons.visibility_off_outlined;
      default:
        return Icons.help_outline;
    }
  }

  /// Returns the color associated with the student's gender.
  Color get genderColor {
    switch (gender.toLowerCase()) {
      case 'male':
        return Colors.blue;
      case 'female':
        return Colors.pink;
      case 'other':
        return Colors.purple;
      case 'prefer_not_to_say':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Returns the year the student joined based on user creation date.
  int? get joinedYear {
    if (user?.createdAt != null) {
      try {
        if (user!.createdAt is String) {
          final date = DateTime.parse(user!.createdAt!);
          return date.year;
        }
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}