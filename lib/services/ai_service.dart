import 'dart:math';
import 'package:flutter/material.dart';

class AIService extends ChangeNotifier {
  String _lastInspiration = '';
  String _lastUserMood = '';
  int _lastTriggeredHour = -1;

  String get lastInspiration => _lastInspiration;

  final List<String> _comfortMessages = [
    '﴿ إِنَّ مَعَ الْعُسْرِ يُسْرًا ﴾',
    '﴿ وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ ﴾',
    '﴿ رَبِّ اشْرَحْ لِي صَدْرِي ﴾',
    '﴿ إِنَّ اللَّهَ لَا يُضَيِّعُ أَجْرَ الْمُحْسِنِينَ ﴾',
    '﴿ وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ ﴾',
    '﴿ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ﴾',
    '﴿ أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ ﴾',
    '﴿ فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ﴾',
    '﴿ مَّا وَدَّعَكَ رَبُّكَ وَمَا قَلَى ﴾',
    '﴿ وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ ﴾',
  ];

  final List<String> _joyMessages = [
    '﴿ وَأَمَّا بِنِعْمَةِ رَبِّكَ فَحَدِّثْ ﴾',
    '﴿ قُلْ بِفَضْلِ اللَّهِ وَبِرَحْمَتِهِ فَبِذَٰلِكَ فَلْيَفْرَحُوا ﴾',
    'الحمد لله الذي بنعمته تتم الصالحات',
    'اللهم لك الحمد كما ينبغي لجلال وجهك وعظيم سلطانك',
    '﴿ رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ ﴾',
  ];

  final List<String> _encouragementMessages = [
    '﴿ إِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ مَنْ أَحْسَنَ عَمَلًا ﴾',
    'استعن بالله ولا تعجز',
    '﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾',
    '﴿ فَإِذَا فَرَغْتَ فَانصَبْ ﴾',
    '﴿ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ﴾',
  ];

  Future<String> generateInspiration({String userMood = '', String context = ''}) async {
    _lastUserMood = userMood;
    List<String> pool;
    if (userMood.contains('حزين') || userMood.contains('تعب') || userMood.contains('ضيق')) {
      pool = _comfortMessages;
    } else if (userMood.contains('فرح') || userMood.contains('سعيد') || userMood.contains('نجاح')) {
      pool = _joyMessages;
    } else {
      pool = [..._comfortMessages, ..._encouragementMessages];
    }
    _lastInspiration = pool[Random().nextInt(pool.length)];
    notifyListeners();
    return _lastInspiration;
  }

  String getDailyInspiration() {
    final all = [..._comfortMessages, ..._joyMessages, ..._encouragementMessages];
    _lastInspiration = all[DateTime.now().day % all.length];
    return _lastInspiration;
  }

  Future<String?> generateNotificationMessage() async {
    if (_lastTriggeredHour == DateTime.now().hour) return null;
    _lastTriggeredHour = DateTime.now().hour;
    if (DateTime.now().hour % 3 == 0) {
      final all = [..._comfortMessages, ..._joyMessages, ..._encouragementMessages];
      return all[Random().nextInt(all.length)];
    }
    return null;
  }

  /// تحليل القصص الأكثر قراءة لإرسال إلهام مخصص
  Future<String> analyzeUserInterest(List<String> recentStoryTitles) async {
    if (recentStoryTitles.isEmpty) return getDailyInspiration();
    // تحليل بسيط: آخر قصة مقروءة
    return '📖 تأمل في قصة "${recentStoryTitles.last}" - فيها عبرة وعظة';
  }
}
