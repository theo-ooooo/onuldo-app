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
    /// 이모지별 리액션 수 (예: {"HEART": 5, "FIRE": 3})
    @Default({}) Map<String, int> reactionCounts,
    @Default(0) int commentCount,
    DateTime? createdAt,
    /// 내가 누른 리액션 목록 (여러 개 가능)
    @Default([]) List<EmojiType> myReactions,
  }) = _FeedItemResponse;

  factory FeedItemResponse.fromJson(Map<String, dynamic> json) =>
      _$FeedItemResponseFromJson(json);
}

/// FeedItemResponse 확장 메서드
extension FeedItemResponseX on FeedItemResponse {
  /// 전체 리액션 수 합계
  int get totalReactionCount =>
      reactionCounts.values.fold(0, (sum, count) => sum + count);

  /// 특정 이모지의 리액션 수
  int getReactionCount(EmojiType emoji) =>
      reactionCounts[emoji.apiKey] ?? 0;

  /// 내가 특정 이모지에 리액션 했는지 여부
  bool hasMyReaction(EmojiType emoji) =>
      myReactions.contains(emoji);
}
