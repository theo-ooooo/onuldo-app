import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics_models.freezed.dart';
part 'statistics_models.g.dart';

@freezed
class UserStatistics with _$UserStatistics {
  const factory UserStatistics({
    required DailyStatistics daily,
    required WeeklyStatistics weekly,
    required MonthlyStatistics monthly,
    @Default([]) List<HobbyStatistics> hobbyStats,
  }) = _UserStatistics;

  factory UserStatistics.fromJson(Map<String, dynamic> json) =>
      _$UserStatisticsFromJson(json);
}

@freezed
class DailyStatistics with _$DailyStatistics {
  const factory DailyStatistics({
    required String date,
    @Default(0) int recordCount,
    @Default(0) int totalDurationSeconds,
  }) = _DailyStatistics;

  factory DailyStatistics.fromJson(Map<String, dynamic> json) =>
      _$DailyStatisticsFromJson(json);
}

@freezed
class WeeklyStatistics with _$WeeklyStatistics {
  const factory WeeklyStatistics({
    required String startDate,
    required String endDate,
    @Default(0) int recordCount,
    @Default(0) int totalDurationSeconds,
  }) = _WeeklyStatistics;

  factory WeeklyStatistics.fromJson(Map<String, dynamic> json) =>
      _$WeeklyStatisticsFromJson(json);
}

@freezed
class MonthlyStatistics with _$MonthlyStatistics {
  const factory MonthlyStatistics({
    required int month,
    @Default(0) int recordCount,
    @Default(0) int totalDurationSeconds,
  }) = _MonthlyStatistics;

  factory MonthlyStatistics.fromJson(Map<String, dynamic> json) =>
      _$MonthlyStatisticsFromJson(json);
}

@freezed
class HobbyStatistics with _$HobbyStatistics {
  const factory HobbyStatistics({
    required int hobbyId,
    required String hobbyName,
    String? hobbyColorCode,
    @Default(0) int totalDurationSeconds,
    @Default(0) int recordCount,
    @Default(0.0) double percentage,
  }) = _HobbyStatistics;

  factory HobbyStatistics.fromJson(Map<String, dynamic> json) =>
      _$HobbyStatisticsFromJson(json);
}
