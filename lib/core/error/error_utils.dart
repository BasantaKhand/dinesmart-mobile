import 'package:dio/dio.dart';

/// Utility class to extract user-friendly error messages from exceptions
class ErrorUtils {
  ErrorUtils._();

  /// Extracts a user-friendly error message from any exception
  static String getMessage(dynamic e) {
    if (e is DioException) {
      return _getDioErrorMessage(e);
    }
    
    final message = e.toString();
    
    // Clean up common error prefixes
    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }
    
    return message;
  }

  /// Extracts error message specifically from DioException
  static String _getDioErrorMessage(DioException e) {
    // Check for connection-related errors
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'No internet connection';
      case DioExceptionType.badResponse:
        // Try to get server error message
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
        return _getStatusCodeMessage(e.response?.statusCode);
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.unknown:
        if (e.message?.contains('SocketException') == true ||
            e.message?.contains('Connection refused') == true) {
          return 'No internet connection';
        }
        return e.message ?? 'Something went wrong';
      default:
        return e.message ?? 'Something went wrong';
    }
  }

  /// Returns a user-friendly message based on HTTP status code
  static String _getStatusCodeMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request';
      case 401:
        return 'Please login again';
      case 403:
        return 'Access denied';
      case 404:
        return 'Not found';
      case 409:
        return 'Conflict occurred';
      case 422:
        return 'Invalid data provided';
      case 500:
        return 'Server error. Please try again later';
      case 502:
      case 503:
      case 504:
        return 'Service temporarily unavailable';
      default:
        return 'Something went wrong';
    }
  }

  /// Checks if the error is due to no internet connection
  static bool isNoInternetError(dynamic e) {
    if (e is DioException) {
      return e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          (e.type == DioExceptionType.unknown &&
              (e.message?.contains('SocketException') == true ||
                  e.message?.contains('Connection refused') == true));
    }
    return false;
  }
}
