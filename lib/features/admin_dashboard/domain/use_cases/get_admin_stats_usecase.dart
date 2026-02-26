import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/failure.dart';
import '../entities/admin_statistics.dart';
import '../repository/admin_dashboard_repository.dart';

final getAdminStatsUseCaseProvider = Provider((ref) {
  return GetAdminStatsUseCase(ref.read(adminDashboardRepositoryProvider));
});

class GetAdminStatsUseCase {
  final IAdminDashboardRepository _repository;
  GetAdminStatsUseCase(this._repository);

  Future<Either<Failure, AdminStatistics>> getOverview(int days) =>
      _repository.getOverview(days);

  Future<Either<Failure, List<SalesData>>> getSalesOverview(int days) =>
      _repository.getSalesOverview(days);

  Future<Either<Failure, List<CategorySalesData>>> getCategorySales(int days) =>
      _repository.getCategorySales(days);
}
