import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../presentation/providers/timer_provider.dart';

class TimerControls extends StatelessWidget {
  final LocalTimerStatus status;
  final VoidCallback? onStart;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onStop;
  final bool isLoading;
  final bool canStart;

  const TimerControls({
    super.key,
    required this.status,
    this.onStart,
    this.onPause,
    this.onResume,
    this.onStop,
    this.isLoading = false,
    this.canStart = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (status == LocalTimerStatus.idle) ...[
          _buildCircleButton(
            icon: Icons.play_arrow,
            color: colors.timerRunning,
            onPressed: canStart && !isLoading ? onStart : null,
            size: 72,
          ),
        ] else ...[
          if (status == LocalTimerStatus.running)
            _buildCircleButton(
              icon: Icons.pause,
              color: colors.timerPaused,
              onPressed: !isLoading ? onPause : null,
              size: 72,
            )
          else
            _buildCircleButton(
              icon: Icons.play_arrow,
              color: colors.timerRunning,
              onPressed: !isLoading ? onResume : null,
              size: 72,
            ),
          const SizedBox(width: 32),
          _buildCircleButton(
            icon: Icons.stop,
            color: colors.error,
            onPressed: !isLoading ? onStop : null,
            size: 56,
          ),
        ],
      ],
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    required double size,
  }) {
    return Material(
      color: onPressed != null ? color : color.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      elevation: onPressed != null ? 4 : 0,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: Colors.white,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
