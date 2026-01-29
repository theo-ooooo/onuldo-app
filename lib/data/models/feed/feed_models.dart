import 'package:freezed_annotation/freezed_annotation.dart';

import '../record/record_models.dart';
import '../reaction/reaction_models.dart';

part 'feed_models.freezed.dart';
part 'feed_models.g.dart';

enum FeedType {
  @JsonValue('ALL')
  all,
  @JsonValue('FOLLOWING')
  following,
}

enum SortType {
  @JsonValue('LATEST')
  latest,
  @JsonValue('POPULAR')
  popular,
}

@freezed
class FeedItemResponse with _$FeedItemResponse {
  const factory FeedItemResponse({
    required int recordId,
    required int userId,
    required String userNickname,
    String? userProfileImageUrl,
    required int hobbyId,
    required String hobbyName,
    required int durationSeconds,
    String? memo,
    required Visibility visibility,
    required String activityDate,
    @Default([]) List<String> tags,
    @Default(0) int reactionCount,
    @Default(0) int commentCount,
    DateTime? createdAt,
    EmojiType? myReaction,
  }) = _FeedItemResponse;

  factory FeedItemResponse.fromJson(Map<String, dynamic> json) =>
      _$FeedItemResponseFromJson(json);
}
