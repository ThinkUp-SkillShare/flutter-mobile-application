import 'package:flutter/material.dart';
import 'package:skillshare/core/themes/app_theme.dart';
import 'package:skillshare/i18n/app_localizations.dart';

/// Widget for the password input field with toggle visibility
class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscurePassword;
  final VoidCallback toggleObscure;
  final AppLocalizations localizations;

  const PasswordField({
    super.key,
    required this.controller,
    required this.obscurePassword,
    required this.toggleObscure,
    required this.localizations,
  });

  /// Validates password input
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscurePassword,
      validator: _validatePassword,
      style: const TextStyle(fontSize: 16, fontFamily: 'Sarabun', color: AppTheme.textImportant),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock_outline, color: AppTheme.iconLessImportant, size: 20),
        labelText: localizations.password,
        labelStyle: const TextStyle(
            fontSize: 16, color: AppTheme.iconLessImportant, fontFamily: 'Sarabun', fontWeight: FontWeight.normal
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: AppTheme.backgroundSecondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.iconLessImportant,
            size: 20,
          ),
          onPressed: toggleObscure,
        ),
      ),
    );
  }
}
