import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/repository/cashier_dashboard_repository.dart';
import 'package:dinesmart_app/features/cashier_dashboard/data/data_sources/cashier_remote_data_source.dart';

final cashierDashboardRepositoryImplProvider = Provider<ICashierDashboardRepository>((ref) {
  return CashierDashboardRepositoryImpl(ref.read(cashierRemoteDataSourceProvider));
});

class CashierDashboardRepositoryImpl implements ICashierDashboardRepository {
  final CashierRemoteDataSource _remoteDataSource;

  CashierDashboardRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, CashierStats>> getCashierStats() async {
    try {
      final model = await _remoteDataSource.getCashierStats();
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
  Future<Either<Failure, List<PaymentQueueItem>>> getPaymentQueue() async {
    try {
      final models = await _remoteDataSource.getPaymentQueue();
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
  Future<Either<Failure, List<Settlement>>> getRecentSettlements() async {
    // Current backend doesn't have a direct "recent settlements" endpoint, 
    // we might need to fetch from orders with COMPLETED status or wait for specific API.
    // For now, returning empty list or fetching COMPLETED orders.
    return const Right([]);
  }

  @override
  Future<Either<Failure, bool>> settlePayment(String orderId, String paymentMethod, {String? transactionId, String? notes}) async {
    try {
      final result = await _remoteDataSource.settlePayment(orderId, paymentMethod, transactionId: transactionId, notes: notes);
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> openCashDrawer(double openingAmount, {String? notes}) async {
    try {
      final result = await _remoteDataSource.openCashDrawer(openingAmount, notes: notes);
      return Right(result);
    } on DioException catch (e) {
      return Left(ApiFailure(
          message: e.response?.data['message'] ?? e.message ?? 'Operation failed',
          statusCode: e.response?.statusCode));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> closeCashDrawer(double closingAmount, {String? notes}) async {
    // Implementation for close drawer
    return const Right(true);
  }
}
