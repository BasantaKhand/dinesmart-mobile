import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/features/auth/domain/entities/auth_entity.dart';
import 'package:dinesmart_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dinesmart_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return UpdateProfileUsecase(repository: repository);
});

class UpdateProfileParams {
  final String? ownerName;
  final String? phoneNumber;
  final String? profilePicture;

  UpdateProfileParams({
    this.ownerName,
    this.phoneNumber,
    this.profilePicture,
  });
}

class UpdateProfileUsecase {
  final IAuthRepository _repository;

  UpdateProfileUsecase({required IAuthRepository repository}) : _repository = repository;

  Future<Either<Failure, AuthEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      ownerName: params.ownerName,
      phoneNumber: params.phoneNumber,
      profilePicture: params.profilePicture,
    );
  }
}
