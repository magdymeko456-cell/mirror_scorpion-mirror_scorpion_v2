import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SettingsProScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const SettingsProScreen({super.key, required this.prefs});

  @override
  State<SettingsProScreen> createState() => _SettingsProScreenState();
}

class _SettingsProScreenState extends State<SettingsProScreen> {
  final TextEditingController _patchController = TextEditingController();
  final String deviceID = "MS-${Platform.operatingSystemVersion.hashCode.toString().substring(0,8).toUpperCase()}";
  String selectedPlan = "شهر واحد - 50 ج.م";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text("تفعيل ميرور سكربيون برو 👑", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // قسم اختيار المدة
            _buildCard("1. اختر مدة الاشتراك", Column(
              children: [
                _buildPlanRadio("شهر واحد - 50 ج.م"),
                _buildPlanRadio("3 شهور - 120 ج.م"),
                _buildPlanRadio("سنة كاملة - 400 ج.م"),
              ],
            )),

            // قسم بيانات الدفع
            _buildCard("2. وسائل الدفع المتاحة", Column(
              children: [
                _buildPaymentTile("انستا باي (InstaPay)", "01558203456", Colors.purpleAccent),
                _buildPaymentTile("فودافون كاش", "01017341250", Colors.redAccent),
                _buildPaymentTile("فودافون كاش (احتياطي)", "01031680816", Colors.redAccent),
              ],
            )),

            // قسم ID الجهاز
            _buildCard("3. معرف الجهاز (ID)", Column(
              children: [
                const Text("انسخ هذا الكود وارسله للمطور مع صورة التحويل", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 10),
                TextField(
                  readOnly: true,
                  controller: TextEditingController(text: deviceID),
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(icon: const Icon(Icons.copy, color: Colors.amber), 
                    onPressed: () => Clipboard.setData(ClipboardData(text: deviceID))),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            )),

            // قسم إرفاق البيانات ولصق الكود
            _buildCard("4. التفعيل", Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () {}, // إضافة مكتبة الصورة لاحقاً
                  icon: const Icon(Icons.upload_file),
                  label: const Text("إرفاق صورة التحويل"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _patchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "الصق كود التفعيل هنا",
                    labelStyle: const TextStyle(color: Colors.amberAccent),
                    suffixIcon: IconButton(icon: const Icon(Icons.paste), onPressed: () async {
                      var data = await Clipboard.getData('text/plain');
                      if(data != null) setState(() => _patchController.text = data.text!);
                    }),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () async {
                    if(_patchController.text.isNotEmpty) {
                      await widget.prefs.setBool('is_pro_version', true);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم تفعيل البرو بنجاح! 🎉")));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, minimumSize: const Size(double.infinity, 50)),
                  child: const Text("تفعيل الآن", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            )),

            // معلومات التواصل
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text("للتواصل مع المطور تامر الدسوقي", style: TextStyle(color: Colors.white54)),
                  Text("dosoky.server@gmail.com", style: TextStyle(color: Colors.blue)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 15),
        content,
      ]),
    );
  }

  Widget _buildPlanRadio(String title) {
    return RadioListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      value: title, groupValue: selectedPlan,
      onChanged: (v) => setState(() => selectedPlan = v.toString()),
    );
  }

  Widget _buildPaymentTile(String title, String num, Color color) {
    return ListTile(
      leading: Icon(Icons.payment, color: color),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(num, style: const TextStyle(color: Colors.white70)),
      trailing: IconButton(icon: const Icon(Icons.copy, size: 18), onPressed: () => Clipboard.setData(ClipboardData(text: num))),
    );
  }
}
