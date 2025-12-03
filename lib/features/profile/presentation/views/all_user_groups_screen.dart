import 'package:flutter/material.dart';
import '../../../groups/presentation/views/group_detail_screen.dart';

/// Screen displaying all groups that the user belongs to.
/// Shows detailed list view of groups with navigation to group details.
class AllUserGroupsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> userGroups;
  final int userId;

  const AllUserGroupsScreen({
    super.key,
    required this.userGroups,
    required this.userId,
  });

  /// Extracts image URL from group data, checking multiple possible fields.
  String _getImageUrl(Map<String, dynamic> group) {
    final possibleKeys = ['coverImage', 'cover_image', 'image', 'imageUrl'];

    for (final key in possibleKeys) {
      final value = group[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }

    return '';
  }

  /// Checks if an image URL is valid (non-empty and starts with http).
  bool _hasValidImage(String? imagePath) {
    return imagePath != null &&
        imagePath.isNotEmpty &&
        imagePath.startsWith('http');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'My Groups (${userGroups.length})',
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
    );
  }

  Widget _buildBody(BuildContext context) {
    if (userGroups.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: userGroups.length,
      itemBuilder: (context, index) => _buildGroupItem(context, userGroups[index]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            'You don\'t belong to any group',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join groups to start collaborating',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupItem(BuildContext context, Map<String, dynamic> group) {
    final isCreator = group['created_by'] == userId;
    final imageUrl = _getImageUrl(group);
    final hasValidImage = _hasValidImage(imageUrl);

    return GestureDetector(
      onTap: () => _navigateToGroupDetail(context, group),
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
            _buildGroupImage(imageUrl, hasValidImage),
            _buildGroupInfo(group, isCreator),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupImage(String imageUrl, bool hasValidImage) {
    return Container(
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
    );
  }

  Widget _buildGroupInfo(Map<String, dynamic> group, bool isCreator) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group['name'] ?? 'No name',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCreator) _buildCreatorBadge(),
              ],
            ),
            if (group['description'] != null && group['description'].toString().isNotEmpty)
              _buildDescription(group['description']),
            const SizedBox(height: 8),
            _buildGroupStats(group),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatorBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.shade700,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Creator',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDescription(String description) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildGroupStats(Map<String, dynamic> group) {
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.people_alt,
          text: '${group['memberCount'] ?? 0} members',
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          icon: Icons.subject,
          text: group['subjectName'] ?? 'No subject',
        ),
      ],
    );
  }

  Widget _buildStatItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultGroupIcon() {
    return Icon(
      Icons.group,
      color: Colors.grey.shade500,
      size: 30,
    );
  }

  void _navigateToGroupDetail(BuildContext context, Map<String, dynamic> group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailScreen(
          groupId: group['id'] ?? 0,
        ),
      ),
    );
  }
}