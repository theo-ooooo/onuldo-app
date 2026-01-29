import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics_models.freezed.dart';
part 'statistics_models.g.dart';

@freezed
class UserStatistics with _$UserStatistics {
  const factory UserStatistics({
    required int totalRecords,
    required int totalSeconds,
    required int totalHobbies,
    required DailyStatistics today,
    required WeeklyStatistics thisWeek,
    required MonthlyStatistics thisMonth,
    required List<HobbyStatistics> hobbyBreakdown,
  }) = _UserStatistics;

  factory UserStatistics.fromJson(Map<String, dynamic> json) =>
      _$UserStatisticsFromJson(json);
}

@freezed
class DailyStatistics with _$DailyStatistics {
  const factory DailyStatistics({
    required String date,
    required int totalSeconds,
    required int recordCount,
    List<HobbyStatistics>? hobbyBreakdown,
  }) = _DailyStatistics;

  factory DailyStatistics.fromJson(Map<String, dynamic> json) =>
      _$DailyStatisticsFromJson(json);
}

@freezed
class WeeklyStatistics with _$WeeklyStatistics {
  const factory WeeklyStatistics({
    required String startDate,
    required String endDate,
    required int totalSeconds,
    required int recordCount,
    required List<DailyStatistics> dailyBreakdown,
  }) = _WeeklyStatistics;

  factory WeeklyStatistics.fromJson(Map<String, dynamic> json) =>
      _$WeeklyStatisticsFromJson(json);
}

@freezed
class MonthlyStatistics with _$MonthlyStatistics {
  const factory MonthlyStatistics({
    required int year,
    required int month,
    required int totalSeconds,
    required int recordCount,
    required List<DailyStatistics> dailyBreakdown,
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
    required int totalSeconds,
    required int recordCount,
    required double percentage,
  }) = _HobbyStatistics;

  factory HobbyStatistics.fromJson(Map<String, dynamic> json) =>
      _$HobbyStatisticsFromJson(json);
}
