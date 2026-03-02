import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/repository/cashier_dashboard_repository.dart';

// ─── Payment Queue ───

final getPaymentQueueUseCaseProvider = Provider((ref) {
  return GetPaymentQueueUseCase(ref.read(cashierDashboardRepositoryProvider));
});

class GetPaymentQueueUseCase {
  final ICashierDashboardRepository _repository;
  GetPaymentQueueUseCase(this._repository);
  Future<Either<Failure, List<PaymentQueueItem>>> call() => _repository.getPaymentQueue();
}

// ─── Recent Settlements ───

final getRecentSettlementsUseCaseProvider = Provider((ref) {
  return GetRecentSettlementsUseCase(ref.read(cashierDashboardRepositoryProvider));
});

class GetRecentSettlementsUseCase {
  final ICashierDashboardRepository _repository;
  GetRecentSettlementsUseCase(this._repository);
  Future<Either<Failure, List<Settlement>>> call() => _repository.getRecentSettlements();
}

// ─── Today Settlement ───

final getTodaySettlementUseCaseProvider = Provider((ref) {
  return GetTodaySettlementUseCase(ref.read(cashierDashboardRepositoryProvider));
});

class GetTodaySettlementUseCase {
  final ICashierDashboardRepository _repository;
  GetTodaySettlementUseCase(this._repository);
  Future<Either<Failure, TodaySettlement>> call() => _repository.getTodaySettlement();
}

// ─── Settle Payment ───

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

// ─── Drawer Status ───

final getDrawerStatusUseCaseProvider = Provider((ref) {
  return GetDrawerStatusUseCase(ref.read(cashierDashboardRepositoryProvider));
});

class GetDrawerStatusUseCase {
  final ICashierDashboardRepository _repository;
  GetDrawerStatusUseCase(this._repository);
  Future<Either<Failure, CashDrawerStatus>> call() => _repository.getDrawerStatus();
}

// ─── Open Cash Drawer ───

final openCashDrawerUseCaseProvider = Provider((ref) {
  return OpenCashDrawerUseCase(ref.read(cashierDashboardRepositoryProvider));
});

class OpenCashDrawerUseCase {
  final ICashierDashboardRepository _repository;
  OpenCashDrawerUseCase(this._repository);
  Future<Either<Failure, bool>> call(double openingAmount, {String? notes}) =>
      _repository.openCashDrawer(openingAmount, notes: notes);
}

// ─── Close Cash Drawer ───

final closeCashDrawerUseCaseProvider = Provider((ref) {
  return CloseCashDrawerUseCase(ref.read(cashierDashboardRepositoryProvider));
});

class CloseCashDrawerUseCase {
  final ICashierDashboardRepository _repository;
  CloseCashDrawerUseCase(this._repository);
  Future<Either<Failure, bool>> call(double closingAmount, {String? notes}) =>
      _repository.closeCashDrawer(closingAmount, notes: notes);
}
