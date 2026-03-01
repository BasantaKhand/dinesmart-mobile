import 'package:dinesmart_app/core/api/api_endpoints.dart';
import 'package:dinesmart_app/core/services/storage/user_session_service.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';



// Provider for ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  final userSessionService = ref.read(userSessionServiceProvider);
  return ApiClient(userSessionService);
});




class ApiClient {
  late final Dio _dio;
  final UserSessionService _userSessionService;

  ApiClient(this._userSessionService) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor(_userSessionService));

    // Auto retry on network failures
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
        retryEvaluator: (error, attempt) {
          // Retry on connection errors and timeouts, not on 4xx/5xx
          return error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError;
        },
      ),
    );

    // Only add logger in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      );
    }
  }

  Dio get dio => _dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(path, queryParameters: queryParameters, options: options);
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // Multipart request for file uploads
  Future<Response> uploadFile(
    String path, {
    required FormData formData,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    return _dio.post(
      path,
      data: formData,
      options: options,
      onSendProgress: onSendProgress,
    );
  }
}

// Auth Interceptor to add JWT token to requests
class _AuthInterceptor extends Interceptor {
  final UserSessionService _userSessionService;

  _AuthInterceptor(this._userSessionService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    final publicEndpoints = [
      ApiEndpoints.login,
    ];

    final isPublicGet =
        options.method == 'GET' &&
        publicEndpoints.any((endpoint) => options.path.startsWith(endpoint));

    final isAuthEndpoint =
        options.path == ApiEndpoints.login ||
        options.path == ApiEndpoints.users;

    if (!isPublicGet && !isAuthEndpoint) {
      final token = await _userSessionService.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    debugPrint('DEBUG: API REQUEST: ${options.method} ${options.baseUrl}${options.path}');
    debugPrint('DEBUG: HEADERS: ${options.headers}');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('DEBUG: API RESPONSE: ${response.statusCode} from ${response.requestOptions.path}');
    if (response.data != null && response.data is Map && response.data.containsKey('data')) {
      final data = response.data['data'];
      if (data is List) {
        debugPrint('DEBUG: API DATA COUNT: ${data.length} items');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('DEBUG: API ERROR: ${err.response?.statusCode} at ${err.requestOptions.path}');
    debugPrint('DEBUG: ERROR MSG: ${err.message}');
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      // Clear entire session
      await _userSessionService.clearSession();
      // Note: Navigation to login usually happens via a navigation observer 
      // or by checking session state in the app's root
    }
    handler.next(err);
  }
}
