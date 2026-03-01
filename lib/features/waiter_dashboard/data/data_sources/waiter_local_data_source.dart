import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/core/constants/hive_box_constants.dart';
import 'package:dinesmart_app/core/services/hive/hive_service.dart';
import 'package:uuid/uuid.dart';
import '../models/category_hive_model.dart';
import '../models/menu_item_hive_model.dart';
import '../models/table_hive_model.dart';
import '../models/order_hive_model.dart';
import '../models/pending_operation_hive_model.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/table_entity.dart';
import '../../domain/entities/order_entity.dart';

final waiterLocalDataSourceProvider = Provider((ref) {
  return WaiterLocalDataSource(ref.read(hiveServiceProvider));
});

class WaiterLocalDataSource {
  final HiveService _hiveService;
  final _uuid = const Uuid();

  WaiterLocalDataSource(this._hiveService);

  List<CategoryEntity> getCategories() {
    return _hiveService.categoryBox.values
        .map((m) => m.toEntity())
        .toList();
  }

  Future<void> saveCategories(List<CategoryEntity> categories) async {
    await _hiveService.categoryBox.clear();
    final models = CategoryHiveModel.fromEntityList(categories);
    for (final model in models) {
      await _hiveService.categoryBox.put(model.id, model);
    }
    _hiveService.updateCacheTimestamp(HiveBoxConstants.categoryCacheKey);
  }

  bool isCategoryCacheValid() {
    return _hiveService.isCacheValid(HiveBoxConstants.categoryCacheKey);
  }

  List<MenuItemEntity> getMenuItems() {
    return _hiveService.menuItemBox.values
        .map((m) => m.toEntity())
        .toList();
  }

  Future<void> saveMenuItems(List<MenuItemEntity> items) async {
    await _hiveService.menuItemBox.clear();
    final models = MenuItemHiveModel.fromEntityList(items);
    for (final model in models) {
      await _hiveService.menuItemBox.put(model.id, model);
    }
    _hiveService.updateCacheTimestamp(HiveBoxConstants.menuItemsCacheKey);
  }

  bool isMenuItemsCacheValid() {
    return _hiveService.isCacheValid(HiveBoxConstants.menuItemsCacheKey);
  }

  List<TableEntity> getTables() {
    return _hiveService.tableBox.values
        .map((m) => m.toEntity())
        .toList();
  }

  Future<void> saveTables(List<TableEntity> tables) async {
    await _hiveService.tableBox.clear();
    final models = TableHiveModel.fromEntityList(tables);
    for (final model in models) {
      await _hiveService.tableBox.put(model.id, model);
    }
    _hiveService.updateCacheTimestamp(HiveBoxConstants.tablesCacheKey);
  }

  bool isTablesCacheValid() {
    return _hiveService.isCacheValid(
      HiveBoxConstants.tablesCacheKey,
      validDuration: HiveBoxConstants.tableCacheValidDuration,
    );
  }

  void invalidateTablesCache() {
    _hiveService.invalidateCache(HiveBoxConstants.tablesCacheKey);
  }

  void invalidateCategoriesCache() {
    _hiveService.invalidateCache(HiveBoxConstants.categoryCacheKey);
  }

  void invalidateMenuItemsCache() {
    _hiveService.invalidateCache(HiveBoxConstants.menuItemsCacheKey);
  }

  List<OrderEntity> getOrders() {
    return _hiveService.orderBox.values
        .map((m) => m.toEntity())
        .toList();
  }

  Future<void> saveOrders(List<OrderEntity> orders) async {
    await _hiveService.orderBox.clear();
    final models = OrderHiveModel.fromEntityList(orders);
    for (final model in models) {
      await _hiveService.orderBox.put(model.id, model);
    }
    _hiveService.updateCacheTimestamp(HiveBoxConstants.ordersCacheKey);
  }

