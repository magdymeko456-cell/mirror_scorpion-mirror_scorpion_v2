package com.mirror.scorpion.v2;

import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.mirror.scorpion.v2/overlay";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("isOverlayGranted")) {
                    result.success(android.provider.Settings.canDrawOverlays(this));
                } else if (call.method.equals("requestOverlay")) {
                    if (!android.provider.Settings.canDrawOverlays(this)) {
                        startActivity(new android.content.Intent(
                            android.provider.Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            android.net.Uri.parse("package:" + getPackageName())
                        ));
                    }
                    result.success(true);
                } else {
                    result.notImplemented();
                }
            });
    }
}
