package com.mirror.scorpion.v2;

import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.graphics.Color;
import android.os.IBinder;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;

public class OverlayService extends Service {
    private WindowManager windowManager;
    private ImageView bubbleView;
    private WindowManager.LayoutParams params;
    private int initialX, initialY;
    private float initialTouchX, initialTouchY;

    @Override
    public IBinder onBind(Intent intent) { return null; }

    @Override
    public void onCreate() {
        super.onCreate();
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        bubbleView = new ImageView(this);
        bubbleView.setImageResource(android.R.drawable.ic_dialog_info);
        bubbleView.setBackgroundColor(Color.argb(180, 13, 27, 42));
        bubbleView.setPadding(10, 10, 10, 10);

        params = new WindowManager.LayoutParams(
            120, 120,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        );
        params.gravity = Gravity.TOP | Gravity.START;
        params.x = 0;
        params.y = 200;

        bubbleView.setOnTouchListener((view, event) -> {
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    initialX = params.x;
                    initialY = params.y;
                    initialTouchX = event.getRawX();
                    initialTouchY = event.getRawY();
                    return true;
                case MotionEvent.ACTION_MOVE:
                    params.x = initialX + (int) (event.getRawX() - initialTouchX);
                    params.y = initialY + (int) (event.getRawY() - initialTouchY);
                    windowManager.updateViewLayout(view, params);
                    return true;
                case MotionEvent.ACTION_UP:
                    if (Math.abs(event.getRawX() - initialTouchX) < 10 &&
                        Math.abs(event.getRawY() - initialTouchY) < 10) {
                        // إرسال إشارة إلى Flutter عند الضغط
                        Intent intent = new Intent("com.mirror.scorpion.v2.BUBBLE_CLICK");
                        sendBroadcast(intent);
                    }
                    return true;
            }
            return false;
        });

        try {
            windowManager.addView(bubbleView, params);
        } catch (Exception e) {
            // silent
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (bubbleView != null) {
            try { windowManager.removeView(bubbleView); } catch (Exception e) {}
        }
    }
}
