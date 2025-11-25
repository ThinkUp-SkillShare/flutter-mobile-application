import 'package:flutter/material.dart';

/// A card widget used to display a single subject in a grid or list.
/// Shows an icon with background color, subject name, and number of groups.
/// The entire card is tappable through the `onTap` callback.
class SubjectCard extends StatelessWidget {
  final Map<String, dynamic> subject;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// Card is clickable; executes the provided callback when tapped.
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),

          /// Subtle shadow for elevation effect.
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top row: colored icon on the left and group count on the right.
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: subject['color'].withOpacity(0.1), // subtle background
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      subject['icon'], // dynamic icon for subject
                      color: subject['color'],
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${subject['groupCount']} groups',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              /// Subject name displayed prominently.
              Text(
                subject['name'],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
