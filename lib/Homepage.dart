import 'package:flutter/material.dart';
import 'dart:ui';
// import 'main_scaffold.dart';
import 'services/profile_service.dart';
import 'services/lawyer_service.dart';
import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'reversition.dart';

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

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadLawyers();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLawyers = List.from(_lawyers);
      } else {
        _filteredLawyers =
            _lawyers.where((lawyer) {
              final name = lawyer['fullName']?.toString().toLowerCase() ?? '';
              return name.contains(query);
            }).toList();
      }
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(),
            buildSearchBar(),
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                      ? Center(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                      : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(children: [buildTopLawyersSection()]),
                      ),
            ),
          ],
        ),
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
                    child:
                        _profileData?['pictureUrl'] != null &&
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
      child: Container(
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF1F41BB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tune, color: Color(0xFF1F41BB), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: "بحث عن ...",
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                    border: InputBorder.none,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        _onSearchChanged();
                      },
                      child: const Icon(
                        Icons.search,
                        color: Color(0xFF1F41BB),
                        size: 20,
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87, fontSize: 14),
                  onChanged: (value) {
                    _onSearchChanged();
                  },
                ),
              ),
            ),
          ],
        ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "عرض المزيد",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F41BB),
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
          _filteredLawyers.isEmpty && _searchController.text.isNotEmpty
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
                _searchController.text.isNotEmpty ? _filteredLawyers : _lawyers,
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
        final reviews = lawyer['reviews'] as List?;
        final reviewComment =
            (reviews != null && reviews.isNotEmpty)
                ? reviews[0]['comment'] as String?
                : null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: buildLawyerCard(
            name: lawyer['fullName'] ?? 'Unknown',
            imageUrl: lawyer['pictureUrl'] ?? '',
            rating: 5.0,
            index: index,
            displayName: lawyer['displayName'],
            phoneNumber: lawyer['phoneNumber'],
            priceOfAppointment: lawyer['priceOfAppointment'],
            // reviewComment: reviewComment,
            specializations: lawyer['specializations'],
          ),
        );
      },
    );
  }

  Widget buildLawyerCard({
    required String name,
    required String imageUrl,
    required double rating,
    required int index,
    String? displayName,
    String? phoneNumber,
    dynamic priceOfAppointment,
    // String? reviewComment,
    List<dynamic>? specializations,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => LawyerProfilePage(lawyerId: _lawyers[index]['id']),
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
                    child:
                        imageUrl.isNotEmpty
                            ? Image.network(
                              imageUrl,
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
                            rating.toString(),
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
                            name,
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
                    if (specializations != null && specializations.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children:
                              specializations.map((spec) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF1F41BB,
                                    ).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF1F41BB,
                                      ).withOpacity(0.1),
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
                              }).toList(),
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (displayName != null && displayName.isNotEmpty)
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
                              displayName,
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
                    if (phoneNumber != null && phoneNumber.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              size: 12,
                              color: Color(0xFF1F41BB),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                phoneNumber,
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
                    if (priceOfAppointment != null)
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
                                '$priceOfAppointment جنيه',
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
                    validator:
                        (v) => v == null || v.isEmpty ? 'Required' : null,
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
                    validator:
                        (v) => v == null || v.isEmpty ? 'Required' : null,
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
                    validator:
                        (v) => v == null || v.isEmpty ? 'Required' : null,
                    onSaved: (v) => _data.password = v ?? '',
                  ),
                  // Gender
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items:
                        ['Male', 'Female', 'Other']
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
                      children:
                          _caseOptions.map((c) {
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
