import 'package:flutter/material.dart';
import 'package:skillshare/core/themes/app_theme.dart';
import 'package:skillshare/i18n/app_localizations.dart';

/// Widget for the sign-in button with loading state
class SignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final AppLocalizations localizations;

  const SignInButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.highlightedElement,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                localizations.signIn,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Sarabun',
                ),
              ),
      ),
    );
  }
}
