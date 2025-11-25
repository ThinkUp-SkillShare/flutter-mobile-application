import 'package:flutter/material.dart';
import '../../../groups/presentation/views/group_detail_screen.dart';

class AllUserGroupsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> userGroups;
  final int userId;

  const AllUserGroupsScreen({
    super.key,
    required this.userGroups,
    required this.userId,
  });

  bool _hasValidImage(String? imagePath) {
    return imagePath != null &&
        imagePath.isNotEmpty &&
        imagePath.startsWith('http');
  }

  String _getImageUrl(Map<String, dynamic> group) {
    if (group['coverImage'] != null && group['coverImage'].toString().isNotEmpty) {
      return group['coverImage'].toString();
    } else if (group['cover_image'] != null && group['cover_image'].toString().isNotEmpty) {
      return group['cover_image'].toString();
    } else if (group['image'] != null && group['image'].toString().isNotEmpty) {
      return group['image'].toString();
    } else if (group['imageUrl'] != null && group['imageUrl'].toString().isNotEmpty) {
      return group['imageUrl'].toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          'Mis Grupos (${userGroups.length})',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: userGroups.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No perteneces a ningún grupo',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Únete a grupos para empezar a colaborar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: userGroups.length,
        itemBuilder: (context, index) {
          final group = userGroups[index];
          final isCreator = group['created_by'] == userId;
          final imageUrl = _getImageUrl(group);
          final hasValidImage = _hasValidImage(imageUrl);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailScreen(
                    groupId: group['id'] ?? 0,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Imagen del grupo
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade200,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: hasValidImage
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultGroupIcon();
                        },
                      )
                          : _buildDefaultGroupIcon(),
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  group['name'] ?? 'Sin nombre',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isCreator)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade700,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Creador',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          if (group['description'] != null && group['description'].toString().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              group['description'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.people_alt,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${group['memberCount'] ?? 0} miembros',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.subject,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                group['subjectName'] ?? 'Sin asignatura',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultGroupIcon() {
    return Icon(
      Icons.group,
      color: Colors.grey.shade500,
      size: 30,
    );
  }
}