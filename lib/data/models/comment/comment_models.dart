import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_models.freezed.dart';
part 'comment_models.g.dart';

@freezed
class CommentResponse with _$CommentResponse {
  const factory CommentResponse({
    required int id,
    required int userId,
    required String userNickname,
    String? userProfileImageUrl,
    required int recordId,
    int? parentCommentId,
    required String content,
    required int replyCount,
    @Default([]) List<CommentResponse> replies,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CommentResponse;

  factory CommentResponse.fromJson(Map<String, dynamic> json) =>
      _$CommentResponseFromJson(json);
}

@freezed
class CreateCommentRequest with _$CreateCommentRequest {
  const factory CreateCommentRequest({
    required String content,
    int? parentCommentId,
  }) = _CreateCommentRequest;

  factory CreateCommentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentRequestFromJson(json);
}

@freezed
class UpdateCommentRequest with _$UpdateCommentRequest {
  const factory UpdateCommentRequest({
    required String content,
  }) = _UpdateCommentRequest;

  factory UpdateCommentRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCommentRequestFromJson(json);
}
