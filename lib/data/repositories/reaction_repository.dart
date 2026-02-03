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

  /// 리액션 추가
  Future<ReactionResponse> addReaction(int recordId, AddReactionRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.recordReactions(recordId),
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

  /// 리액션 제거
  Future<void> removeReaction(int recordId, EmojiType emojiType) async {
    try {
      final response = await _dio.delete(
        ApiConstants.removeReaction(recordId, emojiType.apiKey),
      );

      // 204 No Content는 성공 응답 (body가 없음)
      if (response.statusCode == 204) {
        return;
      }

      // 다른 상태 코드인 경우에만 응답 파싱
      if (response.data != null) {
        final apiResponse = ApiResponse<void>.fromJson(
          response.data,
          (_) {},
        );

        if (!apiResponse.success) {
          throw ApiException(
            message: apiResponse.message ?? '리액션 삭제에 실패했습니다.',
          );
        }
      }
    } on DioException catch (e) {
      // 204 응답은 에러가 아님
      if (e.response?.statusCode == 204) {
        return;
      }
      throw ApiException.fromDioException(e);
    }
  }

  /// 리액션 목록 조회
  Future<List<ReactionWithUserResponse>> getReactions(int recordId) async {
    try {
      final response = await _dio.get(ApiConstants.recordReactions(recordId));

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((json) =>
                ReactionWithUserResponse.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        message: apiResponse.message ?? '리액션 목록을 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// 리액션 통계 조회
  Future<ReactionCountResponse> getReactionCount(int recordId) async {
    try {
      final response = await _dio.get(ApiConstants.recordReactionCount(recordId));

      final apiResponse = ApiResponse<ReactionCountResponse>.fromJson(
        response.data,
        (json) => ReactionCountResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '리액션 수를 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// 내가 누른 리액션 목록 조회
  Future<List<ReactionResponse>> getMyReactions(int recordId) async {
    try {
      final response = await _dio.get(ApiConstants.recordMyReactions(recordId));

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
        message: apiResponse.message ?? '내 리액션 목록을 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
