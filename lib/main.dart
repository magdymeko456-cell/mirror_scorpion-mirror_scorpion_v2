import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/tts_service.dart';
import 'services/database_service.dart';
import 'services/floating_bubble_service.dart';
import 'services/premium_verification_service.dart';
import 'services/language_service.dart';
import 'services/background_service.dart';
import 'services/language_download_service.dart';
import 'features/home_screen.dart';
import 'features/card1_translation/translation_screen.dart';
import 'features/card1_translation/dialogue_screen.dart';
import 'features/card1_translation/document_screen.dart';
import 'features/card4_stories/stories_screen.dart';
import 'features/games/chess_screen.dart';
import 'features/games/rubik_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/about/about_app_screen.dart';
import 'features/admin/key_generator_screen.dart';

/// لغة الجهاز — يفتح التطبيق بلغة المستخدم، مع عودة للعربية عند عدم الدعم
Locale _deviceLocale() {
  final loc = WidgetsBinding.instance.platformDispatcher.locale;
  const supported = [
    Locale('ar'), Locale('en'), Locale('fr'), Locale('es'), Locale('de'),
    Locale('it'), Locale('pt'), Locale('ru'), Locale('zh'), Locale('ja'),
    Locale('ko'), Locale('tr'), Locale('ur'), Locale('fa'), Locale('hi'),
    Locale('bn'), Locale('id'), Locale('ms'), Locale('nl'), Locale('pl'),
    Locale('sv'), Locale('da'), Locale('fi'), Locale('no'), Locale('cs'),
    Locale('hu'), Locale('ro'), Locale('el'), Locale('he'), Locale('th'),
    Locale('vi'), Locale('tl'), Locale('sw'),
  ];
  if (supported.contains(loc)) return loc;
  final lang = Locale(loc.languageCode);
  if (supported.contains(lang)) return lang;
  return const Locale('ar');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageService().init();
  await BackgroundService().initialize();
  await LanguageDownloadService().initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TTSService()),
        ChangeNotifierProvider(create: (_) => DatabaseService()),
        ChangeNotifierProvider(create: (_) => FloatingBubbleService()),
        ChangeNotifierProvider(create: (_) => PremiumVerificationService()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
        ChangeNotifierProvider(create: (_) => BackgroundService()),
        ChangeNotifierProvider(create: (_) => LanguageDownloadService()),
      ],
      child: const MirrorScorpionApp(),
    ),
  );
}

class MirrorScorpionApp extends StatelessWidget {
  const MirrorScorpionApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mirror Scorpion',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'), Locale('en'), Locale('fr'), Locale('es'), Locale('de'),
        Locale('it'), Locale('pt'), Locale('ru'), Locale('zh'), Locale('ja'),
        Locale('ko'), Locale('tr'), Locale('ur'), Locale('fa'), Locale('hi'),
        Locale('bn'), Locale('id'), Locale('ms'), Locale('nl'), Locale('pl'),
        Locale('sv'), Locale('da'), Locale('fi'), Locale('no'), Locale('cs'),
        Locale('hu'), Locale('ro'), Locale('el'), Locale('he'), Locale('th'),
        Locale('vi'), Locale('tl'), Locale('sw'), Locale('ta'), Locale('te'),
        Locale('kn'), Locale('ml'), Locale('gu'), Locale('mr'), Locale('pa'),
        Locale('ne'), Locale('si'), Locale('km'), Locale('my'), Locale('lo'),
        Locale('ka'), Locale('hy'), Locale('az'), Locale('uz'), Locale('kk'),
        Locale('ky'), Locale('tg'), Locale('mn'), Locale('ps'), Locale('sd'),
        Locale('am'), Locale('om'), Locale('ha'), Locale('ig'), Locale('yo'),
        Locale('zu'), Locale('xh'), Locale('af'), Locale('st'), Locale('sn'),
        Locale('rw'), Locale('mg'), Locale('ny'), Locale('eo'), Locale('cy'),
        Locale('ga'), Locale('gd'), Locale('mt'), Locale('is'), Locale('lv'),
        Locale('lt'), Locale('et'), Locale('bs'), Locale('hr'), Locale('sq'),
        Locale('mk'), Locale('sr'), Locale('sl'), Locale('sk'), Locale('eu'),
        Locale('gl'), Locale('ca'), Locale('oc'), Locale('lb'), Locale('fy'),
        Locale('jv'), Locale('su'), Locale('ceb'), Locale('hmn'), Locale('ht'),
        Locale('co'), Locale('la'),
      ],
      locale: _deviceLocale(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/translate': (context) => const TranslationScreen(),
        '/dialogue': (context) => const DialogueScreen(),
        '/document': (context) => const DocumentScreen(),
        '/stories': (context) => const StoriesScreen(),
        '/chess': (context) => const ChessScreen(),
        '/rubik': (context) => const RubikScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/about': (context) => const AboutAppScreen(),
        '/admin_gen': (context) => const KeyGeneratorScreen(),
      },
    );
  }
}
