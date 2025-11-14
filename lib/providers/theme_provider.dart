import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeOption { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  ThemeOption _currentTheme = ThemeOption.system;
  static const String _themeKey = 'selected_theme';

  ThemeOption get currentTheme => _currentTheme;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 2;
    _currentTheme = ThemeOption.values[themeIndex];
    notifyListeners();
  }

  Future<void> changeTheme(ThemeOption theme) async {
    if (_currentTheme == theme) return;

    _currentTheme = theme;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);

    notifyListeners();
  }

  ThemeMode get themeMode {
    switch (_currentTheme) {
      case ThemeOption.light:
        return ThemeMode.light;
      case ThemeOption.dark:
        return ThemeMode.dark;
      case ThemeOption.system:
      default:
        return ThemeMode.system;
    }
  }

  String getThemeName(BuildContext context) {
    switch (_currentTheme) {
      case ThemeOption.light:
        return 'Light';
      case ThemeOption.dark:
        return 'Dark';
      case ThemeOption.system:
      default:
        return 'System';
    }
  }
}