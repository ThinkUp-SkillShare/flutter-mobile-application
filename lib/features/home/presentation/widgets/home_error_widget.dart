import 'package:flutter/material.dart';

/// Widget used to display an error state on the home screen.
/// Shows an error icon, the error message, and a button to retry the action.
/// The message is centered to improve clarity and readability.
class HomeErrorWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const HomeErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      /// Error UI aligned to the center of the available space.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Visual error indicator.
          Icon(
            Icons.error_outline,
            color: Colors.red[300],
            size: 64,
          ),

          const SizedBox(height: 16),

          /// Displays the error message received from the ViewModel.
          /// Text is centered to support long messages gracefully.
          Text(
            'Error: $error',
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          /// Retry button that triggers the provided callback.
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
