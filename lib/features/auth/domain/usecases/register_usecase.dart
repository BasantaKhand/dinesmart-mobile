import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/usecase/app_usecases.dart';
import 'package:dinesmart_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dinesmart_app/features/auth/domain/entities/auth_entity.dart';
import 'package:dinesmart_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterParams extends Equatable {
  final String fullName;
  final String email;
  final String username;
  final String password;
  final String? phoneNumber;

  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.username,
    required this.password,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [
    fullName,
    email,
    username,
    password,
    phoneNumber,
  ];
}

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase implements UsecaseWithParms<bool, RegisterParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterParams params) {
    return _authRepository.sendRequest(
      AuthEntity(
        restaurantName: '',
        ownerName: params.fullName,
        email: params.email,
        phoneNumber: params.phoneNumber ?? '',
        address: '',
        message: '',
        username: params.username,
        password: params.password,
      ),
    );
  }
}
