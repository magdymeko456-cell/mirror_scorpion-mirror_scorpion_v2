import 'package:flutter/material.dart';

class BubbleOptions {
  final String bubbleIcon;
  final double distanceToClose;
  final bool enableAnimateToEdge;
  final bool enableClose;
  final double bubbleSize;
  final double opacity;

  BubbleOptions({
    this.bubbleIcon = "launcher_icon",
    this.distanceToClose = 100,
    this.enableAnimateToEdge = true,
    this.enableClose = true,
    this.bubbleSize = 120,
    this.opacity = 0.8,
  });
}

class DashBubble {
  static final DashBubble instance = DashBubble._();
  DashBubble._();

  bool _isStarted = false;

  Future<bool> hasOverlayPermission() async => true;

  Future<bool> requestOverlayPermission() async => true;

  Future<bool> startBubble({
    required BubbleOptions bubbleOptions,
    VoidCallback? onTap,
  }) async {
    _isStarted = true;
    return true;
  }

  Future<bool> stopBubble() async {
    _isStarted = false;
    return true;
  }

  bool get isStarted => _isStarted;
}
