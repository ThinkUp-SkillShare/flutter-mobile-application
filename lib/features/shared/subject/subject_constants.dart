import 'package:flutter/material.dart';

class SubjectConstants {
  static final Map<String, Color> subjectColors = {
    'Matemáticas': const Color(0xFF3498DB),
    'Mathematics': const Color(0xFF3498DB),
    'Lengua y Literatura': const Color(0xFFE74C3C),
    'Literature': const Color(0xFFE74C3C),
    'Literatura': const Color(0xFFE74C3C),
    'Historia': const Color(0xFF9B59B6),
    'History': const Color(0xFF9B59B6),
    'Ciencias Naturales': const Color(0xFF27AE60),
    'Science': const Color(0xFF27AE60),
    'Ciencias': const Color(0xFF27AE60),
    'Física': const Color(0xFFE67E22),
    'Physics': const Color(0xFFE67E22),
    'Química': const Color(0xFF34495E),
    'Chemistry': const Color(0xFF34495E),
    'Biología': const Color(0xFF1ABC9C),
    'Biology': const Color(0xFF1ABC9C),
    'Informática': const Color(0xFF8E44AD),
    'Technology': const Color(0xFF8E44AD),
    'Tecnología': const Color(0xFF8E44AD),
    'Computer': const Color(0xFF8E44AD),
    'Arte': const Color(0xFFF39C12),
    'Arts': const Color(0xFFF39C12),
    'Inglés': const Color(0xFFD35400),
    'English': const Color(0xFFD35400),
    'Filosofía': const Color(0xFF16A085),
    'Philosophy': const Color(0xFF16A085),
    'Economía': const Color(0xFFC0392B),
    'Economy': const Color(0xFFC0392B),
    'Geografía': const Color(0xFF2980B9),
    'Geography': const Color(0xFF2980B9),
    'Educación Cívica': const Color(0xFF7F8C8D),
    'Civic Education': const Color(0xFF7F8C8D),
    'Música': const Color(0xFF27AE60),
    'Music': const Color(0xFF27AE60),
  };

  static final Map<String, IconData> subjectIcons = {
    'Matemáticas': Icons.functions,
    'Mathematics': Icons.functions,
    'Lengua y Literatura': Icons.menu_book,
    'Literature': Icons.menu_book,
    'Literatura': Icons.menu_book,
    'Historia': Icons.history_edu,
    'History': Icons.history_edu,
    'Ciencias Naturales': Icons.science,
    'Science': Icons.science,
    'Ciencias': Icons.science,
    'Física': Icons.bolt,
    'Physics': Icons.bolt,
    'Química': Icons.biotech,
    'Chemistry': Icons.biotech,
    'Biología': Icons.psychology,
    'Biology': Icons.psychology,
    'Informática': Icons.computer,
    'Technology': Icons.computer,
    'Tecnología': Icons.computer,
    'Computer': Icons.computer,
    'Arte': Icons.palette,
    'Arts': Icons.palette,
    'Inglés': Icons.language,
    'English': Icons.language,
    'Filosofía': Icons.lightbulb,
    'Philosophy': Icons.lightbulb,
    'Economía': Icons.attach_money,
    'Economy': Icons.attach_money,
    'Geografía': Icons.public,
    'Geography': Icons.public,
    'Educación Cívica': Icons.school,
    'Civic Education': Icons.school,
    'Música': Icons.music_note,
    'Music': Icons.music_note,
  };

  static final List<Color> fallbackColors = [
    const Color(0xFF3498DB),
    const Color(0xFFE74C3C),
    const Color(0xFF9B59B6),
    const Color(0xFF27AE60),
    const Color(0xFFE67E22),
    const Color(0xFF34495E),
    const Color(0xFF1ABC9C),
    const Color(0xFFF39C12),
    const Color(0xFFD35400),
    const Color(0xFFC0392B),
    const Color(0xFF8E44AD),
    const Color(0xFF16A085),
    const Color(0xFF2C3E50),
    const Color(0xFF7F8C8D),
    const Color(0xFFBDC3C7),
  ];

  static final List<IconData> fallbackIcons = [
    Icons.functions,
    Icons.menu_book,
    Icons.account_balance,
    Icons.science,
    Icons.bolt,
    Icons.biotech,
    Icons.psychology,
    Icons.computer,
    Icons.palette,
    Icons.language,
    Icons.lightbulb,
    Icons.attach_money,
    Icons.public,
    Icons.school,
    Icons.music_note,
  ];

  static Color getColorForSubject(String subjectName, {int? fallbackIndex}) {
    return subjectColors[subjectName] ??
        fallbackColors[fallbackIndex ?? (subjectName.hashCode % fallbackColors.length).abs()];
  }

  static IconData getIconForSubject(String subjectName, {int? fallbackIndex}) {
    return subjectIcons[subjectName] ??
        fallbackIcons[fallbackIndex ?? (subjectName.hashCode % fallbackIcons.length).abs()];
  }

  static Map<String, dynamic> getSubjectInfo(String subjectName, {int? id}) {
    return {
      'id': id,
      'name': subjectName,
      'color': getColorForSubject(subjectName),
      'icon': getIconForSubject(subjectName),
    };
  }
}