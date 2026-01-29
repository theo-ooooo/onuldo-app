import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/timer/timer_screen.dart';
import '../screens/feed/feed_screen.dart';
import '../screens/statistics/statistics_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/record/create_record_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.loading ||
          authState.status == AuthStatus.initial;
      final isSplash = state.matchedLocation == '/splash';
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      // Show splash while loading
      if (isLoading && isSplash) {
        return null;
      }

      // After loading, redirect based on auth status
      if (!isLoading && isSplash) {
        return isLoggedIn ? '/timer' : '/login';
      }

      // Redirect to login if not authenticated
      if (!isLoggedIn && !isAuthRoute && !isSplash) {
        return '/login';
      }

      // Redirect to home if authenticated and trying to access auth routes
      if (isLoggedIn && isAuthRoute) {
        return '/timer';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/timer',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TimerScreen(),
            ),
          ),
          GoRoute(
            path: '/feed',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FeedScreen(),
            ),
          ),
          GoRoute(
            path: '/statistics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StatisticsScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/create-record',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CreateRecordScreen(
            timerId: extra?['timerId'] as int?,
            hobbyId: extra?['hobbyId'] as int?,
            hobbyName: extra?['hobbyName'] as String?,
            durationSeconds: extra?['durationSeconds'] as int?,
          );
        },
      ),
    ],
  );
});

class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const signup = '/signup';
  static const timer = '/timer';
  static const feed = '/feed';
  static const statistics = '/statistics';
  static const profile = '/profile';
  static const createRecord = '/create-record';
}
