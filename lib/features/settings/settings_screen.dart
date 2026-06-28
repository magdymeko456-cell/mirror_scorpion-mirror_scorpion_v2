import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';
import '../../services/floating_bubble_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final tts = Provider.of<TTSService>(context);
    final bubble = Provider.of<FloatingBubbleService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Premium Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFDAA520)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Colors.black87, size: 32),
                const SizedBox(width: 12),
                const Expanded(child: Text('✓ النسخة البرو مفعلة', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Floating Bubble Section
          const Text('الفقاعة العائمة', style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            secondary: const Icon(Icons.bubble_chart, color: Colors.cyanAccent),
            title: const Text('تفعيل الفقاعة', style: TextStyle(color: Colors.white)),
            subtitle: Text(bubble.isEnabled ? 'الفقاعة نشطة' : 'الفقاعة متوقفة', style: TextStyle(color: bubble.isEnabled ? Colors.greenAccent : Colors.white38, fontSize: 12)),
            value: bubble.isEnabled,
            onChanged: (v) => v ? bubble.startBubble() : bubble.stopBubble(),
            activeColor: Colors.cyanAccent,
          ),
          if (bubble.isEnabled) ...[
            _buildSlider('الشفافية', bubble.opacity, 0.3, 1.0, (v) => bubble.setOpacity(v)),
            Row(children: [
              const Text('حجم الفقاعة', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Expanded(child: Slider(value: bubble.size.toDouble(), min: 60, max: 200, divisions: 7, activeColor: Colors.cyanAccent, inactiveColor: Colors.white12, label: '${bubble.size}', onChanged: (v) => bubble.setSize(v.toInt()))),
              Text('${bubble.size}', style: const TextStyle(color: Colors.cyanAccent, fontSize: 13)),
            ]),
          ],
          const Divider(color: Colors.white12, height: 30),

          // Voice Section
          const Text('اختيار الصوت', style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...TTSService.availableVoices.map((voice) {
            final isSelected = tts.selectedVoice == voice['id'];
            return RadioListTile(
              title: Text('${voice['name']} — ${voice['desc']}', style: TextStyle(color: isSelected ? Colors.cyanAccent : Colors.white, fontSize: 13)),
              value: voice['id'],
              groupValue: tts.selectedVoice,
              onChanged: (v) { if (v != null) tts.setVoice(v as String); },
              activeColor: Colors.cyanAccent,
              dense: true,
            );
          }),
          const Divider(color: Colors.white12, height: 30),

          // Dark Mode
          const Text('الإعدادات العامة', style: TextStyle(color: Colors.tealAccent, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: Colors.blueAccent),
            title: const Text('الوضع المظلم', style: TextStyle(color: Colors.white)),
            value: true,
            onChanged: (v) {},
            activeColor: Colors.blueAccent,
          ),
          const Divider(color: Colors.white12, height: 20),

          // Contact
          const Text('تواصل مع المطور', style: TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildContact('📱', '01017341250'),
          _buildContact('📱', '01031680816'),
          _buildContact('📱', '01558203456'),
          _buildContact('📧', 'dosoky.server@gmail.com'),
          const SizedBox(height: 40),
          const Opacity(opacity: 0.2, child: Text("Mirror Scorpion v1.2.0", style: TextStyle(color: Colors.white, fontSize: 11), textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
        Expanded(child: Slider(value: value, min: min, max: max, divisions: 10, activeColor: Colors.cyanAccent, inactiveColor: Colors.white12, label: value.toStringAsFixed(1), onChanged: onChanged)),
        SizedBox(width: 30, child: Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.cyanAccent, fontSize: 13))),
      ]),
    );
  }

  Widget _buildContact(String icon, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(children: [
        Text('$icon: ', style: TextStyle(color: Colors.cyanAccent.withOpacity(0.8), fontSize: 14)),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14))),
        GestureDetector(
          onTap: () { Clipboard.setData(ClipboardData(text: value)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ'), duration: Duration(seconds: 1))); },
          child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.copy, color: Colors.white38, size: 16)),
        ),
      ]),
    );
  }
}
