import 'package:flutter/material.dart';                    
import 'package:flutter/services.dart';                    
import 'package:provider/provider.dart';                   
import 'core/utils/r_bridge.dart';                         
import 'core/theme/theme_provider.dart';
import 'services/database_service.dart';                   
import 'services/floating_bubble_service.dart';
import 'services/tts_service.dart';                        
import 'services/premium_verification_service.dart';       
import 'services/language_service.dart';                   
import 'services/background_service.dart';
import 'services/language_download_service.dart';
import 'features/home_screen.dart';
import 'features/settings/settings_screen.dart';           
import 'features/about/about_app_screen.dart';             
import 'features/admin/key_generator_screen.dart';         
import 'features/card1_translation/translation_screen.dart';                             
import 'features/card2_dialogue/dialogue_screen.dart';     
import 'features/card3_document/document_screen.dart';
import 'features/card4_stories/stories_screen.dart';       
import 'features/games/chess/chess_screen.dart';           
import 'features/games/rubik_cube/rubik_cube_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();               
  
  // تأمين تهيئة متغيرات الجسر
  try {
    initializeRVariables();    
  } catch (e) {
    debugPrint('⚠ Bridge initialization warning: $e');
  }
                             
  await SystemChrome.setPreferredOrientations([            
    DeviceOrientation.portraitUp,                          
    DeviceOrientation.portraitDown,                        
  ]);                        
                             
  final themeProvider = ThemeProvider();                   
  final databaseService = DatabaseService();               
  final floatingBubbleService = FloatingBubbleService();   
  final premiumService = PremiumVerificationService();     
  final ttsService = TTSService();                         
  final languageService = LanguageService();
  final backgroundService = BackgroundService();
  final languageDownloadService = LanguageDownloadService();

  try {                      
    debugPrint('🚀 Initializing core services...');             
    await databaseService.loadAllData();                   
    await floatingBubbleService.initialize();              
    await premiumService.initialize();
    await languageService.initialize();
    await backgroundService.initialize();
    await languageDownloadService.initialize();
    debugPrint('✅ All services initialized successfully');    
  } catch (e) {              
    debugPrint('⚠ Service initialization warning: $e');    
  }                          
                             
  runApp(                    
    MultiProvider(           
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: databaseService),                            
        ChangeNotifierProvider.value(value: floatingBubbleService),                      
        ChangeNotifierProvider.value(value: ttsService),   
        ChangeNotifierProvider.value(value: premiumService),                             
        ChangeNotifierProvider.value(value: languageService),                             
        ChangeNotifierProvider.value(value: backgroundService),                             
        ChangeNotifierProvider.value(value: languageDownloadService),                             
      ],                     
      child: const MirrorScorpionApp(),                    
    ),                       
  );
}
                             
class MirrorScorpionApp extends StatelessWidget {          
  const MirrorScorpionApp({super.key});                    

  @override                  
  Widget build(BuildContext context) {                     
    return Consumer<ThemeProvider>(                        
      builder: (context, themeProvider, child) {           
        return MaterialApp(  
          title: 'Mirror Scorpion',                        
          debugShowCheckedModeBanner: false,               
          theme: themeProvider.themeData,                  
          initialRoute: '/',
          routes: {          
            '/': (context) => const HomeScreen(),          
            '/translate': (context) => const TextTranslationScreen(),                    
            '/dialogue': (context) => const DialogueTranslationScreen(),                 
            '/document': (context) => const DocumentTranslationScreen(),                 
            '/stories': (context) => const StoriesScreen(),
            '/chess': (context) => const ChessScreen(),
            '/rubik': (context) => const RubikCubeScreen(),
            '/settings': (context) => const SettingsScreen(),                            
            '/about': (context) => const AboutAppScreen(), 
            '/admin_gen': (context) => const KeyGeneratorScreen(),
          },                 
        );
      },                     
    );
  }                          
}
// Adham Secure Core Trigger: 2026-06-02
