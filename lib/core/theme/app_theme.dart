import 'package:flutter/material.dart';

class AppTheme {
  // الألوان الملكية للتطبيق
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color primaryDark = Color(0xFF1A1A2E);
  static const Color primaryLight = Color(0xFFF8F9FA);
  static const Color accentPurple = Color(0xFF6C63FF);
  static const Color accentTeal = Color(0xFF2EC4B6);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryGold,
        secondary: accentPurple,
        surface: primaryLight,
        tertiary: accentTeal,
      ),
      scaffoldBackgroundColor: primaryLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGold,
        foregroundColor: Colors.black,
      ),
      fontFamily: null, // use system font for multi-language
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryGold,
        secondary: accentPurple,
        surface: const Color(0xFF121212),
        tertiary: accentTeal,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGold,
        foregroundColor: Colors.black,
      ),
    );
  }
}
