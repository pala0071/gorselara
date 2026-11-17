import 'package:dio/dio.dart';

enum FailureKind { network, timeout, unauthorized, quota, server, invalid, cancelled, missingKey }

class AppException implements Exception {
  final FailureKind kind;
  const AppException(this.kind);
  factory AppException.from(Object error) {
    if (error is AppException) return error;
    if (error is DioException) {
      if (CancelToken.isCancel(error)) return const AppException(FailureKind.cancelled);
      if ([DioExceptionType.connectionTimeout, DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout].contains(error.type)) {
        return const AppException(FailureKind.timeout);
      }
      if (error.type == DioExceptionType.connectionError) return const AppException(FailureKind.network);
      final status = error.response?.statusCode;
      final body = error.response?.data.toString().toLowerCase() ?? '';
      if (status == 429 || (status == 403 && (body.contains('quota') || body.contains('ratelimit') || body.contains('rate limit')))) {
        return const AppException(FailureKind.quota);
      }
      if (status == 401 || status == 403) return const AppException(FailureKind.unauthorized);
      if (status != null && status >= 500) return const AppException(FailureKind.server);
    }
    return const AppException(FailureKind.invalid);
  }
}
