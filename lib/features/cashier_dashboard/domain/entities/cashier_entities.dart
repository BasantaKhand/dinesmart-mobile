import 'package:equatable/equatable.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/order_entity.dart';

class CashierStats extends Equatable {
  final double collectionsToday;
  final int billsClosedToday;
  final int pendingPayments;
  final double avgBillSize;
  final double cashCollected;

  const CashierStats({
    required this.collectionsToday,
    this.billsClosedToday = 0,
    required this.pendingPayments,
    required this.avgBillSize,
    required this.cashCollected,
  });

  @override
  List<Object?> get props => [collectionsToday, billsClosedToday, pendingPayments, avgBillSize, cashCollected];
}

class PaymentQueueItem extends Equatable {
  final String id;
  final String orderId;
  final String orderNumber;
  final String tableNumber;
  final double amount;
  final double subtotal;
  final double tax;
  final int itemCount;
  final List<OrderItemEntity> items;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;

  const PaymentQueueItem({
    required this.id,
    required this.orderId,
    this.orderNumber = '',
    required this.tableNumber,
    required this.amount,
    this.subtotal = 0,
    this.tax = 0,
    this.itemCount = 0,
    this.items = const [],
    required this.status,
    this.paymentMethod = 'CASH',
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, orderId, orderNumber, tableNumber, amount, subtotal, tax, itemCount, items, status, paymentMethod, createdAt];
}

class Settlement extends Equatable {
  final String id;
  final String orderId;
  final String orderNumber;
  final String tableNumber;
  final double totalAmount;
  final String paymentMethod;
  final DateTime settledAt;

  const Settlement({
    required this.id,
    required this.orderId,
    this.orderNumber = '',
    required this.tableNumber,
    required this.totalAmount,
    required this.paymentMethod,
    required this.settledAt,
  });

  @override
  List<Object?> get props => [id, orderId, orderNumber, tableNumber, totalAmount, paymentMethod, settledAt];
}

class TodaySettlement extends Equatable {
  final double totalCollection;
  final int totalBills;
  final double cashAmount;
  final double qrAmount;
  final double cardAmount;
  final double openingAmount;
  final double expectedCash;
  final double variance;
  final int paymentsSettled;
  final double amountSettled;

  const TodaySettlement({
    this.totalCollection = 0,
    this.totalBills = 0,
    this.cashAmount = 0,
    this.qrAmount = 0,
    this.cardAmount = 0,
    this.openingAmount = 0,
    this.expectedCash = 0,
    this.variance = 0,
    this.paymentsSettled = 0,
    this.amountSettled = 0,
  });

  @override
  List<Object?> get props => [totalCollection, totalBills, cashAmount, qrAmount, cardAmount, openingAmount, expectedCash, variance, paymentsSettled, amountSettled];
}

class CashDrawerStatus extends Equatable {
  final String? id;
  final bool isOpen;
  final double openingAmount;
  final DateTime? openedAt;
  final String? notes;

  const CashDrawerStatus({
    this.id,
    this.isOpen = false,
    this.openingAmount = 0,
    this.openedAt,
    this.notes,
  });

  @override
  List<Object?> get props => [id, isOpen, openingAmount, openedAt, notes];
}
