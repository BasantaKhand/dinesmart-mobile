import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/features/auth/domain/entities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> sendRequest(AuthEntity entity);
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, bool>> changePassword(String currentPassword, String newPassword);
  Future<Either<Failure, AuthEntity>> updateProfile({String? ownerName, String? phoneNumber, String? profilePicture});
}
