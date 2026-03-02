import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:dinesmart_app/core/constants/hive_box_constants.dart';
import '../models/notification_api_model.dart';
import '../../domain/entities/notification_entity.dart';

final notificationLocalDataSourceProvider = Provider((ref) {
  return NotificationLocalDataSource();
});

class NotificationLocalDataSource {
  Box<String> get _box => Hive.box<String>(HiveBoxConstants.notificationsBox);
  Box<DateTime> get _cacheTimestampBox =>
      Hive.box<DateTime>(HiveBoxConstants.cacheTimestampBox);

  // ─── Notifications List ───

  List<NotificationEntity> getNotifications() {
    final raw = _box.get('notificationsList');
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded
        .map((j) => NotificationApiModel.fromJson(j).toEntity())
        .toList();
  }

  Future<void> saveNotifications(List<NotificationApiModel> models) async {
    await _box.put('notificationsList',
        jsonEncode(models.map((m) => m.toJson()).toList()));
    _updateTimestamp(HiveBoxConstants.notificationsCacheKey);
  }

  // ─── Unread Count ───

  int getUnreadCount() {
    final raw = _box.get('unreadCount');
    if (raw == null) return 0;
    return int.tryParse(raw) ?? 0;
  }

  Future<void> saveUnreadCount(int count) async {
    await _box.put('unreadCount', count.toString());
  }

  // ─── Cache Validity ───

  bool isCacheValid() {
    final timestamp =
        _cacheTimestampBox.get(HiveBoxConstants.notificationsCacheKey);
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) <
        HiveBoxConstants.notificationsCacheValidDuration;
  }

  void _updateTimestamp(String key) {
    _cacheTimestampBox.put(key, DateTime.now());
  }

  void invalidateCache() {
    _cacheTimestampBox.delete(HiveBoxConstants.notificationsCacheKey);
  }

  Future<void> clearAll() async {
    await _box.clear();
    invalidateCache();
  }
}