  bool isOrdersCacheValid() {
    return _hiveService.isCacheValid(
      HiveBoxConstants.ordersCacheKey,
      validDuration: HiveBoxConstants.orderCacheValidDuration,
    );
  }

  void invalidateOrdersCache() {
    _hiveService.invalidateCache(HiveBoxConstants.ordersCacheKey);
  }

  OrderEntity? getActiveOrderByTable(String tableId) {
    final orders = _hiveService.activeOrderBox.values
        .where((o) => o.tableId == tableId)
        .toList();
    if (orders.isEmpty) return null;
    return orders.first.toEntity();
  }

  Future<void> saveActiveOrder(OrderEntity order) async {
    final model = OrderHiveModel.fromEntity(order);
    await _hiveService.activeOrderBox.put('${order.tableId}_active', model);
  }

  Future<void> removeActiveOrder(String tableId) async {
    await _hiveService.activeOrderBox.delete('${tableId}_active');
  }

  Future<String> savePendingOrder(OrderEntity order) async {
    final localId = 'local_${_uuid.v4()}';
    final pendingOrder = OrderHiveModel.fromEntity(
      OrderEntity(
        id: localId,
        tableId: order.tableId,
        tableNumber: order.tableNumber,
        waiterName: order.waiterName,
        items: order.items,
        status: order.status,
        subtotal: order.subtotal,
        tax: order.tax,
        vat: order.vat,
        total: order.total,
        notes: order.notes,
        paymentMethod: order.paymentMethod,
        transactionId: order.transactionId,
        createdAt: DateTime.now(),
      ),
      isPending: true,
    );
    await _hiveService.activeOrderBox.put('${order.tableId}_active', pendingOrder);
    return localId;
  }

  Future<void> addPendingOperation(PendingOperationHiveModel operation) async {
    await _hiveService.pendingOperationBox.put(operation.id, operation);
  }

  List<PendingOperationHiveModel> getPendingOperations() {
    return _hiveService.pendingOperationBox.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> removePendingOperation(String id) async {
    await _hiveService.pendingOperationBox.delete(id);
  }

  Future<void> updatePendingOperationRetry(PendingOperationHiveModel operation) async {
    await _hiveService.pendingOperationBox.put(operation.id, operation.copyWithRetry());
  }

  bool hasPendingOperations() {
    return _hiveService.pendingOperationBox.isNotEmpty;
  }

  int getPendingOperationsCount() {
    return _hiveService.pendingOperationBox.length;
  }

  Future<void> updateLocalOrderWithServerId(String localId, String serverId) async {
    final entries = _hiveService.activeOrderBox.toMap().entries;
    for (final entry in entries) {
      if (entry.value.id == localId) {
        final updated = OrderHiveModel(
          id: serverId,
          tableId: entry.value.tableId,
          tableNumber: entry.value.tableNumber,
          waiterName: entry.value.waiterName,
          items: entry.value.items,
          statusIndex: entry.value.statusIndex,
          subtotal: entry.value.subtotal,
          tax: entry.value.tax,
          vat: entry.value.vat,
          total: entry.value.total,
          notes: entry.value.notes,
          paymentMethod: entry.value.paymentMethod,
          transactionId: entry.value.transactionId,
          createdAt: entry.value.createdAt,
          isPending: false,
        );
        await _hiveService.activeOrderBox.put(entry.key, updated);
        break;
      }
    }
  }

  Future<void> clearAllCache() async {
    await _hiveService.categoryBox.clear();
    await _hiveService.menuItemBox.clear();
    await _hiveService.tableBox.clear();
    await _hiveService.orderBox.clear();
    await _hiveService.activeOrderBox.clear();
    _hiveService.invalidateCache(HiveBoxConstants.categoryCacheKey);
    _hiveService.invalidateCache(HiveBoxConstants.menuItemsCacheKey);
    _hiveService.invalidateCache(HiveBoxConstants.tablesCacheKey);
    _hiveService.invalidateCache(HiveBoxConstants.ordersCacheKey);
  }
}
