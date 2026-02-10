import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_models.freezed.dart';
part 'image_models.g.dart';

@freezed
class PresignedUploadUrlResponse with _$PresignedUploadUrlResponse {
  const factory PresignedUploadUrlResponse({
    required String uploadUrl,
    required String imageKey,
    required int expiresIn,
  }) = _PresignedUploadUrlResponse;

  factory PresignedUploadUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$PresignedUploadUrlResponseFromJson(json);
}

@freezed
class ConfirmImageUploadRequest with _$ConfirmImageUploadRequest {
  const factory ConfirmImageUploadRequest({
    required String imageKey,
    required String fileName,
    required int fileSize,
    int? width,
    int? height,
  }) = _ConfirmImageUploadRequest;

  factory ConfirmImageUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$ConfirmImageUploadRequestFromJson(json);
}

@freezed
class ImageUploadResponse with _$ImageUploadResponse {
  const factory ImageUploadResponse({
    required int imageId,
    required String imageUrl,
    required String fileName,
    required int fileSize,
    int? width,
    int? height,
  }) = _ImageUploadResponse;

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$ImageUploadResponseFromJson(json);
}

@freezed
class ProfileImageUploadResponse with _$ProfileImageUploadResponse {
  const factory ProfileImageUploadResponse({
    required String profileImageUrl,
  }) = _ProfileImageUploadResponse;

  factory ProfileImageUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileImageUploadResponseFromJson(json);
}
