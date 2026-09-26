import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Don't add token for auth endpoints
    if (options.path.contains('auth/login') || options.path.contains('auth/register')) {
      return handler.next(options);
    }

    final token = await _storage.read(key: 'authToken');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Token ${token.trim()}';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle logout/redirect logic here via state management
      _storage.delete(key: 'authToken');
    }
    return handler.next(err);
  }
}
