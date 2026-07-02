import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    final premiumService = Provider.of<PremiumVerificationService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // كارت التفعيل البرو الجديد المضمون والمستقل
            const PremiumCard(),
            
            const SizedBox(height: 25),
            const Text(
              'العامة',
              style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // خيارات الإعدادات العامة الافتراضية للتطبيق
            Card(
              color: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dark_mode, color: Colors.amber),
                    title: const Text('الوضع الداكن', style: TextStyle(color: Colors.white)),
                    trailing: Switch(
                      value: _darkMode,
                      activeColor: Colors.amber,
                      onChanged: (val) {
                        setState(() {
                          _darkMode = val;
                        });
                      },
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ListTile(
                    leading: const Icon(Icons.download, color: Colors.amber),
                    title: const Text('تحميل الحزم اللغوية (Offline)', style: TextStyle(color: Colors.white)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                    onTap: () {
                      // مسار تحميل اللغات
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            const Text(
              'عن التطبيق',
              style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            Card(
              color: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: const ListTile(
                leading: Icon(Icons.info_outline, color: Colors.amber),
                title: Text('المطور', style: TextStyle(color: Colors.white)),
                subtitle: Text('tetocollctionway', style: TextStyle(color: Colors.white54)),
                trailing: Text('v2.7', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
