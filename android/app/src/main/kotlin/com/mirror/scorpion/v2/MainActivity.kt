package com.mirror.scorpion.v2

import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "mirror_scorpion/overlay"
    private var overlayServiceIntent: Intent? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterEngineCache.getInstance().put("mirror_engine", flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "createFloatingBubble" -> {
                    startOverlayService("CREATE")
                    result.success(true)
                }
                "destroyFloatingBubble" -> {
                    stopOverlayService()
                    result.success(true)
                }
                "hasOverlayPermission" -> {
                    result.success(hasOverlayPermission())
                }
                "requestOverlayPermission" -> {
                    requestOverlayPermission()
                    result.success(true)
                }
                "onBubbleTapped" -> {
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startOverlayService(action: String) {
        if (!hasOverlayPermission()) return
        overlayServiceIntent = Intent(this, OverlayService::class.java).apply { this.action = action }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(overlayServiceIntent!!)
        } else {
            startService(overlayServiceIntent!!)
        }
    }

    private fun stopOverlayService() {
        overlayServiceIntent?.let { stopService(it) }
        overlayServiceIntent = null
    }

    private fun hasOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else true
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !hasOverlayPermission()) {
            val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                android.net.Uri.parse("package:$packageName"))
            startActivityForResult(intent, 1001)
        }
    }
}
