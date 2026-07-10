import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final List<Map<String, String>> _stories = [
    {
      'title': 'الإصرار والنجاح',
      'content': 'المحاولة المستمرة هي سر النجاح. لا يهم كم مرة سقطت، بل المهم كم مرة نهضت لتكمل طريقك نحو القمة والتحدي.',
    },
    {
      'title': 'قيمة الوقت',
      'content': 'الوقت هو العملة الأغلى في حياتنا. من يملك زمام وقته وتنظيمه، يملك مفاتيح المستقبل وبناء الإمبراطوريات الشخصية.',
    },
    {
      'title': 'الهدوء الداخلي',
      'content': 'في وسط عواصف الحياة الصاخبة، ابحث عن سلامك الداخلي، وثق تماماً أن ما كُتب لك سيأتيك رغماً عن كل الظروف والمصاعب.',
    }
  ];

  @override
  Widget build(BuildContext context) {
    final tts = Provider.of<TTSService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('قصص وإلهام ميرور', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2838),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(story['title']!, style: const TextStyle(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.orangeAccent),
                      onPressed: () => tts.speak(story['content']!),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  story['content']!,
                  style: const TextStyle(color: Colors.white80, fontSize: 14, height: 1.5),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
