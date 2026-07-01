package com.mirror.scorpion.v2

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "mirror_scorpion/overlay"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "createFloatingBubble" -> {
                        val sourceLang = call.argument<String>("sourceLanguage") ?: "ar"
                        val targetLang = call.argument<String>("targetLanguage") ?: "en"
                        startService(
                            android.content.Intent(this, OverlayService::class.java).apply {
                                action = "SHOW"
                                putExtra("source_language", sourceLang)
                                putExtra("target_language", targetLang)
                            }
                        )
                        result.success(true)
                    }
                    "destroyFloatingBubble" -> {
                        startService(
                            android.content.Intent(this, OverlayService::class.java).apply {
                                action = "HIDE"
                            }
                        )
                        result.success(true)
                    }
                    "toggleFloatingBubble" -> {
                        startService(
                            android.content.Intent(this, OverlayService::class.java).apply {
                                action = "TOGGLE"
                            }
                        )
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
