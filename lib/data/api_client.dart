import 'package:dio/dio.dart';
import '../core/app_exception.dart';
import '../core/utils.dart';
import 'api_cache.dart';

class ApiClient {
  final Dio dio;
  final ApiCache cache;
  ApiClient(this.cache) : dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20), receiveTimeout: const Duration(seconds: 40),
    headers: {'User-Agent': 'GorselAra/1.0 (Android; personal image discovery)', 'Accept': 'application/json'},
  ));
  Future<Map<String, dynamic>> get(String url, {Map<String, dynamic> query = const {},
    Map<String, dynamic> headers = const {}, CancelToken? cancelToken, bool cached = true}) async {
    if (!webUrl(url)) throw const AppException(FailureKind.invalid);
    if (cancelToken?.isCancelled == true) throw const AppException(FailureKind.cancelled);
    final key = cache.key(url, query, headers.toString());
    if (cached) {
      final saved = cache.get(key);
      if (saved != null) return saved;
    }
    try {
      final response = await dio.get<dynamic>(url, queryParameters: query,
        options: Options(headers: headers), cancelToken: cancelToken);
      if (response.data is! Map) throw const AppException(FailureKind.invalid);
      final data = asMap(response.data);
      if (cached) await cache.put(key, data);
      return data;
    } on DioException catch (e) { throw AppException.from(e); }
  }
}
