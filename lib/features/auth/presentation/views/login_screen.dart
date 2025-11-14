import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:skill_share/core/themes/app_theme.dart';
import 'package:skill_share/features/auth/domain/use_cases/login_use_case.dart';
import 'package:skill_share/features/register/presentation/views/register.dart';
import 'package:skill_share/i18n/app_localizations.dart';

import '../../application/auth_service.dart';
import '../../infrastructure/datasources/remote/auth_remote_data_source.dart';
import '../../infrastructure/datasources/remote/auth_remote_data_source_impl.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final LoginUseCase _loginUseCase;

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loginUseCase = GetIt.instance<LoginUseCase>();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔗 Testing connection to backend...');
      final authDataSource = GetIt.instance<AuthRemoteDataSource>();
      final connectionSuccess = await (authDataSource as AuthRemoteDataSourceImpl).testConnection();

      if (!connectionSuccess) {
        throw Exception('Cannot connect to server. Please check if backend is running.');
      }

      print('✅ Connection successful, proceeding with login...');

      final (user, token) = await _loginUseCase.execute(email, password);

      if (user.userId != null) {
        await AuthService.saveUserData(user.userId!, user.email, token);
        print('💾 User data saved: userId=${user.userId}, email=${user.email}');
      }

      print('🎉 Login successful! Navigating to home...');
      _showSnackBar('Login successful! Welcome ${user.email}', isError: false);

      // Navigate to home
      Navigator.pushReplacementNamed(context, "/home");

    } catch (e) {
      print('❌ Login error: $e');
      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  _buildLogo(),
                  const SizedBox(height: 50),
                  _buildTitle(localizations),
                  const SizedBox(height: 40),
                  _buildEmailField(localizations),
                  const SizedBox(height: 20),
                  _buildPasswordField(localizations),
                  const SizedBox(height: 36),
                  _buildSignInButton(localizations),
                  const SizedBox(height: 50),
                  _buildSignUpRedirect(localizations),
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
        height: 120,
        width: 120,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitle(AppLocalizations localizations) {
    return Text(
      localizations.loginToYourAccount,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppTheme.textImportant,
        fontFamily: 'Sarabun',
      ),
    );
  }

  Widget _buildEmailField(AppLocalizations localizations) {
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
        labelText: localizations.email,
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

  Widget _buildPasswordField(AppLocalizations localizations) {
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
        labelText: localizations.password,
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

  Widget _buildSignInButton(AppLocalizations localizations) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.highlightedElement,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
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

  Widget _buildSignUpRedirect(AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          localizations.dontHaveAccount,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textGeneral,
            fontFamily: 'Sarabun',
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _navigateToSignUp,
          child: Text(
            localizations.signUp,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.importancePrimary,
              fontFamily: 'Sarabun',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}