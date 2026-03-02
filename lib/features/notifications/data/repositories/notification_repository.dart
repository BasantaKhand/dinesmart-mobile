import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:dinesmart_app/core/error/failure.dart';
import 'package:dinesmart_app/core/error/error_utils.dart';
import 'package:dinesmart_app/core/services/connectivity/network_info.dart';
import '../data_sources/notification_remote_data_source.dart';
import '../data_sources/notification_local_data_source.dart';
import '../../domain/entities/notification_entity.dart';

final notificationRepositoryProvider = Provider((ref) {
  return NotificationRepository(
    remoteDataSource: ref.read(notificationRemoteDataSourceProvider),
    localDataSource: ref.read(notificationLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

class NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final NotificationLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  NotificationRepository({
    required NotificationRemoteDataSource remoteDataSource,
    required NotificationLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  Future<Either<Failure, NotificationsResult>> getNotifications({int page = 1}) async {
    if (await _networkInfo.isConnected) {
      try {
        final response = await _remoteDataSource.getNotifications(page: page);
        // Cache first page only
        if (page == 1) {
          await _localDataSource.saveNotifications(response.notifications);
          await _localDataSource.saveUnreadCount(response.totalUnread);
        }
        final entities = response.notifications.map((m) => m.toEntity()).toList();
        return Right(NotificationsResult(
          notifications: entities,
          totalUnread: response.totalUnread,
        ));
      } catch (e) {
        return Left(ApiFailure(message: ErrorUtils.getMessage(e)));
      }
    } else {
      final cachedNotifications = _localDataSource.getNotifications();
      final cachedUnread = _localDataSource.getUnreadCount();
      return Right(NotificationsResult(
        notifications: cachedNotifications,
        totalUnread: cachedUnread,
      ));
    }
  }

  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    try {
      await _remoteDataSource.markAsRead(notificationId);
      _localDataSource.invalidateCache();
      return const Right(null);
    } catch (e) {
      return Left(ApiFailure(message: ErrorUtils.getMessage(e)));
    }
  }

  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await _remoteDataSource.markAllAsRead();
      _localDataSource.invalidateCache();
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
