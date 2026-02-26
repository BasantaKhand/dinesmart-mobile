import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dinesmart_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updatePasswordUsecaseProvider = Provider<UpdatePasswordUsecase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return UpdatePasswordUsecase(repository: repository);
});

class UpdatePasswordParams {
  final String currentPassword;
  final String newPassword;

  UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}

class UpdatePasswordUsecase {
  final IAuthRepository _repository;

  UpdatePasswordUsecase({required IAuthRepository repository})
      : _repository = repository;

  Future<Either<Failure, bool>> call(UpdatePasswordParams params) async {
    return await _repository.changePassword(
      params.currentPassword,
      params.newPassword,
    );
  }
}
