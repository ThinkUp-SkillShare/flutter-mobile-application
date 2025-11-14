import 'package:flutter/material.dart';

class AppTheme {
  // Main color palette for the SkillShare application
  // Background colors for different surfaces and layers
  static const Color backgroundPrimary = Color(0xFFFAFAFA);   // Main app background
  static const Color backgroundSecondary = Color(0xFFFFFFFF); // Cards and elevated surfaces

  // Primary brand colors for important UI elements
  static const Color importancePrimary = Color(0xFF324779);   // Main brand color for primary actions
  static const Color importanceSecondary = Color(0xFF1E2F50); // Secondary brand color
  static const Color highlightedElement = Color(0xFF182438);  // For buttons and highlighted components

  // Icon colors based on importance hierarchy
  static const Color iconLessImportant = Color(0xFF777777);   // Secondary icons and labels
  static const Color iconImportant = Color(0xFF323232);       // Primary icons and important indicators

  // Text colors for typography hierarchy
  static const Color textGeneral = Color(0xFF6D6D6D);         // Body text and secondary content
  static const Color textImportant = Color(0xFF333333);       // Headings and important text

  // Semantic colors for user feedback and status
  static const Color successColor = Color(0xFF0F9D58);        // Success states and validation
  static const Color errorColor = Color(0xFFD32F2F);          // Error states and warnings

  // Component-specific background colors
  static const Color bottomBarColor = Color(0xFFFFFFFF);      // Bottom navigation bar background
  static const Color topBarColor = Color(0xFFFAFAFA);         // AppBar and top navigation background

  /// Returns the light theme configuration for the SkillShare application
  /// This theme defines the visual appearance for light mode with Sarabun font
  /// and the specified color palette for consistent branding
  static ThemeData get lightTheme {
    return ThemeData(
      // Core color configuration using Material 3 color scheme
      primaryColor: importancePrimary,
      scaffoldBackgroundColor: backgroundPrimary,
      colorScheme: const ColorScheme.light(
        primary: importancePrimary,           // Primary brand color
        secondary: importanceSecondary,       // Secondary brand color
        surface: backgroundSecondary,         // Card and dialog surfaces
        background: backgroundPrimary,        // Main app background
        error: errorColor,                    // Error states color
        onPrimary: Colors.white,              // Text/icon color on primary
        onSecondary: Colors.white,            // Text/icon color on secondary
        onSurface: textImportant,             // Text color on surfaces
        onBackground: textImportant,          // Text color on background
        onError: Colors.white,                // Text color on error
      ),

      // Typography configuration using Sarabun font family
      // Defines text styles for all text variants in the app
      fontFamily: 'Sarabun',
      textTheme: const TextTheme(
        // Display text styles for large headings and hero sections
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textImportant,
          fontFamily: 'Sarabun',
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textImportant,
          fontFamily: 'Sarabun',
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textImportant,
          fontFamily: 'Sarabun',
        ),

        // Title text styles for section headings and important labels
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textImportant,
          fontFamily: 'Sarabun',
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textImportant,
          fontFamily: 'Sarabun',
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textImportant,
          fontFamily: 'Sarabun',
        ),

        // Body text styles for general content and paragraphs
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textGeneral,
          fontFamily: 'Sarabun',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textGeneral,
          fontFamily: 'Sarabun',
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textGeneral,
          fontFamily: 'Sarabun',
        ),

