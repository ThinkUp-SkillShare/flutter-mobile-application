import 'package:flutter/material.dart';

class LargeGroupCard extends StatelessWidget {
  final Map<String, dynamic> group;

  const LargeGroupCard({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final memberCount = group['memberCount'] ?? 0;
    final subjectName = group['subjectName'] ?? 'General';
    final createdAt = DateTime.parse(group['createdAt'] ?? DateTime.now().toIso8601String());
    final daysAgo = DateTime.now().difference(createdAt).inDays;
    final coverImage = group['cover_image'] ?? group['coverImage'];

    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 16, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              image: _hasValidImage(coverImage)
                  ? DecorationImage(
                image: NetworkImage(coverImage.toString()),
                fit: BoxFit.cover,
              )
                  : null,
              gradient: !_hasValidImage(coverImage)
                  ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F4C75),
                  Color(0xFF3282B8),
                ],
              )
                  : null,
            ),
            child: Stack(
              children: [
                if (_hasValidImage(coverImage))
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _hasValidImage(coverImage)
                          ? Colors.white.withOpacity(0.9)
                          : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subjectName,
                      style: TextStyle(
                        color: const Color(0xFF2C3E50),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (!_hasValidImage(coverImage))
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'No Image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['name'] ?? 'Unnamed Group',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
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
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '$memberCount members',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      daysAgo == 0 ? 'Today' : '$daysAgo days ago',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasValidImage(dynamic image) {
    return image != null &&
        image.toString().isNotEmpty &&
        image.toString().startsWith('http');
  }
}