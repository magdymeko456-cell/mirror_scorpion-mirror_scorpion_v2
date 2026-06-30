package com.mirror.scorpion.v2

import android.app.Service
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.drawable.GradientDrawable
import android.graphics.PorterDuff
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import kotlin.math.pow
import kotlin.math.sqrt

class OverlayService : Service() {
    private lateinit var windowManager: WindowManager
    private var bubbleView: ImageView? = null
    private var bubbleExpanded = false
    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f

    private val COLOR_DARK = Color.rgb(13, 27, 42)
    private val COLOR_DARK2 = Color.rgb(27, 40, 56)
    private val COLOR_CYAN = Color.rgb(0, 188, 212)

    override fun onBind(intent: Intent?): IBinder? = null
    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        createBubble()
    }

    private fun createBubble() {
        val bubbleSize = 140
        val params = WindowManager.LayoutParams(
            bubbleSize, bubbleSize,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else WindowManager.LayoutParams.TYPE_SYSTEM_ALERT,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP or Gravity.START
        params.x = 0; params.y = 300

        val bubble = ImageView(this)
        val bgShape = GradientDrawable(GradientDrawable.Orientation.TL_BR, intArrayOf(COLOR_DARK, COLOR_DARK2))
        bgShape.shape = GradientDrawable.OVAL
        bgShape.setSize(bubbleSize, bubbleSize)
        bgShape.setStroke(3, COLOR_CYAN)
        bubble.background = bgShape
        bubble.setImageResource(android.R.drawable.ic_menu_rotate)
        bubble.scaleType = ImageView.ScaleType.CENTER
        bubble.setColorFilter(COLOR_CYAN, PorterDuff.Mode.SRC_IN)
        bubble.alpha = 0.92f

        bubble.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params.x; initialY = params.y
                    initialTouchX = event.rawX; initialTouchY = event.rawY
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    params.x = initialX + (event.rawX - initialTouchX).toInt()
                    params.y = initialY + (event.rawY - initialTouchY).toInt()
                    windowManager.updateViewLayout(bubble, params)
                    true
                }
                MotionEvent.ACTION_UP -> {
                    val distance = sqrt((event.rawX - initialTouchX).pow(2) + (event.rawY - initialTouchY).pow(2))
                    if (distance < 30f) toggleBubble()
                    val display = windowManager.defaultDisplay
                    val size = android.graphics.Point()
                    display.getSize(size)
                    params.x = if (params.x < size.x / 2) 0 else size.x - bubbleSize
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
        val bubble = bubbleView ?: return
        if (bubbleExpanded) {
            bubble.scaleX = 1.4f; bubble.scaleY = 1.4f; bubble.alpha = 1.0f
            bubble.setColorFilter(Color.WHITE, PorterDuff.Mode.SRC_IN)
        } else {
            bubble.scaleX = 1.0f; bubble.scaleY = 1.0f; bubble.alpha = 0.92f
            bubble.setColorFilter(COLOR_CYAN, PorterDuff.Mode.SRC_IN)
        }
    }

    override fun onDestroy() {
        bubbleView?.let { if (it.isAttachedToWindow) try { windowManager.removeView(it) } catch (_: Exception) {} }
        super.onDestroy()
    }

    companion object {
        fun stop(context: android.content.Context) { context.stopService(Intent(context, OverlayService::class.java)) }
    }
}
