import 'package:flutter/material.dart';

class CompactGroupCard extends StatelessWidget {
  final Map<String, dynamic> group;
  final Function(int) onJoinGroup;
  final bool showNewBadge;

  const CompactGroupCard({
    super.key,
    required this.group,
    required this.onJoinGroup,
    this.showNewBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final memberCount = group['memberCount'] ?? 0;
    final subjectName = group['subjectName'] ?? 'General';
    final coverImage = group['cover_image'] ?? group['coverImage'];

    return Container(
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
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: _hasValidImage(coverImage)
                    ? DecorationImage(
                  image: NetworkImage(coverImage.toString()),
                  fit: BoxFit.cover,
                )
                    : null,
                gradient: !_hasValidImage(coverImage)
                    ? LinearGradient(
                  colors: [
                    Colors.primaries[group['id'] % Colors.primaries.length],
                    Colors.primaries[group['id'] % Colors.primaries.length].withOpacity(0.6),
                  ],
                )
                    : null,
              ),
              child: !_hasValidImage(coverImage)
                  ? const Center(
                child: Icon(Icons.groups, color: Colors.white, size: 32),
              )
                  : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBBE1FA),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          subjectName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (showNewBadge) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    group['name'] ?? 'Unnamed Group',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    group['description'] ?? 'No description',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '$memberCount members',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onJoinGroup(group['id']),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F4C75),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Join',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasValidImage(dynamic image) {
    return image != null &&
        image.toString().isNotEmpty &&
        image.toString().startsWith('http');
  }
}