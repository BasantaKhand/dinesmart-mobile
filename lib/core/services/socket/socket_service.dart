import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../storage/user_session_service.dart';
import '../../api/api_endpoints.dart';

typedef NotificationCallback = void Function(Map<String, dynamic> data);

final socketServiceProvider = Provider<SocketService>((ref) {
  final sessionService = ref.read(userSessionServiceProvider);
  return SocketService(sessionService: sessionService);
});

class SocketService {
  final UserSessionService sessionService;
  io.Socket? _socket;
  final List<NotificationCallback> _listeners = [];
  bool _isConnected = false;

  SocketService({required this.sessionService});

  String get _socketUrl {
    final baseUrl = ApiEndpoints.baseUrl;
    return baseUrl.replaceAll('/api', '');
  }

  bool get isConnected => _isConnected;

  void connect() {
    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
    }

    final role = sessionService.getCurrentUserRole();
    final restaurantId = sessionService.getCurrentRestaurantId();

    debugPrint('Socket: role=$role, restaurantId=$restaurantId');

    if (role == null || restaurantId == null) {
      debugPrint('Socket: Cannot connect - missing role or restaurantId');
      return;
    }

    debugPrint('Socket: Connecting to $_socketUrl');

    _socket = io.io(
      _socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      debugPrint('Socket: Connected successfully');
      _socket!.emit('join_notifications', {
        'role': role,
        'restaurantId': restaurantId,
      });
      debugPrint('Socket: Emitted join_notifications for $role at $restaurantId');
    });

    _socket!.on('new_notification', (data) {
      debugPrint('Socket: Received notification - type=${data['type']}');
      if (data is Map) {
        _notifyListeners(Map<String, dynamic>.from(data));
      }
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      debugPrint('Socket: Disconnected');
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      debugPrint('Socket: Connection error - $error');
    });

    _socket!.onError((error) {
      debugPrint('Socket: Error - $error');
    });

    _socket!.connect();
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
    }
  }

  void addListener(NotificationCallback callback) {
    _listeners.add(callback);
  }

  void removeListener(NotificationCallback callback) {
    _listeners.remove(callback);
  }

  void _notifyListeners(Map<String, dynamic> data) {
    for (final listener in _listeners) {
      listener(data);
    }
  }

  void reconnect() {
    disconnect();
    connect();
  }
}
