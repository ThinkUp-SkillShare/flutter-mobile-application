import 'package:flutter/material.dart';

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
  });

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
    );
  }

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
    };
  }

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

  IconData get genderIcon {
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.male;
      case 'female':
        return Icons.female;
      default:
        return Icons.transgender;
    }
  }

  Color get genderColor {
    switch (gender.toLowerCase()) {
      case 'male':
        return Colors.blue;
      case 'female':
        return Colors.pink;
      default:
        return Colors.purple;
    }
  }
}