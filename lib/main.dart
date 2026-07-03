import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('app_locale') ?? 
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  final isDark = prefs.getBool('dark_mode') ?? false;
  
  runApp(MirrorScorpionApp(
    initialLocale: savedLocale,
    isDarkMode: isDark,
  ));
}

class MirrorScorpionApp extends StatelessWidget {
  final String initialLocale;
  final bool isDarkMode;
  
  const MirrorScorpionApp({
    super.key,
    required this.initialLocale,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mirror Scorpion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(initialLocale),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ar'),
        const Locale('en'),
        const Locale('fr'),
        const Locale('es'),
        const Locale('ur'),
        const Locale('tr'),
        const Locale('de'),
        const Locale('zh'),
        const Locale('hi'),
        const Locale('pt'),
        const Locale('ru'),
        const Locale('ja'),
      ],
      home: const MainApp(),
    );
  }
}
