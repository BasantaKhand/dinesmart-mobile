import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/error_utils.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/repository/staff_repository.dart';
import '../data_sources/staff_remote_data_source.dart';
import '../models/staff_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final staffRepositoryProvider = Provider<IStaffRepository>((ref) {
  return StaffRepositoryImpl(ref.read(staffRemoteDataSourceProvider));
});

class StaffRepositoryImpl implements IStaffRepository {
  final StaffRemoteDataSource _remoteDataSource;

  StaffRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<StaffEntity>>> getStaff() async {
    try {
      final result = await _remoteDataSource.getStaff();
      return Right(result.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ApiFailure(message: ErrorUtils.getMessage(e)));
    }
  }

  @override
  Future<Either<Failure, StaffEntity>> createStaff(StaffEntity staff) async {
    try {
      final model = StaffApiModel.fromEntity(staff);
      final result = await _remoteDataSource.createStaff(model);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: ErrorUtils.getMessage(e)));
    }
  }

  @override
  Future<Either<Failure, StaffEntity>> updateStaff(StaffEntity staff) async {
    try {
      final model = StaffApiModel.fromEntity(staff);
      final result = await _remoteDataSource.updateStaff(staff.id, model);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: ErrorUtils.getMessage(e)));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteStaff(String id) async {
    try {
      final result = await _remoteDataSource.deleteStaff(id);
      return Right(result);
    } catch (e) {
      return Left(ApiFailure(message: ErrorUtils.getMessage(e)));
    }
  }

  @override
  Future<Either<Failure, StaffEntity>> toggleStaffStatus(String id) async {
    try {
      final result = await _remoteDataSource.toggleStaffStatus(id);
      return Right(result.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: ErrorUtils.getMessage(e)));
    }
  }
}
