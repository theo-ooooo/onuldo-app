import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/models.dart';

final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  return ImageRepository(ref.read(dioProvider));
});

class ImageRepository {
  final Dio _dio;

  ImageRepository(this._dio);

  Future<PresignedUploadUrlResponse> getPresignedUrl(
    int recordId,
    String fileName,
    String? contentType,
  ) async {
    try {
      final queryParams = <String, dynamic>{
        'fileName': fileName,
      };
      if (contentType != null) {
        queryParams['contentType'] = contentType;
      }

      final response = await _dio.get(
        ApiConstants.recordPresignedUrl(recordId),
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponse<PresignedUploadUrlResponse>.fromJson(
        response.data,
        (json) => PresignedUploadUrlResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? 'Presigned URL 발급에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> uploadToS3(
    String uploadUrl,
    File imageFile,
    String contentType,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final uri = Uri.parse(uploadUrl);
      final httpClient = HttpClient();
      final request = await httpClient.openUrl('PUT', uri);
      request.headers.set(HttpHeaders.contentTypeHeader, contentType);
      request.headers.set(HttpHeaders.contentLengthHeader, bytes.length.toString());
      request.add(bytes);
      final response = await request.close();
      // 응답 본문 소비
      await response.drain<void>();
      httpClient.close();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(
          message: 'S3 업로드에 실패했습니다 (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: 'S3 업로드에 실패했습니다: $e',
      );
    }
  }

  Future<ImageUploadResponse> confirmImageUpload(
    int recordId,
    ConfirmImageUploadRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.recordImageConfirm(recordId),
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<ImageUploadResponse>.fromJson(
        response.data,
        (json) => ImageUploadResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '이미지 업로드 확인에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
