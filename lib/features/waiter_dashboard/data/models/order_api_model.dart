import '../../domain/entities/order_entity.dart';

class OrderApiModel {
  final String? id;
  final String tableId;
  final List<OrderItemApiModel> items;
  final String status;
  final double subtotal;
  final double tax;
  final double vat;
  final double total;
  final String? notes;
  final String? paymentMethod;
  final String? transactionId;
  final String? tableNumber;
  final String? waiterName;
  final DateTime? createdAt;

  OrderApiModel({
    this.id,
    required this.tableId,
    required this.items,
    required this.status,
    required this.subtotal,
    required this.tax,
    this.vat = 0.0,
    required this.total,
    this.notes,
    this.paymentMethod,
    this.transactionId,
    this.tableNumber,
    this.waiterName,
    this.createdAt,
  });

  factory OrderApiModel.fromJson(Map<String, dynamic> json) {
    return OrderApiModel(
      id: json['_id'],
      tableId: json['tableId'] is Map ? json['tableId']['_id'] : json['tableId'],
      tableNumber: json['tableId'] is Map ? json['tableId']['number'] : null,
      waiterName: json['waiterId'] is Map ? json['waiterId']['name'] : null,
      items: (json['items'] as List)
          .map((i) => OrderItemApiModel.fromJson(i))
          .toList(),
      status: json['status'],
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      vat: (json['vat'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      notes: json['notes'],
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'items': items.map((i) => i.toJson()).toList(),
      // 'status': status, // Status is managed by the backend during creation
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      if (notes != null) 'notes': notes,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (transactionId != null) 'transactionId': transactionId,
    };
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id ?? '',
      tableId: tableId,
      items: items.map((i) => i.toEntity()).toList(),
      status: _mapStatus(status),
      subtotal: subtotal,
      tax: tax,
      vat: vat,
      total: total,
      notes: notes,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      tableNumber: tableNumber,
      waiterName: waiterName,
      createdAt: createdAt,
    );
  }

  static OrderStatus _mapStatus(String status) {
    switch (status) {
      case 'COOKING':
        return OrderStatus.COOKING;
      case 'SERVED':
        return OrderStatus.SERVED;
      case 'BILL_PRINTED':
        return OrderStatus.BILL_PRINTED;
      case 'COMPLETED':
        return OrderStatus.COMPLETED;
      case 'CANCELLED':
        return OrderStatus.CANCELLED;
      default:
        return OrderStatus.PENDING;
    }
  }

  factory OrderApiModel.fromEntity(OrderEntity entity) {
    return OrderApiModel(
      id: entity.id.isEmpty ? null : entity.id,
      tableId: entity.tableId,
      items: entity.items.map((i) => OrderItemApiModel.fromEntity(i)).toList(),
      status: entity.status.name,
      subtotal: entity.subtotal,
      tax: entity.tax,
      vat: entity.vat,
      total: entity.total,
      notes: entity.notes,
      paymentMethod: entity.paymentMethod,
      transactionId: entity.transactionId,
    );
  }
}

class OrderItemApiModel {
  final String menuItemId;
  final String name;
  final double price;
  final int quantity;
  final double total;
  final String? status;
  final String? notes;

  OrderItemApiModel({
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
    this.status,
    this.notes,
  });

  factory OrderItemApiModel.fromJson(Map<String, dynamic> json) {
    return OrderItemApiModel(
      menuItemId: json['menuItemId'] is Map ? (json['menuItemId']['_id'] ?? '') : (json['menuItemId'] ?? ''),
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      total: (json['total'] as num).toDouble(),
      status: json['status'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuItemId': menuItemId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'total': total,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
    };
  }

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      menuItemId: menuItemId,
      name: name,
      price: price,
      quantity: quantity,
      total: total,
      status: status,
      notes: notes,
    );
  }

  factory OrderItemApiModel.fromEntity(OrderItemEntity entity) {
    return OrderItemApiModel(
      menuItemId: entity.menuItemId,
      name: entity.name,
      price: entity.price,
      quantity: entity.quantity,
      total: entity.total,
      status: entity.status,
      notes: entity.notes,
    );
  }
}
