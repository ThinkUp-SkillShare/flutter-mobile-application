import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:skillshare/core/dependency_injection.dart';
import 'package:skillshare/core/themes/app_theme.dart';
import 'package:skillshare/features/home/presentation/views/home_screen.dart';
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  AudioPlayerService().init();

  setupDependencies();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (context) => SearchViewModel(),
          child: const SearchScreen(),
        )
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<LanguageProvider, ThemeProvider>(
      builder: (context, languageProvider, themeProvider, child) {
        return MaterialApp(
          title: 'SkillShare',
          debugShowCheckedModeBanner: false,
          routes: {
            '/home': (context) => BottomNavigationScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/signup': (context) => const SignUpScreen(),
          },

          // Location settings
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

          home: FutureBuilder<bool>(
            future: AuthService.isAuthenticated(),
            builder: (context, snapshot) {
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

              if (snapshot.hasData && snapshot.data == true) {
                return BottomNavigationScreen();
              }

              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}