import 'package:flutter/material.dart';
import 'Homepage.dart';
import 'edit_profile.dart';
// import 'services/profile_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'auth/confirem_email.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'screens/available.dart';
// import 'package:flutter_application_4/routes.dart'; // Adjust the path if necessary
import 'package:signalr_netcore/signalr_client.dart';
// Import HubConnectionState
import 'package:logging/logging.dart';
import 'auth/signup.dart';
import 'dart:developer' as developer;
import 'notification.dart';
import 'personal_info_settings.dart';
import 'dart:async';
import 'screens/call_screen.dart' as basic_call;
import 'screens/webrtc_call_screen.dart' as webrtc_call;
import 'services/global_call_service.dart';

class Routes {
  static const String home = '/';
  static const String profile = '/profile';
  static const String appointment = '/appointment';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfilePage(),
          settings: settings,
        );
      case appointment:
        return MaterialPageRoute(
          builder: (_) => const AppointmentPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No route defined for ${settings.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _error;
  String? _userType;

  @override
  void initState() {
    super.initState();
    print('ProfilePage initState called');
    _initializeAndLoadProfile();
  }

  Future<void> _initializeAndLoadProfile() async {
    print('Starting profile initialization...');
    try {
      print('Initializing ProfileService...');
      await ProfileService.initialize();

      print('Getting token...');
      final token = await _profileService._getToken();
      print('Token exists: ${token != null}');

      print('Getting user role...');
      _userType = await _profileService.getCurrentUserRole();
      print('User role: $_userType');

      print('Loading profile data...');
      await _loadProfile();
    } catch (e) {
      print('Error in initialization: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _profileService.getProfile();
      print('Profile data loaded successfully: $data');

      if (!mounted) return;

      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building ProfilePage with data: $_profileData');
    print('Loading state: $_isLoading');
    print('Error state: $_error');

    return Scaffold(
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading profile...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeAndLoadProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : ModernArabicProfileWidget(
                  userName: _profileData?['fullName'] ?? 'Loading...',
                  userEmail: _profileData?['email'] ?? 'No email',
                  userImageUrl: _profileData?['pictureUrl'] ?? 'Not Exist',
                  phoneNumber: _profileData?['phoneNumber'] ?? '',
                  dateOfBirth: _profileData?['dateOfBirth'] ?? '',
                  isConfirmed: _profileData?['isConfiremedEmail'] ?? false,
                  userRole: _userType,
                ),
    );
  }
}

/// A modern Arabic Profile widget with contemporary design elements
class ModernArabicProfileWidget extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userImageUrl;
  final String phoneNumber;
  final String dateOfBirth;
  final bool isConfirmed;
  final VoidCallback? onVerificationTap;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onPaymentHistoryTap;
  final VoidCallback? onGeneralSettingsTap;
  final VoidCallback? onAddressTap;
  final VoidCallback? onFaqTap;
  final VoidCallback? onLogoutTap;
  final Color primaryColor;
  final Color secondaryColor;
  final String? userRole;

  const ModernArabicProfileWidget({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userImageUrl,
    required this.phoneNumber,
    required this.dateOfBirth,
    required this.isConfirmed,
    this.onVerificationTap,
    this.onNotificationsTap,
    this.onPaymentHistoryTap,
    this.onGeneralSettingsTap,
    this.onAddressTap,
    this.onFaqTap,
    this.onLogoutTap,
    this.primaryColor = const Color(0xFF1F41BB),
    this.secondaryColor = const Color(0xFFF6F8FB),
    this.userRole,
  });

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login', // Make sure this route exists in your app
        (route) => false, // Remove all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: secondaryColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'الملف الشخصي',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false, // Remove back arrow
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Modern profile header with gradient background
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: userImageUrl != 'Not Exist'
                          ? CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(userImageUrl),
                            )
                          : CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 35,
                                color: primaryColor,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            userEmail,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileEditePage(),
                                  ),
                                );
                              },
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'تعديل الملف',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Section title
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'الإعدادات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Modern menu items
              _buildModernMenuItem(
                title: 'تفعيل التحقق الشخصي',
                subtitle: 'التحقق من هويتك الشخصية',
                icon: Icons.verified_user_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PasswordResetScreen(),
                    ),
                  );
                },
                color: Colors.green,
              ),
              if (userRole == 'lawyer')
                _buildModernMenuItem(
                  title: 'مواعيدك المتاحة',
                  subtitle: 'المواعيد المتاحة لك',
                  icon: Icons.calendar_month_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AvailableScreen(),
                      ),
                    );
                  },
                  color: Colors.green,
                ),
              _buildModernMenuItem(
                title: 'الإشعارات',
                subtitle: 'إدارة إشعارات التطبيق',
                icon: Icons.notifications_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationPage(),
                    ),
                  );
                },
                color: Colors.orange,
              ),
              if (userRole == 'lawyer')
                _buildModernMenuItem(
                  title: 'السيرة الذاتية',
                  subtitle: 'إضافة المعلومات الشخصية ',
                  icon: Icons.description_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PersonalInfoSettingsPage(),
                      ),
                    );
                  },
                  color: Colors.blue,
                ),
              _buildModernMenuItem(
                title: 'الأسئلة الشائعة',
                subtitle: 'الحصول على إجابات لأسئلتك',
                icon: Icons.help_outline,
                onTap: onFaqTap,
                color: Colors.teal,
              ),

              const SizedBox(height: 20),

              // Section title
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'الحساب',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Logout button
              Padding(
                padding: const EdgeInsets.all(16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 16),
                            Text(
                              'تسجيل الخروج',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: null,
      ),
    );
  }

  Widget _buildModernMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

