import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/repository/cashier_dashboard_repository.dart';

final getCashierStatsUseCaseProvider = Provider((ref) {
  return GetCashierStatsUseCase(ref.read(cashierDashboardRepositoryProvider));
});

class GetCashierStatsUseCase {
  final ICashierDashboardRepository _repository;
  GetCashierStatsUseCase(this._repository);
  Future<Either<Failure, CashierStats>> call() => _repository.getCashierStats();
}

final getPaymentQueueUseCaseProvider = Provider((ref) {
  return GetPaymentQueueUseCase(ref.read(cashierDashboardRepositoryProvider));
});

class GetPaymentQueueUseCase {
  final ICashierDashboardRepository _repository;
  GetPaymentQueueUseCase(this._repository);
  Future<Either<Failure, List<PaymentQueueItem>>> call() => _repository.getPaymentQueue();
}

final settlePaymentUseCaseProvider = Provider((ref) {
  return SettlePaymentUseCase(ref.read(cashierDashboardRepositoryProvider));
});

class SettlePaymentUseCase {
  final ICashierDashboardRepository _repository;
  SettlePaymentUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required String orderId,
    required String paymentMethod,
    String? transactionId,
    String? notes,
  }) {
    return _repository.settlePayment(
      orderId,
      paymentMethod,
      transactionId: transactionId,
      notes: notes,
    );
  }
}
