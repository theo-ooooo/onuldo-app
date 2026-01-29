import 'package:freezed_annotation/freezed_annotation.dart';

part 'record_models.freezed.dart';
part 'record_models.g.dart';

enum Visibility {
  @JsonValue('PUBLIC')
  public,
  @JsonValue('FOLLOWERS')
  followers,
  @JsonValue('PRIVATE')
  private,
}

@freezed
class RecordResponse with _$RecordResponse {
  const factory RecordResponse({
    required int id,
    required int userId,
    required int hobbyId,
    int? timerId,
    required int durationSeconds,
    String? memo,
    required Visibility visibility,
    required String activityDate,
    @Default([]) List<String> tags,
    DateTime? createdAt,
  }) = _RecordResponse;

  factory RecordResponse.fromJson(Map<String, dynamic> json) =>
      _$RecordResponseFromJson(json);
}

@freezed
class CreateRecordRequest with _$CreateRecordRequest {
  const factory CreateRecordRequest({
    required int timerId,
    required int hobbyId,
    required int durationSeconds,
    String? memo,
    @Default(Visibility.public) Visibility visibility,
  }) = _CreateRecordRequest;

  factory CreateRecordRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRecordRequestFromJson(json);
}
