import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'core/api_config.dart';

class AIService extends ChangeNotifier {
  bool _isLoading = false;
  String _lastResponse = '';
  bool get isLoading => _isLoading;
  String get lastResponse => _lastResponse;

  Future<String> generateResponse(String prompt) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (ApiConfig.googleApiKey.isNotEmpty) {
        final url = Uri.parse('${ApiConfig.geminiUrl}?key=${ApiConfig.googleApiKey}');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [{'parts': [{'text': prompt}]}]
          }),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          _lastResponse = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
          _isLoading = false;
          notifyListeners();
          return _lastResponse;
        }
      }
      // fallback
      _lastResponse = 'عذراً، الخدمة غير متوفرة حالياً';
    } catch (e) {
      _lastResponse = 'حدث خطأ: $e';
    }

    _isLoading = false;
    notifyListeners();
    return _lastResponse;
  }
}
