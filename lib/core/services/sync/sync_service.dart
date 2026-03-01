import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/features/waiter_dashboard/data/data_sources/waiter_local_data_source.dart';
import 'package:dinesmart_app/features/waiter_dashboard/data/data_sources/waiter_dashboard_remote_data_source.dart';
import 'package:dinesmart_app/features/waiter_dashboard/data/models/pending_operation_hive_model.dart';
import 'package:dinesmart_app/features/waiter_dashboard/data/models/order_api_model.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.read(waiterLocalDataSourceProvider),
    ref.read(waiterDashboardRemoteDataSourceProvider),
  );
});

final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final pendingOperationsCountProvider = StateProvider<int>((ref) => 0);

class SyncService {
  final WaiterLocalDataSource _localDataSource;
  final WaiterDashboardRemoteDataSource _remoteDataSource;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  SyncService(this._localDataSource, this._remoteDataSource);

  void startListening(void Function(int) onPendingCountChange) {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) async {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      if (isConnected && !_isSyncing) {
        await syncPendingOperations(onPendingCountChange);
      }
    });
  }

  void stopListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  Future<bool> isOnline() async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> syncPendingOperations(void Function(int) onPendingCountChange) async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendingOps = _localDataSource.getPendingOperations();
      onPendingCountChange(pendingOps.length);

      for (final op in pendingOps) {
        try {
          await _processOperation(op);
          await _localDataSource.removePendingOperation(op.id);
          onPendingCountChange(_localDataSource.getPendingOperationsCount());
        } catch (e) {
          if (op.retryCount < 3) {
            await _localDataSource.updatePendingOperationRetry(op);
          } else {
            await _localDataSource.removePendingOperation(op.id);
          }
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processOperation(PendingOperationHiveModel op) async {
    switch (op.operationType) {
      case OperationType.createOrder:
        await _syncCreateOrder(op);
        break;
      case OperationType.addItemsToOrder:
        await _syncAddItems(op);
        break;
      case OperationType.updateOrderStatus:
        await _syncUpdateStatus(op);
        break;
      case OperationType.markBillPrinted:
        await _syncMarkBillPrinted(op);
        break;
    }
  }

  Future<void> _syncCreateOrder(PendingOperationHiveModel op) async {
    final data = op.payloadData;
    final items = (data['items'] as List).map((i) => OrderItemApiModel(
      menuItemId: i['menuItemId'],
      name: i['name'],
      price: (i['price'] as num).toDouble(),
      quantity: i['quantity'] as int,
      total: (i['total'] as num).toDouble(),
      notes: i['notes'],
    )).toList();

    final order = OrderApiModel(
      tableId: data['tableId'],
      items: items,
      status: data['status'] ?? 'PENDING',
      subtotal: (data['subtotal'] as num).toDouble(),
      tax: (data['tax'] as num).toDouble(),
      vat: (data['vat'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num).toDouble(),
      notes: data['notes'],
    );

    final success = await _remoteDataSource.createOrder(order);
    if (success && op.relatedEntityId != null) {
      _localDataSource.invalidateTablesCache();
      _localDataSource.invalidateOrdersCache();
    }
  }

  Future<void> _syncAddItems(PendingOperationHiveModel op) async {
    final data = op.payloadData;
    final orderId = data['orderId'] as String;
    final items = (data['items'] as List).map((i) => OrderItemApiModel(
      menuItemId: i['menuItemId'],
      name: i['name'],
      price: (i['price'] as num).toDouble(),
      quantity: i['quantity'] as int,
      total: (i['total'] as num).toDouble(),
      notes: i['notes'],
    )).toList();

    final order = OrderApiModel(
      tableId: data['tableId'],
      items: items,
      status: 'PENDING',
      subtotal: (data['subtotal'] as num).toDouble(),
      tax: (data['tax'] as num).toDouble(),
      total: (data['total'] as num).toDouble(),
    );

    await _remoteDataSource.addItemsToOrder(orderId, order);
    _localDataSource.invalidateOrdersCache();
  }

  Future<void> _syncUpdateStatus(PendingOperationHiveModel op) async {
    final data = op.payloadData;
    await _remoteDataSource.updateOrderStatus(
      data['orderId'] as String,
      data['status'] as String,
    );
    _localDataSource.invalidateOrdersCache();
  }

  Future<void> _syncMarkBillPrinted(PendingOperationHiveModel op) async {
    final data = op.payloadData;
    await _remoteDataSource.markBillPrinted(data['orderId'] as String);
    _localDataSource.invalidateOrdersCache();
  }

  Future<void> forceSyncNow(void Function(int) onPendingCountChange) async {
    final online = await isOnline();
    if (online) {
      await syncPendingOperations(onPendingCountChange);
    }
  }
}
