import 'package:flutter/material.dart';

import '../../../core/utils/duration_formatter.dart';
import '../../../shared/theme/app_theme.dart';

class TimerDisplay extends StatelessWidget {
  final int seconds;
  final Color? color;
  final double fontSize;

  const TimerDisplay({
    super.key,
    required this.seconds,
    this.color,
    this.fontSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayText = DurationFormatter.formatSeconds(seconds);

    return Text(
      displayText,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w200,
        color: color ?? colors.textPrimary,
        letterSpacing: 2,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

class TimerCircle extends StatelessWidget {
  final int seconds;
  final Color? color;
  final double size;

  const TimerCircle({
    super.key,
    required this.seconds,
    this.color,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final circleColor = color ?? colors.textPrimary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: circleColor,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: circleColor.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: TimerDisplay(
          seconds: seconds,
          color: color,
        ),
      ),
    );
  }
}
