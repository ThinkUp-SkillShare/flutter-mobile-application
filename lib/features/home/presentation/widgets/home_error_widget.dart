import 'package:flutter/material.dart';

/// Widget used to display an error state on the home screen.
/// Shows an error icon, the error message, and a button to retry the action.
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getErrorIcon(),
            color: _getErrorColor(),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _getErrorMessage(),
            style: TextStyle(
              color: _getErrorColor(),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          if (_shouldShowDetails())
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getErrorColor(),
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Determines which icon to show based on error type
  IconData _getErrorIcon() {
    final lowerError = error.toLowerCase();
    if (lowerError.contains('session') || lowerError.contains('expired')) {
      return Icons.login;
    } else if (lowerError.contains('network') || lowerError.contains('connection')) {
      return Icons.wifi_off;
    } else if (lowerError.contains('permission')) {
      return Icons.block;
    } else {
      return Icons.error_outline;
    }
  }

  /// Determines color based on error severity
  Color _getErrorColor() {
    final lowerError = error.toLowerCase();
    if (lowerError.contains('session') || lowerError.contains('expired')) {
      return Colors.orange;
    } else if (lowerError.contains('permission')) {
      return Colors.red;
    } else {
      return Colors.red[700]!;
    }
  }

  /// Gets user-friendly error message
  String _getErrorMessage() {
    final lowerError = error.toLowerCase();
    if (lowerError.contains('session expired')) {
      return 'Session Expired';
    } else if (lowerError.contains('please login')) {
      return 'Please Login';
    } else if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Connection Error';
    } else if (lowerError.contains('permission')) {
      return 'Access Denied';
    } else if (lowerError.contains('failed to load')) {
      return 'Failed to Load Data';
    } else {
      return 'An Error Occurred';
    }
  }

  /// Determines if technical details should be shown
  bool _shouldShowDetails() {
    final lowerError = error.toLowerCase();
    return !lowerError.contains('session') &&
        !lowerError.contains('please login') &&
        !lowerError.contains('network');
  }
}