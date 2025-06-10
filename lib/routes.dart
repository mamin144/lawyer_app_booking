import 'package:flutter/material.dart';
import 'Homepage.dart';
import 'edit_profile.dart';
// import 'services/profile_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'auth/confirem_email.dart';
import 'services/chat_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'screens/available.dart';
// import 'package:flutter_application_4/routes.dart'; // Adjust the path if necessary
import 'package:signalr_netcore/signalr_client.dart';
import 'screens/chat_screen.dart'; // Import HubConnectionState
import 'package:logging/logging.dart';
import 'auth/signup.dart';

class Routes {
  static const String home = '/';
  static const String profile = '/profile';
  static const String chat = '/chat';
  static const String appointment = '/appointment';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case chat:
        return MaterialPageRoute(
          builder: (_) => const ChatScreen(receiverId: '', receiverName: ''),
        );
      case appointment:
        return MaterialPageRoute(builder: (_) => const AppointmentPage());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
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
      body:
          _isLoading
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
    this.primaryColor = const Color(0xFF4A80F0),
    this.secondaryColor = const Color(0xFFEDF1FA),
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'الملف الشخصي',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              onPressed: () {},
            ),
          ],
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
                    colors: [primaryColor.withOpacity(0.8), primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
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
                      child:
                          userImageUrl != 'Not Exist'
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
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const ProfileEditePage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'تعديل الملف',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
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
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'الإعدادات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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
                onTap: onNotificationsTap,
                color: Colors.orange,
              ),
              _buildModernMenuItem(
                title: 'تاريخ المدفوعات',
                subtitle: 'عرض جميع معاملاتك المالية',
                icon: Icons.payment_outlined,
                onTap: onPaymentHistoryTap,
                color: Colors.purple,
              ),
              _buildModernMenuItem(
                title: 'الإعدادات العامة',
                subtitle: 'تخصيص إعدادات التطبيق',
                icon: Icons.settings_outlined,
                onTap: onGeneralSettingsTap,
                color: Colors.blue,
              ),
              _buildModernMenuItem(
                title: 'العنوان',
                subtitle: 'إدارة عناوين التوصيل الخاصة بك',
                icon: Icons.location_on_outlined,
                onTap: onAddressTap,
                color: Colors.red,
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
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'الحساب',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: const ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
        ),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
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

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String receiverId;
  final String receiverName;
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

  @override
  void initState() {
    super.initState();
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });
    _initSignalR();
  }

  @override
  void dispose() {
    hubConnection.stop();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initSignalR() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print('Authentication token not found');
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

    // Configure logging
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });

    hubConnection =
        HubConnectionBuilder()
            .withUrl(
              hubUrl,
              options: HttpConnectionOptions(
                logger: _logger,
                transport: HttpTransportType.WebSockets,
                logMessageContent: true,
                skipNegotiation: true,
              ),
            )
            .withAutomaticReconnect()
            .build();

    // Set up message handlers
    hubConnection.on("ReceiveMessage", _onReceiveMessage);
    hubConnection.on("MessageRead", _onMessageRead);
    hubConnection.on("IncomingCall", _onIncomingCall);
    hubConnection.on("CallAccepted", _onCallAccepted);
    hubConnection.on("CallRejected", _onCallRejected);
    hubConnection.on("CallEnded", _onCallEnded);

    try {
      print('Starting SignalR connection...');

      // Start the connection
      await hubConnection.start();

      // Wait for connection to be fully established
      int retryCount = 0;
      while (hubConnection.connectionId == null && retryCount < 5) {
        await Future.delayed(const Duration(milliseconds: 500));
        retryCount++;
        print('Waiting for connection ID... Attempt $retryCount');
      }

      print('Connection state: ${hubConnection.state}');
      print('Connection ID: ${hubConnection.connectionId}');

      if (hubConnection.state == HubConnectionState.Connected) {
        print('✅ Connected to SignalR successfully!');

        // Try to get connection ID from server
        try {
          final result = await hubConnection.invoke('GetConnectionId');
          final connectionId = result?.toString();
          print('Received connection ID from server: $connectionId');

          if (connectionId != null && connectionId.isNotEmpty) {
            await prefs.setString('signalr_connection_id', connectionId);
            print('Stored connection ID: $connectionId');
          } else {
            print('⚠️ Server returned empty connection ID');
          }
        } catch (e) {
          print('Error getting connection ID from server: $e');
          // Fallback to client-side connection ID if available
          if (hubConnection.connectionId != null) {
            await prefs.setString(
              'signalr_connection_id',
              hubConnection.connectionId!,
            );
            print(
              'Using client-side connection ID: ${hubConnection.connectionId}',
            );
          }
        }
      } else {
        throw Exception(
          'Connection not in Connected state. Current state: ${hubConnection.state}',
        );
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
      print('📩 New message received: $arguments');
      final messageData = arguments[0] as Map<String, dynamic>;
      final message = Message(
        senderId: messageData['senderId'] ?? 'unknown',
        text: messageData['content'] ?? '',
        timestamp: DateTime.parse(messageData['createAt']),
        isSentByMe: messageData['senderId'] == widget.currentUserId,
        id: messageData['id'] ?? '',
      );
      setState(() {
        _messages.insert(0, message);
      });
    }
  }

  void _onMessageRead(List<Object?>? arguments) {
    if (arguments != null && arguments.isNotEmpty) {
      final messageId = arguments[0] as String;
      print('Message Read: $messageId');
    }
  }

  void _onIncomingCall(List<Object?>? arguments) {
    print('📞 Incoming call: $arguments');
    // Handle incoming call
  }

  void _onCallAccepted(List<Object?>? arguments) {
    print('✅ Call accepted: $arguments');
    // Handle call accepted
  }

  void _onCallRejected(List<Object?>? arguments) {
    print('❌ Call rejected: $arguments');
    // Handle call rejected
  }

  void _onCallEnded(List<Object?>? arguments) {
    print('🔚 Call ended: $arguments');
    // Handle call ended
  }

  Future<void> sendMessage({
    required String consultationId,
    required String? delegationId,
    required String content,
    required String type,
  }) async {
    try {
      // Verify connection state
      if (hubConnection.state != HubConnectionState.Connected) {
        print('Connection state: ${hubConnection.state}');
        throw Exception('SignalR connection is not active');
      }

      // Get stored connection ID
      final prefs = await SharedPreferences.getInstance();
      final storedConnectionId = prefs.getString('signalr_connection_id');
      print('Using stored connection ID: $storedConnectionId');

      // Ensure all parameters are properly formatted
      final formattedArgs = [
        consultationId.trim(),
        delegationId?.trim() ?? '',
        content.trim(),
        type.trim(),
      ];

      print('Sending message with formatted args: $formattedArgs');
      print('Connection state: ${hubConnection.state}');
      print('Current connection ID: ${hubConnection.connectionId}');

      await hubConnection.invoke('SendMessage', args: formattedArgs);
      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        String errorMessage = 'Failed to send message';
        if (e.toString().contains('server')) {
          errorMessage = 'Server error: Please try again later';
        } else if (e.toString().contains('connection')) {
          errorMessage =
              'Connection error: Please check your internet connection';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      if (widget.currentUserId.isEmpty) {
        print('Error: currentUserId is empty. Cannot send message.');
        return;
      }
      final messageText = _messageController.text;

      // Add message to UI first
      setState(() {
        _messages.add(
          Message(
            senderId: widget.currentUserId,
            text: messageText,
            timestamp: DateTime.now(),
            isSentByMe: true,
            id: DateTime.now().millisecondsSinceEpoch.toString(),
          ),
        );
      });
      _messageController.clear();

      try {
        const type = 'text';
        await sendMessage(
          consultationId: widget.consultationId,
          delegationId: null,
          content: messageText,
          type: type,
        );
      } catch (e) {
        print('Error sending message via SignalR: $e');
        // Remove the message from UI if sending failed
        setState(() {
          _messages.removeLast();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.isOnline ? 'Active Now' : 'Offline',
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
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.videocam, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[_messages.length - 1 - index];
                  return MessageBubble(
                    message: message,
                    profileImageUrl:
                        message.isSentByMe ? '' : widget.receiverImageUrl,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.blue),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Send Message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.mic, color: Colors.white),
                      onPressed: () {
                        // Handle voice message recording
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
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
}

enum MessageType { text, audio }

class Message {
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isSentByMe;
  final MessageType messageType;
  final String id;

  Message({
    required this.senderId,
    this.text = '',
    required this.timestamp,
    required this.isSentByMe,
    this.messageType = MessageType.text,
    required this.id,
  });
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final String profileImageUrl;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final align =
        message.isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color =
        message.isSentByMe ? const Color(0xFFDCF8C6) : const Color(0xFFE0E0E0);
    final borderRadius = BorderRadius.circular(15);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisAlignment:
                message.isSentByMe
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isSentByMe)
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, size: 15, color: Colors.grey),
                ),
              if (!message.isSentByMe) const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: borderRadius,
                  ),
                  child:
                      message.messageType == MessageType.text
                          ? Text(
                            message.text,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.right,
                          )
                          : const AudioMessageBubble(),
                ),
              ),
              if (message.isSentByMe) const SizedBox(width: 8),
              if (message.isSentByMe)
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, size: 15, color: Colors.grey),
                ),
            ],
          ),
          Padding(
            padding:
                message.isSentByMe
                    ? const EdgeInsets.only(right: 50, top: 2)
                    : const EdgeInsets.only(left: 50, top: 2),
            child: Text(
              '${message.timestamp.hour}:${message.timestamp.minute}',
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class AudioMessageBubble extends StatelessWidget {
  const AudioMessageBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.play_arrow, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Container(width: 100, height: 20, color: Colors.grey.shade400),
      ],
    );
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
        final url =
            userType == 'lawyer'
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
            appointments =
                consultationsData.map<Appointment>((consultation) {
                  print('Consultation data: $consultation'); // Debug log

                  // Determine the name and specialty based on user type
                  final name =
                      userType == 'lawyer'
                          ? consultation['clientName'] ?? 'Unknown Client'
                          : consultation['lawyerName'] ?? 'Unknown Lawyer';
                  final specialty =
                      userType == 'lawyer'
                          ? 'Client'
                          : consultation['specialization'] ?? 'General';

                  // Get the appropriate picture based on user type
                  final lawyerPicture = consultation['pictureOfLawyer'] ?? '';
                  final clientPicture = consultation['pictureOfClient'] ?? '';

                  // Set the display picture based on user type
                  final displayPicture =
                      userType == 'lawyer' ? clientPicture : lawyerPicture;

                  print('User type: $userType');
                  print('Lawyer picture: $lawyerPicture');
                  print('Client picture: $clientPicture');
                  print('Display picture: $displayPicture');

                  return Appointment(
                    doctorName: name,
                    specialty: specialty,
                    rating: (consultation['rating'] ?? 0.0).toDouble(),
                    experience:
                        '${consultation['yearsOfExperience'] ?? 0} years',
                    date: _formatDate(consultation['date']),
                    time: consultation['time'] ?? 'N/A',
                    avatar: displayPicture, // Use the display picture as avatar
                    consultationDate: consultation['consultationDate'] ?? '',
                    pictureOfLawyer: lawyerPicture,
                    pictureOfClient: clientPicture,
                    consultationDateFormatted:
                        consultation['consultationDateFormatted'] ?? '',
                    consultationId: consultation['id'] ?? '',
                  );
                }).toList();
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
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4A80F0).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'lib/assets/23f87c5e73ae7acd01687cec25693b1766d78c51.png',
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.local_hospital,
                    color: Color(0xFF4A80F0),
                    size: 40,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Bookings',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
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
            colors: [Colors.white, const Color(0xFFF8F9FA)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              isLoading
                  ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4A80F0),
                      ),
                    ),
                  )
                  : error != null
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
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
                        const SizedBox(height: 16),
                        Text(
                          error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchConsultations,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A80F0),
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
                          padding: const EdgeInsets.all(16),
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
                        const SizedBox(height: 16),
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
                          final currentUserId =
                              await profileService.getCurrentUserIdFromToken();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatPage(
                                    currentUserId: currentUserId,
                                    receiverId:
                                        appointment
                                            .doctorName, // Using doctor name as ID temporarily
                                    receiverName: appointment.doctorName,
                                    receiverImageUrl: appointment.avatar,
                                    consultationId: appointment.consultationId,
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
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onChatPressed;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.onChatPressed,
  }) : super(key: key);

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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top section with lawyer info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF4A80F0).withOpacity(0.1),
                  Colors.white,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lawyer Avatar
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Builder(
                      builder: (context) {
                        // Debug print to check the image URL
                        print(
                          'Displaying image for ${appointment.doctorName}:',
                        );
                        print('Avatar URL: ${appointment.avatar}');
                        print(
                          'Lawyer Picture URL: ${appointment.pictureOfLawyer}',
                        );
                        print(
                          'Client Picture URL: ${appointment.pictureOfClient}',
                        );

                        // Try to get the best available image URL
                        String imageUrl = appointment.avatar;
                        if (imageUrl.isEmpty) {
                          imageUrl =
                              appointment.pictureOfLawyer.isNotEmpty
                                  ? appointment.pictureOfLawyer
                                  : appointment.pictureOfClient;
                        }

                        if (imageUrl.isNotEmpty) {
                          return Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF4A80F0),
                                    ),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $error');
                              print('Failed URL: $imageUrl');
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 35,
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
                              size: 35,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Lawyer Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        appointment.specialty,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Rating Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  appointment.rating.toString(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.amber,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Experience Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4A80F0).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.work_rounded,
                                  size: 16,
                                  color: Color(0xFF4A80F0),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  appointment.experience,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4A80F0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom section with date and chat button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Date Container
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A80F0).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A80F0).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: Color(0xFF4A80F0),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            appointment.consultationDateFormatted.isNotEmpty
                                ? appointment.consultationDateFormatted
                                : appointment.consultationDate.isNotEmpty
                                ? _formatDate(appointment.consultationDate)
                                : appointment.date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4A80F0),
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Chat Button
                Container(
                  constraints: const BoxConstraints(minWidth: 100),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4A80F0), Color(0xFF3A70E0)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A80F0).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final profileService = ProfileService();
                        await ProfileService.initialize();
                        final currentUserId =
                            await profileService.getCurrentUserIdFromToken();

                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatPage(
                                    currentUserId: currentUserId,
                                    receiverId: appointment.doctorName,
                                    receiverName: appointment.doctorName,
                                    receiverImageUrl: appointment.avatar,
                                    consultationId: appointment.consultationId,
                                  ),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              'Chat',
                              style: TextStyle(
                                fontSize: 12,
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
    return decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
        '';
  }
}
