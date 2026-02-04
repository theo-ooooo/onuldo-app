import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_models.freezed.dart';
part 'follow_models.g.dart';

@freezed
class FollowUserResponse with _$FollowUserResponse {
  const factory FollowUserResponse({
    required int userId,
    required String nickname,
    String? profileImageUrl,
    @JsonKey(name: 'following') required bool isFollowing,
  }) = _FollowUserResponse;

  factory FollowUserResponse.fromJson(Map<String, dynamic> json) =>
      _$FollowUserResponseFromJson(json);
}

@freezed
class FollowCountResponse with _$FollowCountResponse {
  const factory FollowCountResponse({
    required int followerCount,
    required int followingCount,
  }) = _FollowCountResponse;

  factory FollowCountResponse.fromJson(Map<String, dynamic> json) =>
      _$FollowCountResponseFromJson(json);
}

@freezed
class FollowRequest with _$FollowRequest {
  const factory FollowRequest({
    required int targetUserId,
  }) = _FollowRequest;

  factory FollowRequest.fromJson(Map<String, dynamic> json) =>
      _$FollowRequestFromJson(json);
}
