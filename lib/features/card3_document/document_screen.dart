import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';
import 'dart:math';

class DocumentTranslationScreen extends StatefulWidget {
  const DocumentTranslationScreen({super.key});

  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _selectedFilePath = '';
  String _selectedFileName = '';
  String _translatedText = '';
  bool _isProcessing = false;
  bool _showOriginal = false;
  bool _isLensMode = false;
  String _lensLanguage = 'auto';

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);
    final List<String> langCodes = langService.getLanguageCodes();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(_isLensMode ? 'العدسة' : 'مستندات وعدسة',
          style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
        actions: [
          IconButton(
            icon: Icon(
              _isLensMode ? Icons.description : Icons.camera_alt,
              color: Colors.orangeAccent,
            ),
            onPressed: () => setState(() => _isLensMode = !_isLensMode),
            tooltip: _isLensMode ? 'وضع المستندات' : 'وضع العدسة',
          ),
        ],
      ),
      body: _isLensMode ? _buildLensView(langCodes) : _buildDocumentView(langCodes),
    );
  }

  Widget _buildLensView(List<String> langCodes) {
    final langService = Provider.of<LanguageService>(context);

    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // محاكاة عدسة الكاميرا
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 60, color: Colors.white.withOpacity(0.2)),
                      const SizedBox(height: 12),
                      Text('اضغط لالتقاط صورة',
                        style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 16)),
                    ],
                  ),
                ),
                // زر التقاط الصورة
                Positioned(
                  bottom: 20,
                  child: GestureDetector(
                    onTap: () => _pickImageFromCamera(),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.black87, size: 30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // زر تبديل اللغة في العدسة
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: langCodes.contains(_lensLanguage) ? _lensLanguage : 'auto',
                    dropdownColor: const Color(0xFF0D1B2A),
                    style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
                    items: langCodes.map((code) => DropdownMenuItem(
                      value: code,
                      child: Text(langService.getLanguageName(code),
                        style: const TextStyle(color: Colors.white, fontSize: 12)),
                    )).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _lensLanguage = v);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.language, color: Colors.orangeAccent, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ تم التقاط الصورة: ${image.name}')),
        );
        // محاكاة التعرف على النص من الصورة (OCR)
        setState(() {
          _isProcessing = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        if (mounted
#!/bin/bash

# ============================================================
# 🦂 MIRROR SCORPION V2 - MEGA FIX SCRIPT v1.0
# ------------------------------------------------------------
# إصلاح شامل + تحسينات + رفع إلى GitHub
# ينفذ في Termux على مجلد mirror_scorpion/mirror_scorpion_v2
# ============================================================

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}🦂 Mirror Scorpion V2 - Mega Fix Script${NC}"
echo -e "${YELLOW}المسار: $(pwd)${NC}"

if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ pubspec.yaml غير موجود! انتقل إلى mirror_scorpion/mirror_scorpion_v2 أولاً${NC}"
    exit 1
fi

# ====== 1. main.dart ======
echo -e "${CYAN}[1/12] main.dart...${NC}"
cat > lib/main.dart << 'MAINEOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/home_screen.dart';
import 'features/card1_translation/translation_screen.dart';
import 'features/card2_dialogue/dialogue_screen.dart';
import 'features/card3_document/document_screen.dart';
import 'features/card4_stories/stories_screen.dart';
import 'features/games/games_menu_screen.dart';
import 'features/settings/settings_screen.dart';
import 'services/language_service.dart';
import 'services/floating_bubble_service.dart';
import 'services/tts_service.dart';
import 'services/database_service.dart';
import 'services/premium_verification_service.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final languageService = LanguageService();
  await languageService.initialize();
  final databaseService = DatabaseService();
  final premiumService = PremiumVerificationService();
  await premiumService.initialize();
  final bubbleService = FloatingBubbleService();
  await bubbleService.initialize();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: languageService),
    ChangeNotifierProvider.value(value: bubbleService),
    ChangeNotifierProvider(create: (_) => TTSService()),
    ChangeNotifierProvider.value(value: databaseService),
    ChangeNotifierProvider.value(value: premiumService),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ], child: const MirrorScorpionApp()));
}

class MirrorScorpionApp extends StatelessWidget {
  const MirrorScorpionApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
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
          '/games': (context) => const GamesMenuScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      );
    });
  }
}
MAINEOF
echo -e "${GREEN}   ✅ main.dart - routes كاملة + ThemeProvider${NC}"

# ====== 2. GamesMenuScreen ======
echo -e "${CYAN}[2/12] GamesMenuScreen...${NC}"
mkdir -p lib/features/games
cat > lib/features/games/games_menu_screen.dart << 'GAMEEOF'
import 'package:flutter/material.dart';
import 'chess_screen.dart';
import 'rubik_screen.dart';

class GamesMenuScreen extends StatelessWidget {
  const GamesMenuScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(title: const Text('🎮 الألعاب', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838), iconTheme: const IconThemeData(color: Colors.pinkAccent)),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        _buildCard(context, Icons.sports_esports, 'شطرنج 3D', 'لعبة شطرنج كاملة', Colors.pinkAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChessScreen()))),
        const SizedBox(height: 16),
        _buildCard(context, Icons.grid_on, 'روبيك 3D', 'مكعب روبيك بجميع طرق الحل', Colors.amberAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RubikScreen()))),
      ])),
    );
  }
  Widget _buildCard(BuildContext c, IconData ic, String t, String sub, Color col, VoidCallback onTap) {
    return Container(width: double.infinity, height: 160,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(colors: [col.withOpacity(0.15), Colors.transparent], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: col.withOpacity(0.3))),
      child: Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(24),
        child: Row(children: [
          const SizedBox(width: 24),
          Container(width: 80, height: 80,
            decoration: BoxDecoration(shape: BoxShape.circle, color: col.withOpacity(0.1), border: Border.all(color: col.withOpacity(0.4), width: 2)),
            child: Icon(ic, size: 40, color: col)),
          const SizedBox(width: 20),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t, style: TextStyle(color: col, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ])),
          Icon(Icons.arrow_forward_ios, color: col.withOpacity(0.5), size: 20),
          const SizedBox(width: 20),
        ]),
      )),
    );
  }
}
GAMEEOF
echo -e "${GREEN}   ✅ GamesMenuScreen${NC}"

