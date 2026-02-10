import 'dart:io';

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
  String? _previousRouteName;
  bool _permissionRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 토큰 만료(401 + 재발급 실패) 시 전역 강제 로그아웃
    // 실제 로그인 페이지 이동은 ref.listen에서 처리
    AuthInterceptor.onTokenExpired = () async {
      debugPrint('[App] onTokenExpired called, logging out...');
      // auth 상태를 unauthenticated로 변경
      await ref.read(authProvider.notifier).logout();
      debugPrint('[App] Logout completed');
    };

    // iOS에서 푸시 알림 권한 요청
    if (Platform.isIOS) {
      _requestNotificationPermission();
    }
  }

  Future<void> _requestNotificationPermission() async {
    if (_permissionRequested) return;
    _permissionRequested = true;

    try {
      debugPrint('[FCM] Requesting notification permission...');
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('[FCM] Notification permission granted');
      } else {
        debugPrint('[FCM] Notification permission denied');
      }
    } catch (e) {
      debugPrint('[FCM] Error requesting permission: $e');
    }
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
      
      // iOS에서는 권한이 필요합니다
      if (Platform.isIOS && !_permissionRequested) {
        await _requestNotificationPermission();
      }
      
      // Firebase Messaging이 자동으로 APNS 토큰을 처리합니다
      // getToken()을 호출하면 자동으로 APNS 토큰이 준비될 때까지 기다립니다
      final fcmToken = await FirebaseMessaging.instance.getToken();
      debugPrint('[FCM] Token: $fcmToken');
      
      if (fcmToken != null) {
        await ref.read(userRepositoryProvider).updateFcmToken(fcmToken);
        debugPrint('[FCM] Token updated successfully');
      } else {
        debugPrint('[FCM] FCM token is null');
      }
    } catch (e) {
      debugPrint('[FCM] Error: $e');
      // iOS에서 APNS 토큰이 아직 준비되지 않은 경우, 잠시 후 재시도
      if (Platform.isIOS && e.toString().contains('apns-token-not-set')) {
        debugPrint('[FCM] APNS token not ready yet, will retry later...');
        // 나중에 재시도 (예: 5초 후)
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            _updateFcmToken();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeProvider);

    // auth 상태 변경 감지
    ref.listen(authProvider, (prev, next) {
      // 로그인 성공 시 FCM 토큰 업데이트
      if (prev?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated) {
        _updateFcmToken();
      }
      
      // 로그아웃 또는 인증 실패 시 로그인 페이지로 이동
      if (next.status == AuthStatus.unauthenticated &&
          prev?.status != AuthStatus.unauthenticated) {
        debugPrint('[App] Auth status changed to unauthenticated, navigating to login...');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final router = ref.read(routerProvider);
          if (router.current.name != 'LoginRoute') {
            router.replaceAll([const LoginRoute()]);
            debugPrint('[App] Navigated to login page');
          }
        });
      }
    });

    // 페이지 이동 감지 (테스트용)
    final currentRouteName = router.current.name;
    if (_previousRouteName != null && _previousRouteName != currentRouteName) {
      debugPrint('[FCM] Route changed: $_previousRouteName -> $currentRouteName');
      // 페이지 이동 시 FCM 토큰 업데이트 (테스트용)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateFcmToken();
      });
    }
    _previousRouteName = currentRouteName;

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
