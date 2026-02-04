import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_models.freezed.dart';
part 'notification_models.g.dart';

enum NotificationType {
  @JsonValue('REACTION')
  reaction,
  @JsonValue('COMMENT')
  comment,
  @JsonValue('REPLY')
  reply,
  @JsonValue('FOLLOW')
  follow,
}

@freezed
class NotificationResponse with _$NotificationResponse {
  const factory NotificationResponse({
    required int id,
    required NotificationType type,
    required String title,
    required String content,
    int? relatedUserId,
    String? relatedUserNickname,
    int? relatedRecordId,
    int? relatedCommentId,
    required bool isRead,
    required DateTime createdAt,
  }) = _NotificationResponse;

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
}


