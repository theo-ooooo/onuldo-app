import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';
import '../../data/models/api_response.dart';
import 'auth_interceptor.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add logging interceptor in debug mode
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ),
  );

  // Add auth interceptor
  final storage = ref.read(secureStorageProvider);
  dio.interceptors.add(AuthInterceptor(storage, dio));

  return dio;
});

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioException(DioException e) {
    String message;
    int? statusCode = e.response?.statusCode;
    dynamic data = e.response?.data;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '연결 시간이 초과되었습니다.';
        break;
      case DioExceptionType.badResponse:
        message = _parseErrorMessage(e.response?.data) ?? '서버 오류가 발생했습니다.';
        break;
      case DioExceptionType.cancel:
        message = '요청이 취소되었습니다.';
        break;
      case DioExceptionType.connectionError:
        message = '네트워크 연결을 확인해주세요.';
        break;
      default:
        message = '알 수 없는 오류가 발생했습니다.';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: data,
    );
  }

  static String? _parseErrorMessage(dynamic data) {
    if (data == null) return null;
    if (data is Map) {
      // message가 String이면 바로 반환
      if (data['message'] is String) {
        return data['message'];
      }
      // error가 Map이면 그 안의 message 반환
      if (data['error'] is Map) {
        return data['error']['message'] as String?;
      }
      // error가 String이면 그대로 반환
      if (data['error'] is String) {
        return data['error'];
      }
    }
    return null;
  }

  @override
  String toString() => 'ApiException: $message (statusCode: $statusCode)';
}

/// 공용 API 클라이언트
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// GET 요청
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      final apiResponse = ApiResponse<T>.fromJson(
        response.data,
        fromJson,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '요청에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// GET 요청 (List 반환)
  Future<List<T>> getList<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      final apiResponse = ApiResponse<List<dynamic>>.fromJson(
        response.data,
        (json) => json as List<dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!
            .map((e) => fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException(
        message: apiResponse.message ?? '요청에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST 요청
  Future<T> post<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      final apiResponse = ApiResponse<T>.fromJson(
        response.data,
        fromJson,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '요청에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// POST 요청 (응답 데이터 없음)
  Future<void> postVoid(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      final apiResponse = ApiResponse<void>.fromJson(
        response.data,
        (_) {},
      );

      if (!apiResponse.success) {
        throw ApiException(
          message: apiResponse.message ?? '요청에 실패했습니다.',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// PUT 요청
  Future<T> put<T>(
    String path, {
    dynamic data,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      final apiResponse = ApiResponse<T>.fromJson(
        response.data,
        fromJson,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return apiResponse.data!;
      }

      throw ApiException(
        message: apiResponse.message ?? '요청에 실패했습니다.',
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  /// DELETE 요청 (응답 데이터 없음)
  Future<void> deleteVoid(String path) async {
    try {
      final response = await _dio.delete(path);
      final apiResponse = ApiResponse<void>.fromJson(
        response.data,
        (_) {},
      );

      if (!apiResponse.success) {
        throw ApiException(
          message: apiResponse.message ?? '요청에 실패했습니다.',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

/// ApiClient Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.read(dioProvider));
});
