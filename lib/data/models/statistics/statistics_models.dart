import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics_models.freezed.dart';
part 'statistics_models.g.dart';

/// 주간 통계 응답
@freezed
class WeeklyStatisticsResponse with _$WeeklyStatisticsResponse {
  const factory WeeklyStatisticsResponse({
    required String weekStartDate,
    required String weekEndDate,
    @Default(0) int totalDurationSeconds,
    @Default(0) int recordCount,
    @Default([]) List<DailyStatisticsResponse> dailyStatistics,
  }) = _WeeklyStatisticsResponse;

  factory WeeklyStatisticsResponse.fromJson(Map<String, dynamic> json) =>
      _$WeeklyStatisticsResponseFromJson(json);
}

/// 월간 통계 응답
@freezed
class MonthlyStatisticsResponse with _$MonthlyStatisticsResponse {
  const factory MonthlyStatisticsResponse({
    required String yearMonth,
    @Default(0) int totalDurationSeconds,
    @Default(0) int recordCount,
    @Default([]) List<DailyStatisticsResponse> dailyStatistics,
  }) = _MonthlyStatisticsResponse;

  factory MonthlyStatisticsResponse.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStatisticsResponseFromJson(json);
}

/// 일일 통계 응답
@freezed
class DailyStatisticsResponse with _$DailyStatisticsResponse {
  const factory DailyStatisticsResponse({
    required String date,
    @Default(0) int totalDurationSeconds,
    @Default(0) int recordCount,
  }) = _DailyStatisticsResponse;

  factory DailyStatisticsResponse.fromJson(Map<String, dynamic> json) =>
      _$DailyStatisticsResponseFromJson(json);
}

/// 취미별 통계 응답
@freezed
class HobbyStatisticsResponse with _$HobbyStatisticsResponse {
  const factory HobbyStatisticsResponse({
    required int hobbyId,
    required String hobbyName,
    @Default(0) int totalDurationSeconds,
    @Default(0) int recordCount,
    String? firstRecordedAt,
    String? lastRecordedAt,
  }) = _HobbyStatisticsResponse;

  factory HobbyStatisticsResponse.fromJson(Map<String, dynamic> json) =>
      _$HobbyStatisticsResponseFromJson(json);
}

/// 스트릭 응답
@freezed
class StreakResponse with _$StreakResponse {
  const factory StreakResponse({
    @Default(0) int currentStreak,
    @Default(0) int longestStreak,
    String? lastRecordDate,
  }) = _StreakResponse;

  factory StreakResponse.fromJson(Map<String, dynamic> json) =>
      _$StreakResponseFromJson(json);
}

/// 캘린더 기록 응답
@freezed
class CalendarRecordResponse with _$CalendarRecordResponse {
  const factory CalendarRecordResponse({
    required String date,
    @Default(false) bool hasRecord,
    @Default(0) int recordCount,
    @Default(0) int totalDurationSeconds,
  }) = _CalendarRecordResponse;

  factory CalendarRecordResponse.fromJson(Map<String, dynamic> json) =>
      _$CalendarRecordResponseFromJson(json);
}

// ============ 앱 내부용 통합 모델 ============

/// 통합 통계 데이터 (Provider에서 사용)
@freezed
class UserStatistics with _$UserStatistics {
  const factory UserStatistics({
    DailyStatisticsResponse? today,
    WeeklyStatisticsResponse? weekly,
    MonthlyStatisticsResponse? monthly,
    @Default([]) List<HobbyStatisticsResponse> hobbyStats,
    StreakResponse? streak,
  }) = _UserStatistics;

  factory UserStatistics.fromJson(Map<String, dynamic> json) =>
      _$UserStatisticsFromJson(json);
}

// ============ 하위 호환용 타입 별칭 (이전 코드 호환) ============

typedef DailyStatistics = DailyStatisticsResponse;
typedef WeeklyStatistics = WeeklyStatisticsResponse;
typedef MonthlyStatistics = MonthlyStatisticsResponse;
typedef HobbyStatistics = HobbyStatisticsResponse;
