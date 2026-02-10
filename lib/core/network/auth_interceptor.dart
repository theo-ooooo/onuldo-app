import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends QueuedInterceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// 토큰 만료 후 재발급까지 실패했을 때 호출되는 콜백
  /// (예: 전역에서 강제 로그아웃 + 로그인 페이지 이동)
  static Future<void> Function()? onTokenExpired;

  AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for login and signup
    if (_isAuthEndpoint(options.path)) {
      return handler.next(options);
    }

    final accessToken = await _storage.read(key: _accessTokenKey);
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // 인증 관련 엔드포인트 자체의 401은 건너뜀 (무한 루프 방지)
    if (err.response?.statusCode == 401 &&
        !_isAuthEndpoint(err.requestOptions.path)) {
      debugPrint('[AuthInterceptor] 401 error on ${err.requestOptions.path}');
      
      // Token expired, try to refresh
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      bool refreshSucceeded = false;
      
      if (refreshToken != null) {
        debugPrint('[AuthInterceptor] Attempting to refresh token...');
        try {
          // validateStatus를 설정하여 모든 응답을 받도록 함
          final response = await _dio.post(
            '/api/auth/refresh',
            data: {'refreshToken': refreshToken},
            options: Options(
              validateStatus: (status) => true, // 모든 상태 코드 허용
            ),
          );

          if (response.statusCode == 200) {
            debugPrint('[AuthInterceptor] Token refresh successful');
            final newAccessToken = response.data['data']['accessToken'];
            final newRefreshToken = response.data['data']['refreshToken'];

            await _storage.write(key: _accessTokenKey, value: newAccessToken);
            await _storage.write(key: _refreshTokenKey, value: newRefreshToken);

            // Retry the original request
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(options);
            refreshSucceeded = true;
            return handler.resolve(retryResponse);
          } else {
            debugPrint('[AuthInterceptor] Token refresh failed with status: ${response.statusCode}');
          }
        } catch (e) {
          debugPrint('[AuthInterceptor] Token refresh failed with exception: $e');
        }
      } else {
        debugPrint('[AuthInterceptor] No refresh token available');
      }
      
      // refresh 실패 또는 refreshToken이 없으면 로그인 페이지로 이동
      if (!refreshSucceeded) {
        await _handleTokenExpired();
      }
      return handler.next(err);
    }

    return handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
           path.contains('/auth/signup') ||
           path.contains('/auth/refresh');
  }

  Future<void> _handleTokenExpired() async {
    debugPrint('[AuthInterceptor] Token expired, handling...');
    
    // 토큰 삭제
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    debugPrint('[AuthInterceptor] Tokens deleted');

    // 전역 콜백 호출 (예: 로그아웃 + 로그인 페이지 이동)
    final callback = AuthInterceptor.onTokenExpired;
    if (callback != null) {
      debugPrint('[AuthInterceptor] Calling onTokenExpired callback...');
      await callback();
      debugPrint('[AuthInterceptor] onTokenExpired callback completed');
    } else {
      debugPrint('[AuthInterceptor] onTokenExpired callback is null!');
    }
  }

  // Helper methods to manage tokens
  static Future<void> saveTokens(
    FlutterSecureStorage storage, {
    required String accessToken,
    required String refreshToken,
  }) async {
    await storage.write(key: _accessTokenKey, value: accessToken);
    await storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<void> clearTokens(FlutterSecureStorage storage) async {
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
  }

  static Future<String?> getAccessToken(FlutterSecureStorage storage) async {
    return storage.read(key: _accessTokenKey);
  }

  static Future<bool> hasTokens(FlutterSecureStorage storage) async {
    final token = await storage.read(key: _accessTokenKey);
    return token != null;
  }
}
