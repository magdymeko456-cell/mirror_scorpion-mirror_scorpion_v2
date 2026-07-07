import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/premium_verification_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// شاشة توليد أكواد التفعيل للمطور (Tamer Eldosoky)
class KeyGeneratorScreen extends StatefulWidget {
  const KeyGeneratorScreen({super.key});

  @override
  State<KeyGeneratorScreen> createState() => _KeyGeneratorScreenState();
}

class _KeyGeneratorScreenState extends State<KeyGeneratorScreen> {
  final _deviceIdController = TextEditingController();
  final _generatedCodeController = TextEditingController();
  String _selectedDuration = '1';
  List<Map<String, String>> _generatedKeys = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getStringList('generated_keys') ?? [];
    setState(() {
      _generatedKeys = keys.map((k) {
        final parts = k.split('|');
        return {
          'code': parts[0],
          'device': parts[1],
          'period': parts[2],
          'date': parts[3],
        };
      }).toList();
    });
  }

  void _generateCode() {
    final deviceId = _deviceIdController.text.trim();
    if (deviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ الرجاء إدخال معرف الجهاز أو تركه فارغاً لكود عام")),
      );
      return;
    }
    final months = int.parse(_selectedDuration);
    final code = PremiumVerificationService.generateActivationCode(
      deviceId,
      durationMonths: months,
    );
    _generatedCodeController.text = code;

    final entry = <String, String>{
      'code': code,
      'device': deviceId.length > 15 ? '${deviceId.substring(0, 15)}...' : deviceId,
      'period': '$months شهر',
      'date': DateTime.now().toString().substring(0, 16),
    };
    _generatedKeys.insert(0, entry);
    _saveKeys();
    setState(() {});
  }

  Future<void> _saveKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = _generatedKeys.map((k) =>
      '${k['code']}|${k['device']}|${k['period']}|${k['date']}'
    ).toList();
    await prefs.setStringList('generated_keys', keys);
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    _generatedCodeController.dispose();
    super.dispose();
  }

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: '$code — Mirror Scorpion 🦂'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ تم نسخ الكود")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔐 توليد أكواد التفعيل - PRO"),
        backgroundColor: const Color(0xFF0D1B2A),
        centerTitle: true,
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
          padding: const EdgeInsets.all(16),
          children: [
            // بطاقة معلومات المطور
            Card(
              color: Colors.amber.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings, color: Colors.amber, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "لوحة تحكم المطور",
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Tamer Eldosoky",
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // إدخال معرف الجهاز
            const Text(
              "معرف الجهاز (Device ID):",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _deviceIdController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "ألصق معرف الجهاز هنا...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste, color: Colors.amber),
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      _deviceIdController.text = data!.text!;
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // اختيار المدة
            const Text(
              "مدة الاشتراك:",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['1', '3', '12'].map((months) {
                final labels = <String, String>{
                  '1': '🌙 شهر',
                  '3': '📅 3 أشهر',
                  '12': '⭐ سنة',
                };
                final isSelected = _selectedDuration == months;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedDuration = months),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.amber.withOpacity(0.2)
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? Colors.amber : Colors.white24,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          labels[months]!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.amber : Colors.white54,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // زر التوليد
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateCode,
                icon: const Icon(Icons.vpn_key, color: Colors.black87),
                label: const Text(
                  "توليد كود التفعيل",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // الكود المولد
            if (_generatedCodeController.text.isNotEmpty)
              Card(
                color: Colors.green.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "✅ كود التفعيل:",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _generatedCodeController.text,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _copyCode(_generatedCodeController.text),
                            icon: const Icon(Icons.copy, color: Colors.amber, size: 18),
                            label: const Text("نسخ", style: TextStyle(color: Colors.amber)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // سجل الأكواد المولدة
            if (_generatedKeys.isNotEmpty) ...[
              const Text(
                "📋 سجل الأكواد المولدة:",
                style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._generatedKeys.map((key) => Card(
                    color: Colors.white.withOpacity(0.05),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.vpn_key, color: Colors.amber, size: 20),
                      title: Text(
                        '${key['code']!.substring(0, 25)}...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                      subtitle: Text(
                        "${key['device']} • ${key['period']} • ${key['date']}",
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white38, size: 16),
                        onPressed: () => _copyCode(key['code']!),
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
