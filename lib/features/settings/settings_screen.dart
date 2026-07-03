import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/floating_bubble_service.dart';
import '../../services/language_service.dart';
import '../../services/premium_verification_service.dart';
import 'premium_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  @override
  Widget build(BuildContext context) {
    final ps = Provider.of<PremiumVerificationService>(context);
    final bs = Provider.of<FloatingBubbleService>(context);
    final ls = Provider.of<LanguageService>(context);
    return Scaffold(backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(title: const Text('الإعدادات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PremiumCard(), const SizedBox(height: 25),
        const Text('الفقاعة العائمة', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        Card(color: Colors.white.withOpacity(0.05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(children: [
            ListTile(leading: const Icon(Icons.bubble_chart, color: Colors.amber),
              title: const Text('تفعيل الفقاعة العائمة', style: TextStyle(color: Colors.white)),
              subtitle: Text(bs.isStarted ? 'الفقاعة نشطة' : 'الفقاعة متوقفة', style: TextStyle(color: bs.isStarted ? Colors.greenAccent : Colors.white38, fontSize: 12)),
              trailing: Switch(value: bs.isStarted, activeColor: Colors.amber, onChanged: (v) { if (v) bs.startBubble(); else bs.stopBubble(); })),
            if (bs.isStarted) ...[
              const Divider(color: Colors.white10, height: 1),
              ListTile(leading: const Icon(Icons.language, color: Colors.amber), title: const Text('لغة المصدر', style: TextStyle(color: Colors.white)),
                subtitle: Text(ls.getLanguageName(bs.sourceLang), style: const TextStyle(color: Colors.white54)),
                onTap: () async { final r = await _pickLang(context, ls, bs.sourceLang); if (r != null) bs.setSourceLang(r); }),
              const Divider(color: Colors.white10, height: 1),
              ListTile(leading: const Icon(Icons.translate, color: Colors.amber), title: const Text('اللغة الهدف', style: TextStyle(color: Colors.white)),
                subtitle: Text(ls.getLanguageName(bs.targetLang), style: const TextStyle(color: Colors.white54)),
                onTap: () async { final r = await _pickLang(context, ls, bs.targetLang); if (r != null) bs.setTargetLang(r); }),
            ],
          ]),
        ), const SizedBox(height: 20),
        const Text('العامة', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        Card(color: Colors.white.withOpacity(0.05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(children: [
            ListTile(leading: const Icon(Icons.dark_mode, color: Colors.amber), title: const Text('الوضع المظلم', style: TextStyle(color: Colors.white)),
              trailing: Switch(value: _darkMode, activeColor: Colors.amber, onChanged: (v) { setState(() => _darkMode = v); })),
            const Divider(color: Colors.white10, height: 1),
            ListTile(leading: const Icon(Icons.download, color: Colors.amber), title: const Text('تحميل الحزم اللغوية (Offline)', style: TextStyle(color: Colors.white)),
              subtitle: const Text('اختر اللغات للترجمة بدون إنترنت', style: TextStyle(color: Colors.white38, fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16), onTap: () { _showLangDownload(context, ls); }),
            const Divider(color: Colors.white10, height: 1),
            ListTile(leading: const Icon(Icons.book, color: Colors.amber), title: const Text('تحميل مصادر الكتب والقصص', style: TextStyle(color: Colors.white)),
              subtitle: const Text('تفسير الجلالين، قصص الأنبياء، لا تحزن', style: TextStyle(color: Colors.white38, fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16), onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تحميل المصادر...'))); }),
          ]),
        ), const SizedBox(height: 20),
        const Text('عن التطبيق', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        Card(color: Colors.white.withOpacity(0.05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(children: [
            const ListTile(leading: Icon(Icons.info_outline, color: Colors.amber), title: Text('المطور', style: TextStyle(color: Colors.white)), subtitle: Text('Tamer Eldosoky', style: TextStyle(color: Colors.white54)), trailing: Text('v1.2.0', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
            const Divider(color: Colors.white10, height: 1),
            ListTile(leading: const Icon(Icons.verified, color: Colors.amber), title: const Text('حالة التفعيل', style: TextStyle(color: Colors.white)),
              subtitle: Text(ps.isPremium ? 'نسخة مدفوعة ✅' : 'نسخة عادية', style: TextStyle(color: ps.isPremium ? Colors.greenAccent : Colors.white38)),
              trailing: ps.isPremium ? const Icon(Icons.check_circle, color: Colors.greenAccent) : const Icon(Icons.cancel, color: Colors.white24)),
          ]),
        ),
      ])),
    );
  }
  Future<String?> _pickLang(BuildContext ctx, LanguageService ls, String cur) async {
    final codes = ls.getAvailableLanguages();
    return showModalBottomSheet<String>(context: ctx, backgroundColor: const Color(0xFF0D1B2A),
      builder: (c) => Container(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('اختر اللغة', style: TextStyle(color: Colors.amber, fontSize: 18)), const SizedBox(height: 16),
        SizedBox(height: 300, child: ListView.builder(itemCount: codes.length, itemBuilder: (ctx, i) {
          final code = codes[i]; return ListTile(
            title: Text(ls.getLanguageName(code), style: TextStyle(color: code == cur ? Colors.amber : Colors.white)),
            trailing: code == cur ? const Icon(Icons.check, color: Colors.amber) : null,
            onTap: () => Navigator.pop(c, code)); }))])));
  }
  void _showLangDownload(BuildContext ctx, LanguageService ls) {
    final codes = ls.getAvailableLanguages();
    showDialog(context: ctx, builder: (c) => AlertDialog(backgroundColor: const Color(0xFF0D1B2A),
      title: const Text('تحميل اللغات', style: TextStyle(color: Colors.amber)),
      content: SizedBox(width: double.maxFinite,
        child: ListView.builder(shrinkWrap: true, itemCount: codes.length, itemBuilder: (ctx, i) {
          final code = codes[i]; return CheckboxListTile(
            title: Text(ls.getLanguageName(code), style: const TextStyle(color: Colors.white)), value: false,
            onChanged: (v) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('جاري تحميل ${ls.getLanguageName(code)}...'))); Navigator.pop(c); }); })),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('إلغاء', style: TextStyle(color: Colors.amber)))]));
  }
}
