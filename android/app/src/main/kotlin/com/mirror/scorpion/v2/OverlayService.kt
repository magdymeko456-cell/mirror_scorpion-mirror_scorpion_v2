package com.mirror.scorpion.v2
import android.app.Service; import android.content.Intent; import android.graphics.Color; import android.graphics.PixelFormat
import android.os.Build; import android.os.IBinder; import android.view.Gravity; import android.view.MotionEvent; import android.view.WindowManager
import android.widget.FrameLayout; import android.widget.TextView

class OverlayService : Service() {
    private lateinit var wm: WindowManager; private var bv: View? = null; private var vis = false
    private var src = "ar"; private var tgt = "en"
    private var ix = 0; private var iy = 0; private var itx = 0f; private var ity = 0f
    override fun onBind(i: Intent?): IBinder? = null
    override fun onCreate() { super.onCreate(); wm = getSystemService(WINDOW_SERVICE) as WindowManager }
    override fun onStartCommand(i: Intent?, f: Int, si: Int): Int {
        i?.let { src = it.getStringExtra("source_language") ?: "ar"; tgt = it.getStringExtra("target_language") ?: "en"
            when (it.action) { "SHOW" -> if (!vis) show(); "HIDE" -> if (vis) hide(); "TOGGLE" -> if (vis) hide() else show() } }
        return START_STICKY
    }
    private fun show() {
        if (bv != null) return; val p = WindowManager.LayoutParams(180, 180,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE, PixelFormat.TRANSLUCENT)
        p.gravity = Gravity.TOP or Gravity.START; p.x = 50; p.y = 200
        bv = FrameLayout(this).apply {
            setBackgroundColor(Color.argb(200, 0, 188, 212)); alpha = 0.85f
            val tv = TextView(context); tv.text = "🦂"; tv.textSize = 36f; tv.gravity = Gravity.CENTER; tv.setTextColor(Color.WHITE)
            addView(tv, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
            setOnTouchListener { _, e ->
                when (e.action) {
                    MotionEvent.ACTION_DOWN -> { ix = p.x; iy = p.y; itx = e.rawX; ity = e.rawY; true }
                    MotionEvent.ACTION_MOVE -> { p.x = ix + (e.rawX - itx).toInt(); p.y = iy + (e.rawY - ity).toInt(); wm.updateViewLayout(this, p); true }
                    MotionEvent.ACTION_UP -> { val d = (e.rawX - itx)*(e.rawX - itx)+(e.rawY - ity)*(e.rawY - ity)
                        if (d < 100) { val li = packageManager.getLaunchIntentForPackage("com.mirror.scorpion.v2"); if (li != null) startActivity(li) }; true }
                    else -> false } } }
        try { wm.addView(bv, p); vis = true } catch (_: Exception) { bv = null }
    }
    private fun hide() { bv?.let { try { wm.removeView(it) } catch(_: Exception){} }; bv = null; vis = false }
    override fun onDestroy() { hide(); super.onDestroy() }
}
