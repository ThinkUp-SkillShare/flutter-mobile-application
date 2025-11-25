import 'package:flutter/material.dart';
import 'package:skill_share/core/themes/app_theme.dart';

class CompletionScreen extends StatelessWidget {
  final String nickname;

  const CompletionScreen({
    super.key,
    required this.nickname,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: AppTheme.textImportant),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                ),
              ),
              const Spacer(),
              _buildTitle(nickname),
              const SizedBox(height: 20),
              _buildDescription(),
              const SizedBox(height: 40),
              _buildFoxImage(),
              const Spacer(),
              _buildGoHomeButton(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String name) {
    return Text(
      'All done, @$name!',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppTheme.textImportant,
        fontFamily: 'Sarabun',
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      'Your profile is set up.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppTheme.textImportant,
        fontFamily: 'Sarabun',
      ),
    );
  }

  Widget _buildSubDescription() {
    return Text(
      'Now you can create study groups, share your\nknowledge, and revolutionize education with us.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: AppTheme.textGeneral,
        fontFamily: 'Sarabun',
        height: 1.5,
      ),
    );
  }

  Widget _buildFoxImage() {
    return Column(
      children: [
        Image.asset(
          'assets/images/auth/fox_complete.png',
          height: 280,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        _buildSubDescription(),
      ],
    );
  }

  Widget _buildGoHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
                (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.highlightedElement,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Go home',
          style: TextStyle(
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