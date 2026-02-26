import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';
import 'package:dinesmart_app/features/waiter_dashboard/data/models/order_api_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/order_entity.dart';

class CashierStatsModel {
  final double collectionsToday;
  final int pendingPayments;
  final double avgBillSize;
  final double cashInDrawer;

  CashierStatsModel({
    required this.collectionsToday,
    required this.pendingPayments,
    required this.avgBillSize,
    required this.cashInDrawer,
  });

  factory CashierStatsModel.fromJson(Map<String, dynamic> json) {
    return CashierStatsModel(
      collectionsToday: (json['collectionsToday'] as num).toDouble(),
      pendingPayments: json['pendingPayments'] as int,
      avgBillSize: (json['avgBillSize'] as num).toDouble(),
      cashInDrawer: (json['cashInDrawer'] as num).toDouble(),
    );
  }

  CashierStats toEntity() => CashierStats(
    collectionsToday: collectionsToday,
    pendingPayments: pendingPayments,
    avgBillSize: avgBillSize,
    cashInDrawer: cashInDrawer,
  );
}

class PaymentQueueItemModel {
  final String id;
  final String orderId;
  final String tableNumber;
  final double amount;
  final int itemCount;
  final List<OrderItemEntity> items;
  final String status;
  final DateTime createdAt;

  PaymentQueueItemModel({
    required this.id,
    required this.orderId,
    required this.tableNumber,
    required this.amount,
    required this.itemCount,
    this.items = const [],
    required this.status,
    required this.createdAt,
  });

  factory PaymentQueueItemModel.fromJson(Map<String, dynamic> json) {
    final order = json['orderId'] is Map ? json['orderId'] : null;
    return PaymentQueueItemModel(
      id: json['_id'],
      orderId: order != null ? order['_id'] : json['orderId'],
      tableNumber: order != null ? (order['tableId']?['number'] ?? 'N/A') : 'N/A',
      amount: (json['amount'] as num).toDouble(),
      itemCount: order != null ? (order['items'] as List?)?.length ?? 0 : 0,
      items: order != null ? (order['items'] as List?)?.map((i) => OrderItemApiModel.fromJson(i).toEntity()).toList() ?? [] : [],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  PaymentQueueItem toEntity() => PaymentQueueItem(
    id: id,
    orderId: orderId,
    tableNumber: tableNumber,
    amount: amount,
    itemCount: itemCount,
    items: items,
    status: status,
    createdAt: createdAt,
  );
}

class SettlementModel {
  final String id;
  final String orderId;
  final String tableNumber;
  final double totalAmount;
  final String paymentMethod;
  final DateTime settledAt;

  SettlementModel({
    required this.id,
    required this.orderId,
    required this.tableNumber,
    required this.totalAmount,
    required this.paymentMethod,
    required this.settledAt,
  });

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      id: json['_id'],
      orderId: json['orderId']['_id'] ?? json['orderId'],
      tableNumber: json['orderId']['tableId']?['number'] ?? 'N/A',
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'],
      settledAt: DateTime.parse(json['settledAt']),
    );
  }

  Settlement toEntity() => Settlement(
    id: id,
    orderId: orderId,
    tableNumber: tableNumber,
    totalAmount: totalAmount,
    paymentMethod: paymentMethod,
    settledAt: settledAt,
  );
}
