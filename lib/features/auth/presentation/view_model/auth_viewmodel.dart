import 'package:dinesmart_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:dinesmart_app/features/auth/domain/usecases/send_request_usecase.dart';
import 'package:dinesmart_app/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  AuthViewModel.new,
);

class AuthViewModel extends Notifier<AuthState> {
  late final SendRequestUsecase _sendRequestUsecase;
  late final LoginUsecase _loginUsecase;
  late final LogoutUsecase _logoutUsecase;

  @override
  AuthState build() {
    _sendRequestUsecase = ref.read(sendRequestUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _logoutUsecase = ref.read(logoutUsecaseProvider);
    return const AuthState();
  }

  Future<void> sendRequest({
    required String restaurantName,
    required String ownerName,
    required String email,
    required String phoneNumber,
    required String address,
    required String message,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _sendRequestUsecase(
      SendRequestParams(
        restaurantName: restaurantName,
        ownerName: ownerName,
        email: email,
        phoneNumber: phoneNumber,
        address: address,
        message: message,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        status: AuthStatus.registered,
        errorMessage: null,
      ),
    );
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _loginUsecase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      ),
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (_) => state = const AuthState(status: AuthStatus.initial),
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
