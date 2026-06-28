import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_service.dart';

class InspirationService {
  static const String _lastInspirationKey = 'last_inspiration_time';
  Timer? _timer;

  Future<bool> canSendInspiration() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTime = prefs.getInt(_lastInspirationKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastTime) > (3 * 60 * 60 * 1000); // 3 ساعات
  }

  Future<void> markInspirationSent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastInspirationKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<String> getDailyInspiration(String? mood) async {
    return await AIService.generateInspiration(userMood: mood);
  }

  void startDailyTimer(Function(String) onInspiration) {
    _timer = Timer.periodic(const Duration(hours: 3), (timer) async {
      if (await canSendInspiration()) {
        final inspiration = await getDailyInspiration(null);
        onInspiration(inspiration);
        await markInspirationSent();
      }
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}
