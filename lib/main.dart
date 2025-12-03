import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:skillshare/core/dependency_injection.dart';
import 'package:skillshare/core/themes/app_theme.dart';
import 'package:skillshare/features/profile/presentation/views/profile_screen.dart';
import 'package:skillshare/features/register/presentation/views/register_screen.dart';
import 'package:skillshare/features/shared/bottom_navigation_screen/bottom_navigation_screen.dart';
import 'package:skillshare/providers/language_provider.dart';
import 'package:skillshare/providers/theme_provider.dart';
import 'package:skillshare/i18n/app_localizations.dart';

import 'features/auth/application/auth_service.dart';
import 'features/auth/presentation/views/login_screen.dart';
import 'features/groups/services/chat/audio_player_service.dart';
import 'features/home/presentation/view_models/home_view_model.dart';
import 'features/search/presentation/view_models/search_view_model.dart';
import 'features/search/presentation/views/search_screen.dart';

/// Main entry point of the application
/// Initializes dependencies, sets up providers, and configures the app
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI to immersive mode for full screen experience
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  // Initialize dependency injection
  setupDependencies();

  // Initialize audio player service (singleton auto-initializes)
  // No need to call init() anymore as it's done in the constructor
  AudioPlayerService();

  runApp(
    MultiProvider(
      providers: [
        // Application state providers
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
      ],
      child: const SkillShareApp(),
    ),
  );
}

/// Root widget of the SkillShare application
class SkillShareApp extends StatelessWidget {
  const SkillShareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, ThemeProvider>(
      builder: (context, languageProvider, themeProvider, child) {
        return MaterialApp(
          title: 'SkillShare',
          debugShowCheckedModeBanner: false,

          // Application routes
          routes: {
            '/home': (context) => BottomNavigationScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/search': (context) => const SearchScreen(),
          },

          // Internationalization settings
          locale: languageProvider.currentLocale,
          supportedLocales: LanguageProvider.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Theme settings
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,

          // Initial route based on authentication status
          home: _buildHomeScreen(context),
        );
      },
    );
  }

  /// Builds the appropriate home screen based on authentication status
  Widget _buildHomeScreen(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isAuthenticated(),
      builder: (context, snapshot) {
        // Show loading indicator while checking authentication
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundPrimary,
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.highlightedElement,
              ),
            ),
          );
        }

        // Handle authentication result
        if (snapshot.hasError) {
          return _buildErrorScreen(context, snapshot.error.toString());
        }

        if (snapshot.hasData && snapshot.data == true) {
          // User is authenticated, show main app
          return BottomNavigationScreen();
        }

        // User is not authenticated, show login screen
        return const LoginScreen();
      },
    );
  }

  /// Builds an error screen when authentication check fails
  Widget _buildErrorScreen(BuildContext context, String error) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Authentication Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.importancePrimary,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.importancePrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Retry authentication check
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SkillShareApp(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.highlightedElement,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}