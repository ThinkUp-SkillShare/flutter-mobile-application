import 'package:flutter/material.dart';
import '../../../domain/entities/student_entity.dart';

/// Widget for displaying student profile information.
class ProfileInfoSection extends StatelessWidget {
  final Student? student;

  const ProfileInfoSection({super.key, required this.student, required bool isReadOnly});

  @override
  Widget build(BuildContext context) {
    if (student == null) {
      return _buildNoUserFound();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          _buildProfileImage(student!),
          const SizedBox(height: 16),
          _buildName(student!),
          if (student!.educationalCenter != null) _buildEducationalCenter(student!),
          _buildAdditionalInfo(student!),
          const SizedBox(height: 4),
          _buildJoinDate(student!),
        ],
      ),
    );
  }

  Widget _buildNoUserFound() {
    return const Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        SizedBox(height: 16),
        Text(
          'User not found',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(Student student) {
    return Stack(
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
            child: student.user?.profileImage != null &&
                student.user!.profileImage!.isNotEmpty
                ? Image.network(
              student.user!.profileImage!,
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _buildLoadingAvatar();
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
              color: student.genderColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              student.genderIcon,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingAvatar() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
        ),
      ),
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

  Widget _buildName(Student student) {
    return Text(
      '${student.firstName} ${student.lastName}',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildEducationalCenter(Student student) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          student.educationalCenter!,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildAdditionalInfo(Student student) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (student.age != null) _buildAgeInfo(student.age!),
        if (student.age != null && student.country != null)
          const SizedBox(width: 12),
        if (student.country != null) _buildCountryInfo(student),
      ],
    );
  }

  Widget _buildAgeInfo(int age) {
    return Row(
      children: [
        Icon(Icons.cake, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          '$age years',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildCountryInfo(Student student) {
    return Row(
      children: [
        Text(
          student.countryFlag,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 4),
        Text(
          student.country!,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildJoinDate(Student student) {
    return Text(
      'Joined ${student.joinedYear ?? 2025}',
      style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
    );
  }
}