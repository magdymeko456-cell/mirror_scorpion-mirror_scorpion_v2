package com.mirror.scorpion.v2;

import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.IBinder;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;

public class OverlayService extends Service {
    private WindowManager wm;
    private View bubble;
    private WindowManager.LayoutParams params;
    private boolean isExpanded = false;

    @Override public IBinder onBind(Intent i) { return null; }

    @Override
    public void onCreate() {
        super.onCreate();
        wm = (WindowManager) getSystemService(WINDOW_SERVICE);
        bubble = LayoutInflater.from(this).inflate(
            getResources().getIdentifier("overlay_layout", "layout", getPackageName()), null);

        int LAYOUT_FLAG = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
            ? WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            : WindowManager.LayoutParams.TYPE_PHONE;

        params = new WindowManager.LayoutParams(
            180, 180, LAYOUT_FLAG,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT);
        params.gravity = Gravity.TOP | Gravity.START;
        params.x = 50; params.y = 200;

        // سحب الفقاعة
        bubble.setOnTouchListener(new View.OnTouchListener() {
            int initialX, initialY;
            float initialTouchX, initialTouchY;
            long touchStartTime;

            @Override
            public boolean onTouch(View v, MotionEvent e) {
                switch (e.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        initialX = params.x;
                        initialY = params.y;
                        initialTouchX = e.getRawX();
                        initialTouchY = e.getRawY();
                        touchStartTime = System.currentTimeMillis();
                        return true;
                    case MotionEvent.ACTION_MOVE:
                        params.x = initialX + (int)(e.getRawX() - initialTouchX);
                        params.y = initialY + (int)(e.getRawY() - initialTouchY);
                        wm.updateViewLayout(bubble, params);
                        return true;
                    case MotionEvent.ACTION_UP:
                        long dt = System.currentTimeMillis() - touchStartTime;
                        if (dt < 300) {
                            // نقرة بسيطة - إرسال intent لـ Flutter
                            Intent intent = new Intent("com.mirror.scorpion.TOGGLE_BUBBLE");
                            sendBroadcast(intent);
                        }
                        return true;
                }
                return false;
            }
        });

        try { wm.addView(bubble, params); } catch (Exception e) { stopSelf(); }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (bubble != null && wm != null) {
            try { wm.removeView(bubble); } catch (Exception ignored) {}
        }
    }
}
