class ApiConstants {
  ApiConstants._();

  // Android 에뮬레이터: 10.0.2.2 (호스트 PC)
  // iOS 시뮬레이터/웹: localhost
  // 실제 기기: 서버 IP 주소
  static const String baseUrl = 'http://10.0.2.2:8080';

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
  static const String reactions = '/api/reactions';
  static String reactionsByRecord(int recordId) => '/api/reactions/record/$recordId';
  static String reactionCount(int recordId) => '/api/reactions/record/$recordId/count';
  static String removeReaction(int recordId) => '/api/reactions/record/$recordId';

  // Statistics endpoints
  static const String myStatistics = '/api/statistics/me';
}
