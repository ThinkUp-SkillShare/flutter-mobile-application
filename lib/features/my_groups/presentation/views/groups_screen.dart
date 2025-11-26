import 'package:flutter/material.dart';

import '../../../auth/application/auth_service.dart';
import '../../../groups/services/group_service.dart';
import 'create_group_screen.dart';
import '../../../groups/presentation/views/group_detail_screen.dart';
import '../widgets/my_group_card.dart';
import '../widgets/ad_card.dart';

/// Main screen displaying the list of groups the user belongs to.
/// Handles fetching groups, filtering by search, navigation to group details,
/// and inserting ads in the list at regular intervals.
class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  /// Stores the groups returned from the backend.
  List<Map<String, dynamic>> myGroups = [];

  /// Indicates whether data is being loaded.
  bool isLoading = true;

  /// Text used to filter groups by name, subject, or description.
  String searchQuery = '';

  /// Controller for the search input field.
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGroups(); // Initial data fetch on screen startup.
  }

  /// Fetches the user's groups from the backend.
  /// Retrieves authentication data, then calls the GroupService.
  /// Displays a loading indicator while fetching and handles errors gracefully.
  Future<void> _loadGroups() async {
    setState(() => isLoading = true);

    try {
      final userId = await AuthService.getUserId();
      final token = await AuthService.getAuthToken();

      /// If auth data is missing, no API request is made.
      if (userId == null || token == null) return;

      myGroups = await GroupService.getUserGroups(userId, token);
    } catch (e) {
      print('Error loading groups: $e');
    } finally {
      /// Ensure UI updates regardless of success or failure.
      setState(() => isLoading = false);
    }
  }

  /// Filters user groups based on the current search query.
  /// Matches group name, subject name, or description.
  List<Map<String, dynamic>> _filterGroups(List<Map<String, dynamic>> groups) {
    if (searchQuery.isEmpty) return groups;

    return groups.where((group) {
      final name = group['name'].toString().toLowerCase();
      final subject = group['subjectName']?.toString().toLowerCase() ?? '';
      final description = group['description']?.toString().toLowerCase() ?? '';

      return name.contains(searchQuery.toLowerCase()) ||
          subject.contains(searchQuery.toLowerCase()) ||
          description.contains(searchQuery.toLowerCase());
    }).toList();
  }

  /// Navigates to the group detail view.
  /// After returning, it reloads the group list in case data changed.
  void _viewGroupDetails(Map<String, dynamic> group) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupDetailScreen(groupId: group['id']),
      ),
    ).then((_) {
      // Refresh groups when user returns from details.
      _loadGroups();
    });
  }

  /// Builds the UI displayed when a search query is active.
  /// Shows the number of matches and displays filtered group results.
  Widget _buildSearchResults() {
    final filteredGroups = _filterGroups(myGroups);

    if (filteredGroups.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No groups found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header showing the number of results found.
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: Text(
            'Search Results (${filteredGroups.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
        _buildGroupsGrid(filteredGroups),
      ],
    );
  }

  /// Builds the normal (non-search) version of the screen.
  /// Displays a friendly empty state when the user has no groups.
  Widget _buildNormalView() {
    final filteredGroups = _filterGroups(myGroups);

    if (filteredGroups.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No groups yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Create your first group to get started',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Displays how many groups the user belongs to.
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          child: Text(
            'My Groups (${filteredGroups.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
        ),
        _buildGroupsGrid(filteredGroups),
      ],
    );
  }

  /// Builds a vertical list of group cards.
  /// Inserts an AdCard widget after every 3 groups.
  Widget _buildGroupsGrid(List<Map<String, dynamic>> groups) {
    List<Widget> items = [];

    for (int i = 0; i < groups.length; i++) {
      items.add(
        MyGroupCard(
          group: groups[i],
          onTap: () => _viewGroupDetails(groups[i]),
        ),
      );

      /// After every third group, insert a non-intrusive advertisement.
      if ((i + 1) % 3 == 0 && i != groups.length - 1) {
        items.add(const AdCard());
      }
    }

    /// Creates a padded column rather than a grid for a clean vertical layout.
    return Column(
      children: items
          .map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: item,
      ))
          .toList(),
    );
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
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      /// Floating button to create a new group.
      /// After creation, groups are refreshed to reflect new data.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
          );

          if (result == true) {
            _loadGroups(); // Refresh after successful group creation.
          }
        },
        backgroundColor: const Color(0xFF0F4C75),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Create Group'),
      ),

      /// If loading, show spinner. Otherwise show groups & search UI.
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Search bar at the top of the screen.
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) =>
                    setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search groups, subjects',
                  hintStyle: TextStyle(
                      color: Colors.grey[400], fontSize: 14),
                  prefixIcon:
                  Icon(Icons.search, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            /// Switch between normal mode and search results.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: searchQuery.isNotEmpty
                  ? _buildSearchResults()
                  : _buildNormalView(),
            ),
          ],
        ),
      ),
    );
  }
}
