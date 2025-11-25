import 'package:flutter/material.dart';

/// Widget displayed when there are no groups or subjects available to show.
/// Provides a simple empty-state UI and a button to manually retry loading data.
class HomeEmptyStateWidget extends StatelessWidget {
  final VoidCallback onReload;

  const HomeEmptyStateWidget({
    super.key,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      /// Centered column to visually communicate the empty state.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Icon representing the absence of groups.
          Icon(
            Icons.group_work,
            color: Colors.grey[400],
            size: 64,
          ),

          const SizedBox(height: 16),

          /// Short message informing the user that no data is available.
          Text(
            'No hay grupos disponibles',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 8),

          /// Button allowing the user to retry loading data.
          ElevatedButton(
            onPressed: onReload,
            child: const Text('Recargar'),
          ),
        ],
      ),
    );
  }
}
