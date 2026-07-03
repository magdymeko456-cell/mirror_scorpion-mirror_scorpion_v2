import 'package:flutter/material.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});
  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final TextEditingController _urlController = TextEditingController();
  String? _selectedFilePath;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _openLens() {
    // سيتم فتح الكاميرا بعدسة جوجل
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري فتح العدسة...')),
    );
  }

  void _browseFile() {
    // سيتم فتح مستعرض الملفات
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري فتح المستعرض...')),
    );
  }

  void _translateDocument() {
    if (_urlController.text.trim().isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري ترجمة المستند...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🦂 ترجمة مستندات وعدسة')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ✅ زر العدسة
                ElevatedButton.icon(
                  onPressed: _openLens,
                  icon: const Icon(Icons.camera_alt, size: 28),
                  label: const Text('📷 عدسة جوجل', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),

                const SizedBox(height: 24),

                // ✅ حقل إدخال الرابط
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'الصق الرابط أو مسار الملف...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.link, color: Colors.white38),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: _browseFile,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ✅ زر فتح من المستعرض
                ElevatedButton.icon(
                  onPressed: _browseFile,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('📂 فتح من المستعرض'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ زر الترجمة (يظهر في الثلث الأخير)
                if (_urlController.text.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _translateDocument,
                    icon: const Icon(Icons.translate, size: 28),
                    label: const Text('🌍 ترجمة المستند', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
