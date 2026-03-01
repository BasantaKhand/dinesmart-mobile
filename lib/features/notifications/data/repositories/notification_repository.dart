import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/error/error_utils.dart';
import '../data_sources/notification_remote_data_source.dart';
import '../../domain/entities/notification_entity.dart';

final notificationRepositoryProvider = Provider((ref) {
  return NotificationRepository(ref.read(notificationRemoteDataSourceProvider));
});

class NotificationRepository {
  final NotificationRemoteDataSource _dataSource;

  NotificationRepository(this._dataSource);

  Future<Either<Failure, NotificationsResult>> getNotifications({int page = 1}) async {
    try {
      final response = await _dataSource.getNotifications(page: page);
      final entities = response.notifications.map((m) => m.toEntity()).toList();
      return Right(NotificationsResult(
        notifications: entities,
        totalUnread: response.totalUnread,
      ));
    } catch (e) {
      return Left(ApiFailure(message: ErrorUtils.getMessage(e)));
    }
  }

  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _dataSource.markAsRead(notificationId);
      return const Right(null);
    } catch (e) {
      return Left(ApiFailure(message: ErrorUtils.getMessage(e)));
    }
  }

  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await _dataSource.markAllAsRead();
      return const Right(null);
    } catch (e) {
      return Left(ApiFailure(message: ErrorUtils.getMessage(e)));
    }
  }
}

class NotificationsResult {
  final List<NotificationEntity> notifications;
  final int totalUnread;

  NotificationsResult({
    required this.notifications,
    required this.totalUnread,
  });
}
