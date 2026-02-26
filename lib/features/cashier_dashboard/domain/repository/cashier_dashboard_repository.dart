import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';
import 'package:dinesmart_app/features/cashier_dashboard/data/repositories/cashier_dashboard_repository_impl.dart';

abstract class ICashierDashboardRepository {
  Future<Either<Failure, CashierStats>> getCashierStats();
  Future<Either<Failure, List<PaymentQueueItem>>> getPaymentQueue();
  Future<Either<Failure, List<Settlement>>> getRecentSettlements();
  Future<Either<Failure, bool>> settlePayment(String orderId, String paymentMethod, {String? transactionId, String? notes});
  Future<Either<Failure, bool>> openCashDrawer(double openingAmount, {String? notes});
  Future<Either<Failure, bool>> closeCashDrawer(double closingAmount, {String? notes});
}

final cashierDashboardRepositoryProvider = Provider<ICashierDashboardRepository>((ref) {
  return ref.read(cashierDashboardRepositoryImplProvider);
});