// // Example usage
// class ExampleModernUsage extends StatelessWidget {
//   const ExampleModernUsage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         fontFamily: 'Cairo', // Arabic font
//       ),
//       home: const ModernArabicProfileWidget(
//         userName: 'Guy Hawkins',
//         userEmail: 'hawkins@gmail.com',
//         userImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
//         phoneNumber: '+1234567890',
//         dateOfBirth: '2000-05-15',
//         isConfirmed: true,
//       ),
//     );
//   }
// }

// class ExampleUsage extends StatelessWidget {
//   const ExampleUsage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: ModernArabicProfileWidget(
//         userName: 'Guy Hawkins',
//         userEmail: 'hawkins@gmail.com',
//         userImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
//         phoneNumber: '+1234567890',
//         dateOfBirth: '2000-05-15',
//         isConfirmed: true,
//       ),
//     );
//   }
// }

// ملف Flutter كامل مدمج مع الوظائف الإضافية من السيرفر

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String
      receiverId; // This should be the actual user ID, not display name
  final String receiverName; // Add this for display purposes
  final String receiverImageUrl;
  final bool isOnline;
  final String consultationId;

  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImageUrl,
    required this.consultationId,
    this.isOnline = false,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  late HubConnection hubConnection;
  final _logger = Logger('SignalRClient');
  static const String _messagesKey = 'chat_messages_';
  // Call-related variables removed - now handled by GlobalCallService
  // bool _isCallDialogVisible = false;
  // String? _currentCallId;
  // Map<String, dynamic>? _currentCallData;
  // String? _pendingCallId;
  // String? _currentCallerId;
  // String? _currentReceiverId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _initSignalR();
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson =
          prefs.getStringList(_messagesKey + widget.consultationId);
      developer.log(
          'Attempting to load messages for consultationId: ${widget.consultationId}');

      if (messagesJson != null && messagesJson.isNotEmpty) {
        developer
            .log('Found ${messagesJson.length} messages in SharedPreferences.');
        final loadedMessages = messagesJson
            .map((json) => Message.fromJson(jsonDecode(json)))
            .toList();
        setState(() {
          _messages.clear();
          _messages.addAll(loadedMessages);
        });
        developer.log('Successfully loaded ${loadedMessages.length} messages.');
      } else {
        developer.log(
            'No messages found in SharedPreferences for consultationId: ${widget.consultationId}.');
      }
    } catch (e) {
      developer.log('Error loading messages: $e', error: e);
    }
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson =
          _messages.map((message) => jsonEncode(message.toJson())).toList();
      await prefs.setStringList(
          _messagesKey + widget.consultationId, messagesJson);
      developer.log(
          'Successfully saved ${_messages.length} messages for consultationId: ${widget.consultationId}.');
    } catch (e) {
      developer.log('Error saving messages: $e', error: e);
    }
  }

  @override
  void dispose() {
    _saveMessages();
    hubConnection.stop();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initSignalR() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication token not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final hubUrl =
        'http://mohamek-legel.runasp.net/hubs/chathub?access_token=$token';

    hubConnection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            logger: _logger,
            logMessageContent: true,
            skipNegotiation: false,
            accessTokenFactory: () => Future.value(token),
          ),
        )
        .withAutomaticReconnect()
        .build();

    hubConnection.on("ReceiveMessage", _onReceiveMessage);
    hubConnection.on("MessageRead", _onMessageRead);
    hubConnection.on("Error", _onError);
    // Remove call-related handlers since they're now handled globally
    // hubConnection.on("IncomingCall", _onIncomingCall);
    // hubConnection.on("CallStarted", _onCallStarted);
    // hubConnection.on("CallEnded", _onCallEnded);
    // hubConnection.on("CallAccepted", _onCallAccepted);
    // hubConnection.on("CallRejected", _onCallRejected);
    // hubConnection.on("ReceiveOffer", _onReceiveOffer);
    // hubConnection.on("ReceiveAnswer", _onReceiveAnswer);
    // hubConnection.on("ReceiveIceCandidate", _onReceiveIceCandidate);

    try {
      print('Starting SignalR connection...');
      await hubConnection.start();

      if (hubConnection.state == HubConnectionState.Connected) {
        print('✅ Connected to SignalR successfully!');
        if (hubConnection.connectionId != null) {
          await prefs.setString(
            'signalr_connection_id',
            hubConnection.connectionId!,
          );
        } else {
          print(
            '⚠️ Connected but no connection ID available from client side.',
          );
        }
      }
    } catch (e) {
      print('Error connecting to SignalR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _initSignalR(),
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }

  void _onReceiveMessage(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final messageData = arguments[0] as Map<String, dynamic>;
      final serverMessageId = messageData['id'] as String;
      final incomingSenderId = messageData['senderId'] as String;
      final incomingContent = messageData['content'] as String;
      final incomingTimestamp = DateTime.parse(messageData['timestamp']);

      // Check if this is an echo of a message sent by the current user
      if (incomingSenderId == widget.currentUserId) {
        // Try to find a temporary message that matches the content and was sent recently
        final int existingMessageIndex = _messages.indexWhere((msg) {
          // Heuristic: Check if it's a sent message (by current user),
          // its content matches, its ID looks like a temporary client-generated one (numeric and long),
          // and its timestamp is very close to now (within 5 seconds).
          return msg.isSentByMe &&
              msg.text == incomingContent &&
              msg.id.length >= 10 &&
              int.tryParse(msg.id) != null &&
              (DateTime.now().difference(msg.timestamp).abs().inSeconds < 5);
        });

        if (existingMessageIndex != -1) {
          // Found a temporary message, update it with the server's official version
          final updatedMessage = Message(
            senderId: incomingSenderId,
            text: incomingContent,
            timestamp: incomingTimestamp,
            isSentByMe: true, // Still sent by me
            id: serverMessageId, // Use the server's actual ID
            isRead: messageData['isRead'] ?? false, // Update read status
            type: messageData['type'] ?? 'text', // Update type
            senderName: messageData['senderName'] ??
                'You', // Update sender name if available
            receiverName: messageData['receiverName'] ??
                widget.receiverName, // Update receiver name if available
            senderImageUrl:
                messageData['senderImageUrl'] ?? '', // Update image URLs
            receiverImageUrl:
                messageData['receiverImageUrl'] ?? widget.receiverImageUrl,
          );

          setState(() {
            _messages[existingMessageIndex] = updatedMessage;
          });
          developer.log(
              'Updated existing temporary message with server ID: $serverMessageId');
          _saveMessages(); // Save updated messages
          return; // Message handled, prevent duplicate addition
        }
      }

      // If it's a new incoming message (from another user) or a sent message that wasn't matched as temporary
      final message = Message(
        senderId: incomingSenderId,
        text: incomingContent,
        timestamp: incomingTimestamp,
        isSentByMe: incomingSenderId == widget.currentUserId,
        id: serverMessageId,
        isRead: messageData['isRead'] ?? false,
        type: messageData['type'] ?? 'text',
        senderName: messageData['senderName'] ?? 'Unknown',
        receiverName: messageData['receiverName'] ?? 'Unknown',
        senderImageUrl: messageData['senderImageUrl'] ?? '',
        receiverImageUrl: messageData['receiverImageUrl'] ?? '',
      );
      setState(() {
        _messages.insert(0, message); // Add new message at the beginning
      });
      developer.log(
          'Added new incoming message or unmatched sent message (ID: $serverMessageId). Total messages: ${_messages.length}');
      _saveMessages(); // Save messages after adding new message
    }
  }

  void _onMessageRead(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final messageId = arguments[0] as String;
      print('✅ Message read: $messageId');
      setState(() {
        final messageIndex = _messages.indexWhere((m) => m.id == messageId);
        if (messageIndex != -1) {
          _messages[messageIndex].isRead = true;
          _saveMessages(); // Save messages after marking as read
        } else {
          developer.log(
              'Attempted to mark message as read, but message with ID $messageId not found in local list.');
        }
      });
    }
  }

  void _onError(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final error = arguments[0]?.toString() ?? 'Unknown error';
      print('❌ Error from server: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ $error'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Call-related methods removed - now handled by GlobalCallService

  Future<void> sendMessage({
    required String consultationId,
    String? delegationId,
    required String content,
    required String type,
  }) async {
    Message? tempMessage;
    try {
      developer.log(
          '📤 Sending message: {consultationId: $consultationId, delegationId: $delegationId, content: $content, type: $type}');

      // Create a temporary message to display immediately
      tempMessage = Message(
        senderId: widget.currentUserId,
        text: content,
        timestamp: DateTime.now(),
        isSentByMe: true,
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        isRead: false,
        type: type,
        senderName: 'You', // Placeholder, ideally fetch actual user name
        receiverName: widget.receiverName,
        senderImageUrl: '',
        receiverImageUrl: widget.receiverImageUrl,
      );
      developer.log('Created tempMessage: ${tempMessage.toJson()}');

      setState(() {
        _messages.insert(0, tempMessage!);
      });
      developer.log(
          'Messages after adding tempMessage (count: ${_messages.length}):');
      for (var msg in _messages) {
        developer.log(
            '  - ID: ${msg.id}, Content: ${msg.text}, SentByMe: ${msg.isSentByMe}');
      }

      _saveMessages(); // Save immediately
      developer.log('Messages saved after adding tempMessage.');

      if (type == 'file') {
        await hubConnection.invoke('SendFileMessage', args: [
          consultationId,
          delegationId ?? '',
          content,
        ]);
      } else {
        await hubConnection.invoke('SendMessage', args: [
          consultationId,
          delegationId ?? '',
          content,
        ]);
      }

      developer.log('✓ Message sent successfully');
      _messageController.clear();
    } catch (e) {
      developer.log('❌ Error sending message', error: e);
      // Remove the temporary message if sending failed
      if (tempMessage != null) {
        setState(() {
          _messages.removeWhere((msg) => msg.id == tempMessage!.id);
        });
        _saveMessages(); // Resave after removal
        developer.log(
            'Removed tempMessage due to sending error. Messages count: ${_messages.length}');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await hubConnection.invoke('MarkMessageAsRead', args: [messageId]);
      print('🔖 Marked message as read: $messageId');
    } catch (e) {
      print('❌ Failed to mark as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            _buildAvatar(
              widget.receiverImageUrl,
              widget.receiverName,
              radius: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: widget.isOnline ? Colors.green : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.black),
            onPressed: () async {
              print(
                  'Calling StartCall with: consultationId=${widget.consultationId}, delegationId=, type=audio');

              // Use global call service instead of local SignalR
              final globalCallService = GlobalCallService();

              try {
                await globalCallService.startCall(
                  consultationId: widget.consultationId,
                  delegationId: '', // or actual delegationId if you have it
                  type: 'audio',
                );

                print('Global call service started successfully');
                print('Using consultationId: ${widget.consultationId}');

                // Show outgoing call screen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) => basic_call.CallScreen(
                      callerName: widget.receiverName,
                      initialState: basic_call.CallState.outgoing,
                      avatarUrl: widget.receiverImageUrl,
                      onAccept: () {}, // Not used in outgoing call
                      onReject: () {}, // Not used in outgoing call
                      onEnd: () async {
                        // End call using global service
                        await globalCallService.endCall();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                );
              } catch (e) {
                print('Error starting global call: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('فشل في بدء المكالمة: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // TODO: Implement more options
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          // image: const DecorationImage(
          //   image: AssetImage('lib/assets/chat_background.png'),
          //   fit: BoxFit.cover,
          //   opacity: 0.1,
          // ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final showDateHeader = index == _messages.length - 1 ||
                      !_isSameDay(_messages[index].timestamp,
                          _messages[index + 1].timestamp);

                  return Column(
                    children: [
                      if (showDateHeader)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _formatDateHeader(message.timestamp),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      _buildMessageBubble(message),
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () {
                      // TODO: Implement file attachment
                    },
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'اكتب رسالة',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        maxLines: null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A80F0),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (_messageController.text.trim().isNotEmpty) {
                          sendMessage(
                            consultationId: widget.consultationId,
                            delegationId: '',
                            content: _messageController.text,
                            type: 'text',
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isSentByMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isSentByMe) ...[
            _buildAvatar(
              message.senderImageUrl,
              message.senderName,
              radius: 16,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isSentByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!message.isSentByMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      message.senderName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: message.isSentByMe
                        ? const Color(0xFF4A80F0)
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(message.isSentByMe ? 16 : 4),
                      bottomRight: Radius.circular(message.isSentByMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: message.isSentByMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (message.type == 'file')
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.attach_file, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              message.text,
                              style: TextStyle(
                                color: message.isSentByMe
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          message.text,
                          style: TextStyle(
                            color: message.isSentByMe
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.formattedTime,
                            style: TextStyle(
                              fontSize: 10,
                              color: message.isSentByMe
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          if (message.isSentByMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.isRead ? Icons.done_all : Icons.done,
                              size: 14,
                              color: Colors.white70,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (message.isSentByMe) ...[
            const SizedBox(width: 8),
            _buildAvatar(
              message.senderImageUrl,
              message.senderName,
              radius: 16,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(String imageUrl, String name, {double radius = 20}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
      child: imageUrl.isEmpty
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: radius * 0.8,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // --- Call Signaling Methods ---
  // All call methods removed - now handled by GlobalCallService
  // Future<void> startCall(...) { ... }
  // Future<void> rejectCall(...) { ... }
  // Future<void> acceptCall(...) { ... }
  // Future<void> endCall(...) { ... }
  // Future<void> sendOffer(...) { ... }
  // Future<void> sendAnswer(...) { ... }
  // Future<void> sendIceCandidate(...) { ... }
  // void _onCallStarted(...) { ... }
}

class Message {
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isSentByMe;
  final String id;
  bool isRead;
  final String type;
  final String senderName;
  final String receiverName;
  final String senderImageUrl;
  final String receiverImageUrl;

  Message({
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.isSentByMe,
    required this.id,
    required this.isRead,
    required this.type,
    required this.senderName,
    required this.receiverName,
    required this.senderImageUrl,
    required this.receiverImageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isSentByMe': isSentByMe,
      'id': id,
      'isRead': isRead,
      'type': type,
      'senderName': senderName,
      'receiverName': receiverName,
      'senderImageUrl': senderImageUrl,
      'receiverImageUrl': receiverImageUrl,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isSentByMe: json['isSentByMe'] as bool,
      id: json['id'] as String,
      isRead: json['isRead'] as bool,
      type: json['type'] as String,
      senderName: json['senderName'] as String,
      receiverName: json['receiverName'] as String,
      senderImageUrl: json['senderImageUrl'] as String,
      receiverImageUrl: json['receiverImageUrl'] as String,
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  // int _selectedIndex = 2;
  List<Appointment> appointments = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchConsultations();
  }

  Future<void> _fetchConsultations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userType = prefs.getString('user_type');
      print('Retrieved token: $token');
      print('User type: $userType');

      if (token == null) {
        setState(() {
          error = 'No authentication token found';
          isLoading = false;
        });
        return;
      }

      // Create a new HTTP client with specific configuration
      final client = http.Client();
      try {
        // Use the token from login
        final authToken = 'Bearer $token';
        print('Using auth token: $authToken');

        // Determine the endpoint based on user type
        final url = userType == 'lawyer'
            ? 'http://mohamek-legel.runasp.net/api/LawyerDashBoard/lawyer-consultations?includeCompleted=false'
            : 'http://mohamek-legel.runasp.net/api/ClientDashBoard/client-consultations?includeCompleted=true';
        print('Making request to: $url');

        final request = http.Request('GET', Uri.parse(url));
        request.headers.addAll({
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': authToken,
          'Connection': 'keep-alive',
        });

        print('Request headers: ${request.headers}');

        final streamedResponse = await client.send(request);
        final response = await http.Response.fromStream(streamedResponse);

        print('Response status code: ${response.statusCode}');
        print('Response headers: ${response.headers}');
        print('Response body: ${response.body}');

        if (response.statusCode == 401) {
          final responseBody = json.decode(response.body);
          print('401 Error details: $responseBody');

          // Try to get more specific error information
          final errorMessage =
              responseBody['message']?.toString() ?? 'Unknown error';
          print('Error message: $errorMessage');

          if (errorMessage.contains('expired')) {
            setState(() {
              error = 'Your session has expired. Please login again.';
              isLoading = false;
            });
          } else if (errorMessage.contains('authorized')) {
            setState(() {
              error = 'You are not authorized to access this resource.';
              isLoading = false;
            });
          } else {
            setState(() {
              error = 'Authentication failed: $errorMessage';
              isLoading = false;
            });
          }
          return;
        }

        if (response.statusCode == 200) {
          final consultationsData = json.decode(response.body);
          print('Decoded consultations data: $consultationsData');

          if (consultationsData == null || consultationsData.isEmpty) {
            setState(() {
              error = 'No consultations found';
              isLoading = false;
            });
            return;
          }

          // Create appointments from the consultations data
          setState(() {
            appointments = consultationsData.map<Appointment>((consultation) {
              print('=== Processing consultation ===');
              print('Raw consultation data: $consultation');

              // Get IDs first
              final lawyerId = consultation['lawyerId']?.toString() ?? '';
              final clientId = consultation['clientId']?.toString() ?? '';

              print('Extracted IDs:');
              print('- LawyerId: "$lawyerId"');
              print('- ClientId: "$clientId"');

              // Determine the name and ID based on user type
              final name = userType == 'lawyer'
                  ? consultation['clientName'] ?? 'Unknown Client'
                  : consultation['lawyerName'] ?? 'Unknown Lawyer';
              final receiverId = userType == 'lawyer' ? clientId : lawyerId;

              print('User type: $userType');
              print('Selected name: "$name"');
              print('Selected receiverId: "$receiverId"');

              final specialty = userType == 'lawyer'
                  ? 'Client'
                  : consultation['specialization'] ?? 'General';

              // Get the appropriate pictures
              final lawyerPicture = consultation['pictureOfLawyer'] ?? '';
              final clientPicture = consultation['pictureOfClient'] ?? '';
              final displayPicture =
                  userType == 'lawyer' ? clientPicture : lawyerPicture;

              final appointment = Appointment(
                doctorName: name,
                specialty: specialty,
                rating: (consultation['rating'] ?? 0.0).toDouble(),
                experience: '${consultation['yearsOfExperience'] ?? 0} years',
                date: _formatDate(consultation['date']),
                time: consultation['time'] ?? 'N/A',
                avatar: displayPicture,
                consultationDate: consultation['consultationDate'] ?? '',
                pictureOfLawyer: lawyerPicture,
                pictureOfClient: clientPicture,
                consultationDateFormatted:
                    consultation['consultationDateFormatted'] ?? '',
                consultationId: consultation['id'] ?? '',
                receiverId: receiverId, // Pass the correct receiver ID
              );

              print(
                  'Created appointment with receiverId: "${appointment.receiverId}"');
              print('=== End processing consultation ===');

              return appointment;
            }).toList();

            print('=== Final appointments list ===');
            for (int i = 0; i < appointments.length; i++) {
              print('Appointment $i:');
              print('  - doctorName: "${appointments[i].doctorName}"');
              print('  - receiverId: "${appointments[i].receiverId}"');
              print('  - consultationId: "${appointments[i].consultationId}"');
              print(
                  '  - Raw receiverId length: ${appointments[i].receiverId.length}');
              print(
                  '  - Is receiverId empty: ${appointments[i].receiverId.isEmpty}');
              print(
                  '  - Is receiverId UUID format: ${RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false).hasMatch(appointments[i].receiverId)}');
            }
            print('=== End appointments list ===');

            isLoading = false;
          });
        } else {
          setState(() {
            error =
                'Failed to load consultations: ${response.statusCode} - ${response.body}';
            isLoading = false;
          });
        }
      } finally {
        client.close();
      }
    } catch (e, stackTrace) {
      print('Error fetching consultations: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${_getMonthName(date.month)}';
    } catch (e) {
      print('Error formatting date: $e');
      return 'Invalid Date';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        toolbarHeight: 116,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/23f87c5e73ae7acd01687cec25693b1766d78c51.png',
              height: 85,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.local_hospital,
                  color: Color(0xFF1F41BB),
                  size: 50,
                );
              },
            ),
            const SizedBox(height: 0),
            const Text(
              'Your Bookings',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xFFF8F9FA).withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            24,
            16,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1F41BB),
                    ),
                  ),
                )
              : error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _getFriendlyErrorMessage(error!),
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _fetchConsultations,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F41BB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : appointments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.event_busy,
                                  color: Colors.grey,
                                  size: 48,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'No appointments found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = appointments[index];
                            return AppointmentCard(
                              appointment: appointment,
                              onChatPressed: () async {
                                final profileService = ProfileService();
                                await ProfileService.initialize();
                                final currentUserId = await profileService
                                    .getCurrentUserIdFromToken();

                                print('=== Old chat navigation ===');
                                print('Appointment details:');
                                print(
                                    '- doctorName: "${appointment.doctorName}"');
                                print(
                                    '- receiverId: "${appointment.receiverId}"');
                                print(
                                    '- consultationId: "${appointment.consultationId}"');
                                print('- Current user ID: "$currentUserId"');

                                if (appointment.receiverId.isEmpty) {
                                  print('ERROR: receiverId is empty!');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('خطأ: معرف المستخدم غير متوفر'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatPage(
                                      currentUserId: currentUserId,
                                      receiverId: appointment.receiverId,
                                      receiverName: appointment.doctorName,
                                      receiverImageUrl: appointment.avatar,
                                      consultationId:
                                          appointment.consultationId,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
        ),
      ),
    );
  }

  String _getFriendlyErrorMessage(String error) {
    if (error.contains('404') && error.contains('No consultations available')) {
      return 'لا توجد حجوزات متاحة حالياً.'; // Arabic: No bookings available at the moment.
    }
    if (error.contains('No consultations found')) {
      return 'لا توجد حجوزات متاحة حالياً.';
    }
    if (error.contains('expired')) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';
    }
    if (error.contains('authorized')) {
      return 'ليس لديك صلاحية الوصول إلى هذه الصفحة.';
    }
    // Default fallback
    return 'حدث خطأ أثناء تحميل الحجوزات. حاول مرة أخرى.';
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onChatPressed;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onChatPressed,
  });

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day} ${_getMonthName(date.month)}';
    } catch (e) {
      print('Error formatting date: $e');
      return 'Invalid Date';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('user_type')),
      builder: (context, snapshot) {
        final userType = snapshot.data ?? '';
        final specialty =
            userType.toLowerCase() == 'client' ? 'Lawyer' : 'Client';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top section with lawyer info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1F41BB).withOpacity(0.06),
                      Colors.white,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lawyer Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Builder(
                          builder: (context) {
                            String imageUrl = appointment.avatar;
                            if (imageUrl.isEmpty) {
                              imageUrl = appointment.pictureOfLawyer.isNotEmpty
                                  ? appointment.pictureOfLawyer
                                  : appointment.pictureOfClient;
                            }

                            if (imageUrl.isNotEmpty) {
                              return Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Color(0xFF1F41BB),
                                        ),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 30,
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Lawyer Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.doctorName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            specialty,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom section with date and chat button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border(
                    top: BorderSide(
                        color: Colors.grey.withOpacity(0.1), width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    // Date Container
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F41BB).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F41BB).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: Color(0xFF1F41BB),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                appointment.consultationDateFormatted.isNotEmpty
                                    ? appointment.consultationDateFormatted
                                    : appointment.consultationDate.isNotEmpty
                                        ? _formatDate(
                                            appointment.consultationDate)
                                        : appointment.date,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF1F41BB),
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Chat Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1F41BB), Color(0xFF1F3BB0)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final profileService = ProfileService();
                            await ProfileService.initialize();
                            final currentUserId = await profileService
                                .getCurrentUserIdFromToken();

                            print('=== Starting chat navigation ===');
                            print('Appointment details:');
                            print('- doctorName: "${appointment.doctorName}"');
                            print('- receiverId: "${appointment.receiverId}"');
                            print(
                                '- consultationId: "${appointment.consultationId}"');
                            print('- Current user ID: "$currentUserId"');

                            if (appointment.receiverId.isEmpty) {
                              print('ERROR: receiverId is empty!');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('خطأ: معرف المستخدم غير متوفر'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            print('Creating ChatPage with:');
                            print('- currentUserId: "$currentUserId"');
                            print('- receiverId: "${appointment.receiverId}"');
                            print(
                                '- receiverName: "${appointment.doctorName}"');
                            print(
                                '- consultationId: "${appointment.consultationId}"');

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  currentUserId: currentUserId,
                                  receiverId: appointment.receiverId,
                                  receiverName: appointment.doctorName,
                                  receiverImageUrl: appointment.avatar,
                                  consultationId: appointment.consultationId,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Chat',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class Appointment {
  final String doctorName;
  final String specialty;
  final double rating;
  final String experience;
  final String date;
  final String time;
  final String avatar;
  final String consultationDate;
  final String pictureOfLawyer;
  final String pictureOfClient;
  final String consultationDateFormatted;
  final String consultationId;
  final String receiverId; // Add this field

  Appointment({
    required this.doctorName,
    required this.specialty,
    required this.rating,
    required this.experience,
    required this.date,
    required this.time,
    this.avatar = '',
    this.consultationDate = '',
    this.pictureOfLawyer = '',
    this.pictureOfClient = '',
    this.consultationDateFormatted = '',
    required this.consultationId,
    required this.receiverId, // Add this parameter
  });
}

class ProfileService {
  static const String _baseUrl = 'http://mohamek-legel.runasp.net/api';
  static const String _clientProfileUrl = '$_baseUrl/ClientDashBoard/profile';
  static const String _lawyerProfileUrl = '$_baseUrl/LawyerDashBoard/profile';
  static const String _tokenKey = 'auth_token';
  static const String _userTypeKey = 'user_type';
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<String?> _getToken() async {
    return _prefs?.getString(_tokenKey);
  }

  Future<String?> _getUserType() async {
    return _prefs?.getString(_userTypeKey);
  }

  Future<void> saveUserType(String userType) async {
    await _prefs?.setString(_userTypeKey, userType);
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final userType = await _getUserType();
      final baseUrl =
          userType == 'lawyer' ? _lawyerProfileUrl : _clientProfileUrl;
      print('Fetching profile from: $baseUrl');

      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getProfile: $e');
      throw Exception('Failed to load profile: $e');
    }
  }

  Future<String> getCurrentUserRole() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/Account/current-user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final role = data['role'] ?? '';
        await saveUserType(role.toLowerCase());
        return role.toLowerCase();
      } else {
        throw Exception('Failed to get user role: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting user role: $e');
      throw Exception('Failed to get user role');
    }
  }

  Future<String> getCurrentUserIdFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return '';
    Map<String, dynamic> decoded = JwtDecoder.decode(token);
    print('Decoded JWT: $decoded');
    return decoded[
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
        '';
  }
}
