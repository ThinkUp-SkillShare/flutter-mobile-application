import 'package:flutter/material.dart';
import 'package:skill_share/features/groups/presentation/views/video_call_screen.dart';
import '../../../auth/application/auth_service.dart';
import '../../services/group_service.dart';
import '../widgets/calls_section_widget.dart';
import 'group_chat_screen.dart';
import 'group_settings_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final int groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? groupDetails;
  List<Map<String, dynamic>> members = [];
  bool isLoading = true;
  bool isMember = false;
  String? userRole;
  late TabController _tabController;
  int _currentTabIndex = 0;
  int? userId;

  final List<Map<String, dynamic>> _tabs = [
    {
      'icon': Icons.chat_bubble_rounded,
      'label': 'Chat',
      'color': Color(0xFF324779),
    },
    {
      'icon': Icons.folder_rounded,
      'label': 'Files',
      'color': Color(0xFF0F9D58),
    },
    {'icon': Icons.quiz_rounded, 'label': 'Quiz', 'color': Color(0xFFFF6B35)},
    {
      'icon': Icons.video_call_rounded,
      'label': 'Calls',
      'color': Color(0xFF9B59B6),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() => _currentTabIndex = _tabController.index);
    });
    _loadGroupDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGroupDetails() async {
    setState(() => isLoading = true);

    try {
      userId = await AuthService.getUserId();
      final token = await AuthService.getAuthToken();

      if (userId == null || token == null) return;

      groupDetails = await GroupService.getGroupById(
        widget.groupId,
        userId!,
        token,
      );
      members = await GroupService.getGroupMembers(widget.groupId, token);

      final roleValue = groupDetails?['userRole'];
      if (roleValue != null) {
        userRole = roleValue.toString();
      } else {
        userRole = null;
      }
      isMember = userRole != null;
    } catch (e) {
      print('Error loading group details: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _joinGroup() async {
    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      await GroupService.joinGroup(widget.groupId, token);
      _loadGroupDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined the group!'),
            backgroundColor: Color(0xFF0F9D58),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining group: $e'),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  Future<void> _leaveGroup() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD32F2F),
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final token = await AuthService.getAuthToken();
      if (token == null) return;

      await GroupService.leaveGroup(widget.groupId, token);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have left the group')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error leaving group: $e'),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (groupDetails == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: const Center(child: Text('Group not found')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildGroupInfo()),
          if (isMember) ...[
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF324779),
                  unselectedLabelColor: const Color(0xFF777777),
                  indicatorColor: const Color(0xFF324779),
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Sarabun',
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Sarabun',
                  ),
                  tabs: _tabs
                      .map(
                        (tab) => Tab(
                      icon: Icon(tab['icon'] as IconData, size: 24),
                      text: tab['label'] as String,
                    ),
                  )
                      .toList(),
                ),
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChatSection(),
                  _buildFilesSection(),
                  _buildQuizSection(),
                  CallsSectionWidget(
                    groupId: widget.groupId,
                    groupName: groupDetails!['name'],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }


  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF324779),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (isMember &&
            (userRole == 'admin' ||
                (groupDetails!['createdBy'] != null &&
                    groupDetails!['createdBy'] == userId)))
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupSettingsScreen(
                    groupId: widget.groupId,
                    groupDetails: groupDetails!,
                  ),
                ),
              );
              if (result == true) {
                _loadGroupDetails();
              }
            },
          ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          onPressed: () => _showMoreOptions(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              groupDetails!['coverImage'] ??
                  'https://via.placeholder.com/400x280',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBBE1FA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      groupDetails!['subjectName'] ?? 'General',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    groupDetails!['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Sarabun',
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupInfo() {
    return Container(
      margin: const EdgeInsets.all(20),
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
          Row(
            children: [
              _buildStatCard(
                Icons.people_rounded,
                '${groupDetails!['memberCount'] ?? 0}',
                'Members',
                const Color(0xFF324779),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                Icons.schedule_rounded,
                _getTimeAgo(groupDetails!['createdAt'] ?? ''),
                'Created',
                const Color(0xFF0F9D58),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                Icons.person_rounded,
                userRole == 'admin' ? 'Admin' : 'Member',
                'Role',
                const Color(0xFFFF6B35),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 24),

          const Text(
            'About this group',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
              fontFamily: 'Sarabun',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            groupDetails!['description'] ?? 'No description available',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6D6D6D),
              height: 1.6,
              fontFamily: 'Sarabun',
            ),
          ),

          const SizedBox(height: 24),

          if (!isMember)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _joinGroup,
                icon: const Icon(Icons.login_rounded, size: 20),
                label: const Text('Join Group'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF324779),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showMembers,
                    icon: const Icon(Icons.people_rounded, size: 20),
                    label: const Text('View Members'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF324779),
                      side: const BorderSide(
                        color: Color(0xFF324779),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _leaveGroup,
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text('Leave Group'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
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
                fontFamily: 'Sarabun',
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF777777),
                fontFamily: 'Sarabun',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatSection() {
    return GroupChatScreen(
      groupId: widget.groupId,
      groupName: groupDetails!['name'],
    );
  }

  Widget _buildFilesSection() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F9D58).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_rounded,
                size: 64,
                color: Color(0xFF0F9D58),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Files Section',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
                fontFamily: 'Sarabun',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Share and manage your study materials',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF777777),
                fontFamily: 'Sarabun',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSection() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.quiz_rounded,
                size: 64,
                color: Color(0xFFFF6B35),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quiz Section',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF333333),
                fontFamily: 'Sarabun',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Test your knowledge with group quizzes',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF777777),
                fontFamily: 'Sarabun',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMembers() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Group Members',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF333333),
                          fontFamily: 'Sarabun',
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF324779).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${members.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF324779),
                            fontFamily: 'Sarabun',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  final isAdmin = member['role'] == 'admin';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isAdmin
                            ? const Color(0xFF324779).withOpacity(0.3)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF324779),
                          child: Text(
                            member['userEmail'][0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member['userEmail'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF333333),
                                  fontFamily: 'Sarabun',
                                ),
                              ),
                              if (isAdmin)
                                const Text(
                                  'Administrator',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF324779),
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Sarabun',
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isAdmin)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF324779),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ADMIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.share_rounded,
                color: Color(0xFF324779),
              ),
              title: const Text(
                'Share Group',
                style: TextStyle(fontFamily: 'Sarabun'),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_rounded, color: Color(0xFF324779)),
              title: const Text(
                'Group Info',
                style: TextStyle(fontFamily: 'Sarabun'),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show group info
              },
            ),
            if (isMember)
              ListTile(
                leading: const Icon(
                  Icons.notifications_rounded,
                  color: Color(0xFF324779),
                ),
                title: const Text(
                  'Notifications',
                  style: TextStyle(fontFamily: 'Sarabun'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Notification settings
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(String dateStr) {
    if (dateStr.isEmpty) return 'Unknown';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()}y ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}
