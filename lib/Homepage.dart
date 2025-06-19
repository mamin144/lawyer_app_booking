import 'package:flutter/material.dart';
// import 'main_scaffold.dart';
import 'services/profile_service.dart';
import 'services/lawyer_service.dart';
import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'reversition.dart';
import 'dart:async';
import 'package:flutter_application_4/auth/login_as_lawyer.dart'; // Import Specialization
import 'notification.dart'; // Import the NotificationPage
import 'services/notification_service.dart'; // Import the NotificationService
import 'package:flutter_application_4/screens/chatbot_screen.dart';
import 'package:dio/dio.dart';

// Lawyer model class
class Lawyer {
  final String id;
  final String name;
  final String imageUrl;
  final String profession;
  final double rating;
  final String specialization;

  Lawyer({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.profession,
    required this.rating,
    required this.specialization,
  });
}

// Appointment model class
class Appointment {
  final String id;
  final String clientName;
  final String clientImageUrl;
  final String time;
  final String? date;
  final bool hasRating;
  final double? rating;

  Appointment({
    required this.id,
    required this.clientName,
    required this.clientImageUrl,
    required this.time,
    this.date,
    this.hasRating = false,
    this.rating,
  });
}

// Mock data service class
class MockDataService {
  // Mock data for lawyers
  // final List<Lawyer> _lawyers = [
  //   Lawyer(
  //     id: '1',
  //     name: 'أحمد محمد',
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
  //     profession: 'محامي',
  //     rating: 4.8,
  //     specialization: 'العقارات',
  //   ),
  //   Lawyer(
  //     id: '2',
  //     name: 'سارة خالد',
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
  //     profession: 'محامي',
  //     rating: 4.5,
  //     specialization: 'الجنائية',
  //   ),
  //   Lawyer(
  //     id: '3',
  //     name: 'محمد علي',
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
  //     profession: 'محامي',
  //     rating: 4.9,
  //     specialization: 'مدني',
  //   ),
  //   Lawyer(
  //     id: '4',
  //     name: 'فاطمة أحمد',
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
  //     profession: 'محامي',
  //     rating: 4.7,
  //     specialization: 'التجارية',
  //   ),
  //   Lawyer(
  //     id: '5',
  //     name: 'خالد عمر',
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
  //     profession: 'محامي',
  //     rating: 4.6,
  //     specialization: 'البنود',
  //   ),
  //   Lawyer(
  //     id: '6',
  //     name: 'نورا سليم',
  //     imageUrl:
  //         'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
  //     profession: 'محامي',
  //     rating: 4.4,
  //     specialization: 'العقارات',
  //   ),
  // ];

  // // Mock data for appointments
  // final List<Appointment> _appointments = [
  //   Appointment(
  //     id: '1',
  //     clientName: 'عمر خالد',
  //     clientImageUrl:
  //         'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
  //     time: '10:00 AM',
  //     date: '24 Mar',
  //     hasRating: false,
  //   ),
  //   Appointment(
  //     id: '2',
  //     clientName: 'سارة أحمد',
  //     clientImageUrl:
  //         'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
  //     time: '02:30 PM',
  //     date: '25 Mar',
  //     hasRating: true,
  //     rating: 4.8,
  //   ),
  //   // Appointment(
  //   //   id: '3',
  //   //   clientName: 'محمد علي',
  //   //   clientImageUrl:
  //   //       'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
  //   //   time: '11:15 AM',
  //   //   date: '26 Mar',
  //   //   hasRating: false,
  //   // ),
  // ];

  // // Getter for all lawyers
  // List<Lawyer> get lawyers => _lawyers;

  // // Getter for all appointments
  // List<Appointment> get appointments => _appointments;

  // Filter lawyers by specialization
  // List<Lawyer> getLawyersBySpecialization(String specialization) {
  //   return _lawyers
  //       .where((lawyer) => lawyer.specialization == specialization)
  //       .toList();
  // }
}

