import 'package:dinesmart_app/core/api/api_client.dart';
import 'package:dinesmart_app/core/api/api_endpoints.dart';
import 'package:dinesmart_app/features/auth/presentation/state/password_reset_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final passwordResetViewModelProvider =
    NotifierProvider<PasswordResetViewModel, PasswordResetState>(
  PasswordResetViewModel.new,
);

class PasswordResetViewModel extends Notifier<PasswordResetState> {
  late final ApiClient _apiClient;

  @override
  PasswordResetState build() {
    _apiClient = ref.read(apiClientProvider);
    return const PasswordResetState();
  }

  /// Request password reset via email (OTP or Link method)
  Future<bool> forgotPassword({
    required String email,
    required String method, // 'otp' or 'link'
  }) async {
    print('DEBUG: forgotPassword called - email=$email, method=$method');
    state = state.copyWith(status: PasswordResetStatus.loading, errorMessage: null);

    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.baseUrl}/auth/forgot-password',
        data: {
          'email': email,
          'method': method,
        },
      );

      print('DEBUG: API Response status=${response.statusCode}');
      print('DEBUG: API Response data type=${response.data.runtimeType}');
      print('DEBUG: API Response data=${ response.data}');

      // Handle response - check for success in different ways
      bool isSuccess = false;
      String? message;

      if (response.data is Map) {
        isSuccess = response.data['success'] == true;
        message = response.data['message'] as String?;
      }

      if (isSuccess) {
        final successMsg = message ?? 'Reset request sent successfully';
        state = state.copyWith(
          status: PasswordResetStatus.success,
          successMessage: successMsg,
        );
        print('DEBUG: forgotPassword SUCCESS - returning true');
        return true;
      } else {
        final errorMsg = message ?? 'Failed to send reset request';
        state = state.copyWith(
          status: PasswordResetStatus.error,
          errorMessage: errorMsg,
        );
        print('DEBUG: forgotPassword FAILED - returning false, error=$errorMsg');
        return false;
      }
    } catch (e, stackTrace) {
      print('DEBUG: forgotPassword EXCEPTION: $e');
      print('DEBUG: StackTrace: $stackTrace');
      state = state.copyWith(
        status: PasswordResetStatus.error,
        errorMessage: 'Error: ${e.toString()}',
      );
      return false;
    }
  }

  /// Verify OTP for password reset
  Future<bool> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    print('DEBUG: verifyPasswordResetOtp called - email=$email, otp=$otp');
    state = state.copyWith(status: PasswordResetStatus.loading, errorMessage: null);

    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.baseUrl}/auth/verify-otp',
        data: {
          'email': email,
          'otp': otp,
        },
      );

      print('DEBUG: Verify OTP API Response status=${response.statusCode}');
      print('DEBUG: Verify OTP API Response data=${response.data}');

      bool isSuccess = false;
      String? message;

      if (response.data is Map) {
        isSuccess = response.data['success'] == true;
        message = response.data['message'] as String?;
      }

      if (isSuccess) {
        final successMsg = message ?? 'OTP verified successfully';
        state = state.copyWith(
          status: PasswordResetStatus.success,
          successMessage: successMsg,
        );
        print('DEBUG: verifyPasswordResetOtp SUCCESS - returning true');
        return true;
      } else {
        final errorMsg = message ?? 'Invalid or expired OTP';
        state = state.copyWith(
          status: PasswordResetStatus.error,
          errorMessage: errorMsg,
        );
        print('DEBUG: verifyPasswordResetOtp FAILED - returning false, error=$errorMsg');
        return false;
      }
    } catch (e, stackTrace) {
      print('DEBUG: verifyPasswordResetOtp EXCEPTION: $e');
      print('DEBUG: StackTrace: $stackTrace');
      state = state.copyWith(
        status: PasswordResetStatus.error,
        errorMessage: 'Error: ${e.toString()}',
      );
      return false;
    }
  }

  /// Reset password using token or OTP
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
    String? token,
    String? otp,
  }) async {
    print('DEBUG: resetPassword called - email=$email, hasToken=${token != null}, hasOtp=${otp != null}');
    state = state.copyWith(status: PasswordResetStatus.loading, errorMessage: null);

    try {
      final data = {
        'email': email,
        'newPassword': newPassword,
      };

      if (token != null && token.isNotEmpty) {
        data['token'] = token;
      }
      if (otp != null && otp.isNotEmpty) {
        data['otp'] = otp;
      }

      print('DEBUG: resetPassword API data=$data');

      final response = await _apiClient.post(
        '${ApiEndpoints.baseUrl}/auth/reset-password',
        data: data,
      );

      print('DEBUG: Reset password API Response status=${response.statusCode}');
      print('DEBUG: Reset password API Response data=${response.data}');

      bool isSuccess = false;
      String? message;

      if (response.data is Map) {
        isSuccess = response.data['success'] == true;
        message = response.data['message'] as String?;
      }

      if (isSuccess) {
        final successMsg = message ?? 'Password reset successfully';
        state = state.copyWith(
          status: PasswordResetStatus.success,
          successMessage: successMsg,
        );
        print('DEBUG: resetPassword SUCCESS - returning true');
        return true;
      } else {
        final errorMsg = message ?? 'Failed to reset password';
        state = state.copyWith(
          status: PasswordResetStatus.error,
          errorMessage: errorMsg,
        );
        print('DEBUG: resetPassword FAILED - returning false, error=$errorMsg');
        return false;
      }
    } catch (e, stackTrace) {
      print('DEBUG: resetPassword EXCEPTION: $e');
      print('DEBUG: StackTrace: $stackTrace');
      state = state.copyWith(
        status: PasswordResetStatus.error,
        errorMessage: 'Error: ${e.toString()}',
      );
      return false;
    }
  }
}
