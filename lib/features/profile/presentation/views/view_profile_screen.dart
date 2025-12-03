import 'package:flutter/material.dart';
import '../../../auth/application/auth_service.dart';
import '../../domain/entities/student_entity.dart';
import '../../services/student_service.dart';
import '../../../groups/services/group_service.dart';
import '../widgets/group_card_widget.dart';
import '../widgets/profile_stats_widget.dart';

class ViewProfileScreen extends StatefulWidget {
  final int userId;

  const ViewProfileScreen({super.key, required this.userId});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final StudentService _studentService = StudentService();

  Student? _student;
  bool _isLoading = true;
  List<Map<String, dynamic>> _userGroups = [];
  int _createdGroupsCount = 0;
  int _joinedGroupsCount = 0;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final student = await _studentService.getStudentByUserId(widget.userId);

      final String? token = await AuthService.getAuthToken();

      if (token != null && student != null) {
        final userGroups = await GroupService.getUserGroups(widget.userId, token);

        int createdCount = 0;
        int joinedCount = 0;

        for (var group in userGroups) {
          if (group['created_by'] == widget.userId) {
            createdCount++;
          } else {
            joinedCount++;
          }
        }

        setState(() {
          _student = student;
          _userGroups = userGroups;
          _createdGroupsCount = createdCount;
          _joinedGroupsCount = joinedCount;
          _isLoading = false;
        });
      } else {
        setState(() {
          _student = student;
          _isLoading = false;
        });
      }

    } catch (e) {
      print('❌ Error loading user profile: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar el perfil';
      });
    }
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
            if (_student!.genderIcon != null)
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

        if (_student!.educationalCenter != null && _student!.educationalCenter!.isNotEmpty) ...[
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
            if (_student!.country != null && _student!.country!.isNotEmpty) ...[
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
        // Usar createdAt del UserEntity
        Text(
          _student!.user?.createdAt != null
              ? 'Miembro desde ${_getJoinedYear(_student!.user!.createdAt!)}'
              : 'Usuario',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
        ),

        // Nombre de usuario SIN botón de copiar
        const SizedBox(height: 8),
        Text(
          '@${_student!.nickname}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getJoinedYear(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}';
    } catch (e) {
      return '2025';
    }
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
              'No pertenece a ningún grupo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Mostrar solo 3 grupos como en la pantalla principal
    final displayGroups = _userGroups.length > 3 ? _userGroups.sublist(0, 3) : _userGroups;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grupos (${_userGroups.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              if (_userGroups.length > 3)
                Text(
                  '${_userGroups.length - 3} más',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
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
            itemCount: displayGroups.length,
            itemBuilder: (context, index) {
              final group = displayGroups[index];
              final isCreator = group['created_by'] == widget.userId;

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

  Widget _buildAdditionalInfo() {
    if (_student == null) return Container();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Información',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Construir lista dinámica de widgets de información
          ..._buildInfoWidgets(),
        ],
      ),
    );
  }

  List<Widget> _buildInfoWidgets() {
    final List<Widget> infoWidgets = [];

    // Email del usuario (si está disponible)
    if (_student!.user?.email != null && _student!.user!.email!.isNotEmpty) {
      infoWidgets.add(_buildInfoRow('Email', _student!.user!.email!));
    }

    // Centro educativo
    if (_student!.educationalCenter != null && _student!.educationalCenter!.isNotEmpty) {
      if (infoWidgets.isNotEmpty) infoWidgets.add(const SizedBox(height: 12));
      infoWidgets.add(_buildInfoRow('Centro educativo', _student!.educationalCenter!));
    }

    // País
    if (_student!.country != null && _student!.country!.isNotEmpty) {
      if (infoWidgets.isNotEmpty) infoWidgets.add(const SizedBox(height: 12));
      infoWidgets.add(_buildInfoRow('País', _student!.country!));
    }

    // Edad
    if (_student!.age != null) {
      if (infoWidgets.isNotEmpty) infoWidgets.add(const SizedBox(height: 12));
      infoWidgets.add(_buildInfoRow('Edad', '${_student!.age} años'));
    }

    // Género
    if (_student!.gender != null && _student!.gender!.isNotEmpty) {
      if (infoWidgets.isNotEmpty) infoWidgets.add(const SizedBox(height: 12));
      final genderText = _student!.gender == 'male' ? 'Masculino' :
      _student!.gender == 'female' ? 'Femenino' : _student!.gender!;
      infoWidgets.add(_buildInfoRow('Género', genderText));
    }

    // Fecha de creación (desde UserEntity)
    if (_student!.user?.createdAt != null) {
      if (infoWidgets.isNotEmpty) infoWidgets.add(const SizedBox(height: 12));
      infoWidgets.add(_buildInfoRow('Miembro desde', _formatDate(_student!.user!.createdAt!)));
    }

    // Si no hay información adicional
    if (infoWidgets.isEmpty) {
      infoWidgets.add(
        Text(
          'No hay información adicional disponible',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return infoWidgets;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
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
        title: const Text('Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _student == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage.isNotEmpty ? _errorMessage : 'Perfil no encontrado',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadUserProfile,
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

              if (_userGroups.isNotEmpty) ...[
                _buildGroupsSection(),
                const SizedBox(height: 32),
              ],

              _buildAdditionalInfo(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}