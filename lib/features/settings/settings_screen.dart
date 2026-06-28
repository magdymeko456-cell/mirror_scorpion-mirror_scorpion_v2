import "package:flutter/services.dart";
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _isPremium = true; // مفعل خلال التطوير

  @override
  Widget build(BuildContext context) {
    final tts = Provider.of<TTSService>(context);
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
          // ── Premium Upgrade ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Colors.black87, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _isPremium ? '✓ النسخة البرو مفعلة' : 'تفعيل النسخة البرو',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!_isPremium)
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                    child: const Text('اشتراك', style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Dark Mode ──
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: Colors.blueAccent),
            title: const Text('الوضع المظلم', style: TextStyle(color: Colors.white)),
            value: _darkMode,
            onChanged: (v) => setState(() => _darkMode = v),
            activeColor: Colors.blueAccent,
          ),
          const Divider(color: Colors.white12),

          // ── Voices ──
          const Text(
            'اختيار الصوت',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...TTSService.availableVoices.map((voice) {
            final isSelected = tts.selectedVoice == voice['id'];
            return RadioListTile<String>(
              title: Text(
                '${voice['name']} — ${voice['desc']}',
                style: const TextStyle(color: Colors.white),
              ),
              value: voice['id'],
              groupValue: tts.selectedVoice,
              onChanged: (v) {
                if (v != null) tts.setVoice(v);
              },
              activeColor: Colors.cyanAccent,
            );
          }),
          const Divider(color: Colors.white12),

          // ── Contact ──
          const SizedBox(height: 16),
          const Text('تواصل مع المطور', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          _contactItem('📱 واتساب', '01017341250'),
          _contactItem('📱 واتساب', '01031680816'),
          _contactItem('📱 واتساب', '01558203456'),
          _contactItem('📧 بريد', 'dosoky.server@gmail.com'),
          const SizedBox(height: 32),
          const Opacity(
            opacity: 0.2,
            child: Text(
              "Mirror Scorpion v1.2.0 • Build Stable #4",
              style: TextStyle(color: Colors.white, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: Colors.cyanAccent.withOpacity(0.8))),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          GestureDetector(
            onTap: () => Clipboard.setData(ClipboardData(text: value)),
            child: const Icon(Icons.copy, color: Colors.white38, size: 18),
          ),
        ],
      ),
    );
  }
}
