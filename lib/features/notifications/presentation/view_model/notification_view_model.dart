import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dinesmart_app/core/services/socket/socket_service.dart';
import 'package:dinesmart_app/features/notifications/data/repositories/notification_repository.dart';
import 'package:dinesmart_app/features/notifications/domain/entities/notification_entity.dart';

final notificationViewModelProvider =
    StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
  return NotificationViewModel(
    repository: ref.read(notificationRepositoryProvider),
    socketService: ref.read(socketServiceProvider),
  );
});

class NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationViewModel extends StateNotifier<NotificationState> {
  final NotificationRepository repository;
  final SocketService socketService;

  NotificationViewModel({
    required this.repository,
    required this.socketService,
  }) : super(const NotificationState()) {
    _initSocket();
  }

  void _initSocket() {
    socketService.addListener(_handleSocketNotification);
  }

  void _handleSocketNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type != null) {
      state = state.copyWith(unreadCount: state.unreadCount + 1);
      loadNotifications();
    }
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final result = await repository.getNotifications();
    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (data) => state = state.copyWith(
        isLoading: false,
        notifications: data.notifications,
        unreadCount: data.totalUnread,
      ),
    );
  }

  Future<void> markAsRead(String notificationId) async {
    final result = await repository.markAsRead(notificationId);
    result.fold(
      (failure) {},
      (_) {
        final updated = state.notifications.map((n) {
          if (n.id == notificationId) {
            return NotificationEntity(
              id: n.id,
              restaurantId: n.restaurantId,
              type: n.type,
              recipients: n.recipients,
              title: n.title,
              message: n.message,
              data: n.data,
              status: NotificationStatus.read,
              actionUrl: n.actionUrl,
              priority: n.priority,
              createdAt: n.createdAt,
              expiresAt: n.expiresAt,
            );
          }
          return n;
        }).toList();
        
        final newUnread = state.unreadCount > 0 ? state.unreadCount - 1 : 0;
        state = state.copyWith(
          notifications: updated,
          unreadCount: newUnread,
        );
      },
    );
  }

  Future<void> markAllAsRead() async {
    final result = await repository.markAllAsRead();
    result.fold(
      (failure) {},
      (_) {
        final updated = state.notifications.map((n) {
          return NotificationEntity(
            id: n.id,
            restaurantId: n.restaurantId,
            type: n.type,
            recipients: n.recipients,
            title: n.title,
            message: n.message,
            data: n.data,
            status: NotificationStatus.read,
            actionUrl: n.actionUrl,
            priority: n.priority,
            createdAt: n.createdAt,
            expiresAt: n.expiresAt,
          );
        }).toList();
        
        state = state.copyWith(
          notifications: updated,
          unreadCount: 0,
        );
      },
    );
  }

  @override
  void dispose() {
    socketService.removeListener(_handleSocketNotification);
    super.dispose();
  }
}
