import 'package:flutter/material.dart';
import '../../../groups/presentation/views/group_detail_screen.dart';

/// Card widget for displaying group information in a visually appealing format.
/// Used in profile screen to show user's groups.
class GroupCardWidget extends StatelessWidget {
  final String groupName;
  final String groupDescription;
  final String groupMembers;
  final String imagePath;
  final bool isUserCreator;
  final int groupId;

  const GroupCardWidget({
    super.key,
    required this.groupName,
    required this.groupDescription,
    required this.groupMembers,
    required this.imagePath,
    this.isUserCreator = false,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToGroupDetail(context),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupImage(),
            _buildGroupContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupImage() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        color: Colors.grey.shade200,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: imagePath.isNotEmpty
            ? Image.network(
          imagePath,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultGroupImage();
          },
        )
            : _buildDefaultGroupImage(),
      ),
    );
  }

  Widget _buildGroupContent() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupHeader(),
            const SizedBox(height: 8),
            if (groupDescription.isNotEmpty) _buildDescription(),
            const Spacer(),
            _buildMembersInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            groupName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isUserCreator) _buildCreatorBadge(),
      ],
    );
  }

  Widget _buildCreatorBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _buildDescription() {
    return Text(
      groupDescription,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMembersInfo() {
    return Row(
      children: [
        Icon(
          Icons.people_alt,
          size: 14,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Text(
          groupMembers,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultGroupImage() {
    return Container(
      color: Colors.grey.shade300,
      child: Center(
        child: Icon(
          Icons.group,
          size: 40,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  void _navigateToGroupDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailScreen(groupId: groupId),
      ),
    );
  }
}