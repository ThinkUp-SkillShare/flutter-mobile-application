import 'package:flutter/material.dart';
import 'package:skill_share/core/themes/app_theme.dart';
import 'package:skill_share/i18n/app_localizations.dart';

/// Widget for the email input field with validation
class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations localizations;

  const EmailField({
    super.key,
    required this.controller,
    required this.localizations,
  });

  /// Validates email input
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value)) return 'Please enter a valid email address';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      validator: _validateEmail,
      style: const TextStyle(fontSize: 16, fontFamily: 'Sarabun', color: AppTheme.textImportant),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email_outlined, color: AppTheme.iconLessImportant, size: 20),
        labelText: localizations.email,
        labelStyle: const TextStyle(
            fontSize: 16, color: AppTheme.iconLessImportant, fontFamily: 'Sarabun', fontWeight: FontWeight.normal
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: AppTheme.backgroundSecondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
    );
  }
}
