import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repositories/user_repository.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/router/app_router.dart';
import 'shared/theme/app_theme.dart';

class OnuldoApp extends ConsumerStatefulWidget {
  const OnuldoApp({super.key});

  @override
  ConsumerState<OnuldoApp> createState() => _OnuldoAppState();
}

class _OnuldoAppState extends ConsumerState<OnuldoApp> {
  @override
  void initState() {
    super.initState();
    // auth 상태 변경 감지해서 FCM 토큰 업데이트
    Future.microtask(() {
      ref.listen(authProvider, (prev, next) {
        if (prev?.status != AuthStatus.authenticated &&
            next.status == AuthStatus.authenticated) {
          _updateFcmToken();
        }
      });
    });
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

    return MaterialApp.router(
      title: '오늘도',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
