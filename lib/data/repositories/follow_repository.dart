import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/models.dart';

final followRepositoryProvider = Provider<FollowRepository>((ref) {
  return FollowRepository(ref.read(dioProvider));
});

class FollowRepository {
  final Dio _dio;

  FollowRepository(this._dio);

  Future<void> follow(int targetUserId) async {
    try {
      final response = await _dio.post(
        ApiConstants.follow,
        data: FollowRequest(targetUserId: targetUserId).toJson(),
      );

      final apiResponse = ApiResponse<void>.fromJson(
        response.data,
        (_) => null,
      );

      if (!apiResponse.success) {
        throw ApiException(
          message: apiResponse.message ?? '팔로우에 실패했습니다.',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> unfollow(int targetUserId) async {
    try {
      final response = await _dio.delete(ApiConstants.unfollow(targetUserId));

      final apiResponse = ApiResponse<void>.fromJson(
        response.data,
        (_) => null,
      );

      if (!apiResponse.success) {
        throw ApiException(
          message: apiResponse.message ?? '언팔로우에 실패했습니다.',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PagedResponse<FollowUserResponse>> getFollowers(
    int userId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.followers(userId),
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final apiResponse =
          ApiResponse<PagedResponse<FollowUserResponse>>.fromJson(
        response.data,
        (json) => PagedResponse<FollowUserResponse>.fromJson(
          json as Map<String, dynamic>,
          (itemJson) =>
              FollowUserResponse.fromJson(itemJson as Map<String, dynamic>),
        ),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '팔로워 목록을 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<PagedResponse<FollowUserResponse>> getFollowing(
    int userId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.following(userId),
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final apiResponse =
          ApiResponse<PagedResponse<FollowUserResponse>>.fromJson(
        response.data,
        (json) => PagedResponse<FollowUserResponse>.fromJson(
          json as Map<String, dynamic>,
          (itemJson) =>
              FollowUserResponse.fromJson(itemJson as Map<String, dynamic>),
        ),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '팔로잉 목록을 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<FollowCountResponse> getFollowCount(int userId) async {
    try {
      final response = await _dio.get(ApiConstants.followCount(userId));

      final apiResponse = ApiResponse<FollowCountResponse>.fromJson(
        response.data,
        (json) => FollowCountResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '팔로우 수를 불러오는데 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
