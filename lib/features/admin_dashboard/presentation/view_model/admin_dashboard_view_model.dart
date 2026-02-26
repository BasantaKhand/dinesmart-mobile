import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/use_cases/get_orders_usecase.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/use_cases/update_order_status_usecase.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/order_entity.dart';
import 'package:dinesmart_app/features/admin_dashboard/domain/use_cases/get_admin_stats_usecase.dart';
import 'package:dinesmart_app/features/admin_dashboard/presentation/state/admin_dashboard_state.dart';

final adminDashboardViewModelProvider =
    StateNotifierProvider<AdminDashboardViewModel, AdminDashboardState>((ref) {
  return AdminDashboardViewModel(
    getOrdersUseCase: ref.read(getOrdersUseCaseProvider),
    updateOrderStatusUseCase: ref.read(updateOrderStatusUseCaseProvider),
    getAdminStatsUseCase: ref.read(getAdminStatsUseCaseProvider),
  );
});

class AdminDashboardViewModel extends StateNotifier<AdminDashboardState> {
  final GetOrdersUseCase getOrdersUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final GetAdminStatsUseCase getAdminStatsUseCase;

  AdminDashboardViewModel({
    required this.getOrdersUseCase,
    required this.updateOrderStatusUseCase,
    required this.getAdminStatsUseCase,
  }) : super(const AdminDashboardState()) {
    initialize();
  }

  Future<void> initialize() async {
    state = state.copyWith(status: AdminDashboardStatus.loading);
    
    final result = await getOrdersUseCase();
    
    result.fold(
      (failure) {
        debugPrint('DEBUG: AdminDashboard FETCH ERROR: ${failure.message}');
        state = state.copyWith(
          status: AdminDashboardStatus.error,
          errorMessage: failure.message,
        );
      },
      (orders) {
        debugPrint('DEBUG: AdminDashboard FETCH SUCCESS: ${orders.length} orders found');
        state = state.copyWith(
          status: AdminDashboardStatus.success,
          orders: orders,
        );
        fetchStatistics();
      },
    );
  }

  Future<void> fetchStatistics({int days = 30}) async {
    final results = await Future.wait([
      getAdminStatsUseCase.getOverview(days),
      getAdminStatsUseCase.getSalesOverview(days),
      getAdminStatsUseCase.getCategorySales(days),
    ]);

    final overviewResult = results[0] as dynamic; // dartz Either
    final salesResult = results[1] as dynamic;
    final categoryResult = results[2] as dynamic;

    overviewResult.fold(
      (failure) {},
      (stats) {
        state = state.copyWith(adminStatistics: stats);
      },
    );

    salesResult.fold(
      (failure) {},
      (sales) {
        state = state.copyWith(salesData: sales);
      },
    );

    categoryResult.fold(
      (failure) {},
      (categories) {
        state = state.copyWith(categorySales: categories);
      },
    );
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final result = await updateOrderStatusUseCase(orderId, status);
    
    result.fold(
      (failure) => state = state.copyWith(
        errorMessage: failure.message,
      ),
      (success) {
        if (success) {
          refresh();
        }
      },
    );
  }

  Future<void> refresh() => initialize();
}