        // Label text styles for interactive elements and buttons
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Sarabun',
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontFamily: 'Sarabun',
        ),
        labelSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontFamily: 'Sarabun',
        ),

        // Headline text styles with primary brand color accent
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: importancePrimary,
          fontFamily: 'Sarabun',
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: importancePrimary,
          fontFamily: 'Sarabun',
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: importancePrimary,
          fontFamily: 'Sarabun',
        ),
      ),

      // AppBar theme configuration for top navigation bars
      // Uses topBarColor background and maintains flat design
      appBarTheme: const AppBarTheme(
        backgroundColor: topBarColor,
        elevation: 0,                        // Flat design without shadow
        centerTitle: true,                   // Centered title alignment
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textImportant,
          fontFamily: 'Sarabun',
        ),
        iconTheme: IconThemeData(
          color: iconImportant,              // Primary color for AppBar icons
          size: 24,
        ),
        actionsIconTheme: IconThemeData(
          color: iconImportant,              // Primary color for action icons
          size: 24,
        ),
      ),

      // Bottom Navigation Bar theme for tab-based navigation
      // Uses white background with clear selection indicators
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bottomBarColor,
        elevation: 8,                        // Subtle shadow for depth
        selectedItemColor: highlightedElement, // Active tab color
        unselectedItemColor: iconLessImportant, // Inactive tab color
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'Sarabun',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          fontFamily: 'Sarabun',
        ),
      ),

      // Card theme for elevated content containers
      // Features rounded corners and subtle shadows
      cardTheme: const CardThemeData(
        elevation: 2,                        // Subtle elevation for depth
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)), // Rounded corners
        ),
        color: backgroundSecondary,          // White background for cards
        shadowColor: Color(0x1A000000),      // Light black shadow with 10% opacity
        margin: EdgeInsets.all(8),           // Consistent spacing around cards
      ),

      // Input decoration theme for text fields and form inputs
      // Provides consistent styling across all input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,                        // Filled background for inputs
        fillColor: backgroundSecondary,      // White background for inputs
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,                      // Comfortable touch targets
        ),
        // Border states for different input conditions
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)), // Default border
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)), // Enabled state
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: importancePrimary), // Focus state
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),       // Error state
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor),       // Focused error
        ),
        // Text styles for different input states
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: iconLessImportant,          // Secondary color for labels
          fontFamily: 'Sarabun',
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: iconLessImportant,          // Secondary color for hints
          fontFamily: 'Sarabun',
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: errorColor,                 // Error message color
          fontFamily: 'Sarabun',
        ),
      ),

      // Elevated button theme for primary actions
      // Uses highlightedElement color for prominent buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: highlightedElement, // Primary button color
          foregroundColor: Colors.white,     // White text on buttons
          elevation: 0,                      // Flat design
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,                    // Comfortable touch target
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Sarabun',
          ),
        ),
      ),

      // Text button theme for secondary actions
      // Uses primary color for text without background
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: importancePrimary, // Primary color for text
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Sarabun',
          ),
        ),
      ),

      // Outlined button theme for tertiary actions
      // Features bordered design with primary color
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: importancePrimary, // Primary color for text
          side: const BorderSide(color: importancePrimary), // Primary border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Sarabun',
          ),
        ),
      ),

      // Icon theme configuration for consistent icon styling
      iconTheme: const IconThemeData(
        color: iconImportant,                // Primary color for icons
        size: 24,                            // Standard icon size
      ),

      // Divider theme for content separation
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),            // Light gray divider
        thickness: 1,                        // Standard thickness
        space: 1,                            // Minimal spacing
      ),

      // Floating action button theme for primary actions
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: highlightedElement, // Primary action color
        foregroundColor: Colors.white,       // White icon color
        elevation: 4,                        // Subtle elevation
      ),

      // SnackBar theme for user feedback messages
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF323232),  // Dark background for contrast
        contentTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          fontFamily: 'Sarabun',
          color: Colors.white,               // White text for readability
        ),
        behavior: SnackBarBehavior.floating, // Floating design
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)), // Rounded corners
        ),
      ),

      // Bottom sheet theme for modal bottom sheets
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: backgroundSecondary, // White background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),    // Rounded top corners
            topRight: Radius.circular(16),
          ),
        ),
      ),

      // Dialog theme for alert dialogs and modal dialogs
      dialogTheme: const DialogThemeData(
        backgroundColor: backgroundSecondary, // White background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)), // Rounded corners
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textImportant,              // Important text color
          fontFamily: 'Sarabun',
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textGeneral,                // General text color
          fontFamily: 'Sarabun',
        ),
      ),
    );
  }

  /// Returns the dark theme configuration for the SkillShare application
  /// This theme adapts the brand colors for dark mode while maintaining
  /// accessibility and visual hierarchy
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      // Dark mode color adaptation
      primaryColor: importancePrimary,
      scaffoldBackgroundColor: const Color(0xFF121212), // Dark background
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),  // Dark app bar
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF2D2D2D),            // Dark card background
        elevation: 2,
      ),
      colorScheme: const ColorScheme.dark(
        primary: importancePrimary,           // Maintain brand color
        secondary: importanceSecondary,       // Maintain secondary color
        surface: Color(0xFF2D2D2D),          // Dark surfaces
        background: Color(0xFF121212),       // Dark background
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white70,             // Light text on dark
          fontFamily: 'Sarabun',
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Colors.white70,             // Light text on dark
          fontFamily: 'Sarabun',
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2D2D2D),        // Dark input background
        labelStyle: TextStyle(color: Colors.white70), // Light labels
        hintStyle: TextStyle(color: Colors.white54),  // Light hints
      ),
    );
  }

  /// Returns the appropriate color based on validation status
  /// [isValid] - Boolean indicating if the validation passed
  /// Returns successColor for true, errorColor for false
  static Color getSuccessColor(bool isValid) {
    return isValid ? successColor : errorColor;
  }

  /// Returns text style for validation messages
  /// [isValid] - Boolean indicating if the validation passed
  /// Returns styled text with appropriate color for validation state
  static TextStyle getValidationTextStyle(bool isValid) {
    return TextStyle(
      color: isValid ? successColor : errorColor,
      fontSize: 12,
      fontWeight: FontWeight.normal,
      fontFamily: 'Sarabun',
    );
  }
}