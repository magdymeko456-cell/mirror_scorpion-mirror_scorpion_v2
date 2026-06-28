import 'package:flutter/material.dart';
import 'dart:math';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  String _selectedCategory = 'الكل';
  final List<String> _categories = ['الكل', 'قصص القرآن', 'الأمم السابقة', 'قصص الأنبياء', 'أسباب النزول', 'الأربعين النووية', 'أحاديث قدسية'];

  final Map<String, List<Map<String, String>>> _stories = {
    'قصص القرآن': [
      {'title': 'قصة أصحاب الكهف', 'subtitle': 'سورة الكهف - الفتية الذين آمنوا بربهم', 'content': 'قصة الفتية الذين هربوا بدينهم من ظلم الملك...'},
      {'title': 'قصة موسى والخضر', 'subtitle': 'سورة الكهف - رحلة العلم', 'content': 'التقى موسى عليه السلام بالخضر ليتعلم منه...'},
      {'title': 'قصة ذو القرنين', 'subtitle': 'سورة الكهف - الملك الصالح', 'content': 'الملك الذي ملك مشارق الأرض ومغاربها...'},
      {'title': 'قصة سليمان والهدهد', 'subtitle': 'سورة النمل - جيش النمل', 'content': 'الهدهد الذي جاء بخبر مملكة سبأ...'},
      {'title': 'قصة يوسف عليه السلام', 'subtitle': 'أحسن القصص', 'content': 'قصة يوسف مع إخوته ورحلة الصبر والتمكين...'},
      {'title': 'قصة مريم وعيسى', 'subtitle': 'سورة مريم - آيات الله', 'content': 'قصة مريم بنت عمران وولادة عيسى عليه السلام...'},
    ],
    'الأمم السابقة': [
      {'title': 'قوم نوح', 'subtitle': 'أول الرسل - الطوفان العظيم', 'content': 'دعوة نوح عليه السلام لألف سنة إلا خمسين عاماً...'},
      {'title': 'قوم عاد', 'subtitle': 'قوم هود - ذات العماد', 'content': 'قبيلة عاد الذين لم يُخلق مثلها في البلاد...'},
      {'title': 'قوم ثمود', 'subtitle': 'قوم صالح - الناقة', 'content': 'قوم ثمود الذين جابوا الصخر بالواد...'},
      {'title': 'قوم لوط', 'subtitle': 'المؤتفكات - قلوب منقلبة', 'content': 'قصة لوط عليه السلام مع قومه...'},
      {'title': 'قوم فرعون', 'subtitle': 'موسى وهامان - الطغيان', 'content': 'فرعون الذي استعبد بني إسرائيل...'},
      {'title': 'أصحاب الأخدود', 'subtitle': 'قصة الإيمان في النار', 'content': 'الفتية الذين أُحرقوا في الأخدود...'},
    ],
    'قصص الأنبياء': [
      {'title': 'آدم عليه السلام', 'subtitle': 'أبو البشر - خليفة الله', 'content': 'خلق آدم من طين ونفخ الروح فيه...'},
      {'title': 'نوح عليه السلام', 'subtitle': 'أول العزم - السفينة', 'content': 'بناء السفينة ودعوة قومه...'},
      {'title': 'إبراهيم عليه السلام', 'subtitle': 'خليل الرحمن - الكعبة', 'content': 'تحطيم الأصنام وبناء البيت...'},
      {'title': 'موسى عليه السلام', 'subtitle': 'كليم الله - العصا', 'content': 'الطفولة في القصر والرسالة...'},
      {'title': 'عيسى عليه السلام', 'subtitle': 'المسيح - الإنجيل', 'content': 'الولادة المعجزة والدعوة...'},
      {'title': 'محمد ﷺ', 'subtitle': 'خاتم الأنبياء', 'content': 'السيرة العطرة من الميلاد إلى الرفيق الأعلى...'},
    ],
    'أسباب النزول': [
      {'title': 'سبب نزول سورة الفاتحة', 'subtitle': 'أم الكتاب', 'content': 'نزلت لتعليم الأمة كيفية الدعاء...'},
      {'title': 'آية الكرسي', 'subtitle': 'أعظم آية', 'content': 'سبب نزولها وأهميتها...'},
      {'title': 'سورة الإخلاص', 'subtitle': 'التوحيد الخالص', 'content': 'نزلت رداً على المشركين...'},
    ],
    'الأربعين النووية': [
      {'title': 'الحديث الأول', 'subtitle': 'الأعمال بالنيات', 'content': 'إنما الأعمال بالنيات...'},
      {'title': 'الحديث التاسع', 'subtitle': 'ما نهيتكم عنه', 'content': 'ما نهيتكم عنه فاجتنبوه...'},
      {'title': 'الحديث الثالث عشر', 'subtitle': 'لا يؤمن أحدكم', 'content': 'لا يؤمن أحدكم حتى يحب لأخيه...'},
    ],
    'أحاديث قدسية': [
      {'title': 'أنا عند ظن عبدي بي', 'subtitle': 'الحديث القدسي', 'content': 'يقول الله تعالى: أنا عند ظن عبدي بي...'},
      {'title': 'يا عبادي إني حرمت الظلم', 'subtitle': 'الحديث القدسي', 'content': 'يا عبادي إني حرمت الظلم على نفسي...'},
      {'title': 'الرحمة تغلب الغضب', 'subtitle': 'الحديث القدسي', 'content': 'إن رحمتي سبقت غضبي...'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('قصص وإلهام', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Categories horizontal scroll
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _categories.map((cat) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(cat, style: TextStyle(color: _selectedCategory == cat ? Colors.black : Colors.white, fontSize: 13)),
                  selected: _selectedCategory == cat,
                  selectedColor: Colors.amberAccent,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  onSelected: (v) => setState(() => _selectedCategory = cat),
                ),
              )).toList(),
            ),
          ),
          // Stories list
          Expanded(
            child: _selectedCategory == 'الكل'
                ? ListView(
                    padding: const EdgeInsets.all(12),
                    children: _categories.where((c) => c != 'الكل').map((cat) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(cat, style: const TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        ...(_stories[cat] ?? []).map((story) => _buildStoryCard(story)),
                        const SizedBox(height: 8),
                      ],
                    )).toList(),
                  )
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: (_stories[_selectedCategory] ?? []).map((story) => _buildStoryCard(story)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(Map<String, String> story) {
    final colors = [Colors.blueAccent, Colors.cyanAccent, Colors.tealAccent, Colors.orangeAccent, Colors.purpleAccent, Colors.greenAccent];
    final color = colors[Random().nextInt(colors.length)];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.08), Colors.transparent]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        leading: Icon(Icons.auto_stories, color: color),
        title: Text(story['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(story['subtitle'] ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(story['content'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6)),
          ),
        ],
      ),
    );
  }
}
