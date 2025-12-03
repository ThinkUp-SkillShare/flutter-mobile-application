import 'package:flutter/material.dart';

/// Card widget used to display an individual group in the groups list.
/// Includes group image, subject tag, name, description, and member count.
/// Tapping the card triggers navigation to the detailed group screen.
class MyGroupCard extends StatelessWidget {
  final Map<String, dynamic> group;
  final VoidCallback onTap;

  const MyGroupCard({
    super.key,
    required this.group,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// Allows the entire card to be tappable.
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          /// Rounded card edges for modern UI appearance.
          borderRadius: BorderRadius.circular(16),

          /// Soft shadow for elevation effect.
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top section displaying the group cover image.
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),

                /// Displays a custom group cover image or a fallback placeholder.
                image: DecorationImage(
                  image: NetworkImage(
                    group['coverImage'] ?? 'https://i.pinimg.com/originals/45/c1/fc/45c1fcf4aaae94a8ab0015e186070d22.gif',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  /// Subject tag displayed in the top-left corner of the image.
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBBE1FA),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        group['subjectName'] ?? 'General',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// Main content section: name, description, members.
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Group name with ellipsis for long titles.
                  Text(
                    group['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),

                  /// Short description preview.
                  Text(
                    group['description'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),

                  /// Row showing the number of group members.
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${group['memberCount'] ?? 0} members',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
