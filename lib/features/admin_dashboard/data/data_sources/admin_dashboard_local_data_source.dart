import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:dinesmart_app/core/constants/hive_box_constants.dart';
import '../models/admin_stats_model.dart';
import '../../domain/entities/admin_statistics.dart';

final adminDashboardLocalDataSourceProvider = Provider((ref) {
  return AdminDashboardLocalDataSource();
});

class AdminDashboardLocalDataSource {
  Box<String> get _box => Hive.box<String>(HiveBoxConstants.adminDashboardBox);
  Box<DateTime> get _cacheTimestampBox =>
      Hive.box<DateTime>(HiveBoxConstants.cacheTimestampBox);

  // ─── Overview Stats ───

  AdminStatistics? getOverview(int days) {
    final raw = _box.get('overview_$days');
    if (raw == null) return null;
    return AdminStatisticsModel.fromJson(jsonDecode(raw)).toEntity();
  }

  Future<void> saveOverview(int days, AdminStatisticsModel model) async {
    await _box.put('overview_$days', jsonEncode(model.toJson()));
    _updateTimestamp(HiveBoxConstants.adminDashboardCacheKey);
  }

  // ─── Sales Overview ───

  List<SalesData> getSalesOverview(int days) {
    final raw = _box.get('sales_$days');
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded
        .map((j) => SalesDataModel.fromJson(j).toEntity())
        .toList();
  }

  Future<void> saveSalesOverview(
      int days, List<SalesDataModel> models) async {
    await _box.put(
        'sales_$days', jsonEncode(models.map((m) => m.toJson()).toList()));
  }

  // ─── Category Sales ───

  List<CategorySalesData> getCategorySales(int days) {
    final raw = _box.get('categorySales_$days');
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded
        .map((j) => CategorySalesDataModel.fromJson(j).toEntity())
        .toList();
  }

  Future<void> saveCategorySales(
      int days, List<CategorySalesDataModel> models) async {
    await _box.put('categorySales_$days',
        jsonEncode(models.map((m) => m.toJson()).toList()));
  }

  // ─── Cache Validity ───

  bool isCacheValid() {
    final timestamp =
        _cacheTimestampBox.get(HiveBoxConstants.adminDashboardCacheKey);
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) <
        HiveBoxConstants.adminDashboardCacheValidDuration;
  }

  void _updateTimestamp(String key) {
    _cacheTimestampBox.put(key, DateTime.now());
  }

  void invalidateCache() {
    _cacheTimestampBox.delete(HiveBoxConstants.adminDashboardCacheKey);
  }

  Future<void> clearAll() async {
    await _box.clear();
    invalidateCache();
  }
}
