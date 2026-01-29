import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 500));
    ref.read(authProvider.notifier).checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.timer_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '오늘도',
              style: AppTextStyles.h1.copyWith(
                color: Colors.white,
                fontSize: 36,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '취미 활동을 기록하세요',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
