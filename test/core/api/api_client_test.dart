import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dinesmart_app/core/api/api_client.dart';
import 'package:dinesmart_app/core/api/api_endpoints.dart';
import 'package:dinesmart_app/core/services/storage/user_session_service.dart';

class MockUserSessionService extends Mock implements UserSessionService {}
class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

void main() {
  late MockUserSessionService mockUserSessionService;
  late MockHttpClientAdapter mockHttpClientAdapter;
  late ApiClient apiClient;

  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockUserSessionService = MockUserSessionService();
    mockHttpClientAdapter = MockHttpClientAdapter();
    
    apiClient = ApiClient(mockUserSessionService);
    apiClient.dio.httpClientAdapter = mockHttpClientAdapter;
  });

  ResponseBody createSuccessResponse() {
    return ResponseBody.fromString(
      jsonEncode({'data': 'success'}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  group('HTTP Methods', () {
    setUp(() {
      when(() => mockHttpClientAdapter.fetch(any(), any(), any()))
          .thenAnswer((_) async => createSuccessResponse());
      when(() => mockUserSessionService.getToken())
          .thenAnswer((_) async => 'fake_token');
    });

    test('should perform GET request successfully', () async {
      final response = await apiClient.get('/test');
      expect(response.statusCode, 200);
      expect(response.data, {'data': 'success'});
    });

    test('should perform POST request successfully', () async {
      final response = await apiClient.post('/test', data: {'key': 'value'});
      expect(response.statusCode, 200);
    });

    test('should perform PUT request successfully', () async {
      final response = await apiClient.put('/test', data: {'key': 'value'});
      expect(response.statusCode, 200);
    });

    test('should perform DELETE request successfully', () async {
      final response = await apiClient.delete('/test');
      expect(response.statusCode, 200);
    });

    test('should perform PATCH request successfully', () async {
      final response = await apiClient.patch('/test', data: {'key': 'value'});
      expect(response.statusCode, 200);
    });
    
    test('should upload file successfully', () async {
      final formData = FormData.fromMap({'file': MultipartFile.fromString('test')});
      final response = await apiClient.uploadFile('/upload', formData: formData);
      expect(response.statusCode, 200);
    });
  });

  group('Auth Interceptor', () {
    test('should add Authorization header if token exists and not public URL', () async {
      when(() => mockHttpClientAdapter.fetch(any(), any(), any()))
          .thenAnswer((_) async => createSuccessResponse());
      when(() => mockUserSessionService.getToken())
          .thenAnswer((_) async => 'fake_token');

      await apiClient.get('/protected-route');

      // Verify getToken was called
      verify(() => mockUserSessionService.getToken()).called(1);
      
      // Verify the RequestOptions passed to the adapter
      final captured = verify(() => mockHttpClientAdapter.fetch(captureAny(), any(), any())).captured;
      final options = captured.first as RequestOptions;
      expect(options.headers['Authorization'], 'Bearer fake_token');
    });

    test('should NOT add Authorization header for public login URL', () async {
      when(() => mockHttpClientAdapter.fetch(any(), any(), any()))
          .thenAnswer((_) async => createSuccessResponse());
          
      // Login is an exception
      await apiClient.post(ApiEndpoints.login);

      verifyNever(() => mockUserSessionService.getToken());
    });

    test('should clear session on 401 Unauthorized', () async {
      // Simulate 401 error response
      when(() => mockHttpClientAdapter.fetch(any(), any(), any()))
          .thenAnswer((_) async {
            throw DioException(
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                requestOptions: RequestOptions(path: '/test'),
                statusCode: 401,
              ),
              type: DioExceptionType.badResponse,
            );
          });
          
      when(() => mockUserSessionService.getToken())
          .thenAnswer((_) async => 'fake_token');
      when(() => mockUserSessionService.clearSession())
          .thenAnswer((_) async {});

      try {
        await apiClient.get('/test');
        fail('Should have thrown DioException');
      } catch (e) {
        expect(e, isA<DioException>());
      }

      verify(() => mockUserSessionService.clearSession()).called(1);
    });
  });
}
