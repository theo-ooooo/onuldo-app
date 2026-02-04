import 'package:auto_route/auto_route.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/auth_interceptor.dart';
import 'data/repositories/user_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/router/app_router.dart';
import 'shared/theme/app_theme.dart';

class OnuldoApp extends ConsumerStatefulWidget {
  const OnuldoApp({super.key});

  @override
  ConsumerState<OnuldoApp> createState() => _OnuldoAppState();
}

class _OnuldoAppState extends ConsumerState<OnuldoApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 토큰 만료(401 + 재발급 실패) 시 전역 강제 로그아웃 + 로그인 페이지 이동
    AuthInterceptor.onTokenExpired = () async {
      // auth 상태를 unauthenticated로 변경
      await ref.read(authProvider.notifier).logout();

      // 로그인 페이지로 이동 (전체 스택 교체)
      final router = ref.read(routerProvider);
      router.replaceAll([const LoginRoute()]);
    };
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    // 시스템 밝기 변경 감지
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    ref.read(themeProvider.notifier).updateSystemBrightness(brightness);
  }

  Future<void> _updateFcmToken() async {
    try {
      debugPrint('[FCM] Getting token...');
      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('[FCM] Token: $fcmToken');
      if (fcmToken != null) {
        await ref.read(userRepositoryProvider).updateFcmToken(fcmToken);
        debugPrint('[FCM] Token updated successfully');
      }
    } catch (e) {
      debugPrint('[FCM] Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeProvider);

    // auth 상태 변경 감지 (로그인 시 FCM 토큰 업데이트만 처리)
    ref.listen(authProvider, (prev, next) {
      // 로그인 성공 시 FCM 토큰 업데이트
      if (prev?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        _updateFcmToken();
      }
    });

    return MaterialApp.router(
      title: '오늘도',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.resolvedThemeMode,
      routerConfig: router.config(),
    );
  }
}
