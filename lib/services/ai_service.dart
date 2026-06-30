import 'package:flutter/material.dart';

class AIService extends ChangeNotifier {
  String _lastInspiration = '';
  DateTime _lastSentTime = DateTime.now().subtract(const Duration(hours: 3));

  final List<String> _inspirations = [
    "لا تحزن، إن الله معنا",
    "بعد العسر يسراً",
    "إن مع العسر يسراً",
    "فإن مع العسر يسراً",
    "وما توفيقى إلا بالله",
    "رب اشرح لي صدري ويسر لي أمري",
    "إن الله لا يضيع أجر المحسنين",
    "ومن يتوكل على الله فهو حسبه",
    "لا تيأس من روح الله",
    "إن رحمة الله قريب من المحسنين",
    "استعن بالله ولا تعجز",
    "ما ودعك ربك وما قلى",
    "ولسوف يعطيك ربك فترضى",
    "ألم يجدك يتيماً فآوى",
    "ألم نشرح لك صدرك",
    "ووضعنا عنك وزرك",
    "فإذا فرغت فانصب",
    "وإلى ربك فارغب",
  ];

  String get lastInspiration => _lastInspiration;
  DateTime get lastSentTime => _lastSentTime;

  Future<String> generateInspiration({String userMood = '', String context = ''}) async {
    // اختيار رسالة عشوائية
    final random = DateTime.now().millisecondsSinceEpoch % _inspirations.length;
    _lastInspiration = _inspirations[random];
    _lastSentTime = DateTime.now();
    notifyListeners();
    return _lastInspiration;
  }

  bool canSendInspiration() {
    return DateTime.now().difference(_lastSentTime).inHours >= 3;
  }
}
