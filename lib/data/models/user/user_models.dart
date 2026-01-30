import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_models.freezed.dart';
part 'user_models.g.dart';

@freezed
class UserResponse with _$UserResponse {
  const factory UserResponse({
    required int userId,
    required String email,
    required String nickname,
    String? profileImageUrl,
    String? bio,
    required int followerCount,
    required int followingCount,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
}
