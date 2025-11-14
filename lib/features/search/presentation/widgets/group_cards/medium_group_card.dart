import 'package:flutter/material.dart';

class MediumGroupCard extends StatelessWidget {
  final Map<String, dynamic> group;

  const MediumGroupCard({
    super.key,
    required this.group,
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
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
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
                  Colors.primaries[group['id'] % Colors.primaries.length].withOpacity(0.7),
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
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _hasValidImage(coverImage)
                          ? Colors.white.withOpacity(0.9)
                          : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      subjectName,
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group['name'] ?? 'Unnamed Group',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    group['description'] ?? 'No description',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$memberCount members',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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