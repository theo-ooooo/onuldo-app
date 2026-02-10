import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../models/models.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(apiClientProvider));
});

class UserRepository {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  /// 내 정보 조회
  Future<UserResponse> getMyInfo() async {
    return _apiClient.get(
      '/api/users/me',
      fromJson: (json) => UserResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 사용자 정보 조회
  Future<UserResponse> getUser(int userId) async {
    return _apiClient.get(
      '/api/users/$userId',
      fromJson: (json) => UserResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 사용자 검색
  Future<List<UserResponse>> searchUsers(String keyword) async {
    return _apiClient.getList(
      '/api/users',
      queryParameters: {'keyword': keyword},
      fromJson: UserResponse.fromJson,
    );
  }

  /// FCM 토큰 업데이트
  Future<void> updateFcmToken(String fcmToken) async {
    return _apiClient.putVoid(
      '/api/users/me/fcm-token',
      data: {'fcmToken': fcmToken},
    );
  }

  /// 내 프로필 정보 업데이트
  Future<void> updateMyProfile({
    String? nickname,
    String? bio,
    String? profileImageUrl,
  }) async {
    await _apiClient.putVoid(
      '/api/users/me/profile',
      data: {
        if (nickname != null) 'nickname': nickname,
        if (bio != null) 'bio': bio,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      },
    );
  }

  /// 비밀번호 변경
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.putVoid(
      '/api/users/me/password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
