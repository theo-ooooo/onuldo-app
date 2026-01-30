import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../models/models.dart';

final followRepositoryProvider = Provider<FollowRepository>((ref) {
  return FollowRepository(ref.read(apiClientProvider));
});

class FollowRepository {
  final ApiClient _apiClient;

  FollowRepository(this._apiClient);

  /// 사용자 팔로우
  Future<void> follow(int userId) async {
    await _apiClient.postVoid('/api/users/$userId/follow');
  }

  /// 사용자 언팔로우
  Future<void> unfollow(int userId) async {
    await _apiClient.deleteVoid('/api/users/$userId/follow');
  }

  /// 팔로워 목록 조회
  Future<List<FollowUserResponse>> getFollowers(int userId) async {
    return _apiClient.getList(
      '/api/users/$userId/followers',
      fromJson: FollowUserResponse.fromJson,
    );
  }

  /// 팔로잉 목록 조회
  Future<List<FollowUserResponse>> getFollowing(int userId) async {
    return _apiClient.getList(
      '/api/users/$userId/following',
      fromJson: FollowUserResponse.fromJson,
    );
  }

  /// 팔로우 수 조회
  Future<FollowCountResponse> getFollowCount(int userId) async {
    return _apiClient.get(
      '/api/users/$userId/follow-count',
      fromJson: (json) => FollowCountResponse.fromJson(json as Map<String, dynamic>),
    );
  }
}
