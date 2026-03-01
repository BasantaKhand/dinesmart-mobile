import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/core/api/api_client.dart';
import 'package:dinesmart_app/core/api/api_endpoints.dart';
import '../models/notification_api_model.dart';

final notificationRemoteDataSourceProvider = Provider((ref) {
  return NotificationRemoteDataSource(ref.read(apiClientProvider));
});

class NotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSource(this._apiClient);

  Future<NotificationsResponse> getNotifications({int page = 1, int limit = 20}) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.notifications}?page=$page&limit=$limit',
      );
      return NotificationsResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.put(ApiEndpoints.markNotificationRead(notificationId));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.put(ApiEndpoints.markAllNotificationsRead);
    } catch (e) {
      rethrow;
    }
  }
}
