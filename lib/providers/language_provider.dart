import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  static const String _languageKey = 'selected_language';

  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'en';
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    if (_currentLocale.languageCode == languageCode) return;

    _currentLocale = Locale(languageCode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);

    notifyListeners();
  }

  String get currentLanguageName {
    switch (_currentLocale.languageCode) {
      case 'es':
        return 'Español';
      case 'en':
      default:
        return 'English';
    }
  }

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];

  bool isSupported(String languageCode) {
    return supportedLocales.any((locale) => locale.languageCode == languageCode);
  }
}