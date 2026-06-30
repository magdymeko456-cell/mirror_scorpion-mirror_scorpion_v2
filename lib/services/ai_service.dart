import 'package:flutter/material.dart';
class AIService extends ChangeNotifier {
  String _lastInspiration = '';
  String get lastInspiration => _lastInspiration;
  final List<String> _msgs = [
    'لا تحزن، إن الله معنا', 'بعد العسر يسراً', 'إن مع العسر يسراً',
    'وما توفيقى إلا بالله', 'رب اشرح لي صدري', 'إن الله لا يضيع أجر المحسنين',
    'ومن يتوكل على الله فهو حسبه', 'لا تيأس من روح الله',
    'ألم نشرح لك صدرك', 'فإذا فرغت فانصب', 'وإلى ربك فارغب',
    'استعن بالله ولا تعجز', 'ما ودعك ربك وما قلى', 'ولسوف يعطيك ربك فترضى',
  ];
  Future<String> generateInspiration({String userMood = '', String context = ''}) async {
    _lastInspiration = _msgs[DateTime.now().millisecondsSinceEpoch % _msgs.length];
    notifyListeners();
    return _lastInspiration;
  }
}
