import 'package:equatable/equatable.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/order_entity.dart';
import 'package:dinesmart_app/features/admin_dashboard/domain/entities/admin_statistics.dart';

enum AdminDashboardStatus { initial, loading, success, error }

class AdminDashboardState extends Equatable {
  final AdminDashboardStatus status;
  final List<OrderEntity> orders;
  final AdminStatistics? adminStatistics;
  final List<SalesData> salesData;
  final List<CategorySalesData> categorySales;
  final String? errorMessage;

  const AdminDashboardState({
    this.status = AdminDashboardStatus.initial,
    this.orders = const [],
    this.adminStatistics,
    this.salesData = const [],
    this.categorySales = const [],
    this.errorMessage,
  });

  AdminDashboardState copyWith({
    AdminDashboardStatus? status,
    List<OrderEntity>? orders,
    AdminStatistics? adminStatistics,
    List<SalesData>? salesData,
    List<CategorySalesData>? categorySales,
    String? errorMessage,
  }) {
    return AdminDashboardState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      adminStatistics: adminStatistics ?? this.adminStatistics,
      salesData: salesData ?? this.salesData,
      categorySales: categorySales ?? this.categorySales,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        orders,
        adminStatistics,
        salesData,
        categorySales,
        errorMessage,
      ];
}
