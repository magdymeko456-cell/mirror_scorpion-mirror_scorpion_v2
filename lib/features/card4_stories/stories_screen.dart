import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/premium_verification_service.dart';
import '../../services/tts_service.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  String _selectedCategory = 'الأنبياء';
  final List<String> _categories = ['الأنبياء', 'النساء', 'الأقوام', 'الحيوان', 'الإنسان', 'أسباب النزول'];

  // قصص الأنبياء الـ 25
  final List<Map<String, String>> _prophetStories = const [
    {'name': 'آدم عليه السلام', 'summary': 'أبو البشر، خلقه الله من طين، وأسجد له الملائكة، وعاش في الجنة ثم هبط إلى الأرض.', 'detail': 'خلق الله آدم بيده من طين، ونفخ فيه من روحه، وأمر الملائكة بالسجود له فسجدوا إلا إبليس أبى واستكبر. أسكنه الله الجنة مع زوجته حواء، وأباح لهما كل شيء إلا شجرة واحدة. فوسوس لهما الشيطان فأكلا منها، فأنزلهما الله إلى الأرض. تاب آدم فتاب الله عليه، وجعل ذريته خلفاء في الأرض.'},
    {'name': 'نوح عليه السلام', 'summary': 'أول الرسل، دعا قومه 950 سنة، وأمره الله ببناء السفينة.', 'detail': 'بعثه الله إلى قومه يعبدون الأصنام. دعاهم 950 سنة فلم يؤمن إلا قليل. أمره الله ببناء السفينة، وكان يمر به قومه ويسخرون منه. جاء الطوفان فأهلك الله الكافرين، ونجى نوحاً والمؤمنين في السفينة.'},
    {'name': 'إدريس عليه السلام', 'summary': 'نبي كريم، رفعه الله مكاناً علياً، أول من خط بالقلم.', 'detail': 'كان صديقاً نبياً، رفعه الله مكاناً علياً. كان أول من خط بالقلم وأول من خاط الثياب.'},
    {'name': 'هود عليه السلام', 'summary': 'بعث إلى قوم عاد، الذين كانوا أصحاب قوة وجبارين.', 'detail': 'بعثه الله إلى قوم عاد الذين كانوا يسكنون الأحقاف. كانوا أقوياء طغوا في الأرض. دعاهم إلى عبادة الله وحده فكذبوه. أرسل الله عليهم ريحاً صرصراً دمرتهم جميعاً.'},
    {'name': 'صالح عليه السلام', 'summary': 'بعث إلى قوم ثمود، وأتاهم بالناقة آية.', 'detail': 'بعثه الله إلى قوم ثمود الذين كانوا ينحتون الجبال بيوتاً. آتاهم الله الناقة آية، فعقروها. أخذتهم الصيحة فأصبحوا في دارهم جاثمين.'},
    {'name': 'إبراهيم عليه السلام', 'summary': 'خليل الرحمن، أبو الأنبياء، بنى الكعبة.', 'detail': 'ولد في قوم يعبدون الأصنام. كسر أصنامهم فحاولوا حرقه فأنجاه الله. اتخذه الله خليلاً. بشرته الملائكة بإسحاق ويعقوب. بنى الكعبة مع ابنه إسماعيل. ضرب أروع الأمثلة في التسليم لله.'},
    {'name': 'إسماعيل عليه السلام', 'summary': 'ابن إبراهيم، الذبيح، ساعد في بناء الكعبة.', 'detail': 'بشر الله إبراهيم به فبشر. أمر الله إبراهيم بذبحه فاستجابا، ففداه الله بذبح عظيم. ساعد أباه في بناء الكعبة.'},
    {'name': 'إسحاق عليه السلام', 'summary': 'ابن إبراهيم من سارة، نبي كريم.', 'detail': 'بشرت به الملائكة إبراهيم وسارة. أنعم الله عليه بالنبوة وجعل في ذريته الأنبياء.'},
    {'name': 'يعقوب عليه السلام', 'summary': 'ابن إسحاق، إسرائيل، أبو الأسباط.', 'detail': 'كان تقياً كريماً. ابتلي بفقد ابنه يوسف فصبر. اجتمع شمله بأولاده بمصر.'},
    {'name': 'يوسف عليه السلام', 'summary': 'صديق، أحسن القصص، عزيز مصر.', 'detail': 'ابتدأ أمره برؤيا رآها. حسده إخوته فألقوه في الجب. بيع عبداً في مصر. دعي للفحشاء فاستعصم. سجن ثم أصبح عزيز مصر. عفا عن إخوته.'},
    {'name': 'أيوب عليه السلام', 'summary': 'ضرب المثل في الصبر على البلاء.', 'detail': 'ابتلي في جسده وماله وولده. صبر واحتسب. نادى ربه فكشف ضره. آتاه الله أهله ومثلهم معهم.'},
    {'name': 'شعيب عليه السلام', 'summary': 'بعث إلى أهل مدين، خطيب الأنبياء.', 'detail': 'بعثه الله إلى أهل مدين. كانوا ينقصون المكيال والميزان. دعاهم إلى التوحيد والعدل. كذبوه فأخذهم عذاب الظلة.'},
    {'name': 'موسى عليه السلام', 'summary': 'كليم الله، أرسل بآيات عظيمة لفرعون.', 'detail': 'ولد في بيت فرعون. قتل قبطياً خطأ فهرب إلى مدين. ناداه الله في الوادي المقدس. أرسله إلى فرعون بآيات. أيده الله بمعجزات: العصا، اليد، الطوفان، الجراد. خرج ببني إسرائيل وشق الله لهم البحر.'},
    {'name': 'هارون عليه السلام', 'summary': 'أخو موسى، وزيره ونبيه.', 'detail': 'جاء مع موسى إلى فرعون. خلفه في قومه حين ذهب للقاء ربه. واجه بني إسرائيل في قصة العجل.'},
    {'name': 'داود عليه السلام', 'summary': 'خليفة الأرض، آتاه الله الزبور وسخر له الجبال.', 'detail': 'قتل جالوت. آتاه الله الملك والنبوة. أنزل عليه الزبور. سخر الله له الجبال والطير تسبح معه. ألان الله له الحديد.'},
    {'name': 'سليمان عليه السلام', 'summary': 'ملك عظيم، سخر له الريح والجن.', 'detail': 'ورث داود وسأل الله ملكاً لا ينبغي لأحد من بعده. سخر له الريح والجن والإنس. كان يفقه منطق الطير والحيوان. قصته مع بلقيس ملكة سبأ.'},
    {'name': 'الياس عليه السلام', 'summary': 'بعث إلى بني إسرائيل.', 'detail': 'دعا قومه لعبادة الله وترك عبادة بعل. كذبوه فأهلكهم الله.'},
    {'name': 'اليسع عليه السلام', 'summary': 'تابع دعوة الياس.', 'detail': 'آمن بالياس واتبعه. أنعم الله عليه بالنبوة.'},
    {'name': 'ذو الكفل عليه السلام', 'summary': 'نبي كريم من أنبياء بني إسرائيل.', 'detail': 'كان صابراً قاضياً عادلاً. ذكره الله في القرآن.'},
    {'name': 'يونس عليه السلام', 'summary': 'صاحب الحوت، ذو النون.', 'detail': 'دعا قومه فكذبوه. تركهم مغاضباً. ركب السفينة فالتقمه الحوت. نادى في الظلمات: لا إله إلا أنت سبحانك إني كنت من الظالمين. استجاب الله له وأخرجه.'},
    {'name': 'لوط عليه السلام', 'summary': 'بعث إلى قوم يأتون الفاحشة.', 'detail': 'دعا قومه لترك الفاحشة. كذبوه وأرادوا ضيوفه. أهلكهم الله بعذاب عظيم. نجى الله لوطاً وأهله.'},
    {'name': 'زكريا عليه السلام', 'summary': 'نبي كريم، رزقه الله يحيى على الكبر.', 'detail': 'كان ولياً تقياً. دعا ربه أن يهب له ولداً. بشرته الملائكة بيحيى.'},
    {'name': 'يحيى عليه السلام', 'summary': 'سيد الشباب، آتاه الله الحكم صبياً.', 'detail': 'ولد هبة من الله. آتاه الله الحكم والنبوة صبياً. قتله قومه ظلماً.'},
    {'name': 'عيسى عليه السلام', 'summary': 'روح الله وكلمته، أوتي الإنجيل.', 'detail': 'خلقه الله من مريم بلا أب. أنزل عليه الإنجيل. أيده الله بمعجزات: يبرئ الأكمه والأبرص ويحيي الموتى بإذن الله. رفعه الله إليه. سيعود آخر الزمان.'},
    {'name': 'محمد صلى الله عليه وسلم', 'summary': 'خاتم الأنبياء والمرسلين، أفضل الخلق.', 'detail': 'ولد في مكة. بعثه الله رحمة للعالمين. أنزل عليه القرآن. هاجر إلى المدينة. قاد المسلمين. غفر الله له ما تقدم من ذنبه. خير البشر وأكرمهم على الله.'},
  ];

  final Map<String, List<Map<String, String>>> _otherStories = {
    'النساء': [
      {'title': 'مريم بنت عمران', 'summary': 'أفضل نساء العالمين، أم عيسى عليه السلام.'},
      {'title': 'آسية امرأة فرعون', 'summary': 'آمنت بموسى وطلبت بيتاً في الجنة.'},
      {'title': 'خديجة بنت خويلد', 'summary': 'أم المؤمنين، أول من آمن بالنبي.'},
      {'title': 'عائشة أم المؤمنين', 'summary': 'أحب النساء إلى النبي، العالمة الفقيهة.'},
      {'title': 'هاجر أم إسماعيل', 'summary': 'جريت بين الصفا والمروة فصارت من مناسك الحج.'},
    ],
    'الأقوام': [
      {'title': 'قوم عاد', 'summary': 'قوم هود، كانوا أقوياء فأهلكوا بالريح.'},
      {'title': 'قوم ثمود', 'summary': 'قوم صالح، نحتوا الجبال فأهلكوا بالصيحة.'},
      {'title': 'قوم فرعون', 'summary': 'أغرقهم الله في اليم.'},
      {'title': 'قوم لوط', 'summary': 'قلبت عليهم ديارهم.'},
      {'title': 'قوم شعيب', 'summary': 'أصحاب الأيكة، أخذهم عذاب الظلة.'},
    ],
    'الحيوان': [
      {'title': 'ناقة صالح', 'summary': 'آية لقوم ثمود، شربت ماءهم يوماً.'},
      {'title': 'حوت يونس', 'summary': 'التقم يونس ثم أخرجه بإذن الله.'},
      {'title': 'بقرة بني إسرائيل', 'summary': 'قصة القتيل الذي أحياه الله بضرب بعضها.'},
      {'title': 'طير إبراهيم', 'summary': 'أحياه الله ليُري إبراهيم كيف يحيي الموتى.'},
      {'title': 'الفيل', 'summary': 'قصة أبرهة والفيل المذكورة في سورة الفيل.'},
      {'title': 'الغراب', 'summary': 'علم قابيل كيف يواري سوأة أخيه.'},
    ],
    'الإنسان': [
      {'title': 'قابيل وهابيل', 'summary': 'أول ابني آدم، أول قتل في الأرض.'},
      {'title': 'قارون', 'summary': 'خسف الله به وبداره الأرض.'},
      {'title': 'بلعام بن باعورا', 'summary': 'آتاه الله الآيات فانسلخ منها.'},
      {'title': 'أصحاب الكهف', 'summary': 'فتية آمنوا بربهم وزادهم الله هدى.'},
      {'title': 'لقمان الحكيم', 'summary': 'آتاه الله الحكمة ووعظ ابنه.'},
    ],
    'أسباب النزول': [
      {'title': 'سورة الفاتحة', 'summary': 'نزلت بمكة، وهي أول سورة نزلت كاملة.'},
      {'title': 'آية الكرسي (البقرة 255)', 'summary': 'نزلت وآية الكرسي أعظم آية في كتاب الله.'},
      {'title': 'سورة الإخلاص', 'summary': 'نزلت حين قال المشركون: انسب لنا ربك.'},
      {'title': 'سورة الكوثر', 'summary': 'نزلت في العاص بن وائل حين قال النبي أبتر.'},
      {'title': 'سورة المسد', 'summary': 'نزلت في أبي لهب وامرأته.'},
      {'title': 'الزلزلة', 'summary': 'نزلت تسلية للصحابة.'},
      {'title': 'سورة الشرح', 'summary': 'نزلت تسلية للنبي صلى الله عليه وسلم.'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumVerificationService>();
    final isPro = premium.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 قصص وإلهام'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(children: [
        // Categories
        Container(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            children: _categories.map((cat) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(cat),
                selected: _selectedCategory == cat,
                selectedColor: Colors.teal,
                labelStyle: TextStyle(color: _selectedCategory == cat ? Colors.white : Colors.teal),
                onSelected: (_) => setState(() => _selectedCategory = cat),
              ),
            )).toList(),
          ),
        ),
        Expanded(child: _selectedCategory == 'الأنبياء' ? _buildProphetList(isPro) : _buildOtherList(isPro)),
      ]),
    );
  }

  Widget _buildProphetList(bool isPro) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _prophetStories.length,
      itemBuilder: (_, i) {
        final story = _prophetStories[i];
        return Card(margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.teal.shade100, child: Text('${i+1}', style: TextStyle(color: Colors.teal.shade700))),
            title: Text(story['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(story['summary']!, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
            onTap: () => _openStoryDetail(context, story['name']!, story['detail']!, isPro),
          ),
        );
      },
    );
  }

  Widget _buildOtherList(bool isPro) {
    final items = _otherStories[_selectedCategory] ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return Card(margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(Icons.auto_stories, color: Colors.teal),
            title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['summary']!, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
            onTap: () => _openStoryDetail(context, item['title']!, item['summary']!, isPro),
          ),
        );
      },
    );
  }

  void _openStoryDetail(BuildContext context, String title, String content, bool isPro) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => _StoryDetailScreen(title: title, content: content, isPro: isPro)));
  }
}

class _StoryDetailScreen extends StatelessWidget {
  final String title;
  final String content;
  final bool isPro;

  const _StoryDetailScreen({required this.title, required this.content, required this.isPro});

  @override
  Widget build(BuildContext context) {
    final tts = context.watch<TTSService>();
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_stories, color: Colors.teal, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal))),
          ]),
          const Divider(height: 32),
          SelectableText(content, style: const TextStyle(fontSize: 16, height: 1.8), textDirection: TextDirection.rtl),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: const Icon(Icons.volume_up, color: Colors.teal), onPressed: () => tts.speak(content)),
            IconButton(icon: const Icon(Icons.copy, color: Colors.teal), onPressed: () {
              Clipboard.setData(ClipboardData(text: '$title\n\n$content\n\n- Mirror Scorpion'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ')));
            }),
          ]),
          if (!isPro) ...[
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber)),
              child: Row(children: [
                const Icon(Icons.workspace_premium, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(child: Text('جميع القصص كاملة + تحويل إلى فيديو متاح في Pro', style: TextStyle(color: Colors.brown.shade700))),
                TextButton(onPressed: () => Navigator.pushNamed(context, '/settings'), child: const Text('Pro', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
