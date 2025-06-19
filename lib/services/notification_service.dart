import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:logging/logging.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  NotificationService._internal();

  // Stream controller for notification count
  final _notificationCountController = StreamController<int>.broadcast();
  Stream<int> get notificationCount => _notificationCountController.stream;

  // Current unread notification count
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // SignalR connection
  HubConnection? _hubConnection;
  final Logger _logger = Logger('NotificationHub');
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Initialize the service
  Future<void> initialize() async {
    await _connectToSignalR();
  }

  // Connect to SignalR hub
  Future<void> _connectToSignalR() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('❌ No auth token found for SignalR connection');
        return;
      }

      // Configure SignalR connection
      final hubUrl = 'http://mohamek-legel.runasp.net/hubs/notificationhub';
      _hubConnection = HubConnectionBuilder()
          .withUrl(
            '$hubUrl?access_token=$token',
            options: HttpConnectionOptions(
              logger: _logger,
              logMessageContent: true,
              skipNegotiation: false,
              accessTokenFactory: () => Future.value(token),
            ),
          )
          .withAutomaticReconnect()
          .build();

      // Set up event handlers for both new and old notifications
      _hubConnection!.on('ReceiveNewNotification', _handleReceiveNotification);
      _hubConnection!.on('ReceiveOldNotification', _handleReceiveNotification);

      // Start the connection
      await _hubConnection!.start();
      _isConnected = true;
      print('✅ Connected to SignalR notification hub');

      // The hub will automatically send old notifications when connected
    } catch (e) {
      print('❌ Error connecting to SignalR: $e');
      _isConnected = false;
    }
  }

  // Handle receiving a notification
  void _handleReceiveNotification(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty && arguments[0] != null) {
      try {
        final notificationData = arguments[0] as Map<String, dynamic>;
        print('Received notification: $notificationData');

        // Increment unread count
        markAsRead(increment: true);
      } catch (e) {
        print('Error processing notification: $e');
      }
    }
  }

  // Mark a notification as read (or unread if incrementing)
  void markAsRead({bool increment = false}) {
    if (increment) {
      _unreadCount++;
    } else if (_unreadCount > 0) {
      _unreadCount--;
    }
    _notificationCountController.add(_unreadCount);
  }

  // Mark all notifications as read
  void markAllAsRead() {
    _unreadCount = 0;
    _notificationCountController.add(_unreadCount);
  }

  // Clear all notifications (called when notifications are deleted on the server)
  void clearAllNotifications() {
    _unreadCount = 0;
    _notificationCountController.add(_unreadCount);
  }

  // Disconnect from SignalR
  Future<void> disconnect() async {
    try {
      if (_hubConnection != null && _isConnected) {
        await _hubConnection!.stop();
        _isConnected = false;
        print('SignalR connection stopped');
      }
    } catch (e) {
      print('Error stopping SignalR connection: $e');
    }
  }

  // Dispose resources
  void dispose() {
    _notificationCountController.close();
    disconnect();
  }
}
