import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/services/storage/user_session_service.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/send_request_usecase.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_helpers.dart';

class FakeLoginParams extends Fake implements LoginParams {}

void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockSendRequestUsecase mockSendRequestUsecase;
  late MockUpdatePasswordUsecase mockUpdatePasswordUsecase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;
  late MockUserSessionService mockUserSessionService;

  setUpAll(() {
    registerFallbackValue(FakeLoginParams());
  });

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockSendRequestUsecase = MockSendRequestUsecase();
    mockUpdatePasswordUsecase = MockUpdatePasswordUsecase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();
    mockUserSessionService = MockUserSessionService();

    // Default setups
    when(() => mockUserSessionService.hasValidSession()).thenAnswer((_) async => false);
  });

  Widget createLoginPage() {
    return ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        sendRequestUsecaseProvider.overrideWithValue(mockSendRequestUsecase),
        updatePasswordUsecaseProvider.overrideWithValue(mockUpdatePasswordUsecase),
        updateProfileUsecaseProvider.overrideWithValue(mockUpdateProfileUsecase),
        userSessionServiceProvider.overrideWithValue(mockUserSessionService),
      ],
      child: const MaterialApp(
        home: LoginPage(),
      ),
    );
  }

  group('LoginPage Widget Test', () {
    testWidgets('renders all UI elements', (tester) async {
      await tester.pumpWidget(createLoginPage());

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Login to DineSmart →'), findsOneWidget);
    });

    testWidgets('shows validation errors for empty fields', (tester) async {
      await tester.pumpWidget(createLoginPage());

      final loginButton = find.text('Login to DineSmart →');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.text('Please enter your email.'), findsOneWidget);
      expect(find.text('Please enter your password.'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email', (tester) async {
      await tester.pumpWidget(createLoginPage());

      await tester.enterText(find.byType(TextField).first, 'invalid-email');
      
      final loginButton = find.text('Login to DineSmart →');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.text('Enter a valid email.'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(createLoginPage());

      final passwordField = find.byType(TextFormField).last;
      await tester.ensureVisible(passwordField);
      expect(tester.widget<TextField>(find.descendant(of: passwordField, matching: find.byType(TextField))).obscureText, true);

      await tester.tap(find.byIcon(Icons.visibility_off_rounded));
      await tester.pump();

      expect(tester.widget<TextField>(find.descendant(of: passwordField, matching: find.byType(TextField))).obscureText, false);

      await tester.tap(find.byIcon(Icons.visibility_rounded));
      await tester.pump();

      expect(tester.widget<TextField>(find.descendant(of: passwordField, matching: find.byType(TextField))).obscureText, true);
    });

    testWidgets('calls login on ViewModel when form is valid', (tester) async {
      await tester.pumpWidget(createLoginPage());

      when(() => mockLoginUsecase(any())).thenAnswer(
        (_) async => Right(TestData.authEntity()),
      );

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      
      final loginButton = find.text('Login to DineSmart →');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pump();

      verify(() => mockLoginUsecase(any())).called(1);
    });

    testWidgets('displays error snackbar on login failure', (tester) async {
      await tester.pumpWidget(createLoginPage());

      const errorMessage = 'Invalid credentials';
      when(() => mockLoginUsecase(any())).thenAnswer(
        (_) async => const Left(ApiFailure(message: errorMessage)),
      );

      await tester.enterText(find.byType(TextField).first, 'test@example.com');
      await tester.enterText(find.byType(TextField).last, 'password123');
      
      final loginButton = find.text('Login to DineSmart →');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pump(const Duration(milliseconds: 100)); // Allow for state change
      await tester.pump(); // Allow for snackbar to show

      expect(find.text(errorMessage), findsOneWidget);
    });
  });
}
