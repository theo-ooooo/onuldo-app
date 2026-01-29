import 'package:freezed_annotation/freezed_annotation.dart';

part 'reaction_models.freezed.dart';
part 'reaction_models.g.dart';

enum EmojiType {
  @JsonValue('LIKE')
  like,
  @JsonValue('LOVE')
  love,
  @JsonValue('FIRE')
  fire,
  @JsonValue('CLAP')
  clap,
  @JsonValue('WOW')
  wow,
}

extension EmojiTypeExtension on EmojiType {
  String get emoji {
    switch (this) {
      case EmojiType.like:
        return '👍';
      case EmojiType.love:
        return '❤️';
      case EmojiType.fire:
        return '🔥';
      case EmojiType.clap:
        return '👏';
      case EmojiType.wow:
        return '😮';
    }
  }
}

@freezed
class ReactionResponse with _$ReactionResponse {
  const factory ReactionResponse({
    required int id,
    required int recordId,
    required int userId,
    required String userNickname,
    String? userProfileImageUrl,
    required EmojiType emojiType,
    DateTime? createdAt,
  }) = _ReactionResponse;

  factory ReactionResponse.fromJson(Map<String, dynamic> json) =>
      _$ReactionResponseFromJson(json);
}

@freezed
class ReactionCountResponse with _$ReactionCountResponse {
  const factory ReactionCountResponse({
    required EmojiType emojiType,
    required int count,
  }) = _ReactionCountResponse;

  factory ReactionCountResponse.fromJson(Map<String, dynamic> json) =>
      _$ReactionCountResponseFromJson(json);
}

@freezed
class AddReactionRequest with _$AddReactionRequest {
  const factory AddReactionRequest({
    required int recordId,
    required EmojiType emojiType,
  }) = _AddReactionRequest;

  factory AddReactionRequest.fromJson(Map<String, dynamic> json) =>
      _$AddReactionRequestFromJson(json);
}
