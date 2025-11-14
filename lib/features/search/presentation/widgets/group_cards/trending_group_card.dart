import 'package:flutter/material.dart';

class TrendingGroupCard extends StatelessWidget {
  final Map<String, dynamic> group;

  const TrendingGroupCard({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final memberCount = group['memberCount'] ?? 0;
    final subjectName = group['subjectName'] ?? 'General';

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFDC2626),
            Color(0xFFEF4444),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    subjectName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.trending_up, color: Colors.white, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              group['name'] ?? 'Unnamed Group',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              group['description'] ?? 'No description',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withOpacity(0.8),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.people_outline, size: 16, color: Colors.white.withOpacity(0.8)),
                const SizedBox(width: 4),
                Text(
                  '$memberCount members',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}