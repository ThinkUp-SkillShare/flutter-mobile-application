import 'package:flutter/material.dart';

/// Widget displaying user statistics in a card format.
/// Shows counts for created groups, shared files, and joined groups.
class ProfileStatsWidget extends StatelessWidget {
  final String groupsCount;
  final String docsCount;
  final String friendsCount;

  const ProfileStatsWidget({
    super.key,
    required this.groupsCount,
    required this.docsCount,
    required this.friendsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard(
            number: groupsCount,
            label: 'Created\nGroups',
            icon: Icons.create,
            color: Colors.orange.shade700,
          ),
          _buildStatCard(
            number: docsCount,
            label: 'Shared\nFiles',
            icon: Icons.folder,
            color: Colors.blue.shade700,
          ),
          _buildStatCard(
            number: friendsCount,
            label: 'Joined\nGroups',
            icon: Icons.group_add,
            color: Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  /// Builds a single statistic card with icon, number, and label.
  Widget _buildStatCard({
    required String number,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              offset: const Offset(0, 2),
              blurRadius: 4,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIconContainer(icon, color),
            const SizedBox(height: 8),
            _buildNumberText(number, color),
            const SizedBox(height: 4),
            _buildLabelText(label),
          ],
        ),
      ),
    );
  }

  Widget _buildIconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildNumberText(String number, Color color) {
    return Text(
      number,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: color,
      ),
    );
  }

  Widget _buildLabelText(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }
}