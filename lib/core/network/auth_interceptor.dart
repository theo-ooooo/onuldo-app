import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(
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
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try to refresh
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken != null) {
        try {
          final response = await _dio.post(
            '/api/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['data']['accessToken'];
            final newRefreshToken = response.data['data']['refreshToken'];

            await _storage.write(key: _accessTokenKey, value: newAccessToken);
            await _storage.write(key: _refreshTokenKey, value: newRefreshToken);

            // Retry the original request
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await _dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // Refresh failed, clear tokens
          await _storage.delete(key: _accessTokenKey);
          await _storage.delete(key: _refreshTokenKey);
        }
      }
    }

    return handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
           path.contains('/auth/signup') ||
           path.contains('/auth/refresh');
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
