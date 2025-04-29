import 'package:flutter/material.dart';
import 'Homepage.dart';
import 'edit_profile.dart';
import 'services/profile_service.dart';
import 'package:http/http.dart' as http;

class Routes {
  static const String home = '/';
  static const String profile = '/profile';
  static const String chat = '/chat';
  static const String appointment = '/appointment';
  static const String search = '/search';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case chat:
        return MaterialPageRoute(builder: (_) => const ChatPage());
      case appointment:
        return MaterialPageRoute(builder: (_) => const AppointmentPage());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchPage());
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

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _profileService.getProfile();
      print('Profile data loaded: $data');
      if (!mounted) return;

      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildErrorWidget() {
    if (_error?.contains('Authentication required') ?? false) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'Authentication Required',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please sign in to access your profile',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement sign in functionality
                print('Sign in button pressed');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $_error',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadProfile, child: const Text('Retry')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? imagePath = _profileData?['pictureUrl'];
    String imageUrl = 'Not Exist';
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http')) {
        imageUrl = imagePath;
      } else {
        imageUrl = 'http://mohamek-legel.runasp.net/$imagePath';
      }
    }
    print('Profile image URL: $imageUrl');

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
              ? _buildErrorWidget()
              : ModernArabicProfileWidget(
                userName: _profileData?['fullName'] ?? 'User',
                userEmail: _profileData?['email'] ?? 'No email',
                userImageUrl: imageUrl,

                phoneNumber: _profileData?['phoneNumber'] ?? '',
                dateOfBirth: _profileData?['dateOfBirth'] ?? '',
                isConfirmed: _profileData?['isConfirmedEmail'] ?? false,
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
  });

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
                      decoration: BoxDecoration(
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                onTap: onVerificationTap,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                  onTap: onLogoutTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
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
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
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

// Example usage
class ExampleModernUsage extends StatelessWidget {
  const ExampleModernUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo', // Arabic font
      ),
      home: const ModernArabicProfileWidget(
        userName: 'Guy Hawkins',
        userEmail: 'hawkins@gmail.com',
        userImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
        phoneNumber: '+1234567890',
        dateOfBirth: '2000-05-15',
        isConfirmed: true,
      ),
    );
  }
}

class ExampleUsage extends StatelessWidget {
  const ExampleUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ModernArabicProfileWidget(
        userName: 'Guy Hawkins',
        userEmail: 'hawkins@gmail.com',
        userImageUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
        phoneNumber: '+1234567890',
        dateOfBirth: '2000-05-15',
        isConfirmed: true,
      ),
    );
  }
}

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Chat Page')));
  }
}

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Appointment Page')));
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Search Page')));
  }
}
