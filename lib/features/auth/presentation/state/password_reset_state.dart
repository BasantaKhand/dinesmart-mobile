import 'package:equatable/equatable.dart';

enum PasswordResetStatus { initial, loading, success, error }

class PasswordResetState extends Equatable {
  final PasswordResetStatus status;
  final String? errorMessage;
  final String? successMessage;

  const PasswordResetState({
    this.status = PasswordResetStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  PasswordResetState copyWith({
    PasswordResetStatus? status,
    String? errorMessage,
    String? successMessage,
  }) {
    return PasswordResetState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, successMessage];
}
