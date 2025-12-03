import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../auth/application/auth_service.dart';
import '../../../settings/presentation/views/settings_screen.dart';
import '../../domain/entities/student_entity.dart';
import '../../services/student_service.dart';
import '../widgets/profile_stats_widget.dart';
import '../widgets/profile/profile_info_section.dart';
import '../widgets/profile/groups_section.dart';
import './edit_profile_screen.dart';
import '../../../groups/services/group_service.dart';

/// Main profile screen displaying student information and groups.
/// Manages state for user profile data and group information.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StudentService _studentService = StudentService();
  Student? _student;
  bool _isLoading = true;
  List<Map<String, dynamic>> _userGroups = [];
  int _createdGroupsCount = 0;
  int _joinedGroupsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  /// Loads student data and associated groups.
  Future<void> _loadStudentData() async {
    try {
      final int? userId = await AuthService.getUserId();
      final String? token = await AuthService.getAuthToken();

      if (userId == null || token == null) {
        _handleNoAuthenticatedUser();
        return;
      }

      final student = await _studentService.getStudentByUserId(userId);
      await _loadUserGroups(userId, token);

      _updateState(student);

      if (student == null) {
        _showNoProfileWarning();
      }
    } catch (e) {
      _handleLoadError(e.toString());
    }
  }

  void _handleNoAuthenticatedUser() {
    setState(() {
      _isLoading = false;
      _student = null;
    });
  }

  Future<void> _loadUserGroups(int userId, String token) async {
    try {
      final userGroups = await GroupService.getUserGroups(userId, token);

      int createdCount = 0;
      int joinedCount = 0;

      final int userIdInt = userId;

      for (var group in userGroups) {
        final dynamic createdByValue = group['createdBy'];

        bool isCreator = false;

        if (createdByValue != null) {
          if (createdByValue is int) {
            isCreator = createdByValue == userIdInt;
          } else if (createdByValue is String) {
            final createdByInt = int.tryParse(createdByValue);
            isCreator = createdByInt == userIdInt;
          } else if (createdByValue is num) {
            isCreator = createdByValue.toInt() == userIdInt;
          }
        }

        if (isCreator) {
          createdCount++;
        } else {
          joinedCount++;
        }
      }

      setState(() {
        _userGroups = userGroups;
        _createdGroupsCount = createdCount;
        _joinedGroupsCount = joinedCount;
      });

    } catch (e) {
      setState(() {
        _userGroups = [];
        _createdGroupsCount = 0;
        _joinedGroupsCount = 0;
      });
    }
  }

  void _updateState(Student? student) {
    setState(() {
      _student = student;
      _isLoading = false;
    });
  }

  void _showNoProfileWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No student profile found. Please complete your profile.',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleLoadError(String error) {
    setState(() {
      _isLoading = false;
      _student = null;
      _userGroups = [];
      _createdGroupsCount = 0;
      _joinedGroupsCount = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error loading profile: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Copies the username to clipboard.
  void _copyUsername() {
    final username = _student?.nickname ?? 'user';
    Clipboard.setData(ClipboardData(text: '@$username'));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Username @$username copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Navigates to the edit profile screen.
  void _navigateToEditProfile() {
    if (_student == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          student: _student!,
          onSave: (updatedStudent) {
            setState(() {
              _student = updatedStudent;
            });
          },
        ),
      ),
    );
  }

  /// Navigates to the settings screen.
  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F4C75)),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadStudentData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              ProfileInfoSection(student: _student),
              const SizedBox(height: 24),
              ProfileStatsWidget(
                groupsCount: _createdGroupsCount.toString(),
                docsCount: '0',
                friendsCount: _joinedGroupsCount.toString(),
              ),
              const SizedBox(height: 32),
              GroupsSection(userGroups: _userGroups, student: _student),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      surfaceTintColor: const Color(0xFFFAFAFA),
      backgroundColor: const Color(0xFFFAFAFA),
      leading: IconButton(
        onPressed: _student != null ? _navigateToEditProfile : null,
        icon: const Icon(Icons.edit_outlined, color: Colors.black87),
      ),
      title: _buildUsernameTitle(),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: _navigateToSettings,
          icon: const Icon(Icons.settings, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildUsernameTitle() {
    return GestureDetector(
      onTap: _copyUsername,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '@${_student?.nickname ?? 'username'}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.copy, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}