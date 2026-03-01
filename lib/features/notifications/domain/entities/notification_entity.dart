import 'package:equatable/equatable.dart';

enum NotificationStatus { unread, read, archived }

enum NotificationPriority { low, medium, high, critical }

class NotificationEntity extends Equatable {
  final String id;
  final String? restaurantId;
  final String type;
  final List<String> recipients;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final NotificationStatus status;
  final String? actionUrl;
  final NotificationPriority priority;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const NotificationEntity({
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

  @override
  List<Object?> get props => [id, type, title, message, status, createdAt];
}
