import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../screens/user/user_search_screen.dart';
import '../screens/user/user_profile_screen.dart';

part 'app_router.gr.dart';

// Auth guard - 회원가입 페이지에서는 리다이렉트하지 않음
class _SignupGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    // 회원가입 페이지에서는 항상 허용
    resolver.next();
  }
}

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: SplashRoute.page,
      path: '/splash',
      initial: true,
    ),
    AutoRoute(
      page: LoginRoute.page,
      path: '/login',
    ),
    AutoRoute(
      page: SignupRoute.page,
      path: '/signup',
      guards: [_SignupGuard()],
    ),
    AutoRoute(
      page: CreateRecordRoute.page,
      path: '/create-record',
    ),
    AutoRoute(
      page: UserProfileRoute.page,
      path: '/user/:userId',
    ),
    // Shell route for bottom navigation
    AutoRoute(
      page: HomeRoute.page,
      path: '/',
      children: [
        AutoRoute(
          page: TimerRoute.page,
          path: 'timer',
          initial: true,
        ),
        AutoRoute(
          page: FeedRoute.page,
          path: 'feed',
        ),
        AutoRoute(
          page: StatisticsRoute.page,
          path: 'statistics',
        ),
        AutoRoute(
          page: UserSearchRoute.page,
          path: 'search',
        ),
        AutoRoute(
          page: ProfileRoute.page,
          path: 'profile',
        ),
      ],
    ),
  ];
}

// Router provider with auth guard
final routerProvider = Provider<AppRouter>((ref) {
  final router = AppRouter();
  return router;
});

class AppRoutes {
  AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const signup = '/signup';
  static const timer = '/timer';
  static const feed = '/feed';
  static const statistics = '/statistics';
  static const search = '/search';
  static const profile = '/profile';
  static const createRecord = '/create-record';
  static const userSearch = '/search';
  static const userProfile = '/user';
}
