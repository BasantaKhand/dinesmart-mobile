import 'package:equatable/equatable.dart';

enum OrderStatus { PENDING, COOKING, SERVED, BILL_PRINTED, COMPLETED, CANCELLED }

class OrderEntity extends Equatable {
  final String id;
  final String tableId;
  final String? tableNumber;
  final String? waiterName;
  final List<OrderItemEntity> items;
  final OrderStatus status;
  final double subtotal;
  final double tax;
  final double vat;
  final double total;
  final String? notes;
  final String? paymentMethod;
  final String? transactionId;
  final DateTime? createdAt;

  const OrderEntity({
    required this.id,
    required this.tableId,
    this.tableNumber,
    this.waiterName,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.tax,
    this.vat = 0.0,
    required this.total,
    this.notes,
    this.paymentMethod,
    this.transactionId,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        tableId,
        tableNumber,
        waiterName,
        items,
        status,
        subtotal,
        tax,
        vat,
        total,
        notes,
        paymentMethod,
        transactionId,
        createdAt
      ];
}

class OrderItemEntity extends Equatable {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final double total;
  final String? status;
  final String? notes;

  const OrderItemEntity({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
    this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [menuItemId, name, price, quantity, total, status, notes];
}
