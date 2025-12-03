import 'package:flutter/material.dart';
import '../../../domain/entities/student_entity.dart';
import '../group_card_widget.dart';
import '../../views/all_user_groups_screen.dart';

/// Widget for displaying user's groups section in profile.
class GroupsSection extends StatelessWidget {
  final List<Map<String, dynamic>> userGroups;
  final Student? student;

  const GroupsSection({
    super.key,
    required this.userGroups,
    required this.student,
  });

  void _navigateToAllGroups(BuildContext context) {
    if (userGroups.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllUserGroupsScreen(
          userGroups: userGroups,
          userId: student?.userId ?? 0,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(40),
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
      child: Column(
        children: [
          Icon(
            Icons.group_outlined,
            size: 50,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'You don\'t belong to any group',
            style: TextStyle(
              fontSize: 16,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: 16),
        _buildGroupsHorizontalList(),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Groups (${userGroups.length})',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: () => _navigateToAllGroups(context),
            child: const Text(
              'View all',
              style: TextStyle(
                color: Color(0xFF0F4C75),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsHorizontalList() {
    return SizedBox(
      height: 265,
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 20, right: 8),
        scrollDirection: Axis.horizontal,
        itemCount: userGroups.length > 3 ? 3 : userGroups.length,
        itemBuilder: (context, index) {
          final group = userGroups[index];
          final isCreator = group['created_by'] == student?.userId;

          String imageUrl = '';
          if (group['coverImage'] != null && group['coverImage'].toString().isNotEmpty) {
            imageUrl = group['coverImage'].toString();
          } else if (group['cover_image'] != null && group['cover_image'].toString().isNotEmpty) {
            imageUrl = group['cover_image'].toString();
          }

          return GroupCardWidget(
            groupName: group['name'] ?? 'No name',
            groupDescription: group['description'] ?? '',
            groupMembers: '${group['memberCount'] ?? 0} members',
            imagePath: imageUrl,
            isUserCreator: isCreator,
            groupId: group['id'] ?? 0,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userGroups.isEmpty) {
      return _buildEmptyState();
    }

    return _buildGroupsList(context);
  }
}