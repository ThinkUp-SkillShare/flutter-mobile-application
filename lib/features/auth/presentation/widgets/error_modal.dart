import 'package:flutter/material.dart';
import 'package:skillshare/core/themes/app_theme.dart';
import 'package:skillshare/i18n/app_localizations.dart';

/// Modal dialog for displaying user-friendly authentication errors
class ErrorModal extends StatelessWidget {
  final String title;
  final String message;
  final AppLocalizations localizations;
  final IconData icon;

  const ErrorModal({
    super.key,
    required this.title,
    required this.message,
    required this.localizations,
    this.icon = Icons.error_outline,
  });

  /// Shows an authentication error modal
  static Future<void> showAuthError({
    required BuildContext context,
    required String message,
    String? title,
    IconData? icon,
  }) async {
    final localizations = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ErrorModal(
          title: title ?? localizations.error,
          message: message,
          localizations: localizations,
          icon: icon ?? Icons.error_outline,
        );
      },
    );
  }

  /// Shows an invalid credentials error modal
  static Future<void> showInvalidCredentials({
    required BuildContext context,
    String message = 'The email or password you entered is incorrect.',
  }) async {
    final localizations = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ErrorModal(
          title: localizations.error,
          message: message,
          localizations: localizations,
          icon: Icons.lock_outline,
        );
      },
    );
  }

  /// Shows a network error modal
  static Future<void> showNetworkError({
    required BuildContext context,
    String message = 'Network error. Please check your internet connection.',
  }) async {
    final localizations = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ErrorModal(
          title: 'Connection Error',
          message: message,
          localizations: localizations,
          icon: Icons.wifi_off,
        );
      },
    );
  }

  /// Shows a user not found error modal
  static Future<void> showUserNotFound({
    required BuildContext context,
    String message = 'This email is not registered.',
  }) async {
    final localizations = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ErrorModal(
          title: 'Account Not Found',
          message: message,
          localizations: localizations,
          icon: Icons.person_off_outlined,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppTheme.backgroundPrimary,
      title: Row(
        children: [
          Icon(icon, color: AppTheme.errorColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Sarabun',
                color: AppTheme.textImportant,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              fontFamily: 'Sarabun',
              color: AppTheme.textGeneral,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _getSuggestionBasedOnError(title, message),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.importancePrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            localizations.ok,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sarabun',
            ),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.end,
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
    );
  }

  /// Returns a suggestion widget based on the error type
  Widget _getSuggestionBasedOnError(String title, String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('not registered') ||
        lowerMessage.contains('email not found')) {
      return Row(
        children: [
          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tip: Check if you typed your email correctly, or sign up for a new account.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.amber[700],
                fontFamily: 'Sarabun',
              ),
            ),
          ),
        ],
      );
    }

    if (lowerMessage.contains('password') || lowerMessage.contains('incorrect')) {
      return Row(
        children: [
          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tip: Check your CAPS LOCK key and make sure you\'re using the correct password.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.amber[700],
                fontFamily: 'Sarabun',
              ),
            ),
          ),
        ],
      );
    }

    if (lowerMessage.contains('network') || lowerMessage.contains('connection')) {
      return Row(
        children: [
          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tip: Check your Wi-Fi or mobile data connection.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.amber[700],
                fontFamily: 'Sarabun',
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}