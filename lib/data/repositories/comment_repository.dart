import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/models.dart';

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository(ref.read(dioProvider));
});

class CommentRepository {
  final Dio _dio;

  CommentRepository(this._dio);

  /// 댓글 목록 조회
  Future<List<CommentResponse>> getComments(int recordId) async {
    try {
      final response = await _dio.get(ApiConstants.recordComments(recordId));

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((json) => CommentResponse.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        message: apiResponse.message ?? '댓글을 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// 댓글 작성
  Future<CommentResponse> createComment(int recordId, CreateCommentRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.recordComments(recordId),
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<CommentResponse>.fromJson(
        response.data,
        (json) => CommentResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '댓글 작성에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// 댓글 수정
  Future<CommentResponse> updateComment(
    int recordId,
    int commentId,
    UpdateCommentRequest request,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.recordComment(recordId, commentId),
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<CommentResponse>.fromJson(
        response.data,
        (json) => CommentResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '댓글 수정에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// 댓글 삭제
  Future<void> deleteComment(int recordId, int commentId) async {
    try {
      final response = await _dio.delete(
        ApiConstants.recordComment(recordId, commentId),
      );

      final apiResponse = ApiResponse<void>.fromJson(
        response.data,
        (_) {},
      );

      if (!apiResponse.success) {
        throw ApiException(
          message: apiResponse.message ?? '댓글 삭제에 실패했습니다.',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
