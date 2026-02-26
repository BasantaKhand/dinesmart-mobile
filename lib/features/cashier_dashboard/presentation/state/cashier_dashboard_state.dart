import 'package:equatable/equatable.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';

enum CashierDashboardStatus { initial, loading, success, error }

class CashierDashboardState extends Equatable {
  final CashierDashboardStatus status;
  final CashierStats? stats;
  final List<PaymentQueueItem> paymentQueue;
  final List<Settlement> recentSettlements;
  final String? errorMessage;

  const CashierDashboardState({
    this.status = CashierDashboardStatus.initial,
    this.stats,
    this.paymentQueue = const [],
    this.recentSettlements = const [],
    this.errorMessage,
  });

  CashierDashboardState copyWith({
    CashierDashboardStatus? status,
    CashierStats? stats,
    List<PaymentQueueItem>? paymentQueue,
    List<Settlement>? recentSettlements,
    String? errorMessage,
  }) {
    return CashierDashboardState(
      status: status ?? this.status,
      stats: stats ?? this.stats,
      paymentQueue: paymentQueue ?? this.paymentQueue,
      recentSettlements: recentSettlements ?? this.recentSettlements,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, stats, paymentQueue, recentSettlements, errorMessage];
}
