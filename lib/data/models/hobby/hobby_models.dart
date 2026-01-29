import 'package:freezed_annotation/freezed_annotation.dart';

part 'hobby_models.freezed.dart';
part 'hobby_models.g.dart';

@freezed
class HobbyResponse with _$HobbyResponse {
  const factory HobbyResponse({
    required int id,
    required String name,
    String? description,
    String? colorCode,
    String? iconUrl,
  }) = _HobbyResponse;

  factory HobbyResponse.fromJson(Map<String, dynamic> json) =>
      _$HobbyResponseFromJson(json);
}

@freezed
class CreateHobbyRequest with _$CreateHobbyRequest {
  const factory CreateHobbyRequest({
    required String name,
    String? description,
    String? colorCode,
    String? iconName,
  }) = _CreateHobbyRequest;

  factory CreateHobbyRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateHobbyRequestFromJson(json);
}

@freezed
class UpdateHobbyRequest with _$UpdateHobbyRequest {
  const factory UpdateHobbyRequest({
    String? name,
    String? description,
    String? colorCode,
    String? iconName,
  }) = _UpdateHobbyRequest;

  factory UpdateHobbyRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateHobbyRequestFromJson(json);
}