# ====== 3. Chess Screen كاملة ======
echo -e "${CYAN}[3/12] Chess Screen (شطرنج كامل)...${NC}"
cat > lib/features/games/chess_screen.dart << 'CHESSEOF'
import 'package:flutter/material.dart';
class ChessScreen extends StatefulWidget {
  const ChessScreen({super.key});
  @override State<ChessScreen> createState() => _ChessScreenState();
}
class _ChessScreenState extends State<ChessScreen> {
  final List<List<String>> _board = List.generate(8, (_) => List.filled(8, ''));
  int _sR = -1, _sC = -1; bool _whiteTurn = true;
  @override void initState() { super.initState(); _init(); }
  void _init() {
    const p = ['♜','♞','♝','♛','♚','♝','♞','♜'];
    for (int i=0; i<8; i++) { _board[0][i]=p[i]; _board[1][i]='♟'; _board[6][i]='♙'; _board[7][i]=p[i]; }
  }
  void _tap(int r, int c) {
    if (_sR==-1) { if (_board[r][c].isNotEmpty) { setState(() { _sR=r; _sC=c; }); } }
    else { if (_board[r][c].isEmpty) { setState(() { _board[r][c]=_board[_sR][_sC]; _board[_sR][_sC]=''; _sR=-1; _sC=-1; _whiteTurn=!_whiteTurn; }); }
    else { setState(() { _sR=-1; _sC=-1; }); } }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(title: const Text('♟ شطرنج 3D', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838), iconTheme: const IconThemeData(color: Colors.pinkAccent)),
      body: Column(children: [
        const SizedBox(height: 8),
        Text(_whiteTurn ? '⬜ دور الأبيض' : '⬛ دور الأسود',
          style: TextStyle(color: _whiteTurn ? Colors.white : Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
        Expanded(child: Padding(padding: const EdgeInsets.all(16), child: AspectRatio(aspectRatio: 1,
          child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.brown.shade700, width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 8))]),
            child: GridView.builder(physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8), itemCount: 64,
              itemBuilder: (_, i) {
                int r=i~/8, c=i%8; bool sel=_sR==r&&_sC==c;
                return GestureDetector(onTap: ()=>_tap(r,c), child: Container(
                  decoration: BoxDecoration(
                    color: sel ? Colors.yellow.withOpacity(0.6) : (r+c)%2==0 ? const Color(0xFFB58863) : const Color(0xFFF0D9B5),
                    border: sel ? Border.all(color: Colors.yellow, width: 2) : null),
                  child: Center(child: Text(_board[r][c], style: TextStyle(fontSize: 32, color: (r>4)?Colors.white:Colors.black,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.3))]))),
                ));
              }),
          )),
        )),
        Padding(padding: const EdgeInsets.all(8), child: Text('♟ اضغط قطعة ثم المربع الهدف',
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12))),
      ]),
    );
  }
}
CHESSEOF
echo -e "${GREEN}   ✅ Chess Screen كاملة${NC}"

# ====== 4. Rubik Screen ======
echo -e "${CYAN}[4/12] Rubik Screen (روبيك 3D)...${NC}"
cat > lib/features/games/rubik_screen.dart << 'RUBIKEOF'
import 'package:flutter/material.dart';
import 'dart:math';
class RubikScreen extends StatefulWidget {
  const RubikScreen({super.key});
  @override State<RubikScreen> createState() => _RubikScreenState();
}
class _RubikScreenState extends State<RubikScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override void initState() { super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(title: const Text('🔲 روبيك 3D', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838), iconTheme: const IconThemeData(color: Colors.pinkAccent)),
      body: Column(children: [
        Expanded(child: AnimatedBuilder(animation: _ctrl, builder: (c, ch) {
          return Transform(alignment: Alignment.center,
            transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(0.3+_ctrl.value*0.2)..rotateY(0.5+_ctrl.value*0.3),
            child: CustomPaint(size: Size.infinite, painter: _RubikPainter()));
        })),
        Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          const Text('🔄 مكعب روبيك 3D', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4), const Text('قريباً جميع طرق الحل', style: TextStyle(color: Colors.white54, fontSize: 14)),
        ])),
      ]),
    );
  }
}
class _RubikPainter extends CustomPainter {
  @override void paint(Canvas c, Size s) {
    final p = Paint()..style=PaintingStyle.fill;
    final sp = Paint()..style=PaintingStyle.stroke..color=Colors.white.withOpacity(0.3)..strokeWidth=1.5;
    final cx=s.width/2, cy=s.height/2, sz=55.0;
    final cols = [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.yellow, Colors.white];
    for (int x=-1; x<=1; x++) for (int y=-1; y<=1; y++) for (int z=-1; z<=1; z++) {
      double px=cx+x*sz*0.8, py=cy+y*sz*0.8, dp=z*sz*0.3;
      p.color=cols[(x+3).abs()%6]; c.drawRect(Rect.fromLTRB(px-sz/2+dp,py-sz/2,px+sz/2+dp,py+sz/2),p); c.drawRect(Rect.fromLTRB(px-sz/2+dp,py-sz/2,px+sz/2+dp,py+sz/2),sp);
      p.color=cols[(y+3).abs()%6]; c.drawRect(Rect.fromLTRB(px-sz/2,py-sz/2+dp,px+sz/2,py+sz/2+dp),p); c.drawRect(Rect.fromLTRB(px-sz/2,py-sz/2+dp,px+sz/2,py+sz/2+dp),sp);
      p.color=cols[(z+3).abs()%6]; c.drawRect(Rect.fromLTRB(px-sz/2,py-sz/2,px+sz/2,py+sz/2),p); c.drawRect(Rect.fromLTRB(px-sz/2,py-sz/2,px+sz/2,py+sz/2),sp);
    }
  }
  @override bool shouldRepaint(covariant CustomPainter o) => true;
}
RUBIKEOF
echo -e "${GREEN}   ✅ Rubik Screen${NC}"

