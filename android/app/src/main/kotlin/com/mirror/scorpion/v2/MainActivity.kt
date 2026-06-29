package com.mirror.scorpion.v2

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "mirror_scorpion/overlay"
    private val OVERLAY_PERMISSION_REQUEST = 1001

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasOverlayPermission" -> {
                    result.success(hasOverlayPermission())
                }
                "requestOverlayPermission" -> {
                    if (!hasOverlayPermission()) {
                        requestOverlayPermission()
                    }
                    result.success(true)
                }
                "createFloatingBubble" -> {
                    if (hasOverlayPermission()) {
                        startOverlayService(call.arguments as? Map<String, Any>)
                        result.success(true)
                    } else {
                        requestOverlayPermission()
                        result.success(false)
                    }
                }
                "destroyFloatingBubble" -> {
                    stopOverlayService()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasOverlayPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(this)
        } else true
    }

    private fun requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val intent = Intent(
                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                Uri.parse("package:$packageName")
            )
            startActivityForResult(intent, OVERLAY_PERMISSION_REQUEST)
        }
    }

    private fun startOverlayService(params: Map<String, Any>?) {
        val intent = Intent(this, OverlayService::class.java).apply {
            params?.forEach { (key, value) ->
                putExtra(key, value.toString())
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
        Toast.makeText(this, "🦂 فقاعة الترجمة مفعلة", Toast.LENGTH_SHORT).show()
    }

    private fun stopOverlayService() {
        val intent = Intent(this, OverlayService::class.java)
        stopService(intent)
        Toast.makeText(this, "🦂 فقاعة الترجمة متوقفة", Toast.LENGTH_SHORT).show()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == OVERLAY_PERMISSION_REQUEST) {
            if (hasOverlayPermission()) {
                Toast.makeText(this, "✅ تم منح الإذن بنجاح", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this, "❌ يرجى منح إذن الفقاعة العائمة", Toast.LENGTH_LONG).show()
            }
        }
    }
}
