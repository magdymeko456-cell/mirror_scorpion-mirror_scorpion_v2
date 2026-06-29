import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/floating_bubble_service.dart';
import '../../services/tts_service.dart';
import '../../services/premium_verification_service.dart';
import '../../services/offline_translation_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _patchController = TextEditingController();

  @override
  void dispose() {
    _patchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bubble = context.watch<FloatingBubbleService>();
    final tts = context.watch<TTSService>();
    final premium = context.watch<PremiumVerificationService>();
    final offline = context.watch<OfflineTranslationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ الإعدادات'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader('💬 الفقاعة العائمة'),
          SwitchListTile(
            title: const Text('تفعيل الفقاعة العائمة'),
            subtitle: Text(bubble.isEnabled ? 'الفقاعة نشطة' : 'الفقاعة متوقفة'),
            value: bubble.isEnabled,
            onChanged: (v) => bubble.toggle(),
            secondary: Icon(Icons.bubble_chart,
                color: bubble.isEnabled ? Colors.teal : Colors.grey),
          ),
          if (bubble.isEnabled) ...[
            ListTile(
              title: const Text('الشفافية'),
              subtitle: Slider(
                value: bubble.opacity,
                min: 0.2,
                max: 1.0,
                divisions: 8,
                label: '${(bubble.opacity * 100).round()}%',
                onChanged: (v) => bubble.setOpacity(v),
              ),
            ),
            ListTile(
              title: const Text('الحجم'),
              subtitle: Slider(
                value: bubble.size,
                min: 40,
                max: 100,
                divisions: 12,
                label: '${bubble.size.round()}%',
                onChanged: (v) => bubble.setSize(v),
              ),
            ),
          ],
          const Divider(),

          _sectionHeader('🔊 الصوت'),
          DropdownButtonFormField<String>(
            value: tts.selectedVoice,
            decoration: const InputDecoration(
              labelText: 'الصوت',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.record_voice_over),
            ),
            items: tts.voices.map((voice) => DropdownMenuItem<String>(
              value: voice['id'],
              child: Text('${voice['name']} - ${voice['desc']}'),
            )).toList(),
            onChanged: (v) {
              if (v != null) tts.setVoice(v);
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('سرعة النطق'),
            subtitle: Slider(
              value: tts.speed,
              min: 0.2,
              max: 1.0,
              divisions: 16,
              label: '${tts.speed.toStringAsFixed(1)}x',
              onChanged: (v) => tts.setSpeed(v),
            ),
          ),
          const Divider(),

          _sectionHeader('⭐ النسخة المدفوعة (Pro)'),
          if (premium.isPremium) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.amber, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '✅ Pro مفعل - جميع الميزات متاحة',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('معرف الجهاز'),
              subtitle: SelectableText(premium.deviceId,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: premium.getFormattedDeviceId()));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('تم النسخ')));
                },
              ),
            ),
            TextButton(
              onPressed: () => premium.deactivate(),
              child:
                  const Text('إلغاء التفعيل', style: TextStyle(color: Colors.red)),
            ),
          ] else ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ElevatedButton.icon(
                onPressed: () => _showActivationDialog(context, premium),
                icon: const Icon(Icons.workspace_premium, color: Colors.white),
                label: const Text('💎 تفعيل النسخة المدفوعة',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: const Text(
                        '📖 قصص كاملة - جميع القصص مع النص الكامل'),
                    subtitle: const Text('فتح جميع قصص الأنبياء والتفسير'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: const Text('🗣️ 4 أصوات TTS'),
                    subtitle: const Text('أصوات عربية احترافية للنطق'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: const Text('📥 تنزيل اللغات للتفسير دون إنترنت'),
                    subtitle: const Text('حمل لغات الترجمة للاستخدام دون اتصال'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.star, color: Colors.amber),
                    title: const Text('🧠 AI متقدم'),
                    subtitle: const Text('Gemini API + تحليل اللهجات'),
                  ),
                ],
              ),
            ),
          ],
          const Divider(),

          if (premium.isPremium) ...[
            _sectionHeader('📥 تنزيل اللغات (دون إنترنت)'),
            ...offline.availableLanguages.map((entry) {
              final code = entry['code'] as String;
              final name = entry['name'] as String;
              final isDownloaded = offline.isDownloaded(code);
              return ListTile(
                leading: Icon(
                    isDownloaded ? Icons.check_circle : Icons.download,
                    color: isDownloaded ? Colors.green : Colors.grey),
                title: Text(name),
                subtitle: Text(
                    isDownloaded ? 'محملة محلياً' : 'اضغط للتحميل'),
                trailing: isDownloaded
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => offline.removeLanguage(code),
                      )
                    : TextButton(
                        onPressed: () => offline.downloadLanguage(code),
                        child: const Text('تحميل'),
                      ),
              );
            }),
            const Divider(),
          ],

          _sectionHeader('📞 التواصل'),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.teal),
            title: const Text('واتساب 1'),
            subtitle: const SelectableText('01017341250'),
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.teal),
            title: const Text('واتساب 2'),
            subtitle: const SelectableText('01031680816'),
          ),
          ListTile(
            leading: const Icon(Icons.phone, color: Colors.teal),
            title: const Text('واتساب 3'),
            subtitle: const SelectableText('01558203456'),
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.teal),
            title: const Text('البريد الإلكتروني'),
            subtitle: const SelectableText('dosoky.server@gmail.com'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
    );
  }

  void _showActivationDialog(
      BuildContext context, PremiumVerificationService premium) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber),
            SizedBox(width: 8),
            Text('تفعيل Pro'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'أدخل رمز التفعيل (Patch) أو أرسل معرف الجهاز للدعم'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                premium.deviceId,
                style:
                    const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _patchController,
              decoration: InputDecoration(
                labelText: 'رمز التفعيل',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: () async {
                    final data =
                        await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      _patchController.text = data!.text!;
                    }
                  },
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton.icon(
            onPressed: () {
              if (_patchController.text.isNotEmpty) {
                final success = premium
                    .verifyActivationPatch(_patchController.text.trim());
                if (success) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('✅ تم التفعيل بنجاح!'),
                        backgroundColor: Colors.green),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('❌ رمز التفعيل غير صحيح'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('تفعيل'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
