import 'package:flutter/material.dart';
import 'package:skill_share/core/themes/app_theme.dart';
import 'package:skill_share/features/auth/presentation/views/login_screen.dart';
import 'package:skill_share/features/register/presentation/views/welcome_registration_screen.dart';
import 'package:skill_share/i18n/app_localizations.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;
  bool _isLoading = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!_isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? _validateRepeatPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please repeat your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  void _navigateToWelcome() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WelcomeRegistrationScreen(
          email: email,
          password: password,
        ),
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppTheme.textImportant),
                    onPressed: _navigateToLogin,
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  const SizedBox(height: 20),
                  _buildLogo(),
                  const SizedBox(height: 30),
                  _buildTitle(),
                  const SizedBox(height: 10),
                  _buildSubtitle(),
                  const SizedBox(height: 40),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 20),
                  _buildRepeatPasswordField(),
                  const SizedBox(height: 36),
                  _buildSignUpButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        "assets/logo/SkillShare_logo.png",
        height: 100,
        width: 100,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        'SkillShare',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppTheme.textImportant,
          fontFamily: 'Sarabun',
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Center(
      child: Text(
        'Welcome!',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.textImportant,
          fontFamily: 'Sarabun',
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      validator: _validateEmail,
      style: TextStyle(
        fontSize: 16,
        color: AppTheme.textImportant,
        fontFamily: 'Sarabun',
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.email_outlined,
          color: AppTheme.iconLessImportant,
          size: 20,
        ),
        labelText: 'Email',
        labelStyle: TextStyle(
          fontSize: 16,
          color: AppTheme.iconLessImportant,
          fontFamily: 'Sarabun',
          fontWeight: FontWeight.normal,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: AppTheme.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: _validatePassword,
      style: TextStyle(
        fontSize: 16,
        color: AppTheme.textImportant,
        fontFamily: 'Sarabun',
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.lock_outline,
          color: AppTheme.iconLessImportant,
          size: 20,
        ),
        labelText: 'Password',
        labelStyle: TextStyle(
          fontSize: 16,
          color: AppTheme.iconLessImportant,
          fontFamily: 'Sarabun',
          fontWeight: FontWeight.normal,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: AppTheme.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.iconLessImportant,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }

  Widget _buildRepeatPasswordField() {
    return TextFormField(
      controller: _repeatPasswordController,
      obscureText: _obscureRepeatPassword,
      validator: _validateRepeatPassword,
      style: TextStyle(
        fontSize: 16,
        color: AppTheme.textImportant,
        fontFamily: 'Sarabun',
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.lock_outline,
          color: AppTheme.iconLessImportant,
          size: 20,
        ),
        labelText: 'Repeat password',
        labelStyle: TextStyle(
          fontSize: 16,
          color: AppTheme.iconLessImportant,
          fontFamily: 'Sarabun',
          fontWeight: FontWeight.normal,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: AppTheme.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureRepeatPassword ? Icons.visibility_off : Icons.visibility,
            color: AppTheme.iconLessImportant,
            size: 20,
          ),
          onPressed: () {
            setState(() {
              _obscureRepeatPassword = !_obscureRepeatPassword;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _navigateToWelcome,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.highlightedElement,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Sign up',
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }
}