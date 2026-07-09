package com.mirror.scorpion.v2

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel

class OverlayService : Service() {
    private lateinit var windowManager: WindowManager
    private var overlayView: View? = null
    private var isAdded = false

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "CREATE" -> createOverlay()
            "DESTROY" -> destroyOverlay()
        }
        return START_STICKY
    }

    private fun createOverlay() {
        if (isAdded) return
        val inflater = getSystemService(LAYOUT_INFLATER_SERVICE) as LayoutInflater
        overlayView = inflater.inflate(
            resources.getIdentifier("overlay_bubble", "layout", packageName), null
        )
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.START or Gravity.TOP
        params.x = 0; params.y = 200
        overlayView?.setOnTouchListener(object : View.OnTouchListener {
            private var ix = 0; private var iy = 0
            private var itx = 0f; private var ity = 0f
            override fun onTouch(v: View?, event: MotionEvent?): Boolean {
                when (event?.action) {
                    MotionEvent.ACTION_DOWN -> {
                        ix = params.x; iy = params.y
                        itx = event.rawX; ity = event.rawY; return true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        params.x = ix + (event.rawX - itx).toInt()
                        params.y = iy + (event.rawY - ity).toInt()
                        windowManager.updateViewLayout(overlayView, params); return true
                    }
                    MotionEvent.ACTION_UP -> {
                        if (Math.abs(event.rawX - itx) < 10 && Math.abs(event.rawY - ity) < 10) {
                            val engine = FlutterEngineCache.getInstance().get("mirror_engine")
                            if (engine != null) {
                                MethodChannel(engine.dartExecutor.binaryMessenger, "mirror_scorpion/overlay")
                                    .invokeMethod("onBubbleTapped", null)
                            }
                        }; return true
                    }
                }; return false
            }
        })
        try { windowManager.addView(overlayView, params); isAdded = true }
        catch (e: Exception) { e.printStackTrace() }
    }

    private fun destroyOverlay() {
        overlayView?.let {
            if (isAdded) {
                try { windowManager.removeView(it) } catch (_: Exception) {}
                isAdded = false
            }
        }
    }

    override fun onDestroy() { destroyOverlay(); super.onDestroy() }
}
