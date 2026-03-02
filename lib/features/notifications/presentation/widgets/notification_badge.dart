import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/notification_view_model.dart';
import '../pages/notifications_page.dart';

/// Reusable notification bell icon with unread badge.
/// Drop this into any AppBar's `actions` list.
class NotificationBadge extends ConsumerStatefulWidget {
  const NotificationBadge({super.key});

  @override
  ConsumerState<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends ConsumerState<NotificationBadge> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationViewModelProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationViewModelProvider);
    final unreadCount = notificationState.unreadCount;

    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationsPage()),
        );
      },
      icon: SizedBox(
        width: 28,
        height: 28,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_outlined, color: Colors.black87, size: 26),
            if (unreadCount > 0)
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
