import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:dinesmart_app/core/constants/hive_box_constants.dart';

part 'pending_operation_hive_model.g.dart';

enum OperationType {
  createOrder,
  addItemsToOrder,
  updateOrderStatus,
  markBillPrinted,
}

@HiveType(typeId: HiveBoxConstants.pendingOperationTypeId)
class PendingOperationHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int operationTypeIndex;

  @HiveField(2)
  final String payload;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final int retryCount;

  @HiveField(5)
  final String? relatedEntityId;

  PendingOperationHiveModel({
    required this.id,
    required this.operationTypeIndex,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.relatedEntityId,
  });

  OperationType get operationType => OperationType.values[operationTypeIndex];

  Map<String, dynamic> get payloadData => jsonDecode(payload);

  PendingOperationHiveModel copyWithRetry() {
    return PendingOperationHiveModel(
      id: id,
      operationTypeIndex: operationTypeIndex,
      payload: payload,
      createdAt: createdAt,
      retryCount: retryCount + 1,
      relatedEntityId: relatedEntityId,
    );
  }

  factory PendingOperationHiveModel.createOrder({
    required String id,
    required Map<String, dynamic> orderData,
    required String localOrderId,
  }) {
    return PendingOperationHiveModel(
      id: id,
      operationTypeIndex: OperationType.createOrder.index,
      payload: jsonEncode(orderData),
      createdAt: DateTime.now(),
      relatedEntityId: localOrderId,
    );
  }

  factory PendingOperationHiveModel.addItemsToOrder({
    required String id,
    required String orderId,
    required Map<String, dynamic> orderData,
  }) {
    return PendingOperationHiveModel(
      id: id,
      operationTypeIndex: OperationType.addItemsToOrder.index,
      payload: jsonEncode({'orderId': orderId, ...orderData}),
      createdAt: DateTime.now(),
      relatedEntityId: orderId,
    );
  }

  factory PendingOperationHiveModel.updateOrderStatus({
    required String id,
    required String orderId,
    required String status,
  }) {
    return PendingOperationHiveModel(
      id: id,
      operationTypeIndex: OperationType.updateOrderStatus.index,
      payload: jsonEncode({'orderId': orderId, 'status': status}),
      createdAt: DateTime.now(),
      relatedEntityId: orderId,
    );
  }

  factory PendingOperationHiveModel.markBillPrinted({
    required String id,
    required String orderId,
  }) {
    return PendingOperationHiveModel(
      id: id,
      operationTypeIndex: OperationType.markBillPrinted.index,
      payload: jsonEncode({'orderId': orderId}),
      createdAt: DateTime.now(),
      relatedEntityId: orderId,
    );
  }
}
