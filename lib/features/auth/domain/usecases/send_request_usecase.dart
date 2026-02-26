import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/usecase/app_usecases.dart';
import 'package:dinesmart_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dinesmart_app/features/auth/domain/entities/auth_entity.dart';
import 'package:dinesmart_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SendRequestParams extends Equatable {
  final String restaurantName;
  final String ownerName;
  final String email;
  final String phoneNumber;
  final String address;
  final String message;

  const SendRequestParams({
    required this.restaurantName,
    required this.ownerName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.message,
  });

  @override
  List<Object?> get props => [
    restaurantName,
    ownerName,
    email,
    phoneNumber,
    address,
    message,
  ];
}

final sendRequestUsecaseProvider = Provider<SendRequestUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return SendRequestUsecase(authRepository: authRepository);
});

class SendRequestUsecase implements UsecaseWithParms<bool, SendRequestParams> {
  final IAuthRepository _authRepository;

  SendRequestUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(SendRequestParams params) {
    return _authRepository.sendRequest(
      AuthEntity(
        restaurantName: params.restaurantName,
        ownerName: params.ownerName,
        email: params.email,
        phoneNumber: params.phoneNumber,
        address: params.address,
        message: params.message,
      ),
    );
  }
}
