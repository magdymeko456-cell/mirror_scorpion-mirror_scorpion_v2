package com.mirror.scorpion.v2

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.MotionEvent
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView
import kotlin.math.sqrt
import kotlin.math.pow

class OverlayService : Service() {
    
    private lateinit var windowManager: WindowManager
    private var bubbleView: View? = null
    private var expandedView: View? = null
    private var bubbleParams: WindowManager.LayoutParams? = null
    private var expandedParams: WindowManager.LayoutParams? = null
    
    private var isExpanded = false
    private var lastX = 0f
    private var lastY = 0f
    private var initialX = 0
    private var initialY = 0
    
    override fun onBind(intent: Intent?): IBinder? = null
    
    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        createBubble()
    }
    
    private fun createBubble() {
        val density = resources.displayMetrics.density
        val size = (60 * density).toInt()
        
        bubbleParams = WindowManager.LayoutParams(
            size, size,
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
                val lp = bubbleParams ?: return@setOnTouchListener false
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = lp.x
                        initialY = lp.y
                        lastX = event.rawX
                        lastY = event.rawY
                        true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        lp.x = initialX + (event.rawX - lastX).toInt()
                        lp.y = initialY + (event.rawY - lastY).toInt()
                        windowManager.updateViewLayout(this, lp)
                        true
                    }
                    MotionEvent.ACTION_UP -> {
                        val distance = sqrt(
                            ((event.rawX - lastX).toDouble()).pow(2) +
                            ((event.rawY - lastY).toDouble()).pow(2)
                        )
                        if (distance < 20) toggleExpanded()
                        true
                    }
                    else -> false
                }
                true
            }
        }
        
        windowManager.addView(bubble, bubbleParams!!)
        bubbleView = bubble
    }
    
    private fun toggleExpanded() {
        if (isExpanded) hideExpanded()
        else showExpanded()
    }
    
    private fun showExpanded() {
        if (expandedView != null) return
        val density = resources.displayMetrics.density
        val w = (300 * density).toInt()
        val h = (200 * density).toInt()
        
        val params = WindowManager.LayoutParams(
            w, h,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        ).apply {
            x = (bubbleParams?.x ?: 50) - 50
            y = (bubbleParams?.y ?: 200) - 50
            gravity = Gravity.TOP or Gravity.START
        }
        expandedParams = params
        
        val expanded = FrameLayout(this).apply {
            setBackgroundColor(0xE0000000.toInt())
            
            val textView = TextView(this@OverlayService).apply {
                text = "\uD83E\uDD82 Mirror Scorpion\nاضغط للترجمة\nاسحب للتحريك"
                textSize = 16f
                setTextColor(android.graphics.Color.WHITE)
                gravity = Gravity.CENTER
            }
            addView(textView)
            
            setOnTouchListener { _, event ->
                val lp = expandedParams ?: return@setOnTouchListener false
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        lastX = event.rawX
                        lastY = event.rawY
                        true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val dx = event.rawX - lastX
                        val dy = event.rawY - lastY
                        lp.x += dx.toInt()
                        lp.y += dy.toInt()
                        windowManager.updateViewLayout(this, lp)
                        lastX = event.rawX
                        lastY = event.rawY
                        true
                    }
                    MotionEvent.ACTION_UP -> {
                        val distance = sqrt(
                            ((event.rawX - lastX).toDouble()).pow(2) +
                            ((event.rawY - lastY).toDouble()).pow(2)
                        )
                        if (distance < 10) hideExpanded()
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
        expandedView?.let { windowManager.removeView(it) }
        expandedView = null
        isExpanded = false
    }
    
    override fun onDestroy() {
        hideExpanded()
        bubbleView?.let { windowManager.removeView(it) }
        bubbleView = null
        super.onDestroy()
    }
}
