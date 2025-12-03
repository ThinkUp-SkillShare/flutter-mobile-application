import 'package:flutter/material.dart';

/// Widget for displaying and managing the profile image section.
class ProfileImageSection extends StatelessWidget {
  final String profileImageUrl;
  final String selectedGender;

  const ProfileImageSection({
    super.key,
    required this.profileImageUrl,
    required this.selectedGender,
  });

  IconData _getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'male': return Icons.male;
      case 'female': return Icons.female;
      case 'other': return Icons.transgender;
      case 'prefer_not_to_say': return Icons.visibility_off_outlined;
      default: return Icons.help_outline;
    }
  }

  Color _getGenderColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'male': return Colors.blue;
      case 'female': return Colors.pink;
      case 'other': return Colors.purple;
      case 'prefer_not_to_say': return Colors.grey;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
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
              child: profileImageUrl.isNotEmpty
                  ? Image.network(
                profileImageUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultEditAvatar();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildDefaultEditAvatar();
                },
              )
                  : _buildDefaultEditAvatar(),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getGenderColor(selectedGender),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                _getGenderIcon(selectedGender),
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultEditAvatar() {
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
  }
}