import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:dinesmart_app/core/constants/hive_box_constants.dart';
import 'package:dinesmart_app/features/cashier_dashboard/data/models/cashier_models.dart';
import 'package:dinesmart_app/features/cashier_dashboard/domain/entities/cashier_entities.dart';

final cashierLocalDataSourceProvider = Provider((ref) {
  return CashierLocalDataSource();
});

class CashierLocalDataSource {
  Box<String> get _box => Hive.box<String>(HiveBoxConstants.cashierDashboardBox);
  Box<DateTime> get _cacheTimestampBox => Hive.box<DateTime>(HiveBoxConstants.cacheTimestampBox);

  // ─── Payment Queue ───

  List<PaymentQueueItem> getPaymentQueue() {
    final raw = _box.get('paymentQueue');
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((j) => PaymentQueueItemModel.fromCacheJson(j).toEntity()).toList();
  }

  Future<void> savePaymentQueue(List<PaymentQueueItemModel> items) async {
    await _box.put('paymentQueue', jsonEncode(items.map((m) => m.toJson()).toList()));
    _updateTimestamp(HiveBoxConstants.cashierDashboardCacheKey);
  }

  // ─── Recent Settlements ───

  List<Settlement> getRecentSettlements() {
    final raw = _box.get('recentSettlements');
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((j) => SettlementModel.fromCacheJson(j).toEntity()).toList();
  }

  Future<void> saveRecentSettlements(List<SettlementModel> items) async {
    await _box.put('recentSettlements', jsonEncode(items.map((m) => m.toJson()).toList()));
  }

  // ─── Today Settlement ───

  TodaySettlement? getTodaySettlement() {
    final raw = _box.get('todaySettlement');
    if (raw == null) return null;
    return TodaySettlementModel.fromJson(jsonDecode(raw)).toEntity();
  }

  Future<void> saveTodaySettlement(TodaySettlementModel model) async {
    await _box.put('todaySettlement', jsonEncode(model.toJson()));
  }

  // ─── Drawer Status ───

  CashDrawerStatus? getDrawerStatus() {
    final raw = _box.get('drawerStatus');
    if (raw == null) return null;
    return CashDrawerStatusModel.fromJson(jsonDecode(raw)).toEntity();
  }

  Future<void> saveDrawerStatus(CashDrawerStatusModel model) async {
    await _box.put('drawerStatus', jsonEncode(model.toJson()));
  }

  // ─── Cache Validity ───

  bool isCacheValid() {
    final timestamp = _cacheTimestampBox.get(HiveBoxConstants.cashierDashboardCacheKey);
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < HiveBoxConstants.cashierDashboardCacheValidDuration;
  }

  void _updateTimestamp(String key) {
    _cacheTimestampBox.put(key, DateTime.now());
  }

  void invalidateCache() {
    _cacheTimestampBox.delete(HiveBoxConstants.cashierDashboardCacheKey);
  }

  Future<void> clearAll() async {
    await _box.clear();
    invalidateCache();
  }
}
