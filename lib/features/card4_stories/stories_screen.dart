import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/premium_verification_service.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumVerificationService>();
    final isPro = premium.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 قصص إسلامية'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          if (!isPro)
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              icon: const Icon(Icons.workspace_premium, color: Colors.amber),
              label: const Text('Pro', style: TextStyle(color: Colors.amber)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _sourceCard(
            context,
            title: '📚 تفسير الجلالين',
            subtitle: 'تفسير القرآن الكريم للجلالين',
            stories: [
              IslamicStory(
                title: 'سورة الفاتحة',
                content: isPro
                  ? 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ (1) الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ (2) الرَّحْمَٰنِ الرَّحِيمِ (3) مَالِكِ يَوْمِ الدِّينِ (4) إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ (5) اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ (6) صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ (7)\n\nالتفسير: قوله تعالى "رب العالمين" أي مالك جميع الخلق. "الرحمن الرحيم" أي ذو الرحمة العامة والخاصة. "مالك يوم الدين" أي يوم الجزاء.'
                  : 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ... اضغط لعرض التفسير الكامل (يتطلب Pro)',
                icon: Icons.auto_stories,
              ),
              IslamicStory(
                title: 'سورة الإخلاص',
                content: isPro
                  ? 'قُلْ هُوَ اللَّهُ أَحَدٌ (1) اللَّهُ الصَّمَدُ (2) لَمْ يَلِدْ وَلَمْ يُولَدْ (3) وَلَمْ يَكُن لَّهُ كُفُواً أَحَدٌ (4)\n\nالتفسير: سورة الإخلاص تعدل ثلث القرآن. "أحد" أي واحد لا شريك له. "الصمد" أي السيد الذي يُصمد إليه في الحوائج.'
                  : 'قُلْ هُوَ اللَّهُ أَحَدٌ... التفسير الكامل للمشتركين Pro',
                icon: Icons.mosque,
              ),
            ],
          ),
          _sourceCard(
            context,
            title: '📖 تفسير ابن كثير',
            subtitle: 'قصص الأنبياء - ابن كثير',
            stories: [
              IslamicStory(
                title: 'قصة آدم عليه السلام',
                content: isPro
                  ? 'خلق الله آدم من طين من حمأ مسنون، ثم نفخ فيه من روحه، وأمر الملائكة بالسجود له فسجدوا إلا إبليس أبى واستكبر. وأسكن الله آدم الجنة مع زوجته حواء، ونهاهما عن شجرة معينة، فأكلا منها بعد وسوسة الشيطان، فأنزلهما الله إلى الأرض.'
                  : 'خلق الله آدم من طين... القصة الكاملة في النسخة Pro',
                icon: Icons.person,
              ),
              IslamicStory(
                title: 'قصة نوح عليه السلام',
                content: isPro
                  ? 'أرسل الله نوحاً إلى قومه يدعوهم لعبادة الله وحده، فكذبوه واستكبروا. فدعا ربه: "إني مغلوب فانتصر". فأمره الله ببناء السفينة، وحمله الله ومن آمن معه وأهلك الكافرين بالطوفان.'
                  : 'أرسل الله نوحاً إلى قومه... اضغط للمشاهدة الكاملة (Pro)',
                icon: Icons.directions_boat,
              ),
              IslamicStory(
                title: 'قصة إبراهيم عليه السلام',
                content: isPro
                  ? 'ولد إبراهيم في أرض بابل، ورأى قومه يعبدون الأصنام فحطمها، فألقوه في النار فكانت برداً وسلاماً. هاجر إلى الشام، وبنى الكعبة مع ابنه إسماعيل، وابتاه الله بذبح ابنه ففداه بذبح عظيم.'
                  : 'ولد إبراهيم في أرض بابل... القصة كاملة في Pro',
                icon: Icons.shield,
              ),
              IslamicStory(
                title: 'قصة موسى عليه السلام',
                content: isPro
                  ? 'ولد موسى في وقت كان فرعون يذبح أبناء بني إسرائيل، فألقت أمه في اليم، والتقطه آل فرعون. كبر موسى وقتل رجلاً قبطياً فهرب إلى مدين. رجع ونبأه الله، وأرسله مع أخيه هارون إلى فرعون، فأيده الله بآيات عظيمة. أنقذ الله بني إسرائيل وأغرق فرعون وجنوده.'
                  : 'ولد موسى في وقت كان فرعون يذبح أبناء بني إسرائيل... القصة الكاملة في Pro',
                icon: Icons.auto_stories,
              ),
            ],
          ),
          _sourceCard(
            context,
            title: '📜 أسباب النزول',
            subtitle: 'أسباب نزول الآيات القرآنية',
            stories: [
              IslamicStory(
                title: 'سبب نزول سورة الفيل',
                content: isPro
                  ? 'نزلت في قصة أبرهة الحبشي الذي جاء بهدم الكعبة بجيش عظيم معه الفيلة. أرسل الله عليهم طيراً أبابيل ترميهم بحجارة من سجيل فجعلهم كعصف مأكول.'
                  : 'نزلت في قصة أبرهة الحبشي... للاطلاع على القصة كاملة اشترك Pro',
                icon: Icons.terrain,
              ),
              IslamicStory(
                title: 'سبب نزول آية الكرسي',
                content: isPro
                  ? 'نزلت آية الكرسي (اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ...) وهي أعظم آية في كتاب الله. قال صلى الله عليه وسلم: "من قرأها في ليلة لم يزل عليه من الله حافظ ولا يقربه شيطان حتى يصبح".'
                  : 'نزلت آية الكرسي وهي أعظم آية... النص الكامل في Pro',
                icon: Icons.star,
              ),
              IslamicStory(
                title: 'سبب نزول سورة الكوثر',
                content: isPro
                  ? 'نزلت في العاص بن وائل الذي قال عن النبي صلى الله عليه وسلم "إنه أبتر" (لا عقب له). فأنزل الله: "إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ * فَصَلِّ لِرَبِّكَ وَانْحَرْ * إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ".'
                  : 'نزلت في العاص بن وائل... القصة كاملة في النسخة المدفوعة',
                icon: Icons.water,
              ),
            ],
          ),
          _sourceCard(
            context,
            title: '🕌 الأربعون النووية',
            subtitle: '40 حديثاً نبوياً جمعها الإمام النووي',
            stories: [
              IslamicStory(
                title: 'الحديث 1 - الأعمال بالنيات',
                content: 'عن عمر بن الخطاب رضي الله عنه قال: سمعت رسول الله صلى الله عليه وسلم يقول: "إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى..."',
                icon: Icons.format_quote,
              ),
              IslamicStory(
                title: 'الحديث 2 - الإسلام والإيمان',
                content: 'عن عمر بن الخطاب قال: بينما نحن عند رسول الله صلى الله عليه وسلم إذ طلع علينا رجل شديد بياض الثياب... فقال: "الإسلام أن تشهد أن لا إله إلا الله وأن محمداً رسول الله..."',
                icon: Icons.format_quote,
              ),
              IslamicStory(
                title: 'الحديث 3 - أركان الإسلام',
                content: 'عن عبد الله بن عمر رضي الله عنهما قال: قال رسول الله صلى الله عليه وسلم: "بني الإسلام على خمس: شهادة أن لا إله إلا الله وأن محمداً رسول الله، وإقام الصلاة، وإيتاء الزكاة، وحج البيت، وصوم رمضان."',
                icon: Icons.format_quote,
              ),
            ],
          ),
          _sourceCard(
            context,
            title: '🌟 الحديث القدسي',
            subtitle: 'أحاديث يرويها النبي عن ربه',
            stories: [
              IslamicStory(
                title: 'الحديث القدسي - أنا عند ظن عبدي بي',
                content: 'عن أبي هريرة رضي الله عنه أن النبي صلى الله عليه وسلم قال: يقول الله تعالى: "أنا عند ظن عبدي بي، وأنا معه إذا ذكرني..."',
                icon: Icons.star_border,
              ),
              IslamicStory(
                title: 'الحديث القدسي - يا عبادي إني حرمت الظلم',
                content: 'عن أبي ذر رضي الله عنه عن النبي صلى الله عليه وسلم فيما روى عن الله تبارك وتعالى أنه قال: "يا عبادي إني حرمت الظلم على نفسي وجعلته بينكم محرماً فلا تظالموا..."',
                icon: Icons.star_border,
              ),
            ],
          ),
          _sourceCard(
            context,
            title: '📜 صحيح الأحاديث',
            subtitle: 'مجموعة من أحاديث صحيح البخاري ومسلم',
            stories: [
              IslamicStory(
                title: 'حديث - من يرد الله به خيراً',
                content: 'عن معاوية رضي الله عنه قال: قال رسول الله صلى الله عليه وسلم: "من يرد الله به خيراً يفقهه في الدين."',
                icon: Icons.lightbulb,
              ),
              IslamicStory(
                title: 'حديث - الدنيا سجن المؤمن',
                content: 'عن أبي هريرة رضي الله عنه قال: قال رسول الله صلى الله عليه وسلم: "الدنيا سجن المؤمن وجنة الكافر."',
                icon: Icons.lightbulb,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sourceCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<IslamicStory> stories,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: const Icon(Icons.auto_stories, color: Colors.teal),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        children: stories.map((story) => ListTile(
          leading: Icon(story.icon, color: Colors.amber.shade700, size: 28),
          title: Text(story.title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            story.content.length > 80 ? '${story.content.substring(0, 80)}...' : story.content,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: const Icon(Icons.arrow_back_ios_new, size: 16),
          onTap: () => _openStory(context, story),
        )).toList(),
      ),
    );
  }

  void _openStory(BuildContext context, IslamicStory story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _StoryDetailScreen(story: story),
      ),
    );
  }
}

class IslamicStory {
  final String title;
  final String content;
  final IconData icon;
  const IslamicStory({
    required this.title,
    required this.content,
    this.icon = Icons.auto_stories,
  });
}

class _StoryDetailScreen extends StatelessWidget {
  final IslamicStory story;
  const _StoryDetailScreen({required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(story.title),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(story.icon, color: Colors.teal, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    story.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            SelectableText(
              story.content,
              style: const TextStyle(fontSize: 16, height: 1.8, fontFamily: 'Traditional Arabic'),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 24),
            Center(
              child: IconButton(
                icon: const Icon(Icons.copy, color: Colors.teal),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: story.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ المحتوى')),
                  );
                },
                tooltip: 'نسخ المحتوى',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