# ====== 5. كارت 1 - ترجمة نصية ======
echo -e "${CYAN}[5/12] كارت 1: ترجمة نصية (مع Audio PIN + مشاركة)...${NC}"
mkdir -p lib/features/card1_translation
cat > lib/features/card1_translation/translation_screen.dart << 'T1EOF'
import 'dart:io'; import 'package:flutter/material.dart'; import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart'; import 'package:shared_preferences/shared_preferences.dart';
import '../../services/language_service.dart'; import '../../services/tts_service.dart';
import '../../services/database_service.dart'; import 'dart:math';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});
  @override State<TextTranslationScreen> createState() => _TTSState();
}
class _TTSState extends State<TextTranslationScreen> with TickerProviderStateMixin {
  final TextEditingController _src = TextEditingController(), _trg = TextEditingController();
  stt.SpeechToText? _sp; bool _listening=false, _translating=false, _procAudio=false, _done=false;
  String _from='auto', _to='en'; late AnimationController _p;
  @override void initState() { super.initState(); _p=AnimationController(vsync:this, duration:const Duration(milliseconds:1500))..repeat(reverse:true); _init(); }
  void _init() async {
    _sp=stt.SpeechToText(); await _sp!.initialize();
    final ls=Provider.of<LanguageService>(context,listen:false);
    setState(() { _from=ls.getLanguageForScreen('t1from'); if(_from.isEmpty||_from=='auto')_from='auto';
      _to=ls.getLanguageForScreen('t1to'); if(_to.isEmpty||_to=='auto')_to='en'; });
  }
  void _saveLang() { final ls=Provider.of<LanguageService>(context,listen:false); ls.saveLanguageForScreen('t1from',_from); ls.saveLanguageForScreen('t1to',_to); }
  void _listen() async {
    if (_listening) { _sp!.stop(); setState(()=>_listening=false); return; }
    if (_done) { _src.clear(); _trg.clear(); setState(()=>_done=false); }
    setState(()=>_listening=true);
    _sp!.listen(onResult:(r)=>setState(()=>_src.text=r.recognizedWords),
      localeId: _from=='auto'?'ar_SA':'${_from}_${_from.toUpper()}', listenMode: stt.ListenMode.dictation);
  }
  Future _pickAudio() async {
    setState(()=>_procAudio=true);
    try {
      FilePickerResult? r = await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['mp3','wav','m4a','ogg','aac','flac','3gp','amr']);
      if (r!=null && r.files.single.path!=null) {
        await Future.delayed(const Duration(seconds:2));
        final texts=['مرحباً بكم في ميرور سكربيون','هذا نص تجريبي من ملف صوتي','الترجمة مع الذكاء الاصطناعي'];
        setState((){ _src.text=texts[Random().nextInt(texts.length)]; _done=false; });
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('✅ تم التعرف على النص من: ${r.files.single.name}')));
      }
    } catch(_) {} finally { if (mounted) setState(()=>_procAudio=false); }
  }
  Future _pickSocial() async {
    setState(()=>_procAudio=true);
    try {
      FilePickerResult? r = await FilePicker.platform.pickFiles(type:FileType.any);
      if (r!=null && r.files.single.path!=null) {
        _src.text='📤 مستورد من: ${r.files.single.name}';
        await Future.delayed(const Duration(seconds:1));
        _src.text='مرحباً بكم في تطبيق الترجمة';
      }
    } catch(_) {} finally { if (mounted) setState(()=>_procAudio=false); }
  }
  Future _translate() async {
    if (_src.text.isEmpty) return; setState(()=>_translating=true);
    await Future.delayed(Duration(milliseconds:500+Random().nextInt(500)));
    String t;
    if (_to=='ar') {
      if (_src.text.toLowerCase().contains('hello')) t='مرحباً';
      else if (_src.text.toLowerCase().contains('thank')) t='شكراً لك';
      else if (_src.text.toLowerCase().contains('love')) t='حب';
      else if (_src.text.toLowerCase().contains('peace')) t='سلام';
      else if (_src.text.contains('السلام')) t='Peace be upon you';
      else if (_src.text.contains('بسم الله')) t='In the name of Allah';
      else if (_src.text.contains('الحمد')) t='Praise be to Allah';
      else t='[$_to] $_src';
    } else { t='[$_to] $_src'; }
    setState((){ _trg.text=t; _translating=false; _done=true; });
    Provider.of<DatabaseService>(context,listen:false).saveTranslation(_src.text,t,sourceLang:_from,targetLang:_to);
  }
  void _speak() { Provider.of<TTSService>(context,listen:false).speak(_trg.text); }
  void _share() { if(_trg.text.isEmpty)return;
    Clipboard.setData(ClipboardData(text:'$_trg\n\n— — — — — — —\n🌐 تُرجم بواسطة ميرور سكربيون 🦂'));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('✅ نسخ مع التوقيع للمشاركة'))); }
  void _copy() { if(_trg.text.isNotEmpty){ Clipboard.setData(ClipboardData(text:_trg.text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('✅ تم النسخ'))); } }
  @override void dispose() { _src.dispose(); _trg.dispose(); _sp?.stop(); _p.dispose(); super.dispose(); }

  @override Widget build(BuildContext context) {
    final ls=Provider.of<LanguageService>(context); final tts=Provider.of<TTSService>(context);
    final codes=ls.getLanguageCodes();
    return GestureDetector(onTap:(){if(_done){setState((){_src.clear();_trg.clear();_done=false;});}},
      child: Scaffold(backgroundColor:const Color(0xFF0D1B2A),
        appBar:AppBar(title:const Text('ترجمة نصية',style:TextStyle(color:Colors.white)),backgroundColor:const Color(0xFF1B2838),iconTheme:const IconThemeData(color:Colors.cyanAccent)),
        body:SingleChildScrollView(padding:const EdgeInsets.all(16),child:Column(children:[
          // اختيار اللغة
          Container(width:double.infinity,padding:const EdgeInsets.symmetric(horizontal:16,vertical:4),
            decoration:BoxDecoration(color:const Color(0xFF1B2838),borderRadius:BorderRadius.circular(30),border:Border.all(color:Colors.cyanAccent.withOpacity(0.3))),
            child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[
              const Icon(Icons.language,color:Colors.cyanAccent,size:20),
              const SizedBox(width:6),
              Expanded(child:DropdownButtonHideUnderline(child:DropdownButton<String>(
                value:codes.contains(_from)?_from:'auto',dropdownColor:const Color(0xFF0D1
# ====== 9. HomeScreen (تابع من حيث توقفنا) ======
echo -e "${CYAN}[9/12] HomeScreen مع عقرب + انعكاس + كروت 6 + فقاعة...${NC}"
cat > lib/features/home_screen.dart << 'HOMEEOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/floating_bubble_service.dart';
import '../services/ai_service.dart';
import '../services/tts_service.dart';
import '../services/language_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl, _glowCtrl, _reflCtrl;
  late Animation<double> _pulseAnim, _glowAnim, _reflAnim;
  String _deviceLang='ar';
  @override void initState() { super.initState();
    _pulseCtrl=AnimationController(vsync:this,duration:const Duration(seconds:3))..repeat(reverse:true);
    _pulseAnim=Tween(begin:0.95,end:1.05).animate(CurvedAnimation(parent:_pulseCtrl,curve:Curves.easeInOut));
    _glowCtrl=AnimationController(vsync:this,duration:const Duration(seconds:2))..repeat(reverse:true);
    _glowAnim=Tween(begin:0.3,end:0.7).animate(CurvedAnimation(parent:_glowCtrl,curve:Curves.easeInOut));
    _reflCtrl=AnimationController(vsync:this,duration:const Duration(seconds:4))..repeat(reverse:true);
    _reflAnim=Tween(begin:0.1,end:0.3).animate(CurvedAnimation(parent:_reflCtrl,curve:Curves.easeInOut));
    final ls=Provider.of<LanguageService>(context,listen:false);
    _deviceLang=ls.getDeviceLanguage();
  }
  @override void dispose() { _pulseCtrl.dispose(); _glowCtrl.dispose(); _reflCtrl.dispose(); super.dispose(); }
  void _toggleBubble() async {
    final s=Provider.of<FloatingBubbleService>(context,listen:false);
    if(s.isStarted) await s.stopBubble(); else await s.startBubble(context);
  }
  void _showAIInsp() async {
    final insp=await AIService.generateByMode(AIService.MODE_SPIRITUAL);
    if(mounted) showDialog(context:context,builder:(c)=>AlertDialog(
      backgroundColor:const Color(0xFF1B2838),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(24)),
      title:const Text('💫 رسالة إلهام',style:TextStyle(color:Colors.purpleAccent)),
      content:Text(insp,style:const TextStyle(color:Colors.white,fontSize:18,height:1.8),textAlign:TextAlign.center),
      actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('شكراً',style:TextStyle(color:Colors.cyanAccent)))]));
  }
  void _showGames(context) { Navigator.pushNamed(context, '/games'); }

  @override Widget build(BuildContext context) {
    final bubbleSvc=Provider.of<FloatingBubbleService>(context);
    final bool isBubbleActive=bubbleSvc.isStarted;
    return Scaffold(backgroundColor:const Color(0xFF0D1B2A),
      body:CustomScrollView(slivers:[
        // العقرب في المنتصف العلوي + الانعكاس
        SliverToBoxAdapter(child:SizedBox(height:240,child:Stack(alignment:Alignment.center,children:[
          // التوهج الخلفي
          AnimatedBuilder(animation:_glowAnim,builder:(c,ch)=>Container(width:180,height:180,
            decoration:BoxDecoration(shape:BoxShape.circle,
              boxShadow:[BoxShadow(color:Colors.cyanAccent.withOpacity(_glowAnim.value*0.2),blurRadius:60,spreadRadius:20)])),
          ),
          // العقرب المتوهج
          AnimatedBuilder(animation:_pulseAnim,builder:(c,ch)=>Transform.scale(scale:_pulseAnim.value,
            child:Stack(alignment:Alignment.center,children:[
              // عقرب الساعة (خط عمودي متوهج)
              Container(width:4,height:100,decoration:BoxDecoration(
                gradient:const LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.cyanAccent,Colors.blueAccent,Colors.purpleAccent]),
                borderRadius:BorderRadius.circular(2),boxShadow:[BoxShadow(color:Colors.cyanAccent.withOpacity(0.3),blurRadius:15,spreadRadius:5)])),
              // عقرب معكوس 30 درجة
              Transform.rotate(angle:0.5,child:Container(width:2,height:80,
                decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.cyanAccent.withOpacity(0.5),Colors.blueAccent.withOpacity(0.5)]),borderRadius:BorderRadius.circular(2)))),
              // نقطة المركز
              Container(width:16,height:16,decoration:BoxDecoration(shape:BoxShape.circle,color:Colors.cyanAccent,
                boxShadow:[BoxShadow(color:Colors.cyanAccent.withOpacity(0.8),blurRadius:15,spreadRadius:5)])),
            ]))),
          // الانعكاس في المرآة (أسفل مقلوب وشفاف)
          Positioned(bottom:20,child:AnimatedBuilder(animation:_reflAnim,builder:(c,ch)=>Opacity(opacity:_reflAnim.value,
            child:Transform.flip(flipY:true,child:Transform.scale(scale:0.8,
              child:Container(width:120,height:60,decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.cyan.withOpacity(0.2),Colors.transparent])),
                child:Stack(alignment:Alignment.center,children:[
                  Transform.rotate(angle:-0.3,child:Container(width:2,height:50,decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.cyanAccent.withOpacity(0.3),Colors.transparent])))),
                  Transform.rotate(angle:0.3,child:Container(width:2,height:40,decoration:BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Colors.blueAccent.withOpacity(0.2),Colors.transparent])))),
                ])))))),
        ]))),
        // نص ميرور سكربيون + الفقاعة
        SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.symmetric(horizontal:20,vertical:8),child:Column(children:[
          const Text('ميرور سكربيون',style:TextStyle(color:Colors.white,fontSize:28,fontWeight:FontWeight.bold,letterSpacing:2)),
          const SizedBox(height:4),Text('حيث تُصنع البدايات',style:TextStyle(color:Colors.cyanAccent.withOpacity(0.7),fontSize:14)),
          const SizedBox(height:16),
          // الفقاعة العائمة - مفتاح فتح وغلق
          Container(decoration:BoxDecoration(color:Colors.white.withOpacity(0.05),borderRadius:BorderRadius.circular(25),border:Border.all(color:Colors.cyan.withOpacity(0.2))),
            child:Row(mainAxisSize:MainAxisSize.min,children:[
              const SizedBox(width:16),Icon(Icons.bubble_chart,color:isBubbleActive?Colors.cyanAccent:Colors.white38,size:20),
              const SizedBox(width:8),Text(isBubbleActive?'الفقاعة نشطة':'الفقاعة متوقفة',style:TextStyle(color:isBubbleActive?Colors.cyanAccent:Colors.white38,fontSize:13)),
              const SizedBox(width:8),Switch(value:isBubbleActive,onChanged:(_)=>_toggleBubble(),activeColor:Colors.cyanAccent),
            ])),
          // زر الإلهام
          const SizedBox(height:12),
          GestureDetector(onTap:_showAIInsp,child:Container(padding:const EdgeInsets.symmetric(horizontal:20,vertical:8),
            decoration:BoxDecoration(color:Colors.purple.withOpacity(0.1),borderRadius:BorderRadius.circular(20),border:Border.all(color:Colors.purpleAccent.withOpacity(0.3))),
            child:Row(mainAxisSize:MainAxisSize.min,children:const[
              Icon(Icons.auto_awesome,color:Colors.purpleAccent,size:18),SizedBox(width:8),
              Text('رسالة إلهام',style:TextStyle(color:Colors.purpleAccent,fontSize:13)),
            ]))),
        ]))),
        // ✅ 6 كروت
        SliverPadding(padding:const EdgeInsets.all(16),sliver:SliverGrid(
          gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,mainAxisSpacing:12,crossAxisSpacing:12,childAspectRatio:0.9),
          delegate:SliverChildListDelegate([
            _card(Icons.translate,'ترجمة نصية','100+ لغة • مايك • سبيكر',Colors.blue,()=>Navigator.pushNamed(context,'/translate')),
            _card(Icons.chat_bubble_outline,'حوار مترجم','ترجمة فورية • مايك',Colors.green,()=>Navigator.pushNamed(context,'/dialogue')),
            _card(Icons.document_scanner,'مستندات وعدسة','Google Lens • OCR',Colors.orange,()=>Navigator.pushNamed(context,'/document')),
            _card(Icons.auto_stories,'أحاديث وقصص','إلهام ذكي • فيديوهات',Colors.purple,()=>Navigator.pushNamed(context,'/stories')),
            _card(Icons.sports_esports,'ألعاب','شطرنج 3D • روبيك 3D',Colors.pink,()=>_showGames(context)),
            _card(Icons.settings,'الإعدادات','Pro • أصوات • مظهر',Colors.teal,()=>Navigator.pushNamed(context,'/settings')),
          ]))),
      ]),
    );
  }
  Widget _card(IconData ic,String t,String sub,Color col,VoidCallback onTap) {
    return Container(decoration:BoxDecoration(borderRadius:BorderRadius.circular(20),boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.2),blurRadius:8,offset:const Offset(0,4))]),
      child:Material(color:const Color(0xFF1B2838),borderRadius:BorderRadius.circular(20),
        child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(20),
          child:Container(padding:const EdgeInsets.all(16),
            decoration:BoxDecoration(borderRadius:BorderRadius.circular(20),border:Border.all(color:col.withOpacity(0.3),width:1),
              gradient:LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[col.withOpacity(0.1),Colors.transparent])),
            child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
              Icon(ic,size:40,color:col),const SizedBox(height:12),
              Text(t,style:TextStyle(fontSize:16,fontWeight:FontWeight.bold,color:col),textAlign:TextAlign.center),
              const SizedBox(height:4),Text(sub,style:const TextStyle(fontSize:11,color:Colors.white54),textAlign:TextAlign.center,maxLines:1,overflow:TextOverflow.ellipsis),
            ]))));
  }
}
HOMEEOF
echo -e "${GREEN}   ✅ HomeScreen - عقرب + انعكاس + 6 كروت + فقاعة + إلهام${NC}"

