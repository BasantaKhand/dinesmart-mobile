import '../../domain/entities/notification_entity.dart';

class NotificationApiModel {
  final String id;
  final String? restaurantId;
  final String type;
  final List<String> recipients;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final String status;
  final String? actionUrl;
  final String priority;
  final DateTime createdAt;
  final DateTime? expiresAt;

  NotificationApiModel({
    required this.id,
    this.restaurantId,
    required this.type,
    required this.recipients,
    required this.title,
    required this.message,
    this.data,
    required this.status,
    this.actionUrl,
    required this.priority,
    required this.createdAt,
    this.expiresAt,
  });

  factory NotificationApiModel.fromJson(Map<String, dynamic> json) {
    return NotificationApiModel(
      id: json['_id'] ?? json['id'] ?? '',
      restaurantId: json['restaurantId'],
      type: json['type'] ?? '',
      recipients: List<String>.from(json['recipients'] ?? []),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] as Map<String, dynamic>?,
      status: json['status'] ?? 'UNREAD',
      actionUrl: json['actionUrl'],
      priority: json['priority'] ?? 'MEDIUM',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : null,
    );
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      restaurantId: restaurantId,
      type: type,
      recipients: recipients,
      title: title,
      message: message,
      data: data,
      status: _parseStatus(status),
      actionUrl: actionUrl,
      priority: _parsePriority(priority),
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'restaurantId': restaurantId,
      'type': type,
      'recipients': recipients,
      'title': title,
      'message': message,
      'data': data,
      'status': status,
      'actionUrl': actionUrl,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  NotificationStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'READ':
        return NotificationStatus.read;
      case 'ARCHIVED':
        return NotificationStatus.archived;
      default:
        return NotificationStatus.unread;
    }
  }

  NotificationPriority _parsePriority(String priority) {
    switch (priority.toUpperCase()) {
      case 'LOW':
        return NotificationPriority.low;
      case 'HIGH':
        return NotificationPriority.high;
      case 'CRITICAL':
        return NotificationPriority.critical;
      default:
        return NotificationPriority.medium;
    }
  }
}

class NotificationsResponse {
  final List<NotificationApiModel> notifications;
  final int totalUnread;
  final Map<String, int> unreadCounts;

  NotificationsResponse({
    required this.notifications,
    required this.totalUnread,
    required this.unreadCounts,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final List notificationsList = data['notifications'] ?? [];
    return NotificationsResponse(
      notifications: notificationsList
          .map((n) => NotificationApiModel.fromJson(n))
          .toList(),
      totalUnread: data['totalUnread'] ?? 0,
      unreadCounts: Map<String, int>.from(data['unreadCounts'] ?? {}),
    );
  }
}
