package com.mirror.scorpion.v2

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import kotlin.math.pow

class OverlayService : Service() {
    private lateinit var windowManager: WindowManager
    private var bubbleView: View? = null
    private var bubbleExpanded = false
    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        createBubble()
    }

    private fun createBubble() {
        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_SYSTEM_ALERT,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP or Gravity.START
        params.x = 0
        params.y = 300

        // Create bubble view
        val bubble = ImageView(this)
        bubble.setImageResource(android.R.drawable.ic_menu_translate)
        bubble.setBackgroundResource(android.R.drawable.ic_menu_compass)
        bubble.alpha = 0.85f
        bubble.scaleX = 0.8f
        bubble.scaleY = 0.8f

        // Make the bubble circular
        val shape = GradientDrawable()
        shape.shape = GradientDrawable.OVAL
        shape.setSize(120, 120)
        shape.setColor(0xFF0D1B2A.toInt())
        shape.setStroke(3, 0xFF00BCD4.toInt())
        bubble.background = shape

        bubble.setOnTouchListener { _, event ->
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
                    windowManager.updateViewLayout(bubble, params)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    val dx = event.rawX - initialTouchX
                    val dy = event.rawY - initialTouchY
                    val distance = (dx.pow(2) + dy.pow(2)).toDouble().let { kotlin.math.sqrt(it) }
                    if (distance < 30) {
                        // Click
                        toggleBubble()
                    }
                    // Snap to edge
                    val display = windowManager.defaultDisplay
                    val size = android.graphics.Point()
                    display.getSize(size)
                    params.x = if (params.x < size.x / 2) 0 else size.x - 150
                    windowManager.updateViewLayout(bubble, params)
                    true
                }
                else -> false
            }
        }

        bubbleView = bubble
        windowManager.addView(bubble, params)
    }

    private fun toggleBubble() {
        bubbleExpanded = !bubbleExpanded
        val bubble = bubbleView as? ImageView ?: return

        if (bubbleExpanded) {
            bubble.scaleX = 1.2f
            bubble.scaleY = 1.2f
            bubble.alpha = 1.0f
        } else {
            bubble.scaleX = 0.8f
            bubble.scaleY = 0.8f
            bubble.alpha = 0.85f
        }
    }

    override fun onDestroy() {
        bubbleView?.let { if (it.isAttachedToWindow) windowManager.removeView(it) }
        super.onDestroy()
    }

    companion object {
        fun stop(context: android.content.Context) {
            context.stopService(Intent(context, OverlayService::class.java))
        }
    }
}
