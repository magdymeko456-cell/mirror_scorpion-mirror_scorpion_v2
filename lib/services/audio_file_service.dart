import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class AudioFileService extends ChangeNotifier {
  static final AudioFileService _instance = AudioFileService._internal();
  factory AudioFileService() => _instance;
  AudioFileService._internal();

  Future<String?> pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg', 'aac'],
    );
    if (result != null && result.files.single.path != null) {
      return result.files.single.path;
    }
    return null;
  }

  Future<String?> extractTextFromAudio(String audioPath) async {
    // في النسخة العادية، نعيد نصاً تجريبياً
    await Future.delayed(const Duration(seconds: 2));
    return "هذا نص تجريبي مستخرج من الملف الصوتي - ميرور سكربيون";
  }
}
