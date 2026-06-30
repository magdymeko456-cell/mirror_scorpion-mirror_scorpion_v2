import 'package:flutter/material.dart';
class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;
  bool get isDarkMode => _isDark;
  ThemeData get themeData => _isDark
    ? ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        colorScheme: ColorScheme.dark(primary: Colors.blueAccent, secondary: Colors.cyanAccent, surface: const Color(0xFF1B2838)),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1B2838), foregroundColor: Colors.white, elevation: 0))
    : ThemeData.light().copyWith(scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.light(primary: Colors.blue, secondary: Colors.cyan, surface: Colors.white));
  void toggleTheme() { _isDark = !_isDark; notifyListeners(); }
  void setDarkMode(bool v) { _isDark = v; notifyListeners(); }
}
