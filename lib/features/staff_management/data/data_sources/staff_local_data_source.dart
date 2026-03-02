import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:dinesmart_app/core/constants/hive_box_constants.dart';
import '../models/staff_api_model.dart';
import '../../domain/entities/staff_entity.dart';

final staffLocalDataSourceProvider = Provider((ref) {
  return StaffLocalDataSource();
});

class StaffLocalDataSource {
  Box<String> get _box => Hive.box<String>(HiveBoxConstants.staffBox);
  Box<DateTime> get _cacheTimestampBox =>
      Hive.box<DateTime>(HiveBoxConstants.cacheTimestampBox);

  // ─── Staff List ───

  List<StaffEntity> getStaff() {
    final raw = _box.get('staffList');
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((j) => StaffApiModel.fromJson(j).toEntity()).toList();
  }

  Future<void> saveStaff(List<StaffApiModel> models) async {
    await _box.put(
        'staffList', jsonEncode(models.map((m) => _modelToCache(m)).toList()));
    _updateTimestamp(HiveBoxConstants.staffCacheKey);
  }

  /// Convert model to a cache-safe JSON (uses _id key for consistency with fromJson)
  Map<String, dynamic> _modelToCache(StaffApiModel model) {
    return {
      '_id': model.id,
      'name': model.name,
      'email': model.email,
      'phone': model.phone,
      'role': model.role,
      'status': model.status,
    };
  }

  // ─── Cache Validity ───

  bool isCacheValid() {
    final timestamp =
        _cacheTimestampBox.get(HiveBoxConstants.staffCacheKey);
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) <
        HiveBoxConstants.staffCacheValidDuration;
  }

  void _updateTimestamp(String key) {
    _cacheTimestampBox.put(key, DateTime.now());
  }

  void invalidateCache() {
    _cacheTimestampBox.delete(HiveBoxConstants.staffCacheKey);
  }

  Future<void> clearAll() async {
    await _box.clear();
    invalidateCache();
  }
}
