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
import android.widget.FrameLayout
import android.widget.TextView
import kotlin.math.sqrt

class OverlayService : Service() {

    private lateinit var windowManager: WindowManager
    private var bubbleView: View? = null
    private var expandedView: View? = null
    private var bubbleParams: WindowManager.LayoutParams? = null
    private var expandedParams: WindowManager.LayoutParams? = null

    private var isExpanded = false
    private var initialX = 0
    private var initialY = 0
    private var lastTouchX = 0f
    private var lastTouchY = 0f

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        createFloatingBubble()
    }

    private fun createFloatingBubble() {
        val density = resources.displayMetrics.density
        val bubbleSize = (60 * density).toInt()

        bubbleParams = WindowManager.LayoutParams(
            bubbleSize, bubbleSize,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 50
            y = 200
        }

        val bubble = FrameLayout(this).apply {
            setBackgroundResource(android.R.drawable.ic_dialog_info)

            setOnTouchListener { _, event ->
                val params = bubbleParams ?: return@setOnTouchListener false
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = params.x
                        initialY = params.y
                        lastTouchX = event.rawX
                        lastTouchY = event.rawY
                        true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        params.x = initialX + (event.rawX - lastTouchX).toInt()
                        params.y = initialY + (event.rawY - lastTouchY).toInt()
                        windowManager.updateViewLayout(this, params)
                        true
                    }
                    MotionEvent.ACTION_UP -> {
                        val dx = event.rawX - lastTouchX
                        val dy = event.rawY - lastTouchY
                        val distance = sqrt((dx * dx + dy * dy).toDouble())
                        if (distance < 20.0) {
                            toggleExpanded()
                        }
                        true
                    }
                    else -> false
                }
            }
        }

        windowManager.addView(bubble, bubbleParams!!)
        bubbleView = bubble
    }

    private fun toggleExpanded() {
        if (isExpanded) {
            hideExpanded()
        } else {
            showExpanded()
        }
    }

    private fun showExpanded() {
        if (expandedView != null) return

        val density = resources.displayMetrics.density
        val panelWidth = (300 * density).toInt()
        val panelHeight = (200 * density).toInt()

        val params = WindowManager.LayoutParams(
            panelWidth, panelHeight,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = (bubbleParams?.x ?: 50) - 50
            y = (bubbleParams?.y ?: 200) - 50
        }
        expandedParams = params

        val expanded = FrameLayout(this).apply {
            setBackgroundColor(0xE0000000.toInt())

            val textView = TextView(this@OverlayService).apply {
                text = "\uD83E\uDD82 Mirror Scorpion\nاضغط للترجمة\nاسحب للإخفاء"
                textSize = 16f
                setTextColor(android.graphics.Color.WHITE)
                gravity = Gravity.CENTER
            }
            addView(textView)

            setOnTouchListener { _, event ->
                val lp = expandedParams ?: return@setOnTouchListener false
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = lp.x
                        initialY = lp.y
                        lastTouchX = event.rawX
                        lastTouchY = event.rawY
                        true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        lp.x = initialX + (event.rawX - lastTouchX).toInt()
                        lp.y = initialY + (event.rawY - lastTouchY).toInt()
                        windowManager.updateViewLayout(this, lp)
                        true
                    }
                    MotionEvent.ACTION_UP -> {
                        val dx = event.rawX - lastTouchX
                        val dy = event.rawY - lastTouchY
                        val distance = sqrt((dx * dx + dy * dy).toDouble())
                        if (distance < 10.0) {
                            hideExpanded()
                        }
                        true
                    }
                    else -> false
                }
            }
        }

        windowManager.addView(expanded, params)
        expandedView = expanded
        isExpanded = true
    }

    private fun hideExpanded() {
        val view = expandedView
        if (view != null) {
            windowManager.removeView(view)
        }
        expandedView = null
        isExpanded = false
    }

    override fun onDestroy() {
        hideExpanded()
        val view = bubbleView
        if (view != null) {
            windowManager.removeView(view)
        }
        bubbleView = null
        super.onDestroy()
    }
}
