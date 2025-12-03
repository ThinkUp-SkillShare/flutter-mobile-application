import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:skillshare/core/themes/app_theme.dart';
import 'package:skillshare/features/auth/domain/use_cases/login_use_case.dart';
import 'package:skillshare/features/register/presentation/views/register_screen.dart';
import 'package:skillshare/i18n/app_localizations.dart';

import '../../application/auth_service.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';
import '../widgets/sign_in_button.dart';
import '../widgets/sign_up_redirect.dart';
import '../widgets/logo.dart';
import '../widgets/error_modal.dart';

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

  /// Handles the login process
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
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('invalid credentials') ||
          errorString.contains('incorrect') ||
          errorString.contains('wrong password')) {
        await ErrorModal.showInvalidCredentials(context: context);
      } else if (errorString.contains('not registered') ||
          errorString.contains('email not found') ||
          errorString.contains('user not found')) {
        await ErrorModal.showUserNotFound(context: context);
      } else if (errorString.contains('network') ||
          errorString.contains('connection') ||
          errorString.contains('timeout')) {
        await ErrorModal.showNetworkError(context: context);
      } else {
        final errorMessage = _getUserFriendlyErrorMessage(e);
        await ErrorModal.showAuthError(context: context, message: errorMessage);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Gets user-friendly error message based on exception type
  String _getUserFriendlyErrorMessage(dynamic error) {
    if (error is AuthException && error.userFriendlyMessage != null) {
      return error.userFriendlyMessage!;
    }

    final errorString = error.toString().toLowerCase();

    // Check for specific error patterns
    if (errorString.contains('invalid credentials') ||
        errorString.contains('incorrect') ||
        errorString.contains('wrong password') ||
        errorString.contains('unauthorized')) {
      return 'The email or password you entered is incorrect. Please try again.';
    }

    if (errorString.contains('user not found') ||
        errorString.contains('email not found') ||
        errorString.contains('not registered') ||
        errorString.contains('404')) {
      return 'This email is not registered. Please check your email or sign up for an account.';
    }

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('socket')) {
      return 'Network error. Please check your internet connection and try again.';
    }

    if (errorString.contains('server') ||
        errorString.contains('500') ||
        errorString.contains('internal error')) {
      return 'Server error. Please try again in a few minutes.';
    }

    // Generic friendly message for unknown errors
    return 'Login failed. Please check your credentials and try again.';
  }

  /// Maps error messages to user-friendly text
  String _getErrorMessage(String error) {
    final lowerError = error.toLowerCase();
    if (lowerError.contains('invalid credentials') ||
        lowerError.contains('incorrect') ||
        lowerError.contains('login failed')) {
      return 'The email or password you entered is incorrect. Please try again.';
    } else if (lowerError.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else {
      return error;
    }
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpScreen()),
    );
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
                EmailField(
                  controller: _emailController,
                  localizations: localizations,
                ),
                const SizedBox(height: 20),
                PasswordField(
                  controller: _passwordController,
                  obscurePassword: _obscurePassword,
                  toggleObscure: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  localizations: localizations,
                ),
                const SizedBox(height: 36),
                SignInButton(
                  isLoading: _isLoading,
                  onPressed: _login,
                  localizations: localizations,
                ),
                const SizedBox(height: 50),
                SignUpRedirect(
                  localizations: localizations,
                  onTap: _navigateToSignUp,
                ),
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