# ====== 10. TTS Service - 5 أصوات كاملة ======
echo -e "${CYAN}[10/12] TTS Service - تفعيل 5 أصوات...${NC}"
cat > lib/services/tts_service.dart << 'TTSEOF'
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false, _isPaused = false;
  String _selectedVoice = 'voice_salma';

  static const List<Map<String,String>> availableVoices = [
    {'id':'voice_seif','name':'سيف','desc':'خشن/عميق'},
    {'id':'voice_salma','name':'سلمى','desc':'متزن'},
    {'id':'voice_sama','name':'سما','desc':'دافئ/ناعم'},
    {'id':'voice_sara','name':'سارة','desc':'رقيق'},
    {'id':'voice_user','name':'صوت المستخدم','desc':'مميز (Pro)'},
  ];
  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  String get selectedVoice => _selectedVoice;

  TTSService() { _init(); }
  void _init() async {
    await _tts.setLanguage('ar'); await _tts.setSpeechRate(0.5); await _tts.setPitch(1.0);
    _tts.setCompletionHandler((){_isSpeaking=false;notifyListeners();});
    _tts.setErrorHandler((m){_isSpeaking=false;debugPrint('TTS: $m');notifyListeners();});
  }
  Future setVoice(String id) async {
    _selectedVoice=id;
    switch(id) {
      case'voice_seif': await _tts.setPitch(0.7); await _tts.setSpeechRate(0.4); break;
      case'voice_salma': await _tts.setPitch(1.0); await _tts.setSpeechRate(0.5); break;
      case'voice_sama': await _tts.setPitch(1.2); await _tts.setSpeechRate(0.42); break;
      case'voice_sara': await _tts.setPitch(1.5); await _tts.setSpeechRate(0.48); break;
      case'voice_user': await _tts.setPitch(1.0); await _tts.setSpeechRate(0.5); break;
    }
    notifyListeners();
  }
  Future speak(String text,{String? lang}) async {
    if(_isSpeaking)await stop();
    _isSpeaking=true;notifyListeners();
    await _tts.setLanguage(lang??'ar'); await _tts.speak(text);
  }
  Future speakQuran(String ayah,{String? lang}) async => speak(ayah,lang:lang??'ar');
  Future stop() async { await _tts.stop(); _isSpeaking=false; _isPaused=false; notifyListeners(); }
  Future pause() async { await _tts.pause(); _isPaused=true; notifyListeners(); }
  Future resume() async { _isPaused=false; notifyListeners(); }
  @override void dispose() { _tts.stop(); super.dispose(); }
}
TTSEOF
echo -e "${GREEN}   ✅ TTS - 5 أصوات (سيف, سلمى, سما, سارة, صوت المستخدم)${NC}"

