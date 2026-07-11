import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';
import '../../services/premium_verification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedVoice = 'سيف';
  bool _darkMode = true;
  String? _deviceId;
  String? _activationPatch;

  final List<Map<String, String>> _voices = [
    {'id': 'seif', 'name': 'سيف', 'gender': 'ذكر', 'lang': 'ar-SA'},
    {'id': 'salma', 'name': 'سلمى', 'gender': 'أنثى', 'lang': 'ar-SA'},
    {'id': 'sama', 'name': 'سما', 'gender': 'أنثى', 'lang': 'ar-SA'},
    {'id': 'sara', 'name': 'سارة', 'gender': 'أنثى', 'lang': 'ar-SA'},
  ];

  @override
  void initState() {
    super.initState();
    _generateDeviceId();
  }

  String _generateDeviceId() {
    final rng = Random();
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final id = List.generate(16, (_) => chars[rng.nextInt(chars.length)]).join();
    // تشفير بسيط
    final encoded = id.split('').map((c) {
      return String.fromCharCode(c.codeUnitAt(0) ^ 0x5A);
    }).join();
    setState(() => _deviceId = encoded);
    return encoded;
  }

  void _showVoiceSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2838),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر الصوت',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._voices.map((voice) {
                return ListTile(
                  leading: Icon(
                    voice['gender'] == 'ذكر' ? Icons.male : Icons.female,
                    color: voice['name'] == _selectedVoice ? Colors.cyanAccent : Colors.white70,
                  ),
                  title: Text(voice['name']!, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(voice['gender']!, style: const TextStyle(color: Colors.white54)),
                  trailing: voice['name'] == _selectedVoice
                      ? const Icon(Icons.check, color: Colors.cyanAccent)
                      : null,
                  onTap: () {
                    setState(() => _selectedVoice = voice['name']!);
                    context.read<TTSService>().setVoice(voice['name']!);
                    Navigator.pop(context);
                  },
                );
              }),
              const Divider(color: Colors.white24),
              // ── صوت المستخدم (Pro) ──
              ListTile(
                leading: const Icon(Icons.record_voice_over, color: Colors.amber),
                title: const Text('صوت المستخدم (Pro)', style: TextStyle(color: Colors.amber)),
                subtitle: const Text('استنسخ صوتك بالذكاء الاصطناعي', style: TextStyle(color: Colors.white54)),
                onTap: () {
                  Navigator.pop(context);
                  _showProRequired('نسخ صوتك');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProActivationScreen()),
    );
  }

  void _showProRequired(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔒 $feature متاح في النسخة المدفوعة'),
        backgroundColor: Colors.amber,
        action: SnackBarAction(
          label: 'ترقية',
          textColor: Colors.black,
          onPressed: _showProScreen,
        ),
      ),
    );
  }

  void _copyDeviceId() {
    if (_deviceId == null) return;
    Clipboard.setData(ClipboardData(text: _deviceId!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم نسخ معرف الجهاز')),
    );
  }

  void _pastePatch() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      setState(() => _activationPatch = data!.text!);
    }
  }

  Future<void> _activatePro() async {
    if (_activationPatch == null || _activationPatch!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ الصق باتش التفعيل أولاً')),
      );
      return;
    }
    final service = context.read<PremiumVerificationService>();
    final success = await service.activatePremium(_activationPatch!);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 تم تفعيل النسخة المدفوعة بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ باتش التفعيل غير صحيح'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final premiumService = context.watch<PremiumVerificationService>();
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('⚙️ الإعدادات', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── حالة Pro ──
          if (premiumService.isPremium)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.amber, Colors.orange]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✨ النسخة المدفوعة مفعّلة', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('استمتع بجميع الميزات بلا حدود', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            // ── زر تفعيل Pro (ذهبي) ──
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Material(
                color: const Color(0xFFD4AF37), // ذهبي ملكي
                borderRadius: BorderRadius.circular(16),
                elevation: 8,
                shadowColor: const Color(0xFFFFD700).withOpacity(0.5),
                child: InkWell(
                  onTap: _showProScreen,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: const Row(
                      children: [
                        Icon(Icons.workspace_premium, color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تفعيل النسخة المدفوعة',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'جميع الميزات بلا حدود',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // ── الصوت ──
          _buildSection(
            title: '🔊 الصوت',
            children: [
              ListTile(
                leading: const Icon(Icons.record_voice_over, color: Colors.cyanAccent),
                title: const Text('صوت الترجمة', style: TextStyle(color: Colors.white)),
                subtitle: Text(_selectedVoice, style: const TextStyle(color: Colors.white70)),
                trailing: const Icon(Icons.arrow_drop_down, color: Colors.white),
                onTap: _showVoiceSelector,
              ),
            ],
          ),
          // ── المظهر ──
          _buildSection(
            title: '🎨 المظهر',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode, color: Colors.cyanAccent),
                title: const Text('الوضع المظلم', style: TextStyle(color: Colors.white)),
                value: _darkMode,
                onChanged: (val) => setState(() => _darkMode = val),
                activeColor: Colors.cyanAccent,
              ),
            ],
          ),
          // ── إدارة اللغات ──
          _buildSection(
            title: '🌐 إدارة اللغات',
            children: [
              ListTile(
                leading: const Icon(Icons.download, color: Colors.greenAccent),
                title: const Text('تنزيل اللغات للاستخدام دون اتصال', style: TextStyle(color: Colors.white)),
                subtitle: const Text('تنزيل حزم الترجمة محلياً', style: TextStyle(color: Colors.white54)),
                onTap: () => _showMessage('ابدأ التنزيل من الإعدادات'),
              ),
              ListTile(
                leading: const Icon(Icons.book, color: Colors.amber),
                title: const Text('تنزيل مصادر الإلهام', style: TextStyle(color: Colors.white)),
                subtitle: const Text('كتاب لا تحزن + تفسير الجلالين', style: TextStyle(color: Colors.white54)),
                onTap: () => _showMessage('تنزيل المصادر...'),
              ),
            ],
          ),
          // ── عن التطبيق ──
          _buildSection(
            title: 'ℹ️ عن التطبيق',
            children: [
              const ListTile(
                leading: Icon(Icons.info, color: Colors.cyanAccent),
                title: Text('الإصدار', style: TextStyle(color: Colors.white)),
                subtitle: Text('v2.0.0 - Build 669eb2a', style: TextStyle(color: Colors.white54)),
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.amber),
                title: const Text('مشاركة التطبيق', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Share.share(
                    '🦂 جرب تطبيق ميرور سكربيون - ترجمة وإلهام وألعاب!\n'
                    'https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(title, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF1B2838)),
    );
  }
}

// ── شاشة تفعيل النسخة المدفوعة ──
class ProActivationScreen extends StatelessWidget {
  const ProActivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('✨ تفعيل النسخة المدفوعة', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── أيقونة التاج ──
            const Center(
              child: Icon(Icons.workspace_premium, color: Color(0xFFD4AF37), size: 80),
            ),
            const SizedBox(height: 16),
            const Text(
              '✨ النسخة المدفوعة ✨',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'جميع الميزات بلا حدود',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            // ── الميزات ──
            _buildFeature(Icons.translate, 'ترجمة بلا حدود للمستندات'),
            _buildFeature(Icons.record_voice_over, 'نسخ صوتك بالذكاء الاصطناعي'),
            _buildFeature(Icons.movie_creation, 'تحويل الإلهام والقصص لفيديو'),
            _buildFeature(Icons.bubble_chart, 'الفقاعة العائمة'),
            _buildFeature(Icons.auto_stories, 'تنزيل القصص محلياً'),
            _buildFeature(Icons.offline_bolt, 'العمل دون اتصال'),
            const SizedBox(height: 24),
            // ── الأسعار ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD4AF37)),
              ),
              child: const Column(
                children: [
                  Text('💎 فترات الاشتراك', style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                    _buildPriceRow('شهر', '50 جنيه'),
                  _buildPriceRow('3 أشهر', '120 جنيه (وفّر 30)'),
                  _buildPriceRow('سنة', '400 جنيه (وفّر 200)'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ── معلومات الاتصال ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Text('📞 طرق الدفع والتواصل', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  Text('📱 واتساب:', style: TextStyle(color: Colors.white70)),
                  Text('01017341250', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('01031680816', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('01558203456', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('📧 البريد:', style: TextStyle(color: Colors.white70)),
                  Text('dosoky.server@gmail.com', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ── معلومات التفعيل ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: const Text(
                '💡 بعد التحويل، أرسل صورة الإيصال + معرف الجهاز على الواتساب، وسيصلك باتش التفعيل خلال دقائق.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.amber, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14))),
          const Icon(Icons.check_circle, color: Colors.greenAccent),
        ],
      ),
    );
  }

  static Widget _buildPriceRow(String period, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(period, style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(price, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
