package com.mirror.scorpion.v2

import android.app.Service
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView

class OverlayService : Service() {
    private lateinit var wm: WindowManager
    private var bubbleView: View? = null
    private var isVisible = false
    private var sourceLang = "ar"
    private var targetLang = "en"
    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        wm = getSystemService(WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent != null) {
            sourceLang = intent.getStringExtra("source_language") ?: "ar"
            targetLang = intent.getStringExtra("target_language") ?: "en"
            when (intent.action) {
                "SHOW" -> if (!isVisible) showBubble()
                "HIDE" -> if (isVisible) hideBubble()
                "TOGGLE" -> if (isVisible) hideBubble() else showBubble()
            }
        }
        return START_STICKY
    }

    private fun showBubble() {
        if (bubbleView != null) return

        val params = WindowManager.LayoutParams(
            180, 180,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP or Gravity.START
        params.x = 50
        params.y = 200

        bubbleView = FrameLayout(this).apply {
            setBackgroundColor(Color.argb(200, 0, 188, 212))
            alpha = 0.85f

            val textView = TextView(context)
            textView.text = "🦂"
            textView.textSize = 36f
            textView.gravity = Gravity.CENTER
            textView.setTextColor(Color.WHITE)
            addView(textView, FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            ))

            setOnTouchListener { _, event ->
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = params.x
                        initialY = params.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        params.x = initialX + (event.rawX - initialTouchX).toInt()
                        params.y = initialY + (event.rawY - initialTouchY).toInt()
                        wm.updateViewLayout(this, params)
                        true
                    }
                    MotionEvent.ACTION_UP -> {
                        val dx = event.rawX - initialTouchX
                        val dy = event.rawY - initialTouchY
                        val distance = dx * dx + dy * dy
                        if (distance < 100f) {
                            val launchIntent = packageManager.getLaunchIntentForPackage("com.mirror.scorpion.v2")
                            if (launchIntent != null) {
                                startActivity(launchIntent)
                            }
                        }
                        true
                    }
                    else -> false
                }
            }
        }

        try {
            wm.addView(bubbleView, params)
            isVisible = true
        } catch (e: Exception) {
            bubbleView = null
        }
    }

    private fun hideBubble() {
        bubbleView?.let {
            try {
                wm.removeView(it)
            } catch (_: Exception) { }
        }
        bubbleView = null
        isVisible = false
    }

    override fun onDestroy() {
        hideBubble()
        super.onDestroy()
    }
}
