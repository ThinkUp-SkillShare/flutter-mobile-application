import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../auth/application/auth_service.dart';
import '../../../settings/presentation/views/settings_screen.dart';
import '../../domain/entities/student_entity.dart';
import '../../services/student_service.dart';
import '../widgets/group_card_widget.dart';
import '../widgets/profile_stats_widget.dart';
import 'all_user_groups_screen.dart';
import 'edit_profile_screen.dart';
import '../../../groups/services/group_service.dart';

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

  Future<void> _loadStudentData() async {
    try {
      final int? userId = await AuthService.getUserId();
      final String? token = await AuthService.getAuthToken();

      print('🔍 DEBUG - UserId from AuthService: $userId');

      if (userId == null || token == null) {
        print('❌ No authenticated user found');
        setState(() {
          _isLoading = false;
          _student = null;
        });
        return;
      }

      print('👤 Loading student data for userId: $userId');
      final student = await _studentService.getStudentByUserId(userId);

      print('📊 DEBUG - Student data received: $student');

      // Cargar grupos del usuario
      final userGroups = await GroupService.getUserGroups(userId, token);
      print('📊 DEBUG - User groups loaded: ${userGroups.length}');

      // Contar grupos creados vs unidos
      int createdCount = 0;
      int joinedCount = 0;

      for (var group in userGroups) {
        print('📊 DEBUG - Group: ${group['name']}, created_by: ${group['created_by']}, userId: $userId');
        if (group['created_by'] == userId) {
          createdCount++;
        } else {
          joinedCount++;
        }
      }

      print('📊 DEBUG - Created groups: $createdCount, Joined groups: $joinedCount');

      setState(() {
        _student = student;
        _userGroups = userGroups;
        _createdGroupsCount = createdCount;
        _joinedGroupsCount = joinedCount;
        _isLoading = false;
      });

      if (student == null) {
        print('⚠️ No student profile found for user $userId');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No student profile found. Please complete your profile.'),
            backgroundColor: Colors.orange.shade700,
          ),
        );
      }

    } catch (e) {
      print('❌ Error loading student data: $e');
      setState(() {
        _isLoading = false;
        _student = null;
        _userGroups = [];
        _createdGroupsCount = 0;
        _joinedGroupsCount = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _copyUsername() {
    final username = _student?.nickname ?? 'user';
    Clipboard.setData(ClipboardData(text: '@$username'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Usuario @$username copiado al portapapeles'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

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

  void _navigateToAllGroups() {
    if (_userGroups.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllUserGroupsScreen(
          userGroups: _userGroups,
          userId: _student?.userId ?? 0,
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    if (_student == null) {
      return const Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            'Usuario no encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipOval(
                child: _student?.user?.profileImage != null &&
                    _student!.user!.profileImage!.isNotEmpty
                    ? Image.network(
                  _student!.user!.profileImage!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    }
                    return Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatar();
                  },
                )
                    : _buildDefaultAvatar(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _student!.genderColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  _student!.genderIcon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${_student!.firstName} ${_student!.lastName}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        if (_student!.educationalCenter != null) ...[
          Text(
            _student!.educationalCenter!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
        ],

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_student!.age != null) ...[
              Icon(Icons.cake, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${_student!.age} años',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 12),
            ],
            if (_student!.country != null) ...[
              Text(
                _student!.countryFlag,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              Text(
                _student!.country!,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),

        const SizedBox(height: 4),
        Text(
          'Joined ${_student?.joinedYear ?? 2025}',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Colors.grey.shade500,
        size: 50,
      ),
    );
  }

  Widget _buildGroupsSection() {
    if (_userGroups.isEmpty) {
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
              'No perteneces a ningún grupo',
              style: TextStyle(
                fontSize: 16,
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mis Grupos (${_userGroups.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: _navigateToAllGroups,
                child: const Text(
                  'Ver todos',
                  style: TextStyle(
                    color: Color(0xFF0F4C75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 265,
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 20, right: 8),
            scrollDirection: Axis.horizontal,
            itemCount: _userGroups.length > 3 ? 3 : _userGroups.length,
            itemBuilder: (context, index) {
              final group = _userGroups[index];
              final isCreator = group['created_by'] == _student?.userId;

              String imageUrl = '';
              if (group['coverImage'] != null && group['coverImage'].toString().isNotEmpty) {
                imageUrl = group['coverImage'].toString();
              } else if (group['cover_image'] != null && group['cover_image'].toString().isNotEmpty) {
                imageUrl = group['cover_image'].toString();
              }

              return GroupCardWidget(
                groupName: group['name'] ?? 'Sin nombre',
                groupDescription: group['description'] ?? '',
                groupMembers: '${group['memberCount'] ?? 0} miembros',
                imagePath: imageUrl,
                isUserCreator: isCreator,
                groupId: group['id'] ?? 0,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: const Color(0xFFFAFAFA),
        backgroundColor: const Color(0xFFFAFAFA),
        leading: IconButton(
          onPressed: _student != null ? _navigateToEditProfile : null,
          icon: const Icon(Icons.edit_outlined, color: Colors.black87),
        ),
        title: GestureDetector(
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
              const Icon(
                Icons.copy,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.black87),
          ),
        ],
      ),
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: _buildProfileInfo(),
              ),

              ProfileStatsWidget(
                groupsCount: _createdGroupsCount.toString(),
                docsCount: '0',
                friendsCount: _joinedGroupsCount.toString(),
              ),

              const SizedBox(height: 32),

              // Sección de grupos
              _buildGroupsSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}