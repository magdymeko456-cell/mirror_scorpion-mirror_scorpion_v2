import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // ✅ HOTFIX: هذا الـ import كان مفقوداً لاستخدام Platform
import '../../services/tts_service.dart';
import '../../services/premium_verification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _patchController = TextEditingController();

  @override
  void dispose() { _patchController.dispose(); super.dispose(); }

  String _getDeviceId() {
    // ✅ HOTFIX: Platform.isAndroid يعمل الآن بعد إضافة import 'dart:io'
    final id = 'MS-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}-${Platform.isAndroid ? 'ADR' : 'IOS'}';
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final tts = context.watch<TTSService>();
    final premium = context.watch<PremiumVerificationService>();
    final deviceId = _getDeviceId();

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ الإعدادات'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🔊 الأصوات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...TTSService.availableVoices.map((voice) {
              final isPro = voice['id'] == 'voice_user';
              return RadioListTile<String>(
                title: Text('${voice['name']} — ${voice['desc']}'),
                subtitle: isPro ? const Text('🔒 متاح في النسخة المدفوعة', style: TextStyle(color: Colors.amber, fontSize: 12)) : null,
                value: voice['id']!,
                groupValue: tts.selectedVoice,
                activeColor: Colors.teal,
                onChanged: (val) {
                  if (val != null && (!isPro || premium.isPremium)) { tts.setVoice(val); }
                  else if (isPro && !premium.isPremium) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔒 هذا الصوت متاح فقط في النسخة PRO'))); }
                },
              );
            }),
          ]))),
          const SizedBox(height: 12),
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.translate, color: Colors.teal), title: const Text('الترجمة التلقائية'), subtitle: const Text('ترجمة فورية عند لصق النص'), trailing: Switch(value: true, onChanged: (_) {}, activeColor: Colors.teal)),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.dark_mode, color: Colors.teal), title: const Text('الوضع المظلم'), subtitle: const Text('مفعل دائماً'), trailing: Switch(value: true, onChanged: (_) {}, activeColor: Colors.teal)),
          ])),
          const SizedBox(height: 12),
          Card(
            color: Colors.amber.withOpacity(0.08),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.amber.withOpacity(0.3))),
            child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              Row(children: [
                Icon(premium.isPremium ? Icons.workspace_premium : Icons.lock, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Text(premium.isPremium ? '👑 PRO مفعلة' : '👑 النسخة PRO', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.amber)),
              ]),
              const SizedBox(height: 12),
              const Text('مزايا PRO:\n• ترجمة مستندات غير محدودة\n• استنساخ صوت المستخدم (AI)\n• تحويل القصص إلى فيديوهات\n• ترجمة أوفلاين بدون إنترنت', style: TextStyle(fontSize: 13, height: 1.6), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              if (!premium.isPremium) ...[
                Container(decoration: BoxDecoration(border: Border.all(color: Colors.amber.shade300), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Expanded(child: Padding(padding: const EdgeInsets.all(12), child: Text('ID: $deviceId', style: const TextStyle(fontSize: 11, fontFamily: 'monospace')))),
                    IconButton(icon: const Icon(Icons.copy, color: Colors.amber), onPressed: () { Clipboard.setData(ClipboardData(text: deviceId)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم نسخ معرف الجهاز'))); }),
                  ]),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _patchController,
                  decoration: InputDecoration(
                    labelText: '🔑 أدخل باتش التفعيل المشفر',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(icon: const Icon(Icons.paste, color: Colors.grey), onPressed: () async { final data = await Clipboard.getData(Clipboard.kTextPlain); if (data?.text != null) _patchController.text = data!.text!; }),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (_patchController.text.isNotEmpty) {
                      final success = await premium.activateWithPatch(_patchController.text);
                      if (success && mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 تم تفعيل النسخة PRO بنجاح!'), backgroundColor: Colors.green)); }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black87, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                  child: const Text('🔓 تفعيل الآن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ] else ...[
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Column(children: [Icon(Icons.check_circle, color: Colors.green, size: 48), SizedBox(height: 8), Text('✅ PRO نشطة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))])),
              ],
              const SizedBox(height: 16),
              const Divider(), const SizedBox(height: 8),
              const Text('📞 للدعم:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('واتس: 01017341250\n01031680816\n01558203456'),
              const Text('📧 dosoky.server@gmail.com'),
            ])),
          ),
          const SizedBox(height: 20),
          Center(child: Opacity(opacity: 0.3, child: Column(children: [
            const Text('🦂 Mirror Scorpion', style: TextStyle(fontSize: 14)),
            Text('v1.2.0 — ${premium.isPremium ? "PRO" : "Free"}', style: const TextStyle(fontSize: 11)),
            const Text('المطور: Tamer Eldosoky', style: TextStyle(fontSize: 11)),
          ]))),
        ],
      ),
    );
  }
}
