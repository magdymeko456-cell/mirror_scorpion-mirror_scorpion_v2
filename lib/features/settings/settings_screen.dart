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
  bool _isPremium = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Premium banner
            _buildPremiumBanner(),
            const SizedBox(height: 28),
            const Text('الفقاعة العائمة', style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Consumer<FloatingBubbleService>(
              builder: (context, bubble, _) => _buildBubbleSection(bubble),
            ),
            const Divider(color: Colors.white12, height: 30),
            const Text('الصوت والنطق', style: TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Consumer<TTSService>(
              builder: (context, tts, _) => _buildVoiceSection(tts),
            ),
            const Divider(color: Colors.white12, height: 30),
            const Text('الإعدادات العامة', style: TextStyle(color: Colors.tealAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SwitchListTile(
              secondary: const Icon(Icons.dark_mode, color: Colors.blueAccent),
              title: const Text('الوضع المظلم', style: TextStyle(color: Colors.white)),
              value: true,
              onChanged: (v) {},
              activeColor: Colors.blueAccent,
            ),
            const Divider(color: Colors.white12),
            const SizedBox(height: 10),
            const Text('تواصل مع المطور', style: TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildContact('📱', '01017341250'),
            _buildContact('📱', '01031680816'),
            _buildContact('📱', '01558203456'),
            _buildContact('📧', 'dosoky.server@gmail.com'),
            const SizedBox(height: 40),
            const Opacity(opacity: 0.15, child: Text("Mirror Scorpion v2", style: TextStyle(color: Colors.white))),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFDAA520)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 15)],
      ),
      child: Row(
        children: [
          const Icon(Icons.verified, color: Colors.black87, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isPremium ? '✓ النسخة البرو مفعلة' : 'تفعيل النسخة البرو',
                  style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _isPremium ? 'جميع المميزات متاحة' : 'احصل على جميع المميزات الحصرية',
                  style: TextStyle(color: Colors.black87.withOpacity(0.7), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleSection(FloatingBubbleService bubble) {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.bubble_chart, color: Colors.cyanAccent),
          title: const Text('تفعيل الفقاعة', style: TextStyle(color: Colors.white)),
          subtitle: Text(
            bubble.isEnabled ? 'الفقاعة نشطة' : 'الفقاعة متوقفة',
            style: TextStyle(color: bubble.isEnabled ? Colors.greenAccent : Colors.white38, fontSize: 12),
          ),
          value: bubble.isEnabled,
          onChanged: (v) => v ? bubble.startBubble(context) : bubble.stopBubble(),
          activeColor: Colors.cyanAccent,
        ),
        if (bubble.isEnabled) ...[
          _buildSlider('الشفافية', bubble.opacity, 0.3, 1.0, (v) => bubble.setOpacity(v)),
          Row(
            children: [
              const Text('حجم الفقاعة', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Expanded(
                child: Slider(
                  value: bubble.size.toDouble(),
                  min: 60,
                  max: 200,
                  divisions: 7,
                  activeColor: Colors.cyanAccent,
                  inactiveColor: Colors.white12,
                  label: '${bubble.size}',
                  onChanged: (v) => bubble.setSize(v.toInt()),
                ),
              ),
              Text('${bubble.size}', style: const TextStyle(color: Colors.cyanAccent, fontSize: 13)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildVoiceSection(TTSService tts) {
    return Column(
      children: TTSService.availableVoices.map((voice) {
        final vid = voice['id'] as String;
        return RadioListTile<String>(
          title: Text(
            '${voice['name']} — ${voice['desc']}',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          value: vid,
          groupValue: tts.selectedVoice,
          onChanged: (v) {
            if (v != null) tts.setVoice(v);
          },
          activeColor: Colors.cyanAccent,
          dense: true,
        );
      }).toList(),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: 10,
              activeColor: Colors.cyanAccent,
              inactiveColor: Colors.white12,
              label: value.toStringAsFixed(1),
              onChanged: onChanged,
            ),
          ),
          SizedBox(width: 30, child: Text(value.toStringAsFixed(1), style: const TextStyle(color: Colors.cyanAccent, fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildContact(String icon, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Text('$icon: ', style: TextStyle(color: Colors.cyanAccent.withOpacity(0.8), fontSize: 14)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14))),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم النسخ'), duration: Duration(seconds: 1)),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.copy, color: Colors.white38, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
