import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
class BackgroundService extends ChangeNotifier {
  String _path = '';
  String get path => _path;
  Future<void> pickDocument() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.image);
    if (r != null && r.files.single.path != null) { _path = r.files.single.path!; notifyListeners(); }
  }
  void removeBackground() { _path = ''; notifyListeners(); }
}
