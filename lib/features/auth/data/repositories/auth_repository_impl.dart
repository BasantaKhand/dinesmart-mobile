import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/services/connectivity/network_info.dart';
import 'package:dinesmart_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:dinesmart_app/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:dinesmart_app/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:dinesmart_app/features/auth/data/models/auth_api_model.dart';
import 'package:dinesmart_app/features/auth/domain/entities/auth_entity.dart';
import 'package:dinesmart_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authLocalDatasource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepositoryImpl(
    authLocalDatasource: authLocalDatasource,
    authRemoteDatasource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepositoryImpl implements IAuthRepository {
  final ILocalAuthDatasource _authLocalDatasource;
  final IRemoteAuthDatasource _authRemoteDatasource;
  final INetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required ILocalAuthDatasource authLocalDatasource,
    required IRemoteAuthDatasource authRemoteDatasource,
    required INetworkInfo networkInfo,
  }) : _authLocalDatasource = authLocalDatasource,
       _authRemoteDatasource = authRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> sendRequest(AuthEntity entity) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final model = AuthApiModel.fromEntity(entity);
      final result = await _authRemoteDatasource.sendRequest(model);
      if (result) {
        return const Right(true);
      }
      return const Left(ApiFailure(message: 'Request submission failed'));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data?['message']?.toString() ?? 'Request submission failed',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    if (await _networkInfo.isConnected) {
      try {
        final authApiModel = await _authRemoteDatasource.login(email, password);
        if (authApiModel == null) {
          return const Left(ApiFailure(message: 'Invalid email or password'));
        }
        return Right(authApiModel.toEntity());
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data?['message']?.toString() ?? 'Login failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    }

    try {
      final localModel = await _authLocalDatasource.login(email, password);
      if (localModel == null) {
        return const Left(LocalDatabaseFailure(message: 'Invalid email or password'));
      }
      return Right(localModel.toEntity());
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authLocalDatasource.logout();
      if (result) {
        return const Right(true);
      }
      return const Left(LocalDatabaseFailure(message: 'Failed to logout'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> changePassword(String currentPassword, String newPassword) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final result = await _authRemoteDatasource.changePassword(currentPassword, newPassword);
      if (result) {
        return const Right(true);
      }
      return const Left(ApiFailure(message: 'Failed to change password'));
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data?['message']?.toString() ?? 'Failed to change password',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> updateProfile({String? ownerName, String? phoneNumber, String? profilePicture}) async {
    final isConnected = await _networkInfo.isConnected;
    if (!isConnected) {
      return const Left(ApiFailure(message: 'No internet connection'));
    }

    try {
      final authApiModel = await _authRemoteDatasource.updateProfile(
        ownerName: ownerName,
        phoneNumber: phoneNumber,
        profilePicture: profilePicture,
      );
      if (authApiModel == null) {
        return const Left(ApiFailure(message: 'Failed to update profile'));
      }
      return Right(authApiModel.toEntity());
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message: e.response?.data?['message']?.toString() ?? 'Failed to update profile',
          statusCode: e.response?.statusCode,
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}
