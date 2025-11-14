import 'package:flutter/material.dart';
import '../../../shared/subject/subject_utils.dart';

class SubjectGrid extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;
  final List<Map<String, dynamic>> allGroups;
  final Function(int) onSubjectSelected;

  const SubjectGrid({
    super.key,
    required this.subjects,
    required this.allGroups,
    required this.onSubjectSelected,
  });

  @override
  Widget build(BuildContext context) {
    final displaySubjects = SubjectUtils.processSubjectsWithGroups(
      subjects.take(6).toList(),
      allGroups,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: displaySubjects.length,
      itemBuilder: (context, index) {
        final subject = displaySubjects[index];
        final subjectName = subject['name'] as String;
        final subjectId = subject['id'] as int;
        final groupCount = subject['groupCount'] as int;
        final color = subject['color'] as Color;
        final icon = subject['icon'] as IconData;

        return GestureDetector(
          onTap: () => onSubjectSelected(subjectId),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subjectName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$groupCount groups',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}