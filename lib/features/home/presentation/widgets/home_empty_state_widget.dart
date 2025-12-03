import 'package:flutter/material.dart';
import 'package:skillshare/i18n/app_localizations.dart';

/// Widget displayed when there are no groups or subjects available to show.
class HomeEmptyStateWidget extends StatelessWidget {
  final VoidCallback onReload;

  const HomeEmptyStateWidget({
    super.key,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_work_outlined,
            color: Colors.grey[400],
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            localizations?.noGroupsAvailable ?? 'No groups available',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations?.createOrJoinGroup ?? 'Create or join a group to get started',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onReload,
            child: Text(localizations?.reload ?? 'Reload'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              // Navigate to search or create group screen
              Navigator.pushNamed(context, '/search');
            },
            child: Text(localizations?.exploreGroups ?? 'Explore Groups'),
          ),
        ],
      ),
    );
  }
}