import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:dinesmart_app/core/error/error_utils.dart';

void main() {
  group('ErrorUtils.getMessage', () {
    // ─── DioException types ───
    test('connectionError returns "No internet connection"', () {
      final e = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: '/test'),
      );
      expect(ErrorUtils.getMessage(e), 'No internet connection');
    });

    test('connectionTimeout returns "No internet connection"', () {
      final e = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      expect(ErrorUtils.getMessage(e), 'No internet connection');
    });

    test('receiveTimeout returns "No internet connection"', () {
      final e = DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      expect(ErrorUtils.getMessage(e), 'No internet connection');
    });

    test('sendTimeout returns "No internet connection"', () {
      final e = DioException(
        type: DioExceptionType.sendTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      expect(ErrorUtils.getMessage(e), 'No internet connection');
    });

    test('cancel returns "Request cancelled"', () {
      final e = DioException(
        type: DioExceptionType.cancel,
        requestOptions: RequestOptions(path: '/test'),
      );
      expect(ErrorUtils.getMessage(e), 'Request cancelled');
    });

    // ─── badResponse with server message ───
    test('badResponse extracts server message from response data', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: {'message': 'Invalid email format'},
        ),
      );
      expect(ErrorUtils.getMessage(e), 'Invalid email format');
    });

    // ─── badResponse status codes ───
    test('badResponse 400 without message returns "Invalid request"', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
          data: 'raw string',
        ),
      );
      expect(ErrorUtils.getMessage(e), 'Invalid request');
    });

    test('badResponse 401 returns "Please login again"', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
          data: {},
        ),
      );
      expect(ErrorUtils.getMessage(e), 'Please login again');
    });

    test('badResponse 403 returns "Access denied"', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 403,
          data: {},
        ),
      );
      expect(ErrorUtils.getMessage(e), 'Access denied');
    });

    test('badResponse 404 returns "Not found"', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
          data: {},
        ),
      );
      expect(ErrorUtils.getMessage(e), 'Not found');
    });

    test('badResponse 409 returns "Conflict occurred"', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 409,
          data: {},
        ),
      );
      expect(ErrorUtils.getMessage(e), 'Conflict occurred');
    });

    test('badResponse 422 returns "Invalid data provided"', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 422,
          data: {},
        ),
      );
      expect(ErrorUtils.getMessage(e), 'Invalid data provided');
    });

    test('badResponse 500 returns "Server error..."', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
          data: {},
        ),
      );
      expect(ErrorUtils.getMessage(e), 'Server error. Please try again later');
    });

    test('badResponse 502 returns "Service temporarily unavailable"', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 502,
          data: {},
        ),
      );
      expect(ErrorUtils.getMessage(e), 'Service temporarily unavailable');
    });

    test('badResponse 503 returns "Service temporarily unavailable"', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 503,
          data: {},
        ),
      );
      expect(ErrorUtils.getMessage(e), 'Service temporarily unavailable');
    });

    test('badResponse unknown status returns "Something went wrong"', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 418,
          data: {},
        ),
      );
      expect(ErrorUtils.getMessage(e), 'Something went wrong');
    });

    // ─── unknown type with SocketException ───
    test('unknown with SocketException returns "No internet connection"', () {
      final e = DioException(
        type: DioExceptionType.unknown,
        requestOptions: RequestOptions(path: '/test'),
        message: 'SocketException: Connection refused',
      );
      expect(ErrorUtils.getMessage(e), 'No internet connection');
    });

    test('unknown with "Connection refused" returns "No internet connection"', () {
      final e = DioException(
        type: DioExceptionType.unknown,
        requestOptions: RequestOptions(path: '/test'),
        message: 'Connection refused by host',
      );
      expect(ErrorUtils.getMessage(e), 'No internet connection');
    });

    test('unknown with custom message returns that message', () {
      final e = DioException(
        type: DioExceptionType.unknown,
        requestOptions: RequestOptions(path: '/test'),
        message: 'Some weird error',
      );
      expect(ErrorUtils.getMessage(e), 'Some weird error');
    });

    test('unknown with null message returns "Something went wrong"', () {
      final e = DioException(
        type: DioExceptionType.unknown,
        requestOptions: RequestOptions(path: '/test'),
      );
      expect(ErrorUtils.getMessage(e), 'Something went wrong');
    });

    // ─── Non-Dio exceptions ───
    test('Exception with prefix "Exception: " strips it', () {
      expect(ErrorUtils.getMessage(Exception('Custom error')), 'Custom error');
    });

    test('generic string error returns as-is', () {
      expect(ErrorUtils.getMessage('plain error'), 'plain error');
    });
  });

  // ─── isNoInternetError ───
  group('ErrorUtils.isNoInternetError', () {
    test('returns true for connectionError', () {
      final e = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(path: '/test'),
      );
      expect(ErrorUtils.isNoInternetError(e), true);
    });

    test('returns true for connectionTimeout', () {
      final e = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      expect(ErrorUtils.isNoInternetError(e), true);
    });

    test('returns true for receiveTimeout', () {
      final e = DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      expect(ErrorUtils.isNoInternetError(e), true);
    });

    test('returns true for sendTimeout', () {
      final e = DioException(
        type: DioExceptionType.sendTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      expect(ErrorUtils.isNoInternetError(e), true);
    });

    test('returns true for unknown with SocketException', () {
      final e = DioException(
        type: DioExceptionType.unknown,
        requestOptions: RequestOptions(path: '/test'),
        message: 'SocketException: failed host lookup',
      );
      expect(ErrorUtils.isNoInternetError(e), true);
    });

    test('returns false for badResponse', () {
      final e = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/test'),
        response: Response(requestOptions: RequestOptions(path: '/test'), statusCode: 500),
      );
      expect(ErrorUtils.isNoInternetError(e), false);
    });

    test('returns false for non-Dio exception', () {
      expect(ErrorUtils.isNoInternetError(Exception('error')), false);
    });

    test('returns false for cancel type', () {
      final e = DioException(
        type: DioExceptionType.cancel,
        requestOptions: RequestOptions(path: '/test'),
      );
      expect(ErrorUtils.isNoInternetError(e), false);
    });
  });
}