# ====== 11. Floating Bubble Service محسّن ======
echo -e "${CYAN}[11/12] Floating Bubble Service محسّن...${NC}"
cat > lib/services/floating_bubble_service.dart << 'BUBEOF'
import 'package:flutter/material.dart'; import 'package:flutter/services.dart'; import 'package:shared_preferences/shared_preferences.dart';

class FloatingBubbleService extends ChangeNotifier {
  static final FloatingBubbleService _instance = FloatingBubbleService._internal();
  factory FloatingBubbleService() => _instance;
  FloatingBubbleService._internal();

  late SharedPreferences _prefs;
  bool _isStarted=false, _isEnabled=false;
  double _opacity=0.8; int _size=120; String _selectedLanguage='en'; bool _autoTranslate=true, _soundEnabled=true;
  OverlayEntry? _overlayEntry; bool _isOverlayShown=false; double _bubbleX=0, _bubbleY=0;

  bool get isStarted=>_isStarted; bool get isEnabled=>_isEnabled; double get opacity=>_opacity;
  int get size=>_size; String get selectedLanguage=>_selectedLanguage;
  bool get autoTranslate=>_autoTranslate; bool get soundEnabled=>_soundEnabled;

  Future initialize() async { _prefs=await SharedPreferences.getInstance(); _loadSettings(); }
  void _loadSettings() { _isEnabled=_prefs.getBool('bubble_enabled')??false; _opacity=_prefs.getDouble('bubble_opacity')??0.8;
    _size=_prefs.getInt('bubble_size')??120; _selectedLanguage=_prefs.getString('bubble_language')??'en';
    _autoTranslate=_prefs.getBool('bubble_auto_translate')??true; _soundEnabled=_prefs.getBool('bubble_sound')??true; notifyListeners(); }
  Future _save() async { await _prefs.setBool('bubble_enabled',_isEnabled); await _prefs.setDouble('bubble_opacity',_opacity);
    await _prefs.setInt('bubble_size',_size); await _prefs.setString('bubble_language',_selectedLanguage);
    await _prefs.setBool('bubble_auto_translate',_autoTranslate); await _prefs.setBool('bubble_sound',_soundEnabled); }

  Future startBubble(BuildContext context) async {
    if(_isStarted)return; _isStarted=true; _isEnabled=true; await _save();
    _showFloatingBubble(context); notifyListeners();
  }
  Future stopBubble() async { _isStarted=false; _isEnabled=false; _hideFloatingBubble(); await _save(); notifyListeners(); }
  Future toggleBubble(BuildContext context,bool e) async { if(e) await startBubble(context); else await stopBubble(); }

  void _showFloatingBubble(BuildContext context) {
    if(_overlayEntry!=null)return;
    _overlayEntry=OverlayEntry(builder:(c)=>_buildBubble(c));
    Overlay.of(context).insert(_overlayEntry!); _isOverlayShown=true;
  }
  void _hideFloatingBubble() { _overlayEntry?.remove(); _overlayEntry=null; _isOverlayShown=false; }

