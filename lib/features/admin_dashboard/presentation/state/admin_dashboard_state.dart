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
  final String searchQuery;
  final OrderStatus? selectedStatus;
  final PaymentStatus? selectedPaymentStatus;

  const AdminDashboardState({
    this.status = AdminDashboardStatus.initial,
    this.orders = const [],
    this.adminStatistics,
    this.salesData = const [],
    this.categorySales = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.selectedStatus,
    this.selectedPaymentStatus,
  });

  AdminDashboardState copyWith({
    AdminDashboardStatus? status,
    List<OrderEntity>? orders,
    AdminStatistics? adminStatistics,
    List<SalesData>? salesData,
    List<CategorySalesData>? categorySales,
    String? errorMessage,
    String? searchQuery,
    OrderStatus? selectedStatus,
    PaymentStatus? selectedPaymentStatus,
    bool clearStatus = false,
    bool clearPayment = false,
  }) {
    return AdminDashboardState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      adminStatistics: adminStatistics ?? this.adminStatistics,
      salesData: salesData ?? this.salesData,
      categorySales: categorySales ?? this.categorySales,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      selectedPaymentStatus: clearPayment ? null : (selectedPaymentStatus ?? this.selectedPaymentStatus),
    );
  }

  List<OrderEntity> get filteredOrders {
    return orders.where((order) {
      final matchesSearch = order.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (order.waiterName?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false) ||
          (order.tableNumber?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
      
      final matchesStatus = selectedStatus == null || order.status == selectedStatus;
      final matchesPayment = selectedPaymentStatus == null || order.paymentStatus == selectedPaymentStatus;
      
      return matchesSearch && matchesStatus && matchesPayment;
    }).toList();
  }

  @override
  List<Object?> get props => [
        status,
        orders,
        adminStatistics,
        salesData,
        categorySales,
        errorMessage,
        searchQuery,
        selectedStatus,
        selectedPaymentStatus,
      ];
}
