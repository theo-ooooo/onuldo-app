import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/models.dart';

final hobbyRepositoryProvider = Provider<HobbyRepository>((ref) {
  return HobbyRepository(ref.read(dioProvider));
});

class HobbyRepository {
  final Dio _dio;

  HobbyRepository(this._dio);

  Future<List<HobbyResponse>> getHobbies() async {
    try {
      final response = await _dio.get(ApiConstants.hobbies);

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((json) => HobbyResponse.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        message: apiResponse.message ?? '취미 목록을 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<HobbyResponse> getHobby(int id) async {
    try {
      final response = await _dio.get(ApiConstants.hobby(id));

      final apiResponse = ApiResponse<HobbyResponse>.fromJson(
        response.data,
        (json) => HobbyResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '취미를 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<HobbyResponse> createHobby(CreateHobbyRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.hobbies,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<HobbyResponse>.fromJson(
        response.data,
        (json) => HobbyResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '취미 생성에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<HobbyResponse> updateHobby(int id, UpdateHobbyRequest request) async {
    try {
      final response = await _dio.put(
        ApiConstants.hobby(id),
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<HobbyResponse>.fromJson(
        response.data,
        (json) => HobbyResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '취미 수정에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteHobby(int id) async {
    try {
      final response = await _dio.delete(ApiConstants.hobby(id));

      final apiResponse = ApiResponse<void>.fromJson(
        response.data,
        (_) => null,
      );

      if (!apiResponse.success) {
        throw ApiException(
          message: apiResponse.message ?? '취미 삭제에 실패했습니다.',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
