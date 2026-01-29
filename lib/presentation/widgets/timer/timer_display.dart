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
    final displayText = DurationFormatter.formatSeconds(seconds);

    return Text(
      displayText,
      style: AppTextStyles.timer.copyWith(
        color: color ?? AppColors.textPrimary,
        fontSize: fontSize,
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color ?? AppColors.primary,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: (color ?? AppColors.primary).withValues(alpha: 0.2),
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
