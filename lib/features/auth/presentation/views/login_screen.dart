import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:skillshare/core/themes/app_theme.dart';
import 'package:skillshare/features/auth/domain/use_cases/login_use_case.dart';
import 'package:skillshare/features/register/presentation/views/register_screen.dart';
import 'package:skillshare/i18n/app_localizations.dart';

import '../../application/auth_service.dart';
import '../../infrastructure/datasources/remote/auth_remote_data_source.dart';
import '../../infrastructure/datasources/remote/auth_remote_data_source_impl.dart';
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';
import '../widgets/sign_in_button.dart';
import '../widgets/sign_up_redirect.dart';
import '../widgets/logo.dart';

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
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      final (user, token) = await _loginUseCase.execute(email, password);

      if (user.userId != null) {
        await AuthService.saveUserData(user.userId!, user.email, token);
      }

      _showSnackBar('Login successful! Welcome ${user.email}', isError: false);
      Navigator.pushReplacementNamed(context, "/home");
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToSignUp() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()));
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value)) return 'Please enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 80),
                const LogoWidget(),
                const SizedBox(height: 50),
                Text(
                  localizations.loginToYourAccount,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textImportant,
                    fontFamily: 'Sarabun',
                  ),
                ),
                const SizedBox(height: 40),
                EmailField(controller: _emailController, localizations: localizations),
                const SizedBox(height: 20),
                PasswordField(
                  controller: _passwordController,
                  obscurePassword: _obscurePassword,
                  toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                  localizations: localizations,
                ),
                const SizedBox(height: 36),
                SignInButton(
                  isLoading: _isLoading,
                  onPressed: _login,
                  localizations: localizations,
                ),
                const SizedBox(height: 50),
                SignUpRedirect(localizations: localizations, onTap: _navigateToSignUp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