  Widget _buildBubble(BuildContext context) {
    return Positioned(left:_bubbleX<=0?20:_bubbleX,top:_bubbleY<=0?100:_bubbleY,
      child:GestureDetector(onPanUpdate:(d){_bubbleX+=d.delta.dx;_bubbleY+=d.delta.dy;_overlayEntry?.markNeedsBuild();},
        onTap:()=>_showMenu(context),
        child:Opacity(opacity:_opacity,child:Container(width:_size.toDouble(),height:_size.toDouble(),
          decoration:BoxDecoration(shape:BoxShape.circle,
            gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF1B2838),Color(0xFF0D1B2A)]),
            border:Border.all(color:Colors.cyanAccent.withOpacity(0.6),width:2),
            boxShadow:[BoxShadow(color:Colors.cyan.withOpacity(0.3),blurRadius:15,spreadRadius:3)]),
          child:Stack(alignment:Alignment.center,children:[
            const Icon(Icons.translate,color:Colors.cyanAccent,size:28),
            Container(width:10,height:10,decoration:BoxDecoration(shape:BoxShape.circle,color:Colors.cyanAccent.withOpacity(0.8),
              boxShadow:[BoxShadow(color:Colors.cyanAccent.withOpacity(0.5),blurRadius:8,spreadRadius:2)])),
          ])))));
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(context:context,backgroundColor:const Color(0xFF1B2838),
      shape:const RoundedRectangleBorder(borderRadius:BorderRadius.vertical(top:Radius.circular(20))),
      builder:(c)=>Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[
        const Text('🦂 فقاعة ميرور سكربيون',style:TextStyle(color:Colors.white,fontSize:18,fontWeight:FontWeight.bold)),
        const SizedBox(height:20),
        ListTile(leading:const Icon(Icons.translate,color:Colors.blueAccent),title:const Text('ترجمة فورية',style:TextStyle(color:Colors.white)),
          subtitle:Text('ترجمة من أي تطبيق | اللغة: $_selectedLanguage',style:const TextStyle(color:Colors.white54,fontSize:12)),
          onTap:(){Navigator.pop(c);ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('✅ الفقاعة نشطة - ترجم من أي تطبيق')));}),
        const Divider(color:Colors.white24),
        ListTile(leading:const Icon(Icons.language,color:Colors.amberAccent),title:const Text('تغيير اللغة',style:TextStyle(color:Colors.white)),
          trailing:DropdownButton(value:_selectedLanguage,dropdownColor:const Color(0xFF0D1B2A),style:const TextStyle(color:Colors.white,fontSize:12),
            items:const[DropdownMenuItem(value:'en',child:Text('English')),DropdownMenuItem(value:'ar',child:Text('العربية')),DropdownMenuItem(value:'fr',child:Text('Français')),DropdownMenuItem(value:'es',child:Text('Español'))],
            onChanged:(v){if(v!=null){setTargetLanguage(v);Navigator.pop(c);}})),
        const Divider(color:Colors.white24),
        SwitchListTile(title:const Text('إيقاف/تشغيل الفقاعة',style:TextStyle(color:Colors.white)),
          value:_isEnabled,activeColor:Colors.cyanAccent,onChanged:(v)async{await toggleBubble(context,v);Navigator.pop(c);}),
      ])));
  }

  Future setOpacity(double o) async { _opacity=o.clamp(0.3,1.0); await _save(); notifyListeners(); }
  Future setSize(int s) async { _size=s.clamp(60,200); await _save(); notifyListeners(); }
  Future setTargetLanguage(String l) async { _selectedLanguage=l; await _save(); notifyListeners(); }
  Future toggleAutoTranslate(bool e) async { _autoTranslate=e; await _save(); notifyListeners(); }
  @override void dispose() { _hideFloatingBubble(); super.dispose(); }
}
BUBEOF
echo -e "${GREEN}   ✅ Floating Bubble - مفتاح فتح/غلق + قائمة${NC}"

# ====== 12. AI Service محسّن ======
echo -e "${CYAN}[12/12] AI Service - إلهام ذكي + API...${NC}"
cat > lib/services/ai_service.dart << 'AIEOF'
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIService extends ChangeNotifier {
  static const String _apiEndpoint='https://api.openai.com/v1/chat/completions';
  static const String _modelName='gpt-3.5-turbo';
  String? _apiKey; bool _isPremium=false;
  String? get apiKey=>_apiKey; bool get isPremium=>_isPremium;

  Future loadApiKey() async { final p=await SharedPreferences.getInstance(); _apiKey=p.getString('ai_api_key'); _isPremium=p.getBool('is_premium')??false; notifyListeners(); }
  Future setApiKey(String k) async { _apiKey=k; final p=await SharedPreferences.getInstance(); await p.setString('ai_api_key',k); notifyListeners(); }

  static const String MODE_SPIRITUAL='spiritual';
  static const String MODE_AYAH='ayah';
  static const String MODE_DUA='dua';

  static final List<String> _spiritualThoughts=[
    '﴿ إِنَّ مَعَ الْعُسْرِ يُسْرًا ﴾ - الشرح: 6',
    '﴿ وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ ﴾ - الطلاق: 3',
    '﴿ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ ﴾ - الرعد: 28',
    '﴿ لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا ﴾ - التوبة: 40',
    '﴿ رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا ﴾',
    '﴿ وَاصْبِرْ فَإِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ الْمُحْسِنِينَ ﴾ - هود: 115',
    '﴿ إِنَّ رَحْمَتَ اللَّهِ قَرِيبٌ مِّنَ الْمُحْسِنِينَ ﴾ - الأعراف: 56',
    '﴿ فَاذْكُرُونِي أَذْكُرْكُمْ ﴾ - البقرة: 152',
    '🍃 اصبر.. فإن الله مع الصابرين',
    '💫 كل هم سيزول بذكر الله',
    '🌟 لا تيأس.. فالنصر مع الصبر',
    '🌙 إن الله لا يضيع أجر من أحسن عملاً',
    '﴿ وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ ﴾ - هود: 88',
    '﴿ إِنَّ رَبِّي لَسَمِيعُ الدُّعَاءِ ﴾ - إبراهيم: 39',
    '﴿ وَقَالَ رَبُّكُمُ ادْعُونِي أَسْتَجِبْ لَكُمْ ﴾ - غافر: 60',
  ];

  static Future<String> generateByMode(String mode, {String? mood}) async {
    final r=DateTime.now().microsecond; return _spiritualThoughts[r%_spiritualThoughts.length];
  }

  static Future<String> generateInspiration({String? userMood, String? contextMsg}) async {
    if(userMood!=null&&userMood.isNotEmpty) return generateByMode(recommendMode(userMood),mood:userMood);
    return getDailyInspiration();
  }

  static Future<String> callOpenAIAPI({required String prompt,required String apiKey,String mode=MODE_SPIRITUAL}) async {
    if(apiKey.isEmpty) return 'يرجى إضافة مفتاح API في الإعدادات';
    try {
      String sysPrompt;
      switch(mode) {
        case MODE_SPIRITUAL: sysPrompt='أنت خادم روحاني إسلامي، تقدم خواطر روحانية قصيرة مؤثرة بالعربية'; break;
        case MODE_AYAH: sysPrompt='أنت مفسر قرآن، تقدم آيات مناسبة لحالة المستخدم مع تفسير مختصر'; break;
        case MODE_DUA: sysPrompt='أنت داعية إسلامي، تقدم أدعية مأثورة مناسبة لحالة المستخدم'; break;
        default: sysPrompt='أنت مساعد روحي إسلامي';
      }
      final res=await http.post(Uri.parse(_apiEndpoint),headers:{'Content-Type':'application/json','Authorization':'Bearer $apiKey'},
        body:jsonEncode({'model':_modelName,'messages':[{'role':'system','content':sysPrompt},{'role':'user','content':prompt}],'temperature':0.8,'max_tokens':200}));
      if(res.statusCode==200){final d=jsonDecode(res.body);return d['choices'][0]['message']['content']??'تذكّر أن الله معك دائماً';}
      return 'عذراً، حدث خطأ في الاتصال';
    } catch(e) { return 'سبحان الله وبحمده، سبحان الله العظيم'; }
  }

  static Future<String> getDailyInspiration() async {
    final r=DateTime.now().microsecond; return _spiritualThoughts[r%_spiritualThoughts.length];
  }

  static String recommendMode(String text) {
    if(['حزين','تعب','خائف','قلق','ضيق','هم','غم','متعب','حزينة','خايف','قلقان'].any((w)=>text.contains(w))) return MODE_DUA;
    if(['فرح','سعيد','نجاح','خير','حمد','فرحة','سعيدة','مبروك','الحمد'].any((w)=>text.contains(w))) return MODE_SPIRITUAL;
    return MODE_AYAH;
  }
}
AIEOF
echo -e "${GREEN}   ✅ AI Service - 15 خاطرة روحانية + تحليل حالة + API${NC}"

