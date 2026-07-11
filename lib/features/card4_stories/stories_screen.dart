import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';
import '../../services/ai_service.dart';
import '../../core/widgets/shared_widgets.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  // قائمة الأحاديث القدسية
  final List<Map<String, String>> _hadithQudsi = [
    {
      'id': '1',
      'text': 'يا عبادي إني حرمت الظلم على نفسي وجعلته بينكم محرماً فلا تظالموا',
      'meaning': 'الحديث القدسي الشهير عن تحريم الظلم',
    },
    {
      'id': '2',
      'text': 'أنا عند ظن عبدي بي، وأنا معه إذا ذكرني',
      'meaning': 'فضل حسن الظن بالله وذكره',
    },
    {
      'id': '3',
      'text': 'يا عبادي كلكم ضال إلا من هديته فاستهدوني أهدكم',
      'meaning': 'الافتقار إلى الله في الهداية',
    },
    {
      'id': '4',
      'text': 'يا عبادي كلكم جائع إلا من أطعمته فاستطعموني أطعمكم',
      'meaning': 'طلب الرزق من الله وحده',
    },
    {
      'id': '5',
      'text': 'يا عبادي كلكم عار إلا من كسوته فاستكسوني أكسكم',
      'meaning': 'التوكل على الله في كل شيء',
    },
    {
      'id': '6',
      'text': 'من عادى لي ولياً فقد آذنته بالحرب',
      'meaning': 'تحذير من معاداة أولياء الله',
    },
    {
      'id': '7',
      'text': 'كل عمل ابن آدم له إلا الصيام فإنه لي وأنا أجزي به',
      'meaning': 'فضل الصيام وأنه لله',
    },
    {
      'id': '8',
      'text': 'أحب الأعمال إلى الله أدومها وإن قلّ',
      'meaning': 'فضل المداومة على العمل الصالح',
    },
  ];

  // قائمة القصص - 25 قصة الأنبياء + أخرى
  final List<Map<String, dynamic>> _prophetsStories = [
    {
      'id': 'adam',
      'name': 'سيدنا آدم عليه السلام',
      'summary': 'أبو البشر، خلقه الله من طين، وأسجد له الملائكة، وعلمه الأسماء كلها، ثم سكن الجنة مع زوجته حواء، ثم هبطا إلى الأرض بعد المخالفة، فتابا فتاب الله عليهما.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/adam.json',
    },
    {
      'id': 'idris',
      'name': 'سيدنا إدريس عليه السلام',
      'summary': 'من أولي العزم، كان صبوراً صادقاً، رفعه الله مكاناً علياً، وهو أول من خط بالقلم.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/idris.json',
    },
    {
      'id': 'nuh',
      'name': 'سيدنا نوح عليه السلام',
      'summary': 'أول الرسل، دعا قومه 950 عاماً بصبر عظيم، أمره الله ببناء السفينة، فأنجاه الله ومن آمن معه وأغرق الكافرين بالطوفان العظيم.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/nuh.json',
    },
    {
      'id': 'hud',
      'name': 'سيدنا هود عليه السلام',
      'summary': 'أرسل إلى قوم عاد الذين بنوا الأبنية العظيمة، كذبوه فأهلكهم الله بريح صرصر عاتية.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/hud.json',
    },
    {
      'id': 'salih',
      'name': 'سيدنا صالح عليه السلام',
      'summary': 'أرسل إلى قوم ثمود الذين كانوا ينحتون الجبال بيوتاً، أرسل الله لهم الناقة آية فلم يؤمنوا فأهلكهم الله.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/salih.json',
    },
    {
      'id': 'ibrahim',
      'name': 'سيدنا إبراهيم عليه السلام',
      'summary': 'خليل الله، حطم الأصنام، أُلقي في النار فجعلها الله برداً وسلاماً، أمره الله بذبح ابنه إسماعيل ففداه بذبح عظيم، وبنى الكعبة مع ابنه إسماعيل.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/ibrahim.json',
    },
    {
      'id': 'lut',
      'name': 'سيدنا لوط عليه السلام',
      'summary': 'أرسل إلى قوم المؤتفكات الذين ارتكبوا الفاحشة، فلم يؤمنوا فقلب الله عليهم ديارهم وأمطرهم حجارة من سجيل.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/lut.json',
    },
    {
      'id': 'ismail',
      'name': 'سيدنا إسماعيل عليه السلام',
      'summary': 'ابن إبراهيم الأكبر، كان صادق الوعد وأميناً، تركه أبوه مع أمه عند زمزم فجعلها الله مكاناً عظيماً، وأمر الله بذبحه ففدي بكبش عظيم.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/ismail.json',
    },
    {
      'id': 'ishaq',
      'name': 'سيدنا إسحاق عليه السلام',
      'summary': 'ابن إبراهيم من سارة، بشارة الله به لإبراهيم، ومن ذريته جاء يعقوب والأنبياء من بني إسرائيل.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/ishaq.json',
    },
    {
      'id': 'yaqub',
      'name': 'سيدنا يعقوب عليه السلام',
      'summary': 'إسرائيل، ابن إسحاق، أبو يوسف وأخوته، صبر على فراق ابنه يوسف سنين طويلة ثم اجتمع به.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/yaqub.json',
    },
    {
      'id': 'yusuf',
      'name': 'سيدنا يوسف عليه السلام',
      'summary': 'الصدق، رآه أبوه في المنام فأصبح حقيقة، أُلقي في الجب، بيع في مصر، ابتلي بالمرأة العزيزة فصبر، ملك مصر وأبويه وإخوته.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/yusuf.json',
    },
    {
      'id': 'ayyub',
      'name': 'سيدنا أيوب عليه السلام',
      'summary': 'صاحب البلاء العظيم، ابتلي بماله وولده وصحته فصبر صبراً جميلاً، فكشف الله ضره وآتاه أهله ومثلهم معهم.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/ayyub.json',
    },
    {
      'id': 'shuayb',
      'name': 'سيدنا شعيب عليه السلام',
      'summary': 'خطيب الأنبياء، أرسل إلى قوم مدين الذين كانوا يبخسون المكيال والميزان، فكذبوه فأهلكهم الله بعذاب يوم الظلة.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/shuayb.json',
    },
    {
      'id': 'mousa',
      'name': 'سيدنا موسى عليه السلام',
      'summary': 'كليم الله، أرسل إلى فرعون وجنوده، ضرب البحر بعصاه فانفلق، وأنزلت عليه التوراة، وأعطاه الله التسع آيات المبينات.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/mousa.json',
    },
    {
      'id': 'harun',
      'name': 'سيدنا هارون عليه السلام',
      'summary': 'أخو موسى وأمينه، جعله الله نبياً، كان فصيح اللسان مع موسى، شهد معجزات كثيرة.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/harun.json',
    },
    {
      'id': 'dawud',
      'name': 'سيدنا داود عليه السلام',
      'summary': 'ملك من ملوك بني إسرائيل، قتل جالوت، أُنزلت عليه الزبور، كان صوتاً حسناً في التلاوة، سبح الله مع الطير.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/dawud.json',
    },
    {
      'id': 'sulayman',
      'name': 'سيدنا سليمان عليه السلام',
      'summary': 'ابن داود، ملك عظيم، سخر الله له الريح والجن والشياطين، علّمه لغة الطير والنمل، بنى بيت المقدس.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/sulayman.json',
    },
    {
      'id': 'ilyas',
      'name': 'سيدنا إلياس عليه السلام',
      'summary': 'أرسل إلى قومه الذين عبدوا البعل، فكذبوه فدعا عليهم فحبس الله عنهم المطر ثلاث سنين.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/ilyas.json',
    },
    {
      'id': 'al-yasa',
      'name': 'سيدنا اليسع عليه السلام',
      'summary': 'خلف إلياس في النبوة، من الأنبياء الصالحين، آتاه الله معجزات كثيرة.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/al-yasa.json',
    },
    {
      'id': 'yunus',
      'name': 'سيدنا يونس عليه السلام',
      'summary': 'صاحب الحوت، دعا قومه فلم يؤمنوا فتركهم، ركب في سفينة فالتقمه الحوت، نادى في الظلمات فنجاه الله.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/yunus.json',
    },
    {
      'id': 'dhulkifl',
      'name': 'سيدنا ذو الكفل عليه السلام',
      'summary': 'من الأنبياء الصالحين، قيل إنه تكفل بصيام النهار وقيام الليل فسمي ذا الكفل.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/dhulkifl.json',
    },
    {
      'id': 'zakariya',
      'name': 'سيدنا زكريا عليه السلام',
      'summary': 'كفالة مريم، دعا الله أن يرزقه ولداً فاستجاب له ربه وآتاه يحيى في الكبر.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/zakariya.json',
    },
    {
      'id': 'yahya',
      'name': 'سيدنا يحيى عليه السلام',
      'summary': 'ابن زكريا، آتاه الله الحكمة في صغره، كان زاهداً عابداً، بشّر بالمسيح عيسى.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/yahya.json',
    },
    {
      'id': 'issa',
      'name': 'سيدنا عيسى عليه السلام',
      'summary': 'روح الله وكلمته، ولد بدون أب من مريم العذراء، أحيا الموتى بإذن الله، ورفعه الله إليه وسينزل آخر الزمان.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/issa.json',
    },
    {
      'id': 'muhammad',
      'name': 'سيدنا محمد ﷺ',
      'summary': 'خاتم الأنبياء والمرسلين، صاحب الرسالة الخالدة، الرحمة المهداة للعالمين، أسس دولة الإسلام في المدينة، ودخل مكة فاتحاً.',
      'category': 'prophets',
      'source': 'ابن كثير',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/muhammad.json',
    },
  ];

  // قصص القرآن
  final List<Map<String, dynamic>> _quranStories = [
    {
      'id': 'ashab_alfil',
      'name': 'أصحاب الفيل',
      'summary': 'قصة أبرهة الأشرم الذي جاء بجيشه لهدم الكعبة فأهلكه الله بطير أبابيل.',
      'category': 'quran',
      'source': 'تفسير الجلالين',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/ashab_alfil.json',
    },
    {
      'id': 'ashab_alkahf',
      'name': 'أصحاب الكهف',
      'summary': 'فتية آمنوا بربهم فهربوا بدينهم إلى الكهف فلبثوا فيه 309 سنين ثم بعثهم الله.',
      'category': 'quran',
      'source': 'تفسير الجلالين',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/ashab_alkahf.json',
    },
    {
      'id': 'dhulqarnayn',
      'name': 'ذو القرنين',
      'summary': 'الملك الصالح الذي سار في الأرض وساعد الناس وبنى السد العظيم ضد يأجوج ومأجوج.',
      'category': 'quran',
      'source': 'تفسير الجلالين',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/dhulqarnayn.json',
    },
    {
      'id': 'qarun',
      'name': 'قارون',
      'summary': 'الذي آتاه الله من الكنوز ما إن مفاتحه لتنوء بالعصبة، فطغى وبغى فخسف الله به وبداره الأرض.',
      'category': 'quran',
      'source': 'تفسير الجلالين',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/qarun.json',
    },
    {
      'id': 'firawn',
      'name': 'فرعون',
      'summary': 'الطاغية الذي ادعى الألوهية، أباد الله جنوده في البحر، وأغرقه هو وأتوه في الجحيم.',
      'category': 'quran',
      'source': 'تفسير الجلالين',
      'url': 'https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/firawn.json',
    },
  ];

  // أسباب النزول
  final List<Map<String, dynamic>> _asbabNuzul = [
    {
      'id': '1',
      'verse': 'إِنَّا فَتَحْنَا لَكَ فَتْحًا مُّبِينًا',
      'sura': 'الفتح',
      'reason': 'سبب نزول هذه السورة هو صلح الحديبية، حين صالح النبي ﷺ كفار قريش عام 6 هـ.',
      'context': 'نزلت في المدينة بعد أن منع المشركون المسلمين من دخول مكة فاعتمر النبي ﷺ بدلاً منها',
    },
    {
      'id': '2',
      'verse': 'يَا أَيُّهَا النَّبِيُّ جَاهِدِ الْكُفَّارَ وَالْمُنَافِقِينَ',
      'sura': 'التوبة',
      'reason': 'نزلت في المنافقين الذين كانوا يظهرون الإسلام ويبطنون الكفر، ويؤذون المسلمين.',
      'context': 'في المدينة المنورة بعد غزوة تبوك',
    },
    {
      'id': '3',
      'verse': 'لَقَدْ رَضِيَ اللَّهُ عَنِ الْمُؤْمِنِينَ إِذْ يُبَايِعُونَكَ تَحْتَ الشَّجَرَةِ',
      'sura': 'الفتح',
      'reason': 'نزلت في بيعة الرضوان تحت الشجرة في الحديبية، حيث بايع 1400 من المسلمين النبي ﷺ.',
      'context': 'في غزوة الحديبية عام 6 هـ',
    },
  ];

  // إلهام من كتاب "لا تحزن"
  final List<String> _inspirations = [
    '✨ لا تحزن: "إن مع العسر يسراً" - سورة الشرح',
    '💪 قواك في داخلك: "ولا تيأسوا من روح الله" - يوسف 87',
    '🌅 الفجر آتٍ: "فإن مع العسر يسراً، إن مع العسر يسراً"',
    '🎯 رزقك مضمون: "وفي السماء رزقكم وما توعدون" - الذاريات 22',
    '💎 الصبر جوهرة: "إنما يوفى الصابرون أجرهم بغير حساب" - الزمر 10',
    '🛡️ الله نعم الحافظ: "فإني قريب" - البقرة 186',
    '🌟 توكّل: "ومن يتوكل على الله فهو حسبه" - الطلاق 3',
    '📿 اذكر الله: "ألا بذكر الله تطمئن القلوب" - الرعد 28',
  ];

  String _currentHadith = '';
  String _currentHadithMeaning = '';
  String _currentInspiration = '';
  bool _isProEnabled = false;
  int _consecutiveStoryReads = 0;
  String? _lastReadStoryId;

  @override
  void initState() {
    super.initState();
    _showRandomHadith();
  }

  void _showRandomHadith() {
    final random = Random();
    final hadith = _hadithQudsi[random.nextInt(_hadithQudsi.length)];
    final inspiration = _inspirations[random.nextInt(_inspirations.length)];
    setState(() {
      _currentHadith = hadith['text']!;
      _currentHadithMeaning = hadith['meaning']!;
      _currentInspiration = inspiration;
    });
  }

  void _openStoryDetail(Map<String, dynamic> story) {
    // تتبع عدد القراءات المتتالية لنفس القصة
    if (_lastReadStoryId == story['id']) {
      _consecutiveStoryReads++;
      if (_consecutiveStoryReads >= 2) {
        _showInspirationalMessage();
      }
    } else {
      _consecutiveStoryReads = 1;
      _lastReadStoryId = story['id'];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: Text(
          story['name']!,
          style: const TextStyle(color: Colors.cyanAccent),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                story['summary']!,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '📖 المصدر: ${story['source']}',
                  style: const TextStyle(color: Colors.amber, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.volume_up, color: Colors.cyanAccent),
            label: const Text('استمع', style: TextStyle(color: Colors.cyanAccent)),
            onPressed: () {
              Navigator.pop(context);
              context.read<TTSService>().speak(story['summary']!, languageCode: 'ar');
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.share, color: Colors.cyanAccent),
            label: const Text('شارك', style: TextStyle(color: Colors.cyanAccent)),
            onPressed: () {
              Share.share(
                '📚 ${story['name']}\n\n${story['summary']}\n\n— من تطبيق ميرور سكربيون —',
              );
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openMoreLink(story['url']!);
            },
            child: const Text('المزيد...', style: TextStyle(color: Colors.amber)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _openMoreLink(String url) async {
    // فتح الرابط بشكل خفي (يبدو كأنه داخل التطبيق)
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } else {
      _showMessage('الرابط غير متاح حالياً');
    }
  }

  void _showInspirationalMessage() async {
    if (_isProEnabled) {
      // النسخة المدفوعة: تحميل محلي
      _showMessage('💎 Pro: يتم تنزيل القصة محلياً...');
      return;
    }
    // النسخة المجانية: فتح الرابط الخارجي بشكل خفي
    if (_lastReadStoryId != null) {
      final story = _prophetsStories.firstWhere(
        (s) => s['id'] == _lastReadStoryId,
        orElse: () => _prophetsStories[0],
      );
      _openMoreLink(story['url']!);
    }
  }

  void _showAsbabNuzul() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2838),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: const Text(
                    '📜 أسباب النزول',
                    style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _asbabNuzul.length,
                    itemBuilder: (context, index) {
                      final nuzul = _asbabNuzul[index];
                      return Card(
                        color: const Color(0xFF0D1B2A),
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '﴿ ${nuzul['verse']} ﴾',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'سورة: ${nuzul['sura']}',
                                style: const TextStyle(color: Colors.cyanAccent, fontSize: 12),
                              ),
                              const Divider(color: Colors.white24),
                              Text(
                                'السبب:',
                                style: TextStyle(color: Colors.white70.withOpacity(0.8)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                nuzul['reason']!,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'السياق:',
                                style: TextStyle(color: Colors.white70.withOpacity(0.8)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                nuzul['context']!,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _speakCurrent() async {
    final text = '$_currentHadith\n\nالشرح: $_currentHadithMeaning';
    await context.read<TTSService>().speak(text, languageCode: 'ar');
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF1B2838)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('📚 أحاديث وقصص وإلهام', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu, color: Colors.amber),
            tooltip: 'أسباب النزول',
            onPressed: _showAsbabNuzul,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── كارت الحديث الحالي ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B4D8C), Color(0xFF0D2847)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    '✨ حديث قدسي ✨',
                    style: TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentHadith,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.8,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '📖 $_currentHadithMeaning',
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.amber, size: 30),
                        onPressed: _showRandomHadith,
                        tooltip: 'حديث جديد',
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.amber, size: 30),
                        onPressed: _speakCurrent,
                        tooltip: 'استمع',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── إلهام ذكي ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B4513), Color(0xFF5C2E0B)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.amber, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _currentInspiration,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ── قسم القصص ──
            const Text(
              '📖 قصص الأنبياء (25 قصة)',
              style: TextStyle(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._prophetsStories.map((story) => _buildStoryCard(story)),
            const SizedBox(height: 20),
            const Text(
              '📚 قصص القرآن',
              style: TextStyle(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._quranStories.map((story) => _buildStoryCard(story)),
            const SizedBox(height: 30),
            // ── إبداع المستخدم (Pro) ──
            if (_isProEnabled)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Text('✨ إبداع المستخدم', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      'اكتب قصتك الخاصة وسيقوم الذكاء الاصطناعي بتحويلها إلى فيديو',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purpleAccent),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, color: Colors.purpleAccent),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'الإبداع - متاح في النسخة المدفوعة',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
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

  Widget _buildStoryCard(Map<String, dynamic> story) {
    return Card(
      color: const Color(0xFF1B2838),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () => _openStoryDetail(story),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu_book, color: Colors.cyanAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      story['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                story['summary']!,
                style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.6),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'المزيد...',
                    style: TextStyle(color: Colors.amber.withOpacity(0.8), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
