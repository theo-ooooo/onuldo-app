import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  ApiConstants._();

  static const int _port = 8080;

  /// 플랫폼별 baseUrl 반환
  /// - Android 에뮬레이터: 10.0.2.2 (호스트 PC 접근)
  /// - iOS 시뮬레이터: localhost
  /// - Web: localhost
  /// - 실제 기기: 서버 IP 주소 설정 필요
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$_port';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:$_port';
    }

    if (Platform.isIOS) {
      return 'http://localhost:$_port';
    }

    // 기타 플랫폼 (macOS, Windows, Linux)
    return 'http://localhost:$_port';
  }

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String signUp = '/api/auth/signup';
  static const String refresh = '/api/auth/refresh';

  // Hobby endpoints
  static const String hobbies = '/api/hobbies';
  static String hobby(int id) => '/api/hobbies/$id';

  // Timer endpoints
  static const String timerStart = '/api/timers';
  static const String timerPause = '/api/timers/pause';
  static const String timerResume = '/api/timers/resume';
  static const String timerStop = '/api/timers/stop';
  static const String timerCurrent = '/api/timers/current';

  // Record endpoints
  static const String records = '/api/records';
  static String recordPresignedUrl(int recordId) => '/api/records/$recordId/images/presigned-url';
  static String recordImageConfirm(int recordId) => '/api/records/$recordId/images/confirm';

  // Feed endpoints
  static const String feed = '/api/feed';
  static const String feedFollowing = '/api/feed/following';

  // Follow endpoints
  static const String follow = '/api/follow';
  static String unfollow(int userId) => '/api/follow/$userId';
  static String followers(int userId) => '/api/follow/$userId/followers';
  static String following(int userId) => '/api/follow/$userId/following';
  static String followCount(int userId) => '/api/follow/$userId/count';

  // Reaction endpoints
  static String recordReactions(int recordId) => '/api/records/$recordId/reactions';
  static String recordReactionCount(int recordId) => '/api/records/$recordId/reactions/count';
  static String recordMyReactions(int recordId) => '/api/records/$recordId/reactions/me';
  static String removeReaction(int recordId, String emojiType) => '/api/records/$recordId/reactions/$emojiType';

  // Comment endpoints
  static String recordComments(int recordId) => '/api/records/$recordId/comments';
  static String recordComment(int recordId, int commentId) => '/api/records/$recordId/comments/$commentId';

  // Statistics endpoints
  static const String statisticsWeekly = '/api/statistics/weekly';
  static const String statisticsMonthly = '/api/statistics/monthly';
  static const String statisticsDaily = '/api/statistics/daily';
  static const String statisticsHobbies = '/api/statistics/hobbies';
  static const String statisticsStreak = '/api/statistics/streak';
  static const String statisticsCalendar = '/api/statistics/calendar';

  // User endpoints
  static const String users = '/api/users';
  static const String usersMe = '/api/users/me';
  static String user(int userId) => '/api/users/$userId';
  static String userFollow(int userId) => '/api/users/$userId/follow';
  static String userFollowers(int userId) => '/api/users/$userId/followers';
  static String userFollowing(int userId) => '/api/users/$userId/following';
  static const String profileImagePresignedUrl = '/api/users/me/profile-image/presigned-url';
  static const String profileImageConfirm = '/api/users/me/profile-image/confirm';
}
