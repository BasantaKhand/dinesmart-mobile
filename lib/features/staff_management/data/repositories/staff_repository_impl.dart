import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/error_utils.dart';
import '../../../../core/services/connectivity/network_info.dart';
import '../../domain/entities/staff_entity.dart';
import '../../domain/repository/staff_repository.dart';
import '../data_sources/staff_remote_data_source.dart';
import '../data_sources/staff_local_data_source.dart';
import '../models/staff_api_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final staffRepositoryProvider = Provider<IStaffRepository>((ref) {
  return StaffRepositoryImpl(
    remoteDataSource: ref.read(staffRemoteDataSourceProvider),
    localDataSource: ref.read(staffLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class StaffRepositoryImpl implements IStaffRepository {
  final StaffRemoteDataSource _remoteDataSource;
  final StaffLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  StaffRepositoryImpl({
    required StaffRemoteDataSource remoteDataSource,
    required StaffLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<StaffEntity>>> getStaff() async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _remoteDataSource.getStaff();
        await _localDataSource.saveStaff(result);
        return Right(result.map((m) => m.toEntity()).toList());
      } catch (e) {
        return Left(ApiFailure(message: ErrorUtils.getMessage(e)));
      }
    } else {
      final cached = _localDataSource.getStaff();
      return Right(cached);
    }
  }

  @override
  Future<Either<Failure, ({StaffEntity staff, Map<String, dynamic>? credentials})>> createStaff(StaffEntity staff) async {
    try {
      final model = StaffApiModel.fromEntity(staff);
      final result = await _remoteDataSource.createStaff(model);
      _localDataSource.invalidateCache();
      return Right((staff: result.staff.toEntity(), credentials: result.credentials));
    } catch (e) {
      return Left(ApiFailure(message: ErrorUtils.getMessage(e)));
    }
  }

  @override
  Future<Either<Failure, StaffEntity>> updateStaff(StaffEntity staff) async {
    try {
      final model = StaffApiModel.fromEntity(staff);
      final result = await _remoteDataSource.updateStaff(staff.id, model);
      _localDataSource.invalidateCache();
      return Right(result.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: ErrorUtils.getMessage(e)));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteStaff(String id) async {
    try {
      final result = await _remoteDataSource.deleteStaff(id);
      _localDataSource.invalidateCache();
      return Right(result);
    } catch (e) {
      return Left(ApiFailure(message: ErrorUtils.getMessage(e)));
    }
  }

  @override
  Future<Either<Failure, StaffEntity>> toggleStaffStatus(String id) async {
    try {
      final result = await _remoteDataSource.toggleStaffStatus(id);
      _localDataSource.invalidateCache();
      return Right(result.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: ErrorUtils.getMessage(e)));
    }
  }
}
