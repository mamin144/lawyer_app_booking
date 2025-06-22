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
        return 'منذ ${(difference.inDays / 365).floor()} سنة';
      } else if (difference.inDays > 30) {
        return 'منذ ${(difference.inDays / 30).floor()} شهر';
      } else if (difference.inDays > 0) {
        return 'منذ ${difference.inDays} يوم';
      } else if (difference.inHours > 0) {
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inMinutes > 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else {
        return 'الآن';
      }
    } catch (e) {
      print('Error parsing date: $e');
      return 'مؤخراً';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'الإشعارات',
            style: TextStyle(
              color: Color(0xFF1F41BB),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF1F41BB),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFF1F41BB),
              ),
              onPressed: _clearNotifications,
              tooltip: 'مسح جميع الإشعارات',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F41BB)),
                ),
              )
            : _notifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF1F41BB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 60,
              color: Color(0xFF1F41BB),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا الإشعارات الجديدة عند وصولها',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1F41BB),
                  const Color(0xFF1F41BB).withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1F41BB).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الإشعارات',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_notifications.length} إشعار${_notifications.length > 1 ? 'ات' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Notifications list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _buildNotificationCard(notification);
              },
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (notification.unread) {
              _markNotificationAsRead(notification.id);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Notification icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: notification.unread
                        ? const Color(0xFF1F41BB).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification.unread
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                    color: notification.unread
                        ? const Color(0xFF1F41BB)
                        : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: notification.unread
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: notification.unread
                              ? Colors.black87
                              : Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Unread indicator
                if (notification.unread) ...[
                  const SizedBox(width: 12),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1F41BB),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
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
            content: Text('تم مسح جميع الإشعارات'),
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
          content: Text('خطأ في مسح الإشعارات: $e'),
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
