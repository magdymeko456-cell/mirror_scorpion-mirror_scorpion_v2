import 'package:flutter/material.dart';

class WatermarkText extends StatelessWidget {
  final double fontSize;
  final Color? color;
  const WatermarkText({super.key, this.fontSize = 12, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      '🦂 Mirror Scorpion',
      style: TextStyle(fontSize: fontSize, color: color ?? Colors.grey.withOpacity(0.5), fontStyle: FontStyle.italic),
    );
  }
}

class SpeakerButton extends StatelessWidget {
  final String voice;
  final VoidCallback onPressed;
  final double size;
  const SpeakerButton({super.key, required this.voice, required this.onPressed, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: const Icon(Icons.volume_up), tooltip: 'استماع ($voice)', onPressed: onPressed);
  }
}

class MicButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;
  const MicButton({super.key, required this.isListening, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(isListening ? Icons.mic : Icons.mic_none), onPressed: onPressed);
  }
}
