import 'package:hive/hive.dart';
import 'package:dinesmart_app/core/constants/hive_box_constants.dart';
import '../../domain/entities/order_entity.dart';

part 'order_hive_model.g.dart';

@HiveType(typeId: HiveBoxConstants.orderTypeId)
class OrderHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String tableId;

  @HiveField(2)
  final String? tableNumber;

  @HiveField(3)
  final String? waiterName;

  @HiveField(4)
  final List<OrderItemHiveModel> items;

  @HiveField(5)
  final int statusIndex;

  @HiveField(6)
  final double subtotal;

  @HiveField(7)
  final double tax;

  @HiveField(8)
  final double vat;

  @HiveField(9)
  final double total;

  @HiveField(10)
  final String? notes;

  @HiveField(11)
  final String? paymentMethod;

  @HiveField(12)
  final String? transactionId;

  @HiveField(13)
  final DateTime? createdAt;

  @HiveField(14)
  final bool isPending;

  OrderHiveModel({
    required this.id,
    required this.tableId,
    this.tableNumber,
    this.waiterName,
    required this.items,
    required this.statusIndex,
    required this.subtotal,
    required this.tax,
    this.vat = 0.0,
    required this.total,
    this.notes,
    this.paymentMethod,
    this.transactionId,
    this.createdAt,
    this.isPending = false,
  });

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      tableId: tableId,
      tableNumber: tableNumber,
      waiterName: waiterName,
      items: items.map((i) => i.toEntity()).toList(),
      status: OrderStatus.values[statusIndex],
      subtotal: subtotal,
      tax: tax,
      vat: vat,
      total: total,
      notes: notes,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      createdAt: createdAt,
    );
  }

  factory OrderHiveModel.fromEntity(OrderEntity entity, {bool isPending = false}) {
    return OrderHiveModel(
      id: entity.id,
      tableId: entity.tableId,
      tableNumber: entity.tableNumber,
      waiterName: entity.waiterName,
      items: entity.items.map((i) => OrderItemHiveModel.fromEntity(i)).toList(),
      statusIndex: entity.status.index,
      subtotal: entity.subtotal,
      tax: entity.tax,
      vat: entity.vat,
      total: entity.total,
      notes: entity.notes,
      paymentMethod: entity.paymentMethod,
      transactionId: entity.transactionId,
      createdAt: entity.createdAt,
      isPending: isPending,
    );
  }

  static List<OrderHiveModel> fromEntityList(List<OrderEntity> entities) {
    return entities.map((e) => OrderHiveModel.fromEntity(e)).toList();
  }
}

@HiveType(typeId: HiveBoxConstants.orderItemTypeId)
class OrderItemHiveModel extends HiveObject {
  @HiveField(0)
  final String menuItemId;

  @HiveField(1)
  final String? imageUrl;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final int quantity;

  @HiveField(5)
  final double total;

  @HiveField(6)
  final String? status;

  @HiveField(7)
  final String? notes;

  OrderItemHiveModel({
    required this.menuItemId,
    this.imageUrl,
    required this.name,
    required this.price,
    required this.quantity,
    required this.total,
    this.status,
    this.notes,
  });

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      menuItemId: menuItemId,
      imageUrl: imageUrl,
      name: name,
      price: price,
      quantity: quantity,
      total: total,
      status: status,
      notes: notes,
    );
  }

  factory OrderItemHiveModel.fromEntity(OrderItemEntity entity) {
    return OrderItemHiveModel(
      menuItemId: entity.menuItemId,
      imageUrl: entity.imageUrl,
      name: entity.name,
      price: entity.price,
      quantity: entity.quantity,
      total: entity.total,
      status: entity.status,
      notes: entity.notes,
    );
  }
}
