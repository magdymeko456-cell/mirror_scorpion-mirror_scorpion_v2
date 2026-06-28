// R Bridge - حل مشكلة R class في التشفير
// Author: Tamer Eldosoky - Mirror Scorpion Team

import 'package:flutter/foundation.dart';

Map<String, dynamic> _rVars = {};

void initializeRVariables() {
  _rVars = {
    'layout_activity_main': 'com.tetocollctionway.mirror.R\$layout.activity_main',
    'drawable_ic_launcher': 'com.tetocollctionway.mirror.R\$drawable.ic_launcher',
    'bubble_icon': 'com.tetocollctionway.mirror.R\$drawable.bubble_icon',
    'ic_notification': 'com.tetocollctionway.mirror.R\$drawable.ic_notification',
  };
  debugPrint('✅ R Bridge initialized successfully');
}

dynamic getRVariable(String key) {
  return _rVars[key];
}

int? getResourceId(String type, String name) {
  try {
    final className = 'com.tetocollctionway.mirror.R\$$type';
    final cls = Class.forName(className);
    final field = cls.getDeclaredField(name);
    return field.getInt(null);
  } catch (e) {
    debugPrint('⚠ R Bridge: Cannot find $type.$name - $e');
    return null;
  }
}
