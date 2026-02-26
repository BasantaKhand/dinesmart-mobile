import 'package:equatable/equatable.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/order_entity.dart';

class CashierStats extends Equatable {
  final double collectionsToday;
  final int pendingPayments;
  final double avgBillSize;
  final double cashInDrawer;

  const CashierStats({
    required this.collectionsToday,
    required this.pendingPayments,
    required this.avgBillSize,
    required this.cashInDrawer,
  });

  @override
  List<Object?> get props => [collectionsToday, pendingPayments, avgBillSize, cashInDrawer];
}

class PaymentQueueItem extends Equatable {
  final String id;
  final String orderId;
  final String tableNumber;
  final double amount;
  final int itemCount;
  final List<OrderItemEntity> items;
  final String status;
  final DateTime createdAt;

  const PaymentQueueItem({
    required this.id,
    required this.orderId,
    required this.tableNumber,
    required this.amount,
    this.itemCount = 0,
    this.items = const [],
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, orderId, tableNumber, amount, itemCount, items, status, createdAt];
}

class Settlement extends Equatable {
  final String id;
  final String orderId;
  final String tableNumber;
  final double totalAmount;
  final String paymentMethod;
  final DateTime settledAt;

  const Settlement({
    required this.id,
    required this.orderId,
    required this.tableNumber,
    required this.totalAmount,
    required this.paymentMethod,
    required this.settledAt,
  });

  @override
  List<Object?> get props => [id, orderId, tableNumber, totalAmount, paymentMethod, settledAt];
}