class LawyerApp extends StatelessWidget {
  const LawyerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      theme: ThemeData(
        primaryColor: const Color(0xFF1F41BB),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // final int _selectedIndex = 4;
  final ProfileService _profileService = ProfileService();
  final LawyerService _lawyerService = LawyerService();
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _profileData;
  List<dynamic> _lawyers = [];
  List<dynamic> _filteredLawyers = [];
  bool _isLoading = true;
  String? _error;
  List<int> selectedCaseIds = [];
  Timer? _debounceTimer;
  bool _showCases = false;

  // Notification service
  final NotificationService _notificationService = NotificationService();
  int _notificationCount = 0;

  // Define _caseOptions here within the state class
  final List<Map<String, dynamic>> _caseOptions = [
    {'id': 1, 'name': 'قانون الأسرة'},
    {'id': 2, 'name': 'قانون الأعمال'},
    // Add other cases as needed
  ];

  List<Specialization> _specializations = []; // Add state for specializations
  bool _isLoadingSpecializations =
      true; // Add state for loading specializations
  List<String> _selectedSpecializationIds =
      []; // Add state for selected specialization IDs

  // Initialize offset to null
  Offset? _offset;

  // Get the initial position based on screen size
  void _initializePosition(BuildContext context) {
    if (_offset == null) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      // Positioning the button 180 pixels from bottom to be above the navigation bar
      _offset = Offset(screenWidth - 80, screenHeight - 180);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadLawyers();
    _fetchSpecializations(); // Fetch specializations on init
    _searchController.addListener(_onSearchChanged);

    // Initialize notification service
    _notificationService.initialize();

    // Listen for notification count changes
    _notificationService.notificationCount.listen((count) {
      setState(() {
        _notificationCount = count;
      });
    });
  }

  Future<void> _fetchSpecializations() async {
    setState(() {
      _isLoadingSpecializations = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
          'http://mohamek-legel.runasp.net/api/Account/get-all-specializations',
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _specializations = data
              .where((e) => e != null) // Filter out null entries
              .map((e) => Specialization.fromJson(e))
              .toList();
          _isLoadingSpecializations = false;
        });
      } else {
        setState(() {
          _isLoadingSpecializations = false;
          _error = 'Failed to load specializations: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingSpecializations = false;
        _error = 'Error loading specializations: $e';
      });
    }
  }

