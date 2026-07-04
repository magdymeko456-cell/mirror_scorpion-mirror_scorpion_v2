import Foundation
import Flutter

public class SpeechToTextPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "speech_to_text", binaryMessenger: registrar.messenger())
        let instance = SpeechToTextPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            result(true)
        case "listen", "stop", "cancel":
            result(true)
        case "locales":
            result([])
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
