import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/use_cases/cashier_usecases.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/state/cashier_dashboard_state.dart';

final cashierDashboardViewModelProvider =
    StateNotifierProvider<CashierDashboardViewModel, CashierDashboardState>((ref) {
  return CashierDashboardViewModel(
    getPaymentQueueUseCase: ref.read(getPaymentQueueUseCaseProvider),
    getRecentSettlementsUseCase: ref.read(getRecentSettlementsUseCaseProvider),
    getTodaySettlementUseCase: ref.read(getTodaySettlementUseCaseProvider),
    getDrawerStatusUseCase: ref.read(getDrawerStatusUseCaseProvider),
    settlePaymentUseCase: ref.read(settlePaymentUseCaseProvider),
    openCashDrawerUseCase: ref.read(openCashDrawerUseCaseProvider),
    closeCashDrawerUseCase: ref.read(closeCashDrawerUseCaseProvider),
  );
});

class CashierDashboardViewModel extends StateNotifier<CashierDashboardState> {
  final GetPaymentQueueUseCase getPaymentQueueUseCase;
  final GetRecentSettlementsUseCase getRecentSettlementsUseCase;
  final GetTodaySettlementUseCase getTodaySettlementUseCase;
  final GetDrawerStatusUseCase getDrawerStatusUseCase;
  final SettlePaymentUseCase settlePaymentUseCase;
  final OpenCashDrawerUseCase openCashDrawerUseCase;
  final CloseCashDrawerUseCase closeCashDrawerUseCase;

  CashierDashboardViewModel({
    required this.getPaymentQueueUseCase,
    required this.getRecentSettlementsUseCase,
    required this.getTodaySettlementUseCase,
    required this.getDrawerStatusUseCase,
    required this.settlePaymentUseCase,
    required this.openCashDrawerUseCase,
    required this.closeCashDrawerUseCase,
  }) : super(const CashierDashboardState()) {
    initialize();
  }

  Future<void> initialize() async {
    state = state.copyWith(status: CashierDashboardStatus.loading);

    // Fetch all data in parallel
    final queueResult = await getPaymentQueueUseCase();
    final settlementsResult = await getRecentSettlementsUseCase();
    final todayResult = await getTodaySettlementUseCase();
    final drawerResult = await getDrawerStatusUseCase();

    List<PaymentQueueItem> queue = [];
    List<Settlement> settlements = [];
    TodaySettlement? todaySettlement;
    CashDrawerStatus? drawerStatus;
    String? errorMsg;

    queueResult.fold(
      (failure) => errorMsg = failure.message,
      (data) => queue = data,
    );

    settlementsResult.fold(
      (_) {},
      (data) => settlements = data,
    );

    todayResult.fold(
      (_) {},
      (data) => todaySettlement = data,
    );

    drawerResult.fold(
      (_) {},
      (data) => drawerStatus = data,
    );

    state = state.copyWith(
      status: errorMsg != null && queue.isEmpty
          ? CashierDashboardStatus.error
          : CashierDashboardStatus.success,
      paymentQueue: queue,
      recentSettlements: settlements,
      todaySettlement: todaySettlement,
      drawerStatus: drawerStatus,
      errorMessage: errorMsg,
    );
  }

  Future<void> markOrderPaid(
    String orderId, {
    String? transactionId,
    String paymentMethod = 'CASH',
    String? notes,
  }) async {
    state = state.copyWith(isSettling: true);

    final result = await settlePaymentUseCase(
      orderId: orderId,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      notes: notes,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isSettling: false,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(isSettling: false);
        refresh();
      },
    );
  }

  Future<void> openDrawer(double openingAmount, {String? notes}) async {
    state = state.copyWith(status: CashierDashboardStatus.loading);

    final result = await openCashDrawerUseCase(openingAmount, notes: notes);

    result.fold(
      (failure) => state = state.copyWith(
        status: CashierDashboardStatus.error,
        errorMessage: failure.message,
      ),
      (_) => refresh(),
    );
  }

  Future<void> closeDrawer(double closingAmount, {String? notes}) async {
    state = state.copyWith(status: CashierDashboardStatus.loading);

    final result = await closeCashDrawerUseCase(closingAmount, notes: notes);

    result.fold(
      (failure) => state = state.copyWith(
        status: CashierDashboardStatus.error,
        errorMessage: failure.message,
      ),
      (_) => refresh(),
    );
  }

  Future<void> refresh() => initialize();
}
