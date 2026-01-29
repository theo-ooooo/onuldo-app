import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/models.dart';

final timerRepositoryProvider = Provider<TimerRepository>((ref) {
  return TimerRepository(ref.read(dioProvider));
});

class TimerRepository {
  final Dio _dio;

  TimerRepository(this._dio);

  Future<TimerResponse> startTimer(StartTimerRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.timerStart,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<TimerResponse>.fromJson(
        response.data,
        (json) => TimerResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '타이머 시작에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<TimerResponse> pauseTimer() async {
    try {
      final response = await _dio.post(ApiConstants.timerPause);

      final apiResponse = ApiResponse<TimerResponse>.fromJson(
        response.data,
        (json) => TimerResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '타이머 일시정지에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<TimerResponse> resumeTimer() async {
    try {
      final response = await _dio.post(ApiConstants.timerResume);

      final apiResponse = ApiResponse<TimerResponse>.fromJson(
        response.data,
        (json) => TimerResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '타이머 재개에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<TimerResponse> stopTimer() async {
    try {
      final response = await _dio.post(ApiConstants.timerStop);

      final apiResponse = ApiResponse<TimerResponse>.fromJson(
        response.data,
        (json) => TimerResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '타이머 정지에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<TimerResponse?> getCurrentTimer() async {
    try {
      final response = await _dio.get(ApiConstants.timerCurrent);

      final apiResponse = ApiResponse<TimerResponse?>.fromJson(
        response.data,
        (json) => json != null
            ? TimerResponse.fromJson(json as Map<String, dynamic>)
            : null,
      );

      if (apiResponse.success) {
        return apiResponse.data;
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ApiException.fromDioException(e);
    }
  }
}
