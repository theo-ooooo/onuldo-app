import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/models.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(ref.read(dioProvider));
});

class FeedRepository {
  final Dio _dio;

  FeedRepository(this._dio);

  Future<List<FeedItemResponse>> getFeed({
    int page = 0,
    int size = 20,
    SortType sort = SortType.latest,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.feed,
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort.name.toUpperCase(),
        },
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((item) => FeedItemResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        message: apiResponse.message ?? '피드를 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<FeedItemResponse>> getFollowingFeed({
    int page = 0,
    int size = 20,
    SortType sort = SortType.latest,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.feedFollowing,
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort.name.toUpperCase(),
        },
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((item) => FeedItemResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        message: apiResponse.message ?? '팔로잉 피드를 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<FeedItemResponse>> getUserFeed(
    int userId, {
    int page = 0,
    int size = 20,
    SortType sort = SortType.latest,
    int? hobbyId,
    String? tagName,
  }) async {
    try {
      final response = await _dio.get(
        '/api/users/$userId/feed',
        queryParameters: {
          'page': page,
          'size': size,
          // OpenAPI 기준 파라미터명
          'sortType': sort.name.toUpperCase(),
          if (hobbyId != null) 'hobbyId': hobbyId,
          if (tagName != null && tagName.isNotEmpty) 'tagName': tagName,
        },
      );

      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((item) =>
                FeedItemResponse.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        message: apiResponse.message ?? '사용자 피드를 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