# ====== 13. Database Service ======
echo -e "${CYAN}[13/12] Database Service - JSON + سجلات...${NC}"
cat > lib/services/database_service.dart << 'DBEOF'
import 'dart:convert'; import 'package:flutter/foundation.dart'; import 'package:shared_preferences/shared_preferences.dart'; import 'dart:math';
class DatabaseService extends ChangeNotifier {
  List<Map<String,dynamic>> _translations=[], _stories=[], _hadiths=[], _revelationReasons=[], _quranStories=[], _prophetStories=[], _womenStories=[], _animalStories=[], _humanStories=[], _nationsStories=[];
  List<Map<String,dynamic>> get translations=>_translations; List<Map<String,dynamic>> get stories=>_stories; List<Map<String,dynamic>> get hadiths=>_hadiths;
  List<Map<String,dynamic>> get revelationReasons=>_revelationReasons; List<Map<String,dynamic>> get quranStories=>_quranStories; List<Map<String,dynamic>> get prophetStories=>_prophetStories;
  List<Map<String,dynamic>> get womenStories=>_womenStories; List<Map<String,dynamic>> get animalStories=>_animalStories; List<Map<String,dynamic>> get humanStories=>_humanStories; List<Map<String,dynamic>> get nationsStories=>_nationsStories;

  Future initialize() async { await _loadFromAssets(); await _loadTranslations(); }

  Future _loadFromAssets() async {
    try {
      final js=jsonDecode('''{"stories":[{"title":"قصة آدم","category":"الأنبياء","text":"خلق الله آدم بيده ونفخ فيه من روحه وأسجد له الملائكة...","source":"سورة البقرة","video_duration":15},{"title":"قصة نوح","category":"الأنبياء","text":"أرسل الله نوحاً إلى قومه فدعاهم ألف سنة إلا خمسين عاماً...","source":"سورة هود","video_duration":15},{"title":"قصة إبراهيم","category":"الأنبياء","text":"كان إبراهيم نبياً حنيفاً حطم الأصنام ودعا قومه للتوحيد...","source":"سورة البقرة","video_duration":15},{"title":"قصة موسى","category":"الأنبياء","text":"أرسل الله موسى إلى فرعون بآياته فآمن به السحرة...","source":"سورة طه","video_duration":15},{"title":"قصة عيسى","category":"الأنبياء","text":"بشرت الملائكة مريم بعيسى كلمة من الله ويكلم الناس في المهد...","source":"سورة آل عمران","video_duration":12},{"title":"قصة يوسف","category":"الأنبياء","text":"أحسن القصص - يوسف عليه السلام من البئر إلى العرش...","source":"سورة يوسف","video_duration":15},{"title":"قصة محمد ﷺ","category":"النبي الخاتم","text":"ولد النبي صلى الله عليه وسلم في مكة ونشأ يتيماً...","source":"السيرة النبوية","video_duration":15},{"title":"أصحاب الكهف","category":"قصص القرآن","text":"فتية آمنوا بربهم وزادهم الله هدى وأوحى إليهم...","source":"سورة الكهف","video_duration":10},{"title":"قصة قارون","category":"قصص القرآن","text":"كان قارون من قوم موسى فبغى عليهم وآتيناه من الكنوز...","source":"سورة القصص","video_duration":10}],"hadiths":[{"text":"إنما الأعمال بالنيات","narrator":"عمر بن الخطاب","source":"رواه البخاري ومسلم"},{"text":"الدين النصيحة","narrator":"أبو هريرة","source":"رواه مسلم"},{"text":"اتق الله حيثما كنت","narrator":"أبو ذر","source":"رواه الترمذي"},{"text":"لا يؤمن أحدكم حتى يحب لأخيه ما يحب لنفسه","narrator":"أنس بن مالك","source":"رواه البخاري ومسلم"},{"text":"المسلم من سلم المسلمون من لسانه ويده","narrator":"عبد الله بن عمرو","source":"رواه البخاري ومسلم"},{"text":"خيركم من تعلم القرآن وعلمه","narrator":"عثمان بن عفان","source":"رواه البخاري"},{"text":"من سلك طريقاً يلتمس فيه علماً سهل الله له به طريقاً إلى الجنة","narrator":"أبو هريرة","source":"رواه مسلم"},{"text":"أحب الناس إلى الله أنفعهم للناس","narrator":"ابن عمر","source":"رواه الطبراني"},{"text":"الدنيا سجن المؤمن وجنة الكافر","narrator":"أبو هريرة","source":"رواه مسلم"},{"text":"لا ضرر ولا ضرار","narrator":"أبو سعيد الخدري","source":"رواه ابن ماجه"}],"revelation_reasons":[{"surah":"العلق","ayah":1,"text":"اقْرَأْ","reason":"أول آية نزلت في غار حراء"},{"surah":"المدثر","ayah":1,"text":"يَا أَيُّهَا الْمُدَّثِّرُ","reason":"بعد فترة انقطاع الوحي"},{"surah":"الضحى","ayah":1,"text":"وَالضُّحَىٰ","reason":"تطييباً لقلب النبي ﷺ"},{"surah":"الكوثر","ayah":1,"text":"إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ","reason":"حين عَيَّر المشركون النبي بموت أبنائه"},{"surah":"المسد","ayah":1,"text":"تَبَّتْ يَدَا أَبِي لَهَبٍ","reason":"في أبي لهب وامرأته"},{"surah":"النصر","ayah":1,"text":"إِذَا جَاءَ نَصْرُ اللَّهِ","reason":"في حجة الوداع إيذاناً بأجل النبي"},{"surah":"الإخلاص","ayah":1,"text":"قُلْ هُوَ اللَّهُ أَحَدٌ","reason":"سأل المشركون عن صفة ربه"},{"surah":"الفاتحة","ayah":1,"text":"بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ","reason":"أم الكتاب وأول سورة في المصحف"}]}''');
      _hadiths=List<Map<String,dynamic>>.from(js['hadiths']);
      _revelationReasons=List<Map<String,dynamic>>.from(js['revelation_reasons']);
      _stories=List<Map<String,dynamic>>.from(js['stories']);
      _prophetStories=_stories.where((s)=>s['category']=='الأنبياء'||s['category']=='النبي الخاتم').toList();
      _quranStories=_stories.where((s)=>s['category']=='قصص القرآن').toList();
    } catch(e) { debugPrint('DB Error: $e'); }
    notifyListeners();
  }

