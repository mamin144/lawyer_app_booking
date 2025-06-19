import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:logging/logging.dart';
import 'services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _isLoading = false;
  late HubConnection _hubConnection;
  final Logger _logger = Logger('NotificationHub');
  final NotificationService _notificationService = NotificationService();

  // Notifications will be populated by SignalR
  final List<NotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    // Initialize SignalR connection
    _initSignalR();
  }

  @override
  void dispose() {
    // Stop the SignalR connection when the page is disposed
    _stopSignalR();
    super.dispose();
  }

  // Initialize SignalR connection
  Future<void> _initSignalR() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
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
      _hubConnection.on('ReceiveNewNotification', _handleReceiveNotification);
      _hubConnection.on('ReceiveOldNotification', _handleReceiveNotification);

      // Start the connection
      await _hubConnection.start();
      print('✅ Connected to SignalR notification hub');

      // After connecting successfully, clear loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error connecting to SignalR: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect to notification service: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Stop SignalR connection
  Future<void> _stopSignalR() async {
    try {
      if (_hubConnection.state == HubConnectionState.Connected) {
        await _hubConnection.stop();
        print('SignalR connection stopped');
      }
    } catch (e) {
      print('Error stopping SignalR connection: $e');
    }
  }

  // Handle receiving a notification from SignalR
  void _handleReceiveNotification(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty && arguments[0] != null) {
      try {
        final notificationData = arguments[0] as Map<String, dynamic>;
        print('Received notification: $notificationData');

        final notification = NotificationItem(
          id: notificationData['id']?.toString() ?? '',
          message: notificationData['message'] ?? 'New notification',
          timeAgo: notificationData['createAt'] != null
              ? _formatTimeAgo(notificationData['createAt'])
              : 'Just now',
          unread: true,
        );

        if (mounted) {
          setState(() {
            // Add the new notification at the top of the list
            _notifications.insert(0, notification);
          });

          // No snackbar notification needed
        }
      } catch (e) {
        print('Error processing notification: $e');
      }
    }
  }

  // Helper method to format time ago
  String _formatTimeAgo(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} year(s) ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month(s) ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day(s) ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour(s) ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute(s) ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      print('Error parsing date: $e');
      return 'Recently';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Add this button to clear notifications
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black),
            onPressed: _clearNotifications,
            tooltip: 'Clear notifications',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[200]!,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F41BB)),
                ),
              )
            : _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main bell container
                        Container(
                          width: 150,
                          height: 150,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Bell shape
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(50),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Bell "face"
                                    Container(
                                      width: 40,
                                      height: 10,
                                      margin: const EdgeInsets.only(top: 20),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey[800],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Bell "knob" on top
                              Positioned(
                                top: 15,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              // Small curved lines to indicate ringing
                              Positioned(
                                top: 30,
                                left: 30,
                                child: CustomPaint(
                                  size: const Size(20, 20),
                                  painter: BellRingPainter(),
                                ),
                              ),
                              // Bell shadow/base
                              Positioned(
                                bottom: 25,
                                child: Container(
                                  width: 30,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              // Blue circle with empty indicator
                              Positioned(
                                bottom: 20,
                                right: 20,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0A1A3A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.notifications_off_outlined,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Notifications!',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationItem(notification);
                    },
                  ),
      ),
    );
  }

  // Method to clear notifications both locally and on the server
  Future<void> _clearNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      // Call API to delete notifications
      final response = await http.delete(
        Uri.parse(
            'http://mohamek-legel.runasp.net/api/Additional/delete-notification'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Successfully cleared on server, now clear locally
        setState(() {
          _notifications.clear();
          _isLoading = false;
        });

        // Also update the notification service
        _notificationService.clearAllNotifications();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications cleared'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(
            'Failed to clear notifications: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing notifications: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error clearing notifications: $e');
    }
  }

  // Method to mark a notification as read
  void _markNotificationAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index].unread = false;
      }
    });
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        // No profile image, using an icon instead
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1F41BB).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.notifications_none,
              color: Color(0xFF1F41BB),
              size: 20,
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            notification.message,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        subtitle: Text(
          notification.timeAgo,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: notification.unread
            ? Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF1F41BB),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.circle,
                    color: Colors.white,
                    size: 8,
                  ),
                ),
              )
            : null,
        onTap: () {
          // Mark notification as read when tapped
          if (notification.unread) {
            _markNotificationAsRead(notification.id);
          }
        },
      ),
    );
  }
}

class NotificationItem {
  final String id;
  final String message;
  final String timeAgo;
  bool unread;

  NotificationItem({
    required this.id,
    required this.message,
    required this.timeAgo,
    this.unread = false,
  });
}

// Custom painter for the bell ring curved lines
class BellRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw first curved line
    final path1 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.5,
        0,
        size.width,
        size.height * 0.7,
      );
    canvas.drawPath(path1, paint);

    // Draw second curved line (smaller)
    final path2 = Path()
      ..moveTo(3, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.3,
        size.width - 3,
        size.height * 0.8,
      );
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
