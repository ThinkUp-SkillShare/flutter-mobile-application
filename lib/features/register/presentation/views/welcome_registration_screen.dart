import 'package:flutter/material.dart';
import 'package:skill_share/core/themes/app_theme.dart';
import 'package:skill_share/features/register/presentation/views/about_yourself_screen.dart';

class WelcomeRegistrationScreen extends StatelessWidget {
  final String email;
  final String password;

  const WelcomeRegistrationScreen({
    super.key,
    required this.email,
    required this.password,
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
              _buildTitle(),
              const SizedBox(height: 20),
              _buildDescription(),
              const SizedBox(height: 40),
              _buildFoxImage(),
              const Spacer(),
              _buildStartButton(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Welcome to\nSkillShare',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppTheme.textImportant,
        fontFamily: 'Sarabun',
        height: 1.2,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      'Since this is your first time, we need some\ninformation to personalize your experience.',
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
    return Image.asset(
      'assets/images/auth/fox_rocket.png',
      height: 280,
      fit: BoxFit.contain,
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AboutYourselfScreen(
                email: email,
                password: password,
              ),
            ),
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
          'Start',
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