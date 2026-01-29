import 'package:flutter/material.dart';

import '../../../shared/theme/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const LoadingIndicator({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: color ?? AppColors.primary,
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: LoadingIndicator(size: 48),
            ),
          ),
      ],
    );
  }
}

class FullScreenLoading extends StatelessWidget {
  final String? message;

  const FullScreenLoading({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingIndicator(size: 48),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
