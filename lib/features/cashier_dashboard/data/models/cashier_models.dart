import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';
import 'package:dinesmart_app/features/waiter_dashboard/data/models/order_api_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/domain/entities/order_entity.dart';

class CashierStatsModel {
  final double collectionsToday;
  final int billsClosedToday;
  final int pendingPayments;
  final double avgBillSize;
  final double cashCollected;

  CashierStatsModel({
    required this.collectionsToday,
    this.billsClosedToday = 0,
    required this.pendingPayments,
    required this.avgBillSize,
    required this.cashCollected,
  });

  factory CashierStatsModel.fromJson(Map<String, dynamic> json) {
    return CashierStatsModel(
      collectionsToday: (json['collectionsToday'] as num?)?.toDouble() ?? 0,
      billsClosedToday: (json['billsClosedToday'] as num?)?.toInt() ?? 0,
      pendingPayments: (json['pendingPayments'] as num?)?.toInt() ?? 0,
      avgBillSize: (json['avgBillSize'] as num?)?.toDouble() ?? 0,
      cashCollected: (json['cashCollected'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'collectionsToday': collectionsToday,
    'billsClosedToday': billsClosedToday,
    'pendingPayments': pendingPayments,
    'avgBillSize': avgBillSize,
    'cashCollected': cashCollected,
  };

  CashierStats toEntity() => CashierStats(
    collectionsToday: collectionsToday,
    billsClosedToday: billsClosedToday,
    pendingPayments: pendingPayments,
    avgBillSize: avgBillSize,
    cashCollected: cashCollected,
  );
}

class PaymentQueueItemModel {
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

  PaymentQueueItemModel({
    required this.id,
    required this.orderId,
    this.orderNumber = '',
    required this.tableNumber,
    required this.amount,
    this.subtotal = 0,
    this.tax = 0,
    required this.itemCount,
    this.items = const [],
    required this.status,
    this.paymentMethod = 'CASH',
    required this.createdAt,
  });

  /// Parse from the GET /orders response (orders with status SERVED/COMPLETED, paymentStatus PENDING)
  factory PaymentQueueItemModel.fromOrderJson(Map<String, dynamic> json) {
    final tableData = json['tableId'];
    final tableNum = tableData is Map ? (tableData['number'] ?? 'N/A') : 'N/A';
    final itemsList = json['items'] as List? ?? [];

    return PaymentQueueItemModel(
      id: json['_id'] ?? '',
      orderId: json['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      tableNumber: tableNum.toString(),
      amount: (json['total'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      itemCount: itemsList.length,
      items: itemsList.map((i) => OrderItemApiModel.fromJson(i).toEntity()).toList(),
      status: json['status'] ?? 'SERVED',
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'orderId': orderId,
    'orderNumber': orderNumber,
    'tableNumber': tableNumber,
    'amount': amount,
    'subtotal': subtotal,
    'tax': tax,
    'itemCount': itemCount,
    'status': status,
    'paymentMethod': paymentMethod,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Parse from cached JSON (flat format from toJson)
  factory PaymentQueueItemModel.fromCacheJson(Map<String, dynamic> json) {
    return PaymentQueueItemModel(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? json['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      tableNumber: (json['tableNumber'] ?? 'N/A').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      items: const [],
      status: json['status'] ?? 'SERVED',
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  PaymentQueueItem toEntity() => PaymentQueueItem(
    id: id,
    orderId: orderId,
    orderNumber: orderNumber,
    tableNumber: tableNumber,
    amount: amount,
    subtotal: subtotal,
    tax: tax,
    itemCount: itemCount,
    items: items,
    status: status,
    paymentMethod: paymentMethod,
    createdAt: createdAt,
  );
}

class SettlementModel {
  final String id;
  final String orderId;
  final String orderNumber;
  final String tableNumber;
  final double totalAmount;
  final String paymentMethod;
  final DateTime settledAt;

  SettlementModel({
    required this.id,
    required this.orderId,
    this.orderNumber = '',
    required this.tableNumber,
    required this.totalAmount,
    required this.paymentMethod,
    required this.settledAt,
  });

  /// Parse from the GET /orders response (orders with paymentStatus PAID)
  factory SettlementModel.fromOrderJson(Map<String, dynamic> json) {
    final tableData = json['tableId'];
    final tableNum = tableData is Map ? (tableData['number'] ?? 'N/A') : 'N/A';

    return SettlementModel(
      id: json['_id'] ?? '',
      orderId: json['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      tableNumber: tableNum.toString(),
      totalAmount: (json['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      settledAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'orderId': orderId,
    'orderNumber': orderNumber,
    'tableNumber': tableNumber,
    'totalAmount': totalAmount,
    'paymentMethod': paymentMethod,
    'settledAt': settledAt.toIso8601String(),
  };

  /// Parse from cached JSON (flat format from toJson)
  factory SettlementModel.fromCacheJson(Map<String, dynamic> json) {
    return SettlementModel(
      id: json['_id'] ?? '',
      orderId: json['orderId'] ?? json['_id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      tableNumber: (json['tableNumber'] ?? 'N/A').toString(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['paymentMethod'] ?? 'CASH',
      settledAt: json['settledAt'] != null ? DateTime.parse(json['settledAt']) : DateTime.now(),
    );
  }

  Settlement toEntity() => Settlement(
    id: id,
    orderId: orderId,
    orderNumber: orderNumber,
    tableNumber: tableNumber,
    totalAmount: totalAmount,
    paymentMethod: paymentMethod,
    settledAt: settledAt,
  );
}

class TodaySettlementModel {
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

  TodaySettlementModel({
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

  factory TodaySettlementModel.fromJson(Map<String, dynamic> json) {
    final collectionByMethod = json['collectionByMethod'] as Map<String, dynamic>? ?? {};
    return TodaySettlementModel(
      totalCollection: (json['totalCollection'] as num?)?.toDouble() ?? 0,
      totalBills: (json['totalBills'] as num?)?.toInt() ?? 0,
      cashAmount: (collectionByMethod['cash'] as num?)?.toDouble() ??
          (collectionByMethod['CASH'] as num?)?.toDouble() ?? 0,
      qrAmount: (collectionByMethod['qr'] as num?)?.toDouble() ??
          (collectionByMethod['QR'] as num?)?.toDouble() ?? 0,
      cardAmount: (collectionByMethod['card'] as num?)?.toDouble() ??
          (collectionByMethod['CARD'] as num?)?.toDouble() ?? 0,
      openingAmount: (json['openingAmount'] as num?)?.toDouble() ?? 0,
      expectedCash: (json['expectedCash'] as num?)?.toDouble() ?? 0,
      variance: (json['variance'] as num?)?.toDouble() ?? 0,
      paymentsSettled: (json['paymentsSettled'] as num?)?.toInt() ?? 0,
      amountSettled: (json['amountSettled'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalCollection': totalCollection,
    'totalBills': totalBills,
    'cashAmount': cashAmount,
    'qrAmount': qrAmount,
    'cardAmount': cardAmount,
    'openingAmount': openingAmount,
    'expectedCash': expectedCash,
    'variance': variance,
    'paymentsSettled': paymentsSettled,
    'amountSettled': amountSettled,
  };

  TodaySettlement toEntity() => TodaySettlement(
    totalCollection: totalCollection,
    totalBills: totalBills,
    cashAmount: cashAmount,
    qrAmount: qrAmount,
    cardAmount: cardAmount,
    openingAmount: openingAmount,
    expectedCash: expectedCash,
    variance: variance,
    paymentsSettled: paymentsSettled,
    amountSettled: amountSettled,
  );
}

class CashDrawerStatusModel {
  final String? id;
  final bool isOpen;
  final double openingAmount;
  final DateTime? openedAt;
  final String? notes;

  CashDrawerStatusModel({
    this.id,
    this.isOpen = false,
    this.openingAmount = 0,
    this.openedAt,
    this.notes,
  });

  factory CashDrawerStatusModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CashDrawerStatusModel(isOpen: false);
    }
    return CashDrawerStatusModel(
      id: json['_id'] ?? json['id'],
      isOpen: json['status'] == 'OPEN' || json['isOpen'] == true,
      openingAmount: (json['openingAmount'] as num?)?.toDouble() ?? 0,
      openedAt: json['openedAt'] != null ? DateTime.parse(json['openedAt']) : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'isOpen': isOpen,
    'openingAmount': openingAmount,
    'openedAt': openedAt?.toIso8601String(),
    'notes': notes,
  };

  CashDrawerStatus toEntity() => CashDrawerStatus(
    id: id,
    isOpen: isOpen,
    openingAmount: openingAmount,
    openedAt: openedAt,
    notes: notes,
  );
}
