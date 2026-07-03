import 'package:flutter/foundation.dart';

class PremiumService extends ChangeNotifier {
  bool _isPremium = true;

  bool get isPremium => _isPremium;

  void setPremium(bool v) {
    _isPremium = v;
    notifyListeners();
  }
}
