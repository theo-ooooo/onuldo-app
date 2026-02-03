import 'package:freezed_annotation/freezed_annotation.dart';

part 'reaction_models.freezed.dart';
part 'reaction_models.g.dart';

enum EmojiType {
  @JsonValue('HEART')
  heart,
  @JsonValue('FIRE')
  fire,
  @JsonValue('CLAP')
  clap,
  @JsonValue('THUMBS_UP')
  thumbsUp,
  @JsonValue('STAR')
  star,
  @JsonValue('PARTY')
  party,
}

extension EmojiTypeExtension on EmojiType {
  String get emoji {
    switch (this) {
      case EmojiType.heart:
        return '❤️';
      case EmojiType.fire:
        return '🔥';
      case EmojiType.clap:
        return '👏';
      case EmojiType.thumbsUp:
        return '👍';
      case EmojiType.star:
        return '⭐';
      case EmojiType.party:
        return '🎉';
    }
  }

  /// API에서 사용하는 대문자 키 값 (HEART, FIRE, etc.)
  String get apiKey {
    switch (this) {
      case EmojiType.heart:
        return 'HEART';
      case EmojiType.fire:
        return 'FIRE';
      case EmojiType.clap:
        return 'CLAP';
      case EmojiType.thumbsUp:
        return 'THUMBS_UP';
      case EmojiType.star:
        return 'STAR';
      case EmojiType.party:
        return 'PARTY';
    }
  }
}

@freezed
class ReactionResponse with _$ReactionResponse {
  const factory ReactionResponse({
    required int id,
    required int recordId,
    required int userId,
    required EmojiType emojiType,
    required DateTime createdAt,
  }) = _ReactionResponse;

  factory ReactionResponse.fromJson(Map<String, dynamic> json) =>
      _$ReactionResponseFromJson(json);
}

/// 리액션과 사용자 정보가 함께 포함된 응답
@freezed
class ReactionWithUserResponse with _$ReactionWithUserResponse {
  const factory ReactionWithUserResponse({
    required int id,
    required int userId,
    required String nickname,
    String? profileImageUrl,
    required EmojiType emojiType,
    required DateTime createdAt,
  }) = _ReactionWithUserResponse;

  factory ReactionWithUserResponse.fromJson(Map<String, dynamic> json) =>
      _$ReactionWithUserResponseFromJson(json);
}

@freezed
class ReactionCountResponse with _$ReactionCountResponse {
  const factory ReactionCountResponse({
    required int recordId,
    required Map<String, int> counts,
    required int totalCount,
  }) = _ReactionCountResponse;

  factory ReactionCountResponse.fromJson(Map<String, dynamic> json) =>
      _$ReactionCountResponseFromJson(json);
}

@freezed
class AddReactionRequest with _$AddReactionRequest {
  const factory AddReactionRequest({
    required EmojiType emojiType,
  }) = _AddReactionRequest;

  factory AddReactionRequest.fromJson(Map<String, dynamic> json) =>
      _$AddReactionRequestFromJson(json);
}
