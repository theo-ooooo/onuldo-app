class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:8080';

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String signUp = '/api/auth/signup';
  static const String refresh = '/api/auth/refresh';

  // Hobby endpoints
  static const String hobbies = '/api/hobbies';
  static String hobby(int id) => '/api/hobbies/$id';

  // Timer endpoints
  static const String timerStart = '/api/timer/start';
  static const String timerPause = '/api/timer/pause';
  static const String timerResume = '/api/timer/resume';
  static const String timerStop = '/api/timer/stop';
  static const String timerCurrent = '/api/timer/current';

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
