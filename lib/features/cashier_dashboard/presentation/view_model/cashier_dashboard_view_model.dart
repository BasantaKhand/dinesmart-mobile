import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/use_cases/cashier_usecases.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/state/cashier_dashboard_state.dart';

final cashierDashboardViewModelProvider =
    StateNotifierProvider<CashierDashboardViewModel, CashierDashboardState>((ref) {
  return CashierDashboardViewModel(
    getCashierStatsUseCase: ref.read(getCashierStatsUseCaseProvider),
    getPaymentQueueUseCase: ref.read(getPaymentQueueUseCaseProvider),
    settlePaymentUseCase: ref.read(settlePaymentUseCaseProvider),
  );
});

class CashierDashboardViewModel extends StateNotifier<CashierDashboardState> {
  final GetCashierStatsUseCase getCashierStatsUseCase;
  final GetPaymentQueueUseCase getPaymentQueueUseCase;
  final SettlePaymentUseCase settlePaymentUseCase;

  CashierDashboardViewModel({
    required this.getCashierStatsUseCase,
    required this.getPaymentQueueUseCase,
    required this.settlePaymentUseCase,
  }) : super(const CashierDashboardState()) {
    initialize();
  }

  Future<void> initialize() async {
    state = state.copyWith(status: CashierDashboardStatus.loading);
    
    final statsResult = await getCashierStatsUseCase();
    final queueResult = await getPaymentQueueUseCase();

    statsResult.fold(
      (failure) => state = state.copyWith(status: CashierDashboardStatus.error, errorMessage: failure.message),
      (stats) {
        queueResult.fold(
          (failure) => state = state.copyWith(status: CashierDashboardStatus.error, errorMessage: failure.message),
          (queue) => state = state.copyWith(
            status: CashierDashboardStatus.success,
            stats: stats,
            paymentQueue: queue,
          ),
        );
      },
    );
  }

  Future<void> markOrderPaid(String orderId, {String? transactionId, String? paymentMethod = 'CASH', String? notes}) async {
    state = state.copyWith(status: CashierDashboardStatus.loading);
    
    final result = await settlePaymentUseCase(
      orderId: orderId,
      paymentMethod: paymentMethod ?? 'CASH',
      transactionId: transactionId,
      notes: notes,
    );

    result.fold(
      (failure) => state = state.copyWith(status: CashierDashboardStatus.error, errorMessage: failure.message),
      (success) => refresh(),
    );
  }

  Future<void> refresh() => initialize();
}
