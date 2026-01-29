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

  Future<UserStatistics> getMyStatistics() async {
    try {
      final response = await _dio.get(ApiConstants.myStatistics);

      final apiResponse = ApiResponse<UserStatistics>.fromJson(
        response.data,
        (json) => UserStatistics.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '통계를 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