  // Function to filter lawyers based on selected specializations
  void _filterLawyers() {
    print(
        'Filtering lawyers by specializationIds: $_selectedSpecializationIds');

    if (_selectedSpecializationIds.isEmpty) {
      setState(() {
        _filteredLawyers = _lawyers;
      });
      return;
    }

    // تحويل معرفات التخصصات المحددة إلى أسماء التخصصات
    final selectedSpecializationNames = _selectedSpecializationIds.map((id) {
      final spec = _specializations.firstWhere(
        (spec) => spec.id == id,
        orElse: () => Specialization(id: '', name: ''),
      );
      return spec.name.toLowerCase();
    }).toList();

    final filtered = _lawyers.where((lawyer) {
      // التحقق مما إذا كان المحامي لديه أي من التخصصات المحددة
      if (lawyer['specializations'] == null ||
          !(lawyer['specializations'] is List)) {
        return false;
      }

      final lawyerSpecializations = lawyer['specializations'] as List;

      // التحقق من وجود أي من التخصصات المحددة في تخصصات المحامي
      for (var lawyerSpec in lawyerSpecializations) {
        final lawyerSpecName = (lawyerSpec['name'] ?? '').toLowerCase();
        for (var selectedSpecName in selectedSpecializationNames) {
          if (lawyerSpecName == selectedSpecName) {
            return true;
          }
        }
      }

      return false;
    }).toList();

    setState(() {
      _filteredLawyers = filtered;
    });
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // استدعاء دالة البحث
      _searchLawyersList();
    });
  }

  // Function to filter lawyers based on search query
  void _searchLawyersList() {
    final query = _searchController.text.trim().toLowerCase();
    print('Filtering lawyers by search query: $query');

    if (query.isEmpty) {
      setState(() {
        _filteredLawyers = _lawyers;
      });
      return;
    }

    final filtered = _lawyers.where((lawyer) {
      // البحث في اسم المحامي (بالعربية والإنجليزية)
      final nameMatches =
          (lawyer['fullName'] ?? '').toLowerCase().contains(query);

      // البحث في التخصصات
      bool specializationMatches = false;
      if (lawyer['specializations'] != null &&
          lawyer['specializations'] is List) {
        final specializations = lawyer['specializations'] as List;
        for (var spec in specializations) {
          if (spec['name'] != null &&
              spec['name'].toString().toLowerCase().contains(query)) {
            specializationMatches = true;
            break;
          }
        }
      }

      // البحث في الوصف إذا كان متاحًا
      final descriptionMatches = lawyer['description'] != null &&
          lawyer['description'].toString().toLowerCase().contains(query);

      // البحث في رقم الهاتف
      final phoneMatches = lawyer['phoneNumber'] != null &&
          lawyer['phoneNumber'].toString().toLowerCase().contains(query);

      // البحث في أي معلومات إضافية
      final displayNameMatches = lawyer['displayName'] != null &&
          lawyer['displayName'].toString().toLowerCase().contains(query);

      // إرجاع النتيجة النهائية - يجب أن تتطابق مع أي من معايير البحث
      return nameMatches ||
          specializationMatches ||
          descriptionMatches ||
          phoneMatches ||
          displayNameMatches;
    }).toList();

    setState(() {
      _filteredLawyers = filtered;
    });
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _profileService.getProfile();
      if (mounted) {
        setState(() {
          _profileData = data;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> _loadLawyers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await LawyerService.initialize();
      final lawyers = await _lawyerService.getAllLawyers();
      print('Fetched lawyers: $lawyers');
      setState(() {
        _lawyers = lawyers;
        _filteredLawyers = lawyers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _notificationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _initializePosition(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Stack(
        children: [
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                // Refresh all data
                await _loadLawyers();
                await _fetchSpecializations();
              },
              color: const Color(0xFF1F41BB),
              child: Column(
                children: [
                  buildHeader(),
                  buildSearchBar(),
                  if (_showCases) _buildCasesList(),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF1F41BB)),
                            ),
                          )
                        : _error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Error: $_error',
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _loadLawyers,
                                      child: const Text('إعادة المحاولة'),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: Column(
                                    children: [buildTopLawyersSection()]),
                              ),
                  ),
                ],
              ),
            ),
          ),

          // Draggable chat bot button with adjusted size and shadow
          Positioned(
            left: _offset!.dx,
            top: _offset!.dy,
            child: Draggable(
              feedback: _buildChatBotButton(),
              childWhenDragging: Container(),
              onDragEnd: (details) {
                setState(() {
                  double newX = details.offset.dx;
                  double newY = details.offset.dy;

                  final screenWidth = MediaQuery.of(context).size.width;
                  final screenHeight = MediaQuery.of(context).size.height;

                  // Adjust the bottom boundary to stay above navigation bar
                  newX = newX.clamp(0, screenWidth - 60);
                  newY = newY.clamp(0, screenHeight - 180);

                  _offset = Offset(newX, newY);
                });
              },
              child: _buildChatBotButton(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F41BB),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPage(),
                ),
              );
            },
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_none_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                // Notification badge - only show when there are notifications
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.circle,
                        color: Colors.white,
                        size: 6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "🎉 مرحباً بك",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _profileData?['fullName'] ?? 'Loading...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _profileData?['pictureUrl'] != null &&
                            _profileData?['pictureUrl'] != 'Not Exist'
                        ? Image.network(
                            _profileData!['pictureUrl'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white.withOpacity(0.2),
                                child: const Icon(
                                  Icons.person,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              );
                            },
                          )
                        : Image.asset(
                            'assets/images/profile_placeholder.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white.withOpacity(0.2),
                                child: const Icon(
                                  Icons.person,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              );
                            },
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

  Widget buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.tune,
                    color:
                        _showCases ? const Color(0xFF1F41BB) : Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _showCases = !_showCases;
                    });
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextField(
                      controller: _searchController,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                        locale: Locale('ar', 'SA'),
                      ),
                      decoration: InputDecoration(
                        hintText: "بحث عن محامي أو تخصص...",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          locale: const Locale('ar', 'SA'),
                        ),
                        border: InputBorder.none,
                        suffixIcon: _searchController.text.isNotEmpty
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchLawyersList();
                                      });
                                    },
                                    child: Icon(
                                      Icons.clear,
                                      color: Colors.grey[400],
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.search,
                                    color: Color(0xFF1F41BB),
                                    size: 20,
                                  ),
                                ],
                              )
                            : const Icon(
                                Icons.search,
                                color: Color(0xFF1F41BB),
                                size: 20,
                              ),
                      ),
                      onChanged: (value) {
                        _onSearchChanged();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_searchController.text.isNotEmpty ||
              _selectedSpecializationIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_selectedSpecializationIds.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _selectedSpecializationIds.map((id) {
                            final spec = _specializations.firstWhere(
                              (spec) => spec.id == id,
                              orElse: () => Specialization(id: '', name: ''),
                            );
                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Chip(
                                label: Text(
                                  spec.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                                deleteIcon: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                onDeleted: () {
                                  setState(() {
                                    _selectedSpecializationIds.remove(id);
                                    _filterLawyers();
                                  });
                                },
                                backgroundColor: const Color(0xFF1F41BB),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 0),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  if (_searchController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        "نتائج البحث عن: ${_searchController.text}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
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

  Widget buildTopLawyersSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "ابرز المحامين",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F41BB),
                  ),
                ),
              ],
            ),
          ),
          _filteredLawyers.isEmpty &&
                  (_searchController.text.isNotEmpty ||
                      _selectedSpecializationIds.isNotEmpty)
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'لا يوجد نتائج للبحث',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                )
              : _lawyers.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'لا يوجد محامين',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    )
                  : buildLawyersGrid(
                      // استخدام القائمة المفلترة إذا كان هناك بحث أو تخصص محدد
                      _searchController.text.isNotEmpty ||
                              _selectedSpecializationIds.isNotEmpty
                          ? _filteredLawyers
                          : _lawyers,
                    ),
        ],
      ),
    );
  }

  Widget buildLawyersGrid(List<dynamic> lawyers) {
    return ListView.builder(
      itemCount: lawyers.length,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      cacheExtent: 1000.0,
      addAutomaticKeepAlives: true,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) {
        final lawyer = lawyers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: buildLawyerCard(
            lawyer: lawyer, // Pass the entire lawyer map
          ),
        );
      },
    );
  }

  Widget buildLawyerCard({
    required Map<String, dynamic>
        lawyer, // Changed to directly accept lawyer map
  }) {
    // Calculate average rating from 'averageRating' field if present
    double avgRating = 3.0;
    if (lawyer['averageRating'] != null) {
      final ratingStr = lawyer['averageRating'].toString();
      switch (ratingStr) {
        case 'FiveStars':
          avgRating = 5.0;
          break;
        case 'FourStars':
          avgRating = 4.0;
          break;
        case 'ThreeStars':
          avgRating = 3.0;
          break;
        case 'TwoStars':
          avgRating = 2.0;
          break;
        case 'OneStar':
          avgRating = 1.0;
          break;
        default:
          avgRating = 3.0;
      }
    } else {
      // Fallback to previous logic if averageRating is not present
      final reviews = lawyer['reviews'] as List?;
      if (reviews != null && reviews.isNotEmpty) {
        double sum = 0;
        int count = 0;
        for (var review in reviews) {
          var r = review['rating'];
          if (r is int || r is double) {
            sum += r.toDouble();
            count++;
          } else if (r is String) {
            final parsed = double.tryParse(r);
            if (parsed != null) {
              sum += parsed;
              count++;
            }
          }
        }
        if (count > 0) avgRating = sum / count;
      } else if (lawyer['rating'] != null && lawyer['rating'] != 0) {
        avgRating = lawyer['rating'] is num
            ? lawyer['rating'].toDouble()
            : double.tryParse(lawyer['rating'].toString()) ?? 3.0;
      }
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LawyerProfilePage(
              lawyerId: lawyer['id'], // Use the passed lawyer data
              lawyerData: lawyer, // Use the passed lawyer data
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFF1F41BB).withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            SizedBox(
              width: 100,
              height: 140,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF1F41BB).withOpacity(0.1),
                          const Color(0xFF1F41BB).withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                    child: (lawyer['pictureUrl'] ?? '')
                            .isNotEmpty // Use lawyer['pictureUrl']
                        ? Image.network(
                            lawyer['pictureUrl'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.person,
                                  size: 32,
                                  color: Color(0xFF1F41BB),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.person,
                              size: 32,
                              color: Color(0xFF1F41BB),
                            ),
                          ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 60,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 25,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info Section
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lawyer['fullName'] ??
                                'Unknown', // Use lawyer['fullName']
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1F41BB),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F41BB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            "محامي",
                            style: TextStyle(
                              color: Color(0xFF1F41BB),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (lawyer['specializations'] != null &&
                        (lawyer['specializations'] as List).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: SizedBox(
                          height: 26, // Fixed height for specializations row
                          child: Row(
                            children: [
                              Expanded(
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: (lawyer['specializations'] as List)
                                              .length >
                                          2
                                      ? 2 // Show only 2 specializations
                                      : (lawyer['specializations'] as List)
                                          .length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(width: 4),
                                  itemBuilder: (context, index) {
                                    final spec = (lawyer['specializations']
                                        as List)[index];
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1F41BB)
                                            .withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: const Color(0xFF1F41BB)
                                              .withOpacity(0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.work_outline,
                                            size: 10,
                                            color: Color(0xFF1F41BB),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            spec['name'] ?? '',
                                            style: const TextStyle(
                                              color: Color(0xFF1F41BB),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Show +X more if there are more than 2 specializations
                              if ((lawyer['specializations'] as List).length >
                                  2)
                                Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1F41BB)
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: const Color(0xFF1F41BB)
                                          .withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    "+${(lawyer['specializations'] as List).length - 2}",
                                    style: const TextStyle(
                                      color: Color(0xFF1F41BB),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (lawyer['displayName'] != null &&
                        (lawyer['displayName'] as String).isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 12,
                            color: Color(0xFF1F41BB),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lawyer[
                                  'displayName'], // Use lawyer['displayName']
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    if (lawyer['priceOfAppointment'] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.attach_money,
                              size: 12,
                              color: Color(0xFF1F41BB),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${lawyer['priceOfAppointment']} جنيه', // Use lawyer['priceOfAppointment']
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCasesList() {
    // Show loading indicator if specializations are being fetched
    if (_isLoadingSpecializations) {
      return const Center(child: CircularProgressIndicator());
    }
    // Show error message if fetching failed
    if (_error != null && _specializations.isEmpty) {
      return Center(
        child: Text(
          'Error loading cases: $_error',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    // Show message if no specializations are available
    if (_specializations.isEmpty) {
      return const Center(
        child: Text(
          'No cases available.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // إضافة زر لمسح جميع التخصصات المحددة
    return Column(
      children: [
        if (_selectedSpecializationIds.isNotEmpty)
          Padding(
            padding:
                const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التخصصات المحددة: ${_selectedSpecializationIds.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F41BB),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedSpecializationIds.clear();
                      _filterLawyers();
                    });
                  },
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('مسح الكل'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        Container(
          height: 50, // Give the container a fixed height for horizontal list
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ), // Adjust padding
          child: ListView.separated(
            scrollDirection:
                Axis.horizontal, // Set scroll direction to horizontal
            itemCount: _specializations.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: 8), // Add spacing between chips
            itemBuilder: (context, index) {
              final caseOption = _specializations[index];
              return ChoiceChip(
                label: Text(
                  caseOption.name ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: _selectedSpecializationIds.contains(caseOption.id)
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                selected: _selectedSpecializationIds.contains(caseOption.id),
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFF1F41BB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: _selectedSpecializationIds.contains(caseOption.id)
                        ? const Color(0xFF1F41BB)
                        : Colors.grey.shade400,
                    width: 1,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedSpecializationIds.add(caseOption.id);
                    } else {
                      _selectedSpecializationIds.remove(caseOption.id);
                    }
                    _filterLawyers(); // Call filter function
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatBotButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1F41BB),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatbotScreen()),
            );
          },
          customBorder: const CircleBorder(),
          child: const Icon(
            Icons.smart_toy,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class LawyerSignupData {
  String fullName = '';
  String email = '';
  String phoneNumber = '';
  String ssn = '';
  String priceOfAppointment = '';
  File? barAssociationImage;
  File? picture;
  List<String> selectedCases = [];
  String password = '';
  String gender = '';
  String dateOfBirth = '';
  String recaptchaToken = '';
}

class LawyerSignupScreen extends StatefulWidget {
  const LawyerSignupScreen({super.key});

  @override
  State<LawyerSignupScreen> createState() => _LawyerSignupScreenState();
}

class _LawyerSignupScreenState extends State<LawyerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final LawyerSignupData _data = LawyerSignupData();
  bool _isLoading = false;
  List<int> selectedCaseIds = [];

  final List<Map<String, dynamic>> _caseOptions = [
    {'id': 1, 'name': 'Family Law'},
    {'id': 2, 'name': 'Business Law'},
    // ...etc, use real IDs from backend
  ];

  Future<void> _pickImage(bool isProfile) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isProfile) {
          _data.picture = File(picked.path);
        } else {
          _data.barAssociationImage = File(picked.path);
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_data.picture == null || _data.barAssociationImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Both images are required!')),
      );
      return;
    }
    if (selectedCaseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one case!')),
      );
      return;
    }
    setState(() => _isLoading = true);

    var uri = Uri.parse(
      'http://mohamek-legel.runasp.net/api/Account/register-as-lawyer',
    );
    var request = http.MultipartRequest('POST', uri);

    request.fields['FullName'] = _data.fullName;
    request.fields['Email'] = _data.email.trim().toLowerCase();
    request.fields['PhoneNumber'] = _data.phoneNumber;
    request.fields['SSN'] = _data.ssn;
    request.fields['PriceOfAppointment'] = _data.priceOfAppointment;
    request.fields['Password'] = _data.password;
    request.fields['Gender'] = _data.gender;
    request.fields['DateOfBirth'] = _data.dateOfBirth;
    request.fields['RecaptchaToken'] = _data.recaptchaToken;
    request.fields['SelectedCases'] = jsonEncode(selectedCaseIds);

    request.files.add(
      await http.MultipartFile.fromPath('Picture', _data.picture!.path),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'BarAssociationImage',
        _data.barAssociationImage!.path,
      ),
    );

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        // await ProfileService().saveUserType('lawyer');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lawyer Registration')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Full Name
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'FullName'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                    onSaved: (v) => _data.fullName = v ?? '',
                  ),
                  // Email
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email *'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
                      return null;
                    },
                    onSaved: (v) => _data.email = v ?? '',
                  ),
                  // Phone Number
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                    keyboardType: TextInputType.phone,
                    onSaved: (v) => _data.phoneNumber = v ?? '',
                  ),
                  // SSN
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'SSN *'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                    onSaved: (v) => _data.ssn = v ?? '',
                  ),
                  // Price Of Appointment
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Price Of Appointment *',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (int.tryParse(v) == null) {
                        return 'Enter a valid integer';
                      }
                      return null;
                    },
                    onSaved: (v) => _data.priceOfAppointment = v ?? '',
                  ),
                  // Password
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password *'),
                    obscureText: true,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                    onSaved: (v) => _data.password = v ?? '',
                  ),
                  // Gender
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female', 'Other']
                        .map(
                          (g) => DropdownMenuItem(value: g, child: Text(g)),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _data.gender = v ?? ''),
                    onSaved: (v) => _data.gender = v ?? '',
                  ),
                  // Date of Birth
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth (YYYY-MM-DD)',
                    ),
                    keyboardType: TextInputType.datetime,
                    onSaved: (v) => _data.dateOfBirth = v ?? '',
                  ),
                  // Recaptcha Token
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Recaptcha Token',
                    ),
                    onSaved: (v) => _data.recaptchaToken = v ?? '',
                  ),
                  // Selected Cases
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Wrap(
                      spacing: 8,
                      children: _caseOptions.map((c) {
                        final selected = selectedCaseIds.contains(c['id']);
                        return FilterChip(
                          label: Text(c['name']),
                          selected: selected,
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                selectedCaseIds.add(c['id']);
                              } else {
                                selectedCaseIds.remove(c['id']);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  if (selectedCaseIds.isEmpty)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select at least one case *',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  // Picture
                  ListTile(
                    title: Text(
                      _data.picture == null
                          ? 'Pick Profile Picture *'
                          : 'Profile Picture Selected',
                    ),
                    trailing: const Icon(Icons.image),
                    onTap: () => _pickImage(true),
                  ),
                  // Bar Association Image
                  ListTile(
                    title: Text(
                      _data.barAssociationImage == null
                          ? 'Pick Bar Association Image *'
                          : 'Bar Association Image Selected',
                    ),
                    trailing: const Icon(Icons.image),
                    onTap: () => _pickImage(false),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
