import 'package:flutter/material.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 24),
                _buildAppLogo(),
                const SizedBox(height: 24),
                _buildAppTitle(),
                const SizedBox(height: 32),
                _buildAboutSection(),
                const SizedBox(height: 32),
                _buildDedicationSection(),
                const SizedBox(height: 32),
                _buildFeaturesList(),
                const SizedBox(height: 32),
                _buildContactSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'عن التطبيق',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.purple.shade600],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.language,
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return Column(
      children: [
        const Text(
          'ميرور سكربيون',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Mirror Scorpion Translate',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.withOpacity(0.5)),
          ),
          child: const Text(
            'الإصدار 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نبذة عن التطبيق',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'ميرور سكربيون: حيث تُصنع البدايات\n\n'
              'الوقت هو العملة الأغلى التي مُنحت للإنسان. هنا، نحن لا نقيس أعمارنا بالسنوات، بل بكل ثانية نصنع فيها إنجازاً حقيقياً.\n\n'
              'هنا ستكتشف أن كل انكسار مررت به لم يكن إلا تمهيداً لانطلاقة أعظم؛ فالماضي ليس للمحو، بل للتعلّم، والمستقبل هو ما يستحق انتباهك الآن.\n\n'
              'تذكّر دائماً.. قصتك لا تزال تُكتب، والنهاية لم يحن وقتها بعد.',
              style: TextStyle(
                fontSize: 14,
                height: 1.8,
                color: Colors.white,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDedicationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink.withOpacity(0.1),
              Colors.red.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'كلمة إهداء',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '''أهدي هذا التطبيق إلى كل من أثر في حياتي من الأحباء...

إلى كل من ساندني وآمن برؤيتي
إلى كل من وقف بجانبي في أصعب اللحظات
إلى كل من علمني معنى الحب والعطاء
إلى كل من كان سبباً في ابتسامتي

أنتم الإلهام الذي يدفعني للأمام، وأنتم السبب في كل إنجاز أحققه.

شكراً لكم من قلب امتلأ بالحب والامتنان.

🌟 هذا العمل ثمرة محبتكم وتشجيعكم 🌟''',
              style: TextStyle(
                fontSize: 14,
                height: 1.8,
                color: Colors.white.withOpacity(0.9),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.translate, 'title': 'ترجمة ذكية', 'desc': 'ترجمة فورية بدقة عالية'},
      {'icon': Icons.image, 'title': 'مسح المستندات', 'desc': 'عدسة ذكية لمسح الصور'},
      {'icon': Icons.games, 'title': 'ألعاب تعليمية', 'desc': 'شطرنج وروبيك احترافي'},
      {'icon': Icons.bubble_chart, 'title': 'فقاعة عائمة', 'desc': 'ترجمة سريعة فوق التطبيقات'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الميزات الرئيسية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      color: Colors.blue.shade300,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['title'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['desc'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'معلومات التطبيق',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('المطور', 'Tamer Eldosoky'),
            const SizedBox(height: 12),
            _buildInfoRow('الإصدار', 'v1.0.0'),
            const SizedBox(height: 12),
            _buildInfoRow('الترخيص', 'Mirror Scorpion © 2026'),
            const SizedBox(height: 12),
            _buildInfoRow('الحقوق', 'جميع الحقوق محفوظة'),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'حيث تُصنع البدايات ✨',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.amber.shade300,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
