import 'package:flutter/material.dart';

import '../../../auth/application/auth_service.dart';
import '../../services/group_service.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  List<Map<String, dynamic>> recentGroups = [];
  List<Map<String, dynamic>> myGroups = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => isLoading = true);

    try {
      final userId = await AuthService.getUserId();
      final token = await AuthService.getAuthToken();

      if (userId == null || token == null) return;

      myGroups = await GroupService.getUserGroups(userId, token);
      recentGroups = await GroupService.getRecentGroups(userId, token);
    } catch (e) {
      print('Error loading groups: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> _filterGroups(List<Map<String, dynamic>> groups) {
    if (searchQuery.isEmpty) return groups;
    return groups.where((group) {
      final name = group['name'].toString().toLowerCase();
      final subject = group['subjectName']?.toString().toLowerCase() ?? '';
      return name.contains(searchQuery.toLowerCase()) ||
          subject.contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        surfaceTintColor: const Color(0xFFFAFAFA),
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        title: const Text(
          'My Groups',
          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2C3E50), fontSize: 18),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
          );
          if (result == true) {
            _loadGroups();
          }
        },
        backgroundColor: const Color(0xFF0F4C75),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Group'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search groups, subjects',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            if (_filterGroups(recentGroups).isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  'Recent Groups',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _filterGroups(recentGroups).length,
                  itemBuilder: (context, index) {
                    final group = _filterGroups(recentGroups)[index];
                    return _buildRecentGroupCard(group);
                  },
                ),
              ),
            ],

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'My Groups',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
              ),
            ),
            _buildMyGroupsGrid(_filterGroups(myGroups)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentGroupCard(Map<String, dynamic> group) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: NetworkImage(group['coverImage'] ?? 'https://via.placeholder.com/180x100'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBBE1FA),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      group['subjectName'] ?? 'General',
                      style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  group['description'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${group['memberCount'] ?? 0} members', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyGroupsGrid(List<Map<String, dynamic>> groups) {
    List<Widget> items = [];

    for (int i = 0; i < groups.length; i++) {
      items.add(_buildMyGroupCard(groups[i]));

      if ((i + 1) % 3 == 0 && i != groups.length - 1) {
        items.add(_buildAdCard());
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: item,
        )).toList(),
      ),
    );
  }

  Widget _buildMyGroupCard(Map<String, dynamic> group) {
    return GestureDetector(
      onTap: () => _viewGroupDetails(group),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(group['coverImage'] ?? 'https://via.placeholder.com/400x120'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBBE1FA),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        group['subjectName'] ?? 'General',
                        style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    group['description'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.people_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${group['memberCount'] ?? 0} members', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdCard() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.campaign_outlined, color: Colors.amber[700], size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Sponsored Content', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF7F8C8D))),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }

  void _viewGroupDetails(Map<String, dynamic> group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailScreen(groupId: group['id']),
      ),
    );
  }
}