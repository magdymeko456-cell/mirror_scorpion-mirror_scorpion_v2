#!/usr/bin/env bash
set -euo pipefail

cd ~/mirror_scorpion/mirror_scorpion_v2

echo "══════════════════════════════════════════"
echo "  إعادة أيقونة التطبيق الأصلية لـ OverlayService"
echo "══════════════════════════════════════════"

cat > android/app/src/main/kotlin/com/mirror/scorpion/v2/OverlayService.kt << 'KTEOL'
package com.mirror.scorpion.v2

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.core.app.NotificationCompat
import kotlin.math.abs
import kotlin.math.pow
import kotlin.math.sqrt

class OverlayService : Service() {
    private lateinit var windowManager: WindowManager
    private var bubbleView: FrameLayout? = null
    private var expandedView: FrameLayout? = null
    private var isExpanded = false
    private var initialX = 0f
    private var initialY = 0f
    private var lastX = 0f
    private var lastY = 0f
    private var bubbleParams: WindowManager.LayoutParams? = null
    private var expandedParams: WindowManager.LayoutParams? = null

    companion object {
        private const val CHANNEL_ID = "mirror_scorpion_overlay"
        private const val NOTIFICATION_ID = 1001
    }

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        showBubble()
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "فقاعة الترجمة",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "خدمة الفقاعة العائمة للترجمة"
            }
            val manager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        // نستخدم الميبراب الافتراضي الخاص بالتطبيق ليكون متناسقاً
        val iconRes = applicationContext.applicationInfo.icon
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("🦂 Mirror Scorpion")
            .setContentText("فقاعة الترجمة مفعلة")
            .setSmallIcon(if (iconRes != 0) iconRes else android.R.drawable.ic_dialog_info)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setOngoing(true)
            .build()
    }

    private fun showBubble() {
        if (bubbleView != null) return

        val density = resources.displayMetrics.density
        val bubbleSize = (60 * density).toInt()

        val params = WindowManager.LayoutParams().apply {
            type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE
            format = PixelFormat.TRANSLUCENT
            flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
            width = bubbleSize
            height = bubbleSize
            x = 50
            y = 200
            gravity = Gravity.TOP or Gravity.START
        }
        bubbleParams = params

        val bubble = FrameLayout(this).apply {
            val imageView = ImageView(this@OverlayService).apply {
                // سحب أيقونة التطبيق الرسمية والديناميكية لتعود الواجهة مخصصة 100%
                val iconRes = applicationContext.applicationInfo.icon
                setImageResource(if (iconRes != 0) iconRes else android.R.drawable.ic_dialog_info)
                scaleType = ImageView.ScaleType.CENTER_INSIDE
                setPadding(10, 10, 10, 10)
                setBackgroundColor(0xCC2196F3.toInt())
                alpha = 0.9f
            }
            addView(imageView)

            setOnTouchListener { _, event ->
                val p = bubbleParams ?: return@setOnTouchListener false
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = event.rawX
                        initialY = event.rawY
                        lastX = event.rawX
                        lastY = event.rawY
                        true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val dx = event.rawX - lastX
                        val dy = event.rawY - lastY
                        p.x += dx.toInt()
                        p.y += dy.toInt()
                        windowManager.updateViewLayout(this, p)
                        lastX = event.rawX
                        lastY = event.rawY
                        true
                    }
                    MotionEvent.ACTION_UP -> {
                        val distance = sqrt(
                            (event.rawX - initialX).toDouble().pow(2) +
                            (event.rawY - initialY).toDouble().pow(2)
                        )
                        if (distance < 20) {
                            toggleExpanded()
                        }
                        true
                    }
                    else -> false
                }
            }
        }

        windowManager.addView(bubble, params)
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

        val bParams = bubbleParams
        val params = WindowManager.LayoutParams().apply {
            type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else
                WindowManager.LayoutParams.TYPE_PHONE
            format = PixelFormat.TRANSLUCENT
            flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS
            width = w
            height = h
            x = (bParams?.x ?: 50) - 50
            y = (bParams?.y ?: 200) - 50
            gravity = Gravity.TOP or Gravity.START
        }
        expandedParams = params

        val expanded = FrameLayout(this).apply {
            setBackgroundColor(0xE0000000.toInt())

            val textView = TextView(this@OverlayService).apply {
                text = "🦂 Mirror Scorpion\nاضغط للترجمة\nاسحب للتحريك"
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
                            (event.rawX - lastX).toDouble().pow(2) +
                            (event.rawY - lastY).toDouble().pow(2)
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
KTEOL

echo "✅ تم تأصيل وتعديل الأيقونة برمجياً للهوية الرسمية للتطبيق"

git add -A
git commit -m "fix(overlay): استرجاع أيقونة ميرور الرسمية بدلاً من الافتراضية طبقاً للمنهجية المعتمدة" || true
git push origin main

echo "══════════════════════════════════════════"
echo " 🚀 تم الحفظ والرفع بنجاح وفق الطريقة المعتمدة!"
echo "══════════════════════════════════════════"
