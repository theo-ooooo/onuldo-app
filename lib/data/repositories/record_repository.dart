import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/models.dart';

final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  return RecordRepository(ref.read(dioProvider));
});

class RecordRepository {
  final Dio _dio;

  RecordRepository(this._dio);

  Future<RecordResponse> createRecord(CreateRecordRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.records,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<RecordResponse>.fromJson(
        response.data,
        (json) => RecordResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '기록 생성에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
