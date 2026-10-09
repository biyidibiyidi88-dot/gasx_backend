import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';

class DioClient {
  final Dio _dio;

  DioClient() : _dio = Dio() {
    _dio
      ..options.baseUrl = ApiConstants.onlineBaseUrl
      ..options.connectTimeout = const Duration(
        milliseconds: ApiConstants.connectionTimeout,
      )
      ..options.receiveTimeout = const Duration(
        milliseconds: ApiConstants.receiveTimeout,
      )
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'GaSX/1.0.0 (Flutter)',
      }
      ..interceptors.add(AuthInterceptor())
      ..interceptors.add(_BackendFailoverInterceptor(_dio))
      ..interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
        ),
      );
  }

  Dio get dio => _dio;
}

class _BackendFailoverInterceptor extends Interceptor {
  static const _fallbackAttemptedKey = 'localBackendFallbackAttempted';

  final Dio _dio;

  _BackendFailoverInterceptor(this._dio);

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) async {
    final request = error.requestOptions;
    final method = request.method.toUpperCase();
    final isSafeRead = const {'GET', 'HEAD', 'OPTIONS'}.contains(method);
    final isPaymentInitiation =
        method == 'POST' &&
        RegExp(r'(?:^|/)payments/initiate/?$').hasMatch(request.path);
    final onlineUri = Uri.parse(ApiConstants.onlineBaseUrl);
    final requestUri = request.uri;
    final isOnlineRequest =
        requestUri.scheme == onlineUri.scheme &&
        requestUri.host == onlineUri.host &&
        requestUri.port == onlineUri.port &&
        requestUri.path.startsWith(onlineUri.path);
    final isConnectionFailure =
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout;
    final isReadTimeout =
        isSafeRead && error.type == DioExceptionType.receiveTimeout;
    final canTryLocal =
        error.response == null &&
        isOnlineRequest &&
        ApiConstants.localBaseUrl != ApiConstants.onlineBaseUrl &&
        request.extra[_fallbackAttemptedKey] != true &&
        !isPaymentInitiation &&
        (isConnectionFailure || isReadTimeout);

    if (!canTryLocal) {
      handler.next(error);
      return;
    }

    final retryData = request.data is FormData
        ? (request.data as FormData).clone()
        : request.data;
    final retryOptions = request.copyWith(
      baseUrl: ApiConstants.localBaseUrl,
      data: retryData,
      extra: {...request.extra, _fallbackAttemptedKey: true},
    );

    try {
      final response = await _dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (fallbackError) {
      handler.next(fallbackError);
    } catch (fallbackError) {
      handler.next(
        DioException(requestOptions: retryOptions, error: fallbackError),
      );
    }
  }
}
