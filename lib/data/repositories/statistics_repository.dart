import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/models.dart';

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepository(ref.read(dioProvider));
});

class StatisticsRepository {
  final Dio _dio;

  StatisticsRepository(this._dio);

  /// 주간 통계 조회
  Future<WeeklyStatisticsResponse> getWeeklyStatistics(String weekStartDate) async {
    try {
      final response = await _dio.get(
        ApiConstants.statisticsWeekly,
        queryParameters: {'weekStartDate': weekStartDate},
      );

      final apiResponse = ApiResponse<WeeklyStatisticsResponse>.fromJson(
        response.data,
        (json) => WeeklyStatisticsResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '주간 통계를 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// 월간 통계 조회
  Future<MonthlyStatisticsResponse> getMonthlyStatistics(String yearMonth) async {
    try {
      final response = await _dio.get(
        ApiConstants.statisticsMonthly,
        queryParameters: {'yearMonth': yearMonth},
      );

      final apiResponse = ApiResponse<MonthlyStatisticsResponse>.fromJson(
        response.data,
        (json) => MonthlyStatisticsResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '월간 통계를 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// 일일 통계 조회 (기간)
  Future<List<DailyStatisticsResponse>> getDailyStatistics(
    String startDate,
    String endDate,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.statisticsDaily,
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
        },
      );

      final apiResponse = ApiResponse<List<DailyStatisticsResponse>>.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => DailyStatisticsResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '일일 통계를 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// 취미별 통계 조회
  Future<List<HobbyStatisticsResponse>> getHobbyStatistics() async {
    try {
      final response = await _dio.get(ApiConstants.statisticsHobbies);

      final apiResponse = ApiResponse<List<HobbyStatisticsResponse>>.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => HobbyStatisticsResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '취미별 통계를 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// 스트릭 조회
  Future<StreakResponse> getStreak() async {
    try {
      final response = await _dio.get(ApiConstants.statisticsStreak);

      final apiResponse = ApiResponse<StreakResponse>.fromJson(
        response.data,
        (json) => StreakResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '스트릭을 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// 캘린더 기록 조회
  Future<List<CalendarRecordResponse>> getCalendarRecords(String yearMonth) async {
    try {
      final response = await _dio.get(
        ApiConstants.statisticsCalendar,
        queryParameters: {'yearMonth': yearMonth},
      );

      final apiResponse = ApiResponse<List<CalendarRecordResponse>>.fromJson(
        response.data,
        (json) => (json as List)
            .map((e) => CalendarRecordResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '캘린더 기록을 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
