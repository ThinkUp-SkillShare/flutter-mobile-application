import 'package:flutter/material.dart';
import 'package:skillshare/core/themes/app_theme.dart';
import 'package:skillshare/i18n/app_localizations.dart';

/// Widget to redirect users to the sign-up screen
class SignUpRedirect extends StatelessWidget {
  final AppLocalizations localizations;
  final VoidCallback onTap;

  const SignUpRedirect({
    super.key,
    required this.localizations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          localizations.dontHaveAccount,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Sarabun',
            fontWeight: FontWeight.normal,
            color: AppTheme.textGeneral,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onTap,
          child: Text(
            localizations.signUp,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Sarabun',
              fontWeight: FontWeight.w600,
              color: AppTheme.importancePrimary,
            ),
          ),
        ),
      ],
    );
  }
}
