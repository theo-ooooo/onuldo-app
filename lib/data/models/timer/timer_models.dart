import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_models.freezed.dart';
part 'timer_models.g.dart';

enum TimerStatus {
  @JsonValue('RUNNING')
  running,
  @JsonValue('PAUSED')
  paused,
  @JsonValue('STOPPED')
  stopped,
}

@freezed
class TimerResponse with _$TimerResponse {
  const factory TimerResponse({
    required int id,
    required int hobbyId,
    required TimerStatus status,
    required DateTime startTime,
    DateTime? endTime,
    @Default(0) int durationSeconds,
  }) = _TimerResponse;

  factory TimerResponse.fromJson(Map<String, dynamic> json) =>
      _$TimerResponseFromJson(json);
}

@freezed
class StartTimerRequest with _$StartTimerRequest {
  const factory StartTimerRequest({
    required int hobbyId,
  }) = _StartTimerRequest;

  factory StartTimerRequest.fromJson(Map<String, dynamic> json) =>
      _$StartTimerRequestFromJson(json);
}

@freezed
class TimerStopResult with _$TimerStopResult {
  const factory TimerStopResult({
    required int totalSeconds,
    required int hobbyId,
    required String hobbyName,
    required DateTime startedAt,
    required DateTime stoppedAt,
  }) = _TimerStopResult;

  factory TimerStopResult.fromJson(Map<String, dynamic> json) =>
      _$TimerStopResultFromJson(json);
}
