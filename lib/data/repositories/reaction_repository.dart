import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/models.dart';

final reactionRepositoryProvider = Provider<ReactionRepository>((ref) {
  return ReactionRepository(ref.read(dioProvider));
});

class ReactionRepository {
  final Dio _dio;

  ReactionRepository(this._dio);

  Future<ReactionResponse> addReaction(AddReactionRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.reactions,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<ReactionResponse>.fromJson(
        response.data,
        (json) => ReactionResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '리액션 추가에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> removeReaction(int recordId) async {
    try {
      final response = await _dio.delete(ApiConstants.removeReaction(recordId));

      final apiResponse = ApiResponse<void>.fromJson(
        response.data,
        (_) {},
      );

      if (!apiResponse.success) {
        throw ApiException(
          message: apiResponse.message ?? '리액션 삭제에 실패했습니다.',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<ReactionResponse>> getReactions(int recordId) async {
    try {
      final response = await _dio.get(ApiConstants.reactionsByRecord(recordId));

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((json) =>
                ReactionResponse.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        message: apiResponse.message ?? '리액션 목록을 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<ReactionCountResponse>> getReactionCount(int recordId) async {
    try {
      final response = await _dio.get(ApiConstants.reactionCount(recordId));

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((json) =>
                ReactionCountResponse.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        message: apiResponse.message ?? '리액션 수를 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
