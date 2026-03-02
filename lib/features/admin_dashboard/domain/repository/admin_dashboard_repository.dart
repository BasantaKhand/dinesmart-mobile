import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/services/connectivity/network_info.dart';
import 'package:dinesmart_app/features/admin_dashboard/domain/entities/admin_statistics.dart';
import 'package:dinesmart_app/features/admin_dashboard/data/data_sources/admin_dashboard_remote_data_source.dart';
import 'package:dinesmart_app/features/admin_dashboard/data/data_sources/admin_dashboard_local_data_source.dart';

abstract class IAdminDashboardRepository {
  Future<Either<Failure, AdminStatistics>> getOverview(int days);
  Future<Either<Failure, List<SalesData>>> getSalesOverview(int days);
  Future<Either<Failure, List<CategorySalesData>>> getCategorySales(int days);
}

final adminDashboardRepositoryProvider = Provider<IAdminDashboardRepository>((ref) {
  return AdminDashboardRepositoryImpl(
    remoteDataSource: ref.read(adminDashboardRemoteDataSourceProvider),
    localDataSource: ref.read(adminDashboardLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class AdminDashboardRepositoryImpl implements IAdminDashboardRepository {
  final AdminDashboardRemoteDataSource _remoteDataSource;
  final AdminDashboardLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  AdminDashboardRepositoryImpl({
    required AdminDashboardRemoteDataSource remoteDataSource,
    required AdminDashboardLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AdminStatistics>> getOverview(int days) async {
    if (await _networkInfo.isConnected) {
      try {
        final model = await _remoteDataSource.getOverview(days);
        await _localDataSource.saveOverview(days, model);
        return Right(model.toEntity());
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch overview',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      final cached = _localDataSource.getOverview(days);
      if (cached != null) return Right(cached);
      return const Left(Failure('No internet connection and no cached data'));
    }
  }

  @override
  Future<Either<Failure, List<SalesData>>> getSalesOverview(int days) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getSalesOverview(days);
        await _localDataSource.saveSalesOverview(days, models);
        return Right(models.map((m) => m.toEntity()).toList());
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch sales',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      final cached = _localDataSource.getSalesOverview(days);
      return Right(cached);
    }
  }

  @override
  Future<Either<Failure, List<CategorySalesData>>> getCategorySales(int days) async {
    if (await _networkInfo.isConnected) {
      try {
        final models = await _remoteDataSource.getCategorySales(days);
        await _localDataSource.saveCategorySales(days, models);
        return Right(models.map((m) => m.toEntity()).toList());
      } on DioException catch (e) {
        return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch category sales',
          statusCode: e.response?.statusCode,
        ));
      } catch (e) {
        return Left(Failure(e.toString()));
      }
    } else {
      final cached = _localDataSource.getCategorySales(days);
      return Right(cached);
    }
  }
}
