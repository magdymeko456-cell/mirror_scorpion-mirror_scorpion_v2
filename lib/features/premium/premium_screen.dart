import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/premium_verification_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});
  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _patchCtrl = TextEditingController();
  bool _working = false;

  Future<void> _copyDeviceId() async {
    final id = context.read<PremiumVerificationService>().deviceId;
    await Clipboard.setData(ClipboardData(text: id));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تم نسخ معرف الجهاز')));
  }

  Future<void> _copyActivationData() async {
    final data = context.read<PremiumVerificationService>().exportActivationData();
    await Clipboard.setData(ClipboardData(text: data));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نسخ بيانات التفعيل — أرسلها للمطور')));
  }

  Future<void> _applyPatch() async {
    final svc = context.read<PremiumVerificationService>();
    final patch = _patchCtrl.text.trim();
    if (patch.isEmpty) return;
    setState(() => _working = true);
    final ok = await svc.applyPatch(patch);
    if (!mounted) return;
    setState(() => _working = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'تم تفعيل برو بنجاح 🎉' : 'باتش غير صالح أو منتهي')));
  }

  Future<void> _copyContact(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('تم نسخ $label: $text')));
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<PremiumVerificationService>();
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('تفعيل ميرور برو'),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFB8860B)]),
            ),
            child: Column(children: [
              const Icon(Icons.workspace_premium, size: 56, color: Colors.black87),
              const SizedBox(height: 8),
              Text(
                svc.isPremium
                    ? 'برو مفعّل ✓'
                    : 'ميرور برو ✦',
                style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                svc.isPremium
                    ? 'صالح حتى: ${svc.expiryDate.split('T').first}'
                    : 'حيث تُصنع البدايات بلا حدود',
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _box('معرف جهازك (مشفر) — انسخه وأرسله للمطور للحصول على الباتش', [
            SelectableText(svc.deviceId,
                style: const TextStyle(
                    color: Colors.amberAccent,
                    fontFamily: 'monospace',
                    fontSize: 13)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copyDeviceId,
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('نسخ المعرف'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amberAccent),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _copyActivationData,
                  icon: const Icon(Icons.data_object, size: 16),
                  label: const Text('نسخ بيانات التفعيل'),
                  style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black87),
                ),
              ),
            ]),
          ]),
          _box('أدخل باتش التفعيل (يُفعَّل عبر الإنترنت فقط)', [
            TextField(
              controller: _patchCtrl,
              style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'MS.xxxx.xxxx',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xFF0D1B2A),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.white12)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _working ? null : _applyPatch,
                icon: _working
                    ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.verified),
                label: const Text('تفعيل برو'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ]),
          _box('كيف يعمل التفعيل؟', [
            const Text(
              '1. انسخ معرف جهازك المشفر\n'
              '2. تواصل مع المطور عبر واتساب أو البريد\n'
              '3. ستصلك حزمة الباتش المرتبطة بجهازك فقط\n'
              '4. الصقها هنا — يتطلب اتصالاً بالإنترنت (الوقت من الإنترنت)\n'
              '5. البرو مرتبط بهذا الجهاز ولا ينتقل عند المشاركة (المشاركة تبقى نسخة مجانية)',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.7),
            ),
          ]),
          _box('تواصل مع المطور', [
            _contactTile('واتساب 1', '01017341250', Icons.chat, Colors.greenAccent),
            _contactTile('واتساب 2', '01031680816', Icons.chat, Colors.greenAccent),
            _contactTile('واتساب 3', '01558203456', Icons.chat, Colors.greenAccent),
            _contactTile('البريد', 'dosoky.server@gmail.com', Icons.email, Colors.orangeAccent),
          ]),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _box(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                color: Colors.amberAccent,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        const SizedBox(height: 10),
        ...children,
      ]),
    );
  }

  Widget _contactTile(String label, String value, IconData ic, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(ic, color: color),
      title: Text('$label: $value',
          style: const TextStyle(color: Colors.white, fontSize: 13)),
      trailing: IconButton(
        icon: const Icon(Icons.copy, size: 18, color: Colors.white38),
        onPressed: () => _copyContact(value, label),
      ),
    );
  }
}
