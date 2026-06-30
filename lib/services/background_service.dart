import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class BackgroundService extends ChangeNotifier {
  String _backgroundPath = '';
  String get backgroundPath => _backgroundPath;

  Future<void> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        _backgroundPath = result.files.single.path!;
        notifyListeners();
      }
    } catch (_) {}
  }

  void removeBackground() {
    _backgroundPath = '';
    notifyListeners();
  }
}
