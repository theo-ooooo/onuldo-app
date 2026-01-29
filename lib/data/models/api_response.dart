import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@Freezed(genericArgumentFactories: true)
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required bool success,
    T? data,
    String? message,
    String? error,
  }) = _ApiResponse<T>;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);
}

@Freezed(genericArgumentFactories: true)
class PagedResponse<T> with _$PagedResponse<T> {
  const factory PagedResponse({
    required List<T> content,
    required int page,
    required int size,
    required int totalElements,
    required int totalPages,
    required bool first,
    required bool last,
  }) = _PagedResponse<T>;

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      _$PagedResponseFromJson(json, fromJsonT);
}
