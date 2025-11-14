import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../auth/application/auth_service.dart';
import '../../../settings/presentation/views/settings_screen.dart';
import '../../domain/entities/student_entity.dart';
import '../../services/student_service.dart';
import '../widgets/group_card_widget.dart';
import '../widgets/badge_card_widget.dart';
import '../widgets/profile_stats_widget.dart';
import '../widgets/activity_chart_widget.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StudentService _studentService = StudentService();
  Student? _student;
  bool _isLoading = true;

  final List<String> groupNames = [
    'Humanities',
    'Humanities',
    'Fundamental concepts of polit...',
  ];

  final List<String> groupDescriptions = [
    'Lorem ipsum dolor sit amet consectetur adipiscing t amet consectetur adipiscing t amet consectetur adipiscing t amet consectetur adipiscing t amet consectetur adipiscing',
    'Lorem ipsum dolor sit amet consectetur adipiscing elit.',
    'Legislative concepts, main laws, human rights',
  ];

  final List<String> groupMembers = [
    '37 members',
    '85 members',
    '12 members',
  ];

  final List<String> groupCovers = [
    'assets/images/programacion.jpg',
    'assets/images/musica.jpg',
    'assets/images/socrates.jpg',
  ];

  final List<int> studyHours = [3, 4, 2, 5, 6, 3, 7];
  final List<String> weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  final List<Map<String, dynamic>> badges = [
    {
      'name': 'Outstanding student',
      'icon': Icons.school,
      'color': Colors.blue,
    },
    {
      'name': 'Active participation',
      'icon': Icons.forum,
      'color': Colors.green,
    },
    {
      'name': 'Quiz Master',
      'icon': Icons.quiz,
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      final int? userId = await AuthService.getUserId();

      print('🔍 DEBUG - UserId from AuthService: $userId');

      if (userId == null) {
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

      setState(() {
        _student = student;
        _isLoading = false;
      });

      if (student == null) {
        print('⚠️ No student profile found for user $userId');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No student profile found. Please complete your profile.'),
            backgroundColor: Colors.orange,
          ),
        );
      }

    } catch (e) {
      print('❌ Error loading student data: $e');
      setState(() {
        _isLoading = false;
        _student = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: Colors.red,
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
        backgroundColor: Colors.green,
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
                child: Image.network(
                  'https://i.pinimg.com/736x/12/05/9e/12059e4b1e9db778b8ee2dc9b4290232.jpg',
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        color: Colors.grey.shade500,
                        size: 50,
                      ),
                    );
                  },
                ),
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
          'Joined 2025',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: _buildProfileInfo(),
            ),

            ProfileStatsWidget(
              groupsCount: '15',
              docsCount: '09',
              friendsCount: '22',
            ),

            const SizedBox(height: 32),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'My badges',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 20, right: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: badges.length,
                    itemBuilder: (context, index) => BadgeCardWidget(
                      badge: badges[index],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Joined Groups',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 20, right: 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: groupCovers.length,
                    itemBuilder: (context, index) => GroupCardWidget(
                      groupName: groupNames[index],
                      groupDescription: groupDescriptions[index],
                      groupMembers: groupMembers[index],
                      imagePath: groupCovers[index],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            ActivityChartWidget(
              studyHours: studyHours,
              weekDays: weekDays,
              totalStudyHours: 30,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}