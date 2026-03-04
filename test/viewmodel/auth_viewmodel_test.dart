import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/services/storage/user_session_service.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/send_request_usecase.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:dinesmart_app/features/auth/presentation/state/auth_state.dart';
import 'package:dinesmart_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helpers.dart';

class FakeLoginParams extends Fake implements LoginParams {}
class FakeSendRequestParams extends Fake implements SendRequestParams {}
class FakeUpdatePasswordParams extends Fake implements UpdatePasswordParams {}
class FakeUpdateProfileParams extends Fake implements UpdateProfileParams {}

void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockSendRequestUsecase mockSendRequestUsecase;
  late MockUpdatePasswordUsecase mockUpdatePasswordUsecase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;
  late MockUserSessionService mockUserSessionService;

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
    registerFallbackValue(FakeSendRequestParams());
    registerFallbackValue(FakeUpdatePasswordParams());
    registerFallbackValue(FakeUpdateProfileParams());
  });

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockSendRequestUsecase = MockSendRequestUsecase();
    mockUpdatePasswordUsecase = MockUpdatePasswordUsecase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();
    mockUserSessionService = MockUserSessionService();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        sendRequestUsecaseProvider.overrideWithValue(mockSendRequestUsecase),
        updatePasswordUsecaseProvider.overrideWithValue(mockUpdatePasswordUsecase),
        updateProfileUsecaseProvider.overrideWithValue(mockUpdateProfileUsecase),
        userSessionServiceProvider.overrideWithValue(mockUserSessionService),
      ],
    );
  }

  group('AuthViewModel', () {
    test('initial state should be initial', () {
      final container = createContainer();
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });

    group('login', () {
      test('should update state to authenticated on success', () async {
        final container = createContainer();
        final user = TestData.authEntity();
        
        when(() => mockLoginUsecase(any())).thenAnswer((_) async => Right(user));

        final notifier = container.read(authViewModelProvider.notifier);
        await notifier.login(email: 'test@test.com', password: 'password');

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, user);
        expect(state.errorMessage, isNull);
      });

      test('should update state to passwordChangeRequired if user must change password', () async {
        final container = createContainer();
        final user = TestData.authEntity(mustChangePassword: true);
        
        when(() => mockLoginUsecase(any())).thenAnswer((_) async => Right(user));

        final notifier = container.read(authViewModelProvider.notifier);
        await notifier.login(email: 'test@test.com', password: 'password');

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.passwordChangeRequired);
        expect(state.user, user);
        expect(state.errorMessage, isNull);
      });

      test('should update state to error on failure', () async {
        final container = createContainer();
        const errorMessage = 'Invalid credentials';
        
        when(() => mockLoginUsecase(any())).thenAnswer(
          (_) async => const Left(ApiFailure(message: errorMessage)),
        );

        final notifier = container.read(authViewModelProvider.notifier);
        await notifier.login(email: 'test@test.com', password: 'password');

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, errorMessage);
        expect(state.user, isNull);
      });
    });

    group('logout', () {
      test('should reset state on success', () async {
        final container = createContainer();
        when(() => mockLogoutUsecase()).thenAnswer((_) async => const Right(true));

        final notifier = container.read(authViewModelProvider.notifier);
        await notifier.logout();

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.initial);
        expect(state.user, isNull);
        expect(state.errorMessage, isNull);
      });
    });

    group('hydrateFromSession', () {
      test('should update state to authenticated if valid session exists', () async {
        final container = createContainer();
        when(() => mockUserSessionService.hasValidSession()).thenAnswer((_) async => true);
        when(() => mockUserSessionService.getCurrentUserId()).thenReturn('user_123');
        when(() => mockUserSessionService.getCurrentUserFullName()).thenReturn('John Doe');
        when(() => mockUserSessionService.getCurrentUserEmail()).thenReturn('john@example.com');
        when(() => mockUserSessionService.getCurrentUserPhoneNumber()).thenReturn('1234567890');
        when(() => mockUserSessionService.getCurrentUserUsername()).thenReturn('johndoe');
        when(() => mockUserSessionService.getCurrentUserRole()).thenReturn('waiter');
        when(() => mockUserSessionService.getCurrentRestaurantId()).thenReturn('rest_1');
        when(() => mockUserSessionService.getCurrentUserProfilePicture()).thenReturn(null);

        final notifier = container.read(authViewModelProvider.notifier);
        await notifier.hydrateFromSession();

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.user?.authId, 'user_123');
        expect(state.user?.ownerName, 'John Doe');
      });

      test('should do nothing if no valid session', () async {
        final container = createContainer();
        when(() => mockUserSessionService.hasValidSession()).thenAnswer((_) async => false);

        final notifier = container.read(authViewModelProvider.notifier);
        await notifier.hydrateFromSession();

        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.initial);
      });
    });
  });
}
