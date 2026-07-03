import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _isPro = false;
  String _deviceId = 'MIRROR-ABCD-1234-XYZ';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('dark_mode') ?? false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() => _isDarkMode = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    // إعادة تشغيل التطبيق (سيتم تطبيق الثيم عند إعادة التشغيل)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // تفعيل النسخة البرو
          Card(
            color: const Color(0xFFFFD700).withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium, size: 48, color: Color(0xFFFFD700)),
                  const SizedBox(height: 8),
                  const Text(
                    'النسخة البرو',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB8860B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showProDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'تفعيل النسخة البرو',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // الوضع المظلم
          Card(
            child: SwitchListTile(
              title: const Text('الوضع المظلم'),
              subtitle: const Text('تغيير مظهر التطبيق'),
              secondary: Icon(
                _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: _isDarkMode ? Colors.amber : Colors.grey,
              ),
              value: _isDarkMode,
              onChanged: _toggleDarkMode,
            ),
          ),
          
          // تذييل
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                const Text(
                  'Mirror Scorpion v1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(const Text(
                    'Mirror Scorpion v1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '© 2026 Tamer Eldosoky',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفعيل النسخة البرو'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('مزايا النسخة البرو:'),
            const SizedBox(height: 12),
            const Text('• صوت المستخدم الخامس'),
            const Text('• ترجمة مستندات بلا حدود'),
            const Text('• تحويل الإلهام إلى فيديو'),
            const Text('• قصص القرآن كاملة'),
            const SizedBox(height: 16),
            // ID الجهاز
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'ID: ${_deviceId.substring(0, 15)}...',
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // حقل إدخال الباتش
            TextField(
              decoration: InputDecoration(
                hintText: 'أدخل باتش التفعيل',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: () {},
                ),
              ),
            ),
            const SizedBox(height: 16),
            // معلومات الاتصال
            Text(
              'للتواصل: 01017341250\n01031680816\ndosoky.server@gmail.com',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('تفعيل'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }
}
