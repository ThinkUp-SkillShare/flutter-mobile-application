import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../../providers/language_provider.dart';
import '../../../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFAFAFA),
        surfaceTintColor: const Color(0xFFFAFAFA),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
        ),
        title: Text(
          localizations.settings,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingItem(
              context,
              icon: Icons.language,
              title: localizations.language,
              subtitle: _getLanguageDisplayName(context),
              onTap: () => _showLanguageDialog(context),
            ),

            const SizedBox(height: 12),

            _buildSettingItem(
              context,
              icon: Icons.palette_outlined,
              title: localizations.theme,
              subtitle: _getThemeDisplayName(context),
              onTap: () => _showThemeDialog(context),
            ),

            const SizedBox(height: 12),

            _buildSettingItem(
              context,
              icon: Icons.notifications_outlined,
              title: localizations.notifications,
              hasArrow: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${localizations.notifications} - Coming soon!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? subtitle,
        bool hasArrow = false,
        required VoidCallback onTap,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.black87,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        )
            : null,
        trailing: hasArrow
            ? Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
          size: 24,
        )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  String _getLanguageDisplayName(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    switch (languageProvider.currentLocale.languageCode) {
      case 'es':
        return localizations.spanish;
      case 'en':
      default:
        return localizations.english;
    }
  }

  String _getThemeDisplayName(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    switch (themeProvider.currentTheme) {
      case ThemeOption.light:
        return localizations.light;
      case ThemeOption.dark:
        return localizations.dark;
      case ThemeOption.system:
      default:
        return localizations.system;
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  localizations.language,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                _buildLanguageOption(
                  context,
                  languageCode: 'en',
                  languageName: localizations.english,
                  flag: '🇺🇸',
                ),
                const SizedBox(height: 8),
                _buildLanguageOption(
                  context,
                  languageCode: 'es',
                  languageName: localizations.spanish,
                  flag: '🇲🇽',
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  localizations.theme,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                _buildThemeOption(
                  context,
                  theme: ThemeOption.light,
                  themeName: localizations.light,
                  icon: Icons.light_mode,
                ),
                const SizedBox(height: 8),
                _buildThemeOption(
                  context,
                  theme: ThemeOption.dark,
                  themeName: localizations.dark,
                  icon: Icons.dark_mode,
                ),
                const SizedBox(height: 8),
                _buildThemeOption(
                  context,
                  theme: ThemeOption.system,
                  themeName: localizations.system,
                  icon: Icons.settings_system_daydream,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
      BuildContext context, {
        required String languageCode,
        required String languageName,
        required String flag,
      }) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isSelected = languageProvider.currentLocale.languageCode == languageCode;

        return Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.blue.shade200, width: 1)
                : null,
          ),
          child: ListTile(
            leading: Text(flag, style: const TextStyle(fontSize: 24)),
            title: Text(
              languageName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.blue.shade700 : Colors.black87,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: Colors.blue.shade600, size: 24)
                : null,
            onTap: () {
              languageProvider.changeLanguage(languageCode);
              Navigator.of(context).pop();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
      BuildContext context, {
        required ThemeOption theme,
        required String themeName,
        required IconData icon,
      }) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isSelected = themeProvider.currentTheme == theme;

        return Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.shade50 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Colors.blue.shade200, width: 1)
                : null,
          ),
          child: ListTile(
            leading: Icon(icon, size: 24, color: Colors.grey.shade700),
            title: Text(
              themeName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.blue.shade700 : Colors.black87,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle, color: Colors.blue.shade600, size: 24)
                : null,
            onTap: () {
              themeProvider.changeTheme(theme);
              Navigator.of(context).pop();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}