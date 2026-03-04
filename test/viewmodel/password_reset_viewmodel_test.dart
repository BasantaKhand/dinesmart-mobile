import 'package:dinesmart_app/core/api/api_client.dart';
import 'package:dinesmart_app/core/api/api_endpoints.dart';
import 'package:dinesmart_app/features/auth/presentation/state/password_reset_state.dart';
import 'package:dinesmart_app/features/auth/presentation/view_model/password_reset_viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helpers.dart';

void main() {
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(mockApiClient),
      ],
    );
  }

  group('PasswordResetViewModel', () {
    test('initial state should be initial', () {
      final container = createContainer();
      final state = container.read(passwordResetViewModelProvider);
      expect(state.status, PasswordResetStatus.initial);
      expect(state.errorMessage, isNull);
      expect(state.successMessage, isNull);
    });

    group('forgotPassword', () {
      test('should update state to success on API success', () async {
        final container = createContainer();
        final response = Response(
          requestOptions: RequestOptions(path: ''),
          data: {'success': true, 'message': 'OTP sent'},
          statusCode: 200,
        );

        when(() => mockApiClient.post(
          '${ApiEndpoints.baseUrl}/auth/forgot-password',
          data: any(named: 'data'),
        )).thenAnswer((_) async => response);

        final notifier = container.read(passwordResetViewModelProvider.notifier);
        final result = await notifier.forgotPassword(email: 'test@test.com', method: 'otp');

        expect(result, true);
        final state = container.read(passwordResetViewModelProvider);
        expect(state.status, PasswordResetStatus.success);
        expect(state.successMessage, 'OTP sent');
      });

      test('should update state to error on API failure', () async {
        final container = createContainer();
        final response = Response(
          requestOptions: RequestOptions(path: ''),
          data: {'success': false, 'message': 'User not found'},
          statusCode: 404,
        );

        when(() => mockApiClient.post(
          '${ApiEndpoints.baseUrl}/auth/forgot-password',
          data: any(named: 'data'),
        )).thenAnswer((_) async => response);

        final notifier = container.read(passwordResetViewModelProvider.notifier);
        final result = await notifier.forgotPassword(email: 'test@test.com', method: 'otp');

        expect(result, false);
        final state = container.read(passwordResetViewModelProvider);
        expect(state.status, PasswordResetStatus.error);
        expect(state.errorMessage, 'User not found');
      });

      test('should update state to error on network exception', () async {
        final container = createContainer();
        
        when(() => mockApiClient.post(
          '${ApiEndpoints.baseUrl}/auth/forgot-password',
          data: any(named: 'data'),
        )).thenThrow(Exception('Network error'));

        final notifier = container.read(passwordResetViewModelProvider.notifier);
        final result = await notifier.forgotPassword(email: 'test@test.com', method: 'otp');

        expect(result, false);
        final state = container.read(passwordResetViewModelProvider);
        expect(state.status, PasswordResetStatus.error);
        expect(state.errorMessage, contains('Network error'));
      });
    });

    group('verifyPasswordResetOtp', () {
      test('should return true and update state on success', () async {
        final container = createContainer();
        final response = Response(
          requestOptions: RequestOptions(path: ''),
          data: {'success': true, 'message': 'Verified'},
          statusCode: 200,
        );

        when(() => mockApiClient.post(
          '${ApiEndpoints.baseUrl}/auth/verify-otp',
          data: any(named: 'data'),
        )).thenAnswer((_) async => response);

        final notifier = container.read(passwordResetViewModelProvider.notifier);
        final result = await notifier.verifyPasswordResetOtp(email: 'test@test.com', otp: '123456');

        expect(result, true);
        final state = container.read(passwordResetViewModelProvider);
        expect(state.status, PasswordResetStatus.success);
      });
    });

    group('resetPassword', () {
      test('should return true and update state on success', () async {
        final container = createContainer();
        final response = Response(
          requestOptions: RequestOptions(path: ''),
          data: {'success': true, 'message': 'Password reset'},
          statusCode: 200,
        );

        when(() => mockApiClient.post(
          '${ApiEndpoints.baseUrl}/auth/reset-password',
          data: any(named: 'data'),
        )).thenAnswer((_) async => response);

        final notifier = container.read(passwordResetViewModelProvider.notifier);
        final result = await notifier.resetPassword(
          email: 'test@test.com',
          newPassword: 'new-password',
          otp: '123456',
        );

        expect(result, true);
        final state = container.read(passwordResetViewModelProvider);
        expect(state.status, PasswordResetStatus.success);
      });
    });
  });
}
