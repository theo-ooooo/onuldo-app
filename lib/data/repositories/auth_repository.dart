import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/auth_interceptor.dart';
import '../models/models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(dioProvider),
    ref.read(secureStorageProvider),
  );
});

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<LoginResult> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<LoginResult>.fromJson(
        response.data,
        (json) => LoginResult.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        await AuthInterceptor.saveTokens(
          _storage,
          accessToken: apiResponse.data!.accessToken,
          refreshToken: apiResponse.data!.refreshToken,
        );
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '로그인에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<SignUpResponse> signUp(SignUpRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.signUp,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<SignUpResponse>.fromJson(
        response.data,
        (json) => SignUpResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      // error 객체에서 메시지 추출
      String errorMessage = '회원가입에 실패했습니다.';
      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['error'] is Map) {
          final error = data['error'] as Map<String, dynamic>;
          errorMessage = error['message'] as String? ?? errorMessage;
        } else if (data['message'] is String) {
          errorMessage = data['message'] as String;
        } else if (apiResponse.message != null) {
          errorMessage = apiResponse.message!;
        }
      }

      throw ApiException(
        message: errorMessage,
        statusCode: response.statusCode,
        data: response.data,
      );
    } on DioException catch (e) {
      // DioException에서도 error 객체에서 메시지 추출 시도
      String errorMessage = '회원가입에 실패했습니다.';
      if (e.response?.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;
        if (data['error'] is Map) {
          final error = data['error'] as Map<String, dynamic>;
          errorMessage = error['message'] as String? ?? errorMessage;
        } else if (data['message'] is String) {
          errorMessage = data['message'] as String;
        }
      }
      
      // 에러 메시지를 파싱했으면 그것을 사용, 아니면 기본 파싱 사용
      if (errorMessage != '회원가입에 실패했습니다.') {
        throw ApiException(
          message: errorMessage,
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        );
      }
      
      throw ApiException.fromDioException(e);
    }
  }

  Future<RefreshTokenResponse> refresh(String refreshToken) async {
    try {
      final response = await _dio.post(
        ApiConstants.refresh,
        data: RefreshTokenRequest(refreshToken: refreshToken).toJson(),
      );

      final apiResponse = ApiResponse<RefreshTokenResponse>.fromJson(
        response.data,
        (json) => RefreshTokenResponse.fromJson(json as Map<String, dynamic>),
      );

      if (apiResponse.success && apiResponse.data != null) {
        await AuthInterceptor.saveTokens(
          _storage,
          accessToken: apiResponse.data!.accessToken,
          refreshToken: apiResponse.data!.refreshToken,
        );
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '토큰 갱신에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> logout() async {
    await AuthInterceptor.clearTokens(_storage);
  }

  Future<bool> hasValidToken() async {
    return AuthInterceptor.hasTokens(_storage);
  }
}
