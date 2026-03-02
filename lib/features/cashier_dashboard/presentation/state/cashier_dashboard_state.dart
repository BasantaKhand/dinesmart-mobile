import 'package:equatable/equatable.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';

enum CashierDashboardStatus { initial, loading, success, error }

class CashierDashboardState extends Equatable {
  final CashierDashboardStatus status;
  final List<PaymentQueueItem> paymentQueue;
  final List<Settlement> recentSettlements;
  final TodaySettlement? todaySettlement;
  final CashDrawerStatus? drawerStatus;
  final bool isOffline;
  final String? errorMessage;
  final bool isSettling;

  const CashierDashboardState({
    this.status = CashierDashboardStatus.initial,
    this.paymentQueue = const [],
    this.recentSettlements = const [],
    this.todaySettlement,
    this.drawerStatus,
    this.isOffline = false,
    this.errorMessage,
    this.isSettling = false,
  });

  /// Computed stats from the data we already have
  CashierStats get stats => CashierStats(
    collectionsToday: todaySettlement?.totalCollection ?? 0,
    billsClosedToday: todaySettlement?.totalBills ?? 0,
    pendingPayments: paymentQueue.length,
    avgBillSize: recentSettlements.isNotEmpty
        ? recentSettlements.fold(0.0, (sum, s) => sum + s.totalAmount) / recentSettlements.length
        : 0,
    cashCollected: todaySettlement?.cashAmount ?? 0,
  );

  CashierDashboardState copyWith({
    CashierDashboardStatus? status,
    List<PaymentQueueItem>? paymentQueue,
    List<Settlement>? recentSettlements,
    TodaySettlement? todaySettlement,
    CashDrawerStatus? drawerStatus,
    bool? isOffline,
    String? errorMessage,
    bool? isSettling,
  }) {
    return CashierDashboardState(
      status: status ?? this.status,
      paymentQueue: paymentQueue ?? this.paymentQueue,
      recentSettlements: recentSettlements ?? this.recentSettlements,
      todaySettlement: todaySettlement ?? this.todaySettlement,
      drawerStatus: drawerStatus ?? this.drawerStatus,
      isOffline: isOffline ?? this.isOffline,
      errorMessage: errorMessage,
      isSettling: isSettling ?? this.isSettling,
    );
  }

  @override
  List<Object?> get props => [status, paymentQueue, recentSettlements, todaySettlement, drawerStatus, isOffline, errorMessage, isSettling];
}
