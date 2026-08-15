import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class SpeechToTextPlugin {
    static void registerWith(Registrar registrar) {
        final channel = MethodChannel('speech_to_text', const StandardMethodCodec(), registrar);
        final instance = SpeechToTextPlugin();
        channel.setMethodCallHandler(instance.handleMethodCall);
    }
    
    Future<dynamic> handleMethodCall(MethodCall call) async {
        switch (call.method) {
            case 'initialize': return true;
            case 'listen': return true;
            case 'stop': return true;
            case 'cancel': return true;
            case 'locales': return [];
            default: throw UnimplementedError(call.method);
        }
    }
}
