import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/premium_verification_service.dart';

class PremiumCard extends StatefulWidget {
  const PremiumCard({super.key});

  @override
  State<PremiumCard> createState() => _PremiumCardState();
}

class _PremiumCardState extends State<PremiumCard> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final premiumService = Provider.of<PremiumVerificationService>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.withOpacity(0.15), Colors.orange.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          const Row(
            children: [
              Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
              SizedBox(width: 12),
              Text('تفعيل النسخة البرو (PRO)',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),

          // معرف الجهاز
          const Text('معرف الجهاز (ID):',
              style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildDeviceIdRow(premiumService),
          const SizedBox(height: 20),

          // التفعيل اليدوي
          _buildManualActivation(premiumService),
          const SizedBox(height: 20),

          // التفعيل السحابي
          _buildCloudActivation(premiumService),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 8),

          // معلومات الاتصال
          _buildContactInfo(),
        ],
      ),
    );
  }

  Widget _buildDeviceIdRow(PremiumVerificationService service) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            child: Text(service.encryptedDeviceId,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'monospace')),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.amber, size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: service.encryptedDeviceId));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ معرف الجهاز')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManualActivation(PremiumVerificationService service) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.key, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Text('التفعيل اليدوي (كود التفعيل)',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('ألصق كود التفعيل:', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'باتش التفعيل...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.paste, color: Colors.amber),
                onPressed: () async {
                  final data = await Clipboard.getData('text/plain');
                  if (data != null) _codeController.text = data.text!;
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final success = await service.activatePremium(_codeController.text);
                if (success) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ تم تفعيل النسخة الاحترافية بنجاح')));
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('❌ كود التفعيل غير صحيح'), backgroundColor: Colors.red));
                }
              },
              icon: const Icon(Icons.lock_open, size: 18),
              label: const Text('تفعيل بالكود', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudActivation(PremiumVerificationService service) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cloud, color: Colors.green, size: 18),
              SizedBox(width: 8),
              Text('التفعيل السحابي (أونلاين)',
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('سيتم إرسال معرف جهازك إلى السيرفر للتحقق والتفعيل الفوري',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: service.isLoading ? null : () async {
                final success = await service.activateWithServer();
                if (!mounted) return;
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ تم التفعيل السحابي بنجاح')));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('❌ فشل التفعيل السحابي، تحقق من اتصالك أو راجع السيرفر'),
                          backgroundColor: Colors.red));
                }
              },
              icon: service.isLoading
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cloud_upload, size: 18),
              label: Text(service.isLoading ? 'جاري التفعيل...' : 'تفعيل سحابي',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_support, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text('معلومات الاتصال للحصول على الكود',
                  style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [Icon(Icons.whatsapp, color: Colors.green, size: 18), SizedBox(width: 8), Text('واتساب:', style: TextStyle(color: Colors.white54, fontSize: 12))],
          ),
          Padding(padding: EdgeInsets.only(left: 26), child: Text('01017341250', style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace'))),
          Padding(padding: EdgeInsets.only(left: 26), child: Text('01031680816', style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace'))),
          Padding(padding: EdgeInsets.only(left: 26), child: Text('01558203456', style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace'))),
          SizedBox(height: 10),
          Row(
            children: [Icon(Icons.email, color: Colors.blue, size: 18), SizedBox(width: 8), Text('إيميل:', style: TextStyle(color: Colors.white54, fontSize: 12))],
          ),
          Padding(padding: EdgeInsets.only(left: 26), child: Text('dosoky.server@gmail.com', style: TextStyle(color: Colors.blueAccent, fontSize: 13, fontFamily: 'monospace'))),
        ],
      ),
    );
  }
}
