class AppConstants {
  static const String appName = 'SkillShare';
  static const String apiBaseUrl = 'http://10.0.2.2:5118/api';

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration apiTimeout = Duration(seconds: 30);

  static const int defaultPageSize = 20;

  static const String emailPattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
  static const String passwordPattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^\da-zA-Z]).{8,}$';
}