import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/features/admin_dashboard/domain/entities/admin_statistics.dart';
import 'package:dinesmart_app/features/admin_dashboard/data/data_sources/admin_dashboard_remote_data_source.dart';

abstract class IAdminDashboardRepository {
  Future<Either<Failure, AdminStatistics>> getOverview(int days);
  Future<Either<Failure, List<SalesData>>> getSalesOverview(int days);
  Future<Either<Failure, List<CategorySalesData>>> getCategorySales(int days);
}

final adminDashboardRepositoryProvider = Provider<IAdminDashboardRepository>((ref) {
  return AdminDashboardRepositoryImpl(ref.read(adminDashboardRemoteDataSourceProvider));
});

class AdminDashboardRepositoryImpl implements IAdminDashboardRepository {
  final AdminDashboardRemoteDataSource _remoteDataSource;

  AdminDashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, AdminStatistics>> getOverview(int days) async {
    try {
      final model = await _remoteDataSource.getOverview(days);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalesData>>> getSalesOverview(int days) async {
    try {
      final models = await _remoteDataSource.getSalesOverview(days);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategorySalesData>>> getCategorySales(int days) async {
    try {
      final models = await _remoteDataSource.getCategorySales(days);
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
