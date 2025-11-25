import 'package:flutter/material.dart';

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

  Widget _buildStatCard(String number, String label, IconData icon, Color color) {
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
            Container(
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
            ),
            const SizedBox(height: 8),
            Text(
              number,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatCard(groupsCount, 'Grupos\nCreados', Icons.create, Colors.orange.shade700),
          _buildStatCard(docsCount, 'Archivos\nCompartidos', Icons.folder, Colors.blue.shade700),
          _buildStatCard(friendsCount, 'Grupos\nUnidos', Icons.group_add, Colors.green.shade700),
        ],
      ),
    );
  }
}