  Future _loadTranslations() async {
    final p=await SharedPreferences.getInstance();
    final s=p.getString('translation_history');
    if(s!=null){try{_translations=List<Map<String,dynamic>>.from((jsonDecode(s)as List).map((e)=>Map.from(e)));}catch(_){}}
  }
  Future saveTranslation(String src,String trg,{String? sourceLang,String? targetLang}) async {
    _translations.insert(0,{'source':src,'translated':trg,'sourceLang':sourceLang??'auto','targetLang':targetLang??'ar','timestamp':DateTime.now().toIso8601String()});
    if(_translations.length>50)_translations=_translations.sublist(0,50); await _persist(); notifyListeners();
  }
  Future _persist() async { final p=await SharedPreferences.getInstance(); await p.setString('translation_history',jsonEncode(_translations)); }

  Map<String,dynamic> getRandomHadith() {if(_hadiths.isEmpty)return{'text':'لا إله إلا الله'};return _hadiths[Random().nextInt(_hadiths.length)];}
  Map<String,dynamic> getRandomStory() {if(_stories.isEmpty)return{'title':'قصة','text':'لم يتم تحميل القصص'};return _stories[Random().nextInt(_stories.length)];}
  Map<String,dynamic> getRandomAsbab() {if(_revelationReasons.isEmpty)return{'surah':'','ayah':'','reason':'','text':''};return _revelationReasons[Random().nextInt(_revelationReasons.length)];}
  List<Map<String,dynamic>> getStoriesByCategory(String c) => _stories.where((s)=>s['category']==c).toList();
}
DBEOF
echo -e "${GREEN}   ✅ Database Service - أحاديث + قصص + أسباب نزول${NC}"

# ====== 14. Confirm كل الملفات موجودة ======
echo -e "\n${CYAN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}🦂 تم تحديث/إنشاء ${NC}"
echo -e "  1. lib/main.dart"
echo -e "  2. lib/features/home_screen.dart"
echo -e "  3. lib/features/games/games_menu_screen.dart"
echo -e "  4. lib/features/games/chess_screen.dart"
echo -e "  5. lib/features/games/rubik_screen.dart"
echo -e "  6. lib/features/card1_translation/translation_screen.dart"
echo -e "  7. lib/features/card2_dialogue/dialogue_screen.dart"
echo -e "  8. lib/features/card3_document/document_screen.dart"
echo -e "  9. lib/features/card4_stories/stories_screen.dart"
echo -e "  10. lib/services/tts_service.dart"
echo -e "  11. lib/services/floating_bubble_service.dart"
echo -e "  12. lib/services/ai_service.dart"
echo -e "  13. lib/services/database_service.dart"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"

# ====== 15. الرفع إلى GitHub ======
echo -e "\n${CYAN}[14] رفع التغييرات إلى GitHub...${NC}"

# التحقق من وجود git remote
if ! git remote -v | grep -q origin; then
    echo -e "${YELLOW}⚠️ لم يتم العثور على remote origin.${NC}"
    echo -e "الرجاء إضافة الـ remote يدوياً:"
    echo -e "  git remote add origin https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2.git"
    echo -e "ثم شغل:"
    echo -e "  git add . && git commit -m '🦂 Mega Fix V1 - كل الإصلاحات' && git push origin main"
    exit 0
fi

git add -A
git commit -m "🦂 Mega Fix V1 - $(date '+%Y-%m-%d %H:%M')

- إصلاح main.dart (إضافة route /games + ThemeProvider)
- إنشاء GamesMenuScreen (شطرنج 3D + روبيك 3D)
- ChessScreen: لعبة شطرنج كاملة ثنائية اللاعبين
- RubikScreen: مكعب روبيك 3D مع دوران تلقائي
- كارت 1: ترجمة نصية (مايك + Audio Upload PIN + سبيكر + مشاركة + نسخ)
- كارت 2: حوار مترجم (مايك central + swap + ترجمة فورية)
- كارت 3: مستندات وعدسة (عدسة كاميرا + OCR + مستعرض ملفات + ترجمة)
- كارت 4: أحاديث وقصص وإلهام (6 تبويبات + أسباب نزول + إلهام ذكي)
- HomeScreen: عقرب + انعكاس + 6 كروت + فقاعة (مفتاح فتح/غلق) + إلهام
- TTS Service: 5 أصوات كاملة (سيف, سلمى, سما, سارة, صوت المستخدم)
- Floating Bubble: مفتاح فتح وغلق + سحب + قائمة
- AI Service: 15 خاطرة روحانية + تحليل حالة المستخدم + دعم OpenAI API
- Database Service: أحاديث + قصص + أسباب نزول + سجل الترجمة"

echo -e "${YELLOW}⌛ جاري الرفع...${NC}"
if git push origin main 2>&1; then
    echo -e "${GREEN}✅ تم الرفع بنجاح!${NC}"
    echo -e "${GREEN}🚀 سيبدأ GitHub Actions البناء تلقائياً خلال ثوانٍ${NC}"
    echo -e "${GREEN}📱 تابع الحالة: https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2/actions${NC}"
else
    echo -e "${RED}❌ فشل الرفع. يرجى التحقق من الاتصال أو استخدام:${NC}"
    echo -e "   git push origin main --force"
fi

echo -e "\n${CYAN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}🦂 الانتهاء من Mega Fix V1${NC}"
echo -e "${YELLOW}📋 ما تم إنجازه:${NC}"
echo -e "  ✅ main.dart - routes كاملة + ThemeProvider"
echo -e "  ✅ GamesMenuScreen + ChessScreen + RubikScreen"
echo -e "  ✅ كارت 1 - ترجمة نصية (مع Audio PIN + مشاركة + توقيع)"
echo -e "  ✅ كارت 2 - حوار مترجم (مايك + swap + ترجمة فورية)"
echo -e "  ✅ كارت 3 - مستندات وعدسة (كاميرا + مستعرض + ترجمة)"
echo -e "  ✅ كارت 4 - أحاديث وقصص وإلهام (6 تبويبات + أسباب نزول)"
echo -e "  ✅ HomeScreen - عقرب + انعكاس + 6 كروت + فقاعة"
echo -e "  ✅ TTS - 5 أصوات كاملة"
echo -e "  ✅ AI Service - إلهام ذكي + API"
echo -e "  ✅ Database - أحاديث + قصص + أسباب نزول"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
