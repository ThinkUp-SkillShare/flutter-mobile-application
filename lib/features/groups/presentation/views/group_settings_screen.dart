import 'package:flutter/material.dart';
import '../../../auth/application/auth_service.dart';
import '../../services/group_management_service.dart';
import 'edit_group_screen.dart';
import 'manage_members_screen.dart';

class GroupSettingsScreen extends StatefulWidget {
  final int groupId;
  final Map<String, dynamic> groupDetails;

  const GroupSettingsScreen({
    super.key,
    required this.groupId,
    required this.groupDetails,
  });

  @override
  State<GroupSettingsScreen> createState() => _GroupSettingsScreenState();
}

class _GroupSettingsScreenState extends State<GroupSettingsScreen> {
  Map<String, dynamic>? permissions;
  Map<String, dynamic>? statistics;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      final perms = await GroupManagementService.getUserPermissions(widget.groupId, token);
      final stats = await GroupManagementService.getGroupStatistics(widget.groupId, token);

      setState(() {
        permissions = perms;
        statistics = stats;
      });
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFD32F2F) : const Color(0xFF0F9D58),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _deleteGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text(
          'Are you sure you want to delete this group? This action cannot be undone and all members will lose access.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFD32F2F)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      final success = await GroupManagementService.deleteGroup(widget.groupId, token);

      if (success) {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          _showSnackBar('Group deleted successfully');
        }
      } else {
        _showSnackBar('Failed to delete group', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAFAFA),
          title: const Text('Group Settings'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final canEdit = permissions?['canEditGroup'] ?? false;
    final canDelete = permissions?['canDeleteGroup'] ?? false;
    final canManageMembers = permissions?['canManageMembers'] ?? false;
    final isOwner = permissions?['isOwner'] ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        surfaceTintColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF2C3E50)),
        ),
        title: const Text(
          'Group Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Statistics Card
          if (statistics != null) _buildStatisticsCard(),
          const SizedBox(height: 20),

          // Management Section
          _buildSectionTitle('Management'),
          const SizedBox(height: 12),

          if (canEdit)
            _buildSettingTile(
              icon: Icons.edit_rounded,
              title: 'Edit Group Details',
              subtitle: 'Change name, description, cover image',
              color: const Color(0xFF324779),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditGroupScreen(
                      groupId: widget.groupId,
                      groupDetails: widget.groupDetails,
                    ),
                  ),
                );
                if (result == true && mounted) {
                  Navigator.pop(context, true);
                }
              },
            ),

          if (canManageMembers)
            _buildSettingTile(
              icon: Icons.people_rounded,
              title: 'Manage Members',
              subtitle: 'View, promote, or remove members',
              color: const Color(0xFF0F9D58),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageMembersScreen(
                      groupId: widget.groupId,
                      groupName: widget.groupDetails['name'],
                      permissions: permissions!,
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 20),

          // Danger Zone
          if (canDelete) ...[
            _buildSectionTitle('Danger Zone'),
            const SizedBox(height: 12),
            _buildSettingTile(
              icon: Icons.delete_forever_rounded,
              title: 'Delete Group',
              subtitle: 'Permanently delete this group',
              color: const Color(0xFFD32F2F),
              onTap: _deleteGroup,
            ),
          ],

          const SizedBox(height: 20),

          // Role Badge
          _buildRoleBadge(isOwner),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Group Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                Icons.people_rounded,
                '${statistics!['totalMembers']}',
                'Total Members',
                const Color(0xFF324779),
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                Icons.admin_panel_settings_rounded,
                '${statistics!['adminCount']}',
                'Admins',
                const Color(0xFFFF6B35),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem(
                Icons.chat_rounded,
                '${statistics!['totalMessages']}',
                'Messages',
                const Color(0xFF0F9D58),
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                Icons.calendar_today_rounded,
                _formatDate(statistics!['createdAt']),
                'Created',
                const Color(0xFF9B59B6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF777777),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF777777),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF777777),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Color(0xFF777777),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildRoleBadge(bool isOwner) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOwner ? const Color(0xFFFFD700).withOpacity(0.1) : const Color(0xFF324779).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOwner ? const Color(0xFFFFD700).withOpacity(0.3) : const Color(0xFF324779).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOwner ? Icons.workspace_premium_rounded : Icons.admin_panel_settings_rounded,
            color: isOwner ? const Color(0xFFFFD700) : const Color(0xFF324779),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOwner ? 'Group Owner' : 'Group Admin',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isOwner ? const Color(0xFFFFD700) : const Color(0xFF324779),
                  ),
                ),
                Text(
                  isOwner
                      ? 'You have full control over this group'
                      : 'You can manage members and edit group details',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF777777),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else {
      return 'Today';
    }
  }
}