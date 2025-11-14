import 'package:flutter/material.dart';
import 'subject_constants.dart';

class SubjectUtils {
  static List<Map<String, dynamic>> processSubjectsWithGroups(
      List<Map<String, dynamic>> subjects,
      List<Map<String, dynamic>> allGroups,
      ) {
    final subjectGroupCount = <int, int>{};

    for (var group in allGroups) {
      final subjectId = group['subjectId'] as int?;
      if (subjectId != null) {
        subjectGroupCount[subjectId] = (subjectGroupCount[subjectId] ?? 0) + 1;
      }
    }

    final processedSubjects = subjects.map((subject) {
      final subjectId = subject['id'] as int;
      final subjectName = subject['name'] as String;
      final groupCount = subjectGroupCount[subjectId] ?? 0;

      return {
        'id': subjectId,
        'name': subjectName,
        'groupCount': groupCount,
        'color': SubjectConstants.getColorForSubject(subjectName),
        'icon': SubjectConstants.getIconForSubject(subjectName),
      };
    }).toList();

    return processedSubjects;
  }

  static List<Map<String, dynamic>> getPopularSubjects(
      List<Map<String, dynamic>> subjects,
      List<Map<String, dynamic>> allGroups, {
        int limit = 6,
      }) {
    final processedSubjects = processSubjectsWithGroups(subjects, allGroups);

    final subjectsWithGroups = processedSubjects
        .where((subject) => subject['groupCount'] > 0)
        .toList();

    subjectsWithGroups.sort((a, b) => (b['groupCount'] as int).compareTo(a['groupCount'] as int));

    return subjectsWithGroups.take(limit).toList();
  }

  static Map<String, dynamic> getSubjectInfo(Map<String, dynamic> subject) {
    final subjectName = subject['name'] as String;
    return SubjectConstants.getSubjectInfo(subjectName, id: subject['id'] as int?);
  }

  static void debugSubjects(List<Map<String, dynamic>> subjects) {
    print('🔍 DEBUG: Subjects information');
    print('Total subjects: ${subjects.length}');

    for (var subject in subjects) {
      print('   - ${subject['name']} (${subject['id']}): ${subject['groupCount']} groups');
    }
  }
}