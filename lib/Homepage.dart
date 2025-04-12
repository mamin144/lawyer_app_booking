import 'package:flutter/material.dart';
import 'dart:ui';

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
  final List<Lawyer> _lawyers = [
    Lawyer(
      id: '1',
      name: 'أحمد محمد',
      imageUrl:
          'https://images.unsplash.com/photo-1560250097-0b93528c311a?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
      profession: 'محامي',
      rating: 4.8,
      specialization: 'العقارات',
    ),
    Lawyer(
      id: '2',
      name: 'سارة خالد',
      imageUrl:
          'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
      profession: 'محامي',
      rating: 4.5,
      specialization: 'الجنائية',
    ),
    Lawyer(
      id: '3',
      name: 'محمد علي',
      imageUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
      profession: 'محامي',
      rating: 4.9,
      specialization: 'مدني',
    ),
    Lawyer(
      id: '4',
      name: 'فاطمة أحمد',
      imageUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
      profession: 'محامي',
      rating: 4.7,
      specialization: 'التجارية',
    ),
    Lawyer(
      id: '5',
      name: 'خالد عمر',
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
      profession: 'محامي',
      rating: 4.6,
      specialization: 'البنود',
    ),
    Lawyer(
      id: '6',
      name: 'نورا سليم',
      imageUrl:
          'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
      profession: 'محامي',
      rating: 4.4,
      specialization: 'العقارات',
    ),
  ];

  // Mock data for appointments
  final List<Appointment> _appointments = [
    Appointment(
      id: '1',
      clientName: 'عمر خالد',
      clientImageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
      time: '10:00 AM',
      date: '24 Mar',
      hasRating: false,
    ),
    Appointment(
      id: '2',
      clientName: 'سارة أحمد',
      clientImageUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
      time: '02:30 PM',
      date: '25 Mar',
      hasRating: true,
      rating: 4.8,
    ),
    // Appointment(
    //   id: '3',
    //   clientName: 'محمد علي',
    //   clientImageUrl:
    //       'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
    //   time: '11:15 AM',
    //   date: '26 Mar',
    //   hasRating: false,
    // ),
  ];

  // Getter for all lawyers
  List<Lawyer> get lawyers => _lawyers;

  // Getter for all appointments
  List<Appointment> get appointments => _appointments;

  // Filter lawyers by specialization
  List<Lawyer> getLawyersBySpecialization(String specialization) {
    return _lawyers
        .where((lawyer) => lawyer.specialization == specialization)
        .toList();
  }
}

class LawyerApp extends StatelessWidget {
  const LawyerApp({Key? key}) : super(key: key);

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
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 4; // Home tab selected by default
  late TabController _categoryTabController;
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    "العقارات",
    "الجنائية",
    "مدني",
    "التجارية",
    "البنود",
  ];

  // Create an instance of MockDataService
  final MockDataService _dataService = MockDataService();

  // State variables to hold filtered data
  late List<Lawyer> _displayedLawyers;
  late List<Appointment> _displayedAppointments;

  @override
  void initState() {
    super.initState();
    _categoryTabController = TabController(
      length: _categories.length,
      vsync: this,
      initialIndex: _selectedCategoryIndex,
    )..addListener(() {
      if (!_categoryTabController.indexIsChanging) {
        setState(() {
          _selectedCategoryIndex = _categoryTabController.index;
          _updateDisplayedLawyers();
        });
      }
    });

    // Initialize displayed data
    _displayedAppointments = _dataService.appointments;
    _updateDisplayedLawyers();
  }

  void _updateDisplayedLawyers() {
    if (_selectedCategoryIndex >= 0 &&
        _selectedCategoryIndex < _categories.length) {
      _displayedLawyers = _dataService.getLawyersBySpecialization(
        _categories[_selectedCategoryIndex],
      );
      // If no lawyers in this category, show all lawyers
      if (_displayedLawyers.isEmpty) {
        _displayedLawyers = _dataService.lawyers;
      }
    } else {
      _displayedLawyers = _dataService.lawyers;
    }
  }

  @override
  void dispose() {
    _categoryTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header with profile
            buildHeader(),

            // Search bar
            buildSearchBar(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Upcoming appointments
                    buildAppointmentsSection(),

                    // Top lawyers section
                    buildTopLawyersSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1F41BB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Notification icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),

          // Right side - Profile info and image
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        "🎉 مرحباً بك",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Savannah Nguyen",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1F41BB),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.tune, color: Colors.white.withOpacity(0.8), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: TextField(
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: "بحث عن ...",
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    suffixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppointmentsSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  "المواعيد القادمة",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 190,
            child:
                _displayedAppointments.isEmpty
                    ? const Center(child: Text('لا توجد مواعيد قادمة'))
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _displayedAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _displayedAppointments[index];
                        return buildAppointmentCard(
                          name: appointment.clientName,
                          imageUrl: appointment.clientImageUrl,
                          time: appointment.time,
                          date: appointment.date,
                          hasRating: appointment.hasRating,
                          rating: appointment.rating,
                          index: index,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget buildAppointmentCard({
    required String name,
    required String imageUrl,
    required String time,
    String? date,
    bool hasRating = false,
    double? rating,
    required int index,
  }) {
    return Container(
      width: 230,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3E64FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (hasRating && rating != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(Icons.star, color: Colors.white, size: 16),
                      ],
                    ),
                  )
                else
                  const SizedBox(width: 40),

                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "عميل",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (date != null)
                  Row(
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ],
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
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.only(top: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "عرض المزيد",
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF3E64FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  "ابرز المحامين",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          buildCategoryFilter(),
          _displayedLawyers.isEmpty
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('لا يوجد محامين'),
                ),
              )
              : buildLawyersGrid(_displayedLawyers),
        ],
      ),
    );
  }

  Widget buildLawyersGrid(List<Lawyer> lawyers) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
      ),
      itemCount: lawyers.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      itemBuilder: (context, index) {
        final lawyer = lawyers[index];
        return buildLawyerCard(
          name: lawyer.name,
          imageUrl: lawyer.imageUrl,
          rating: lawyer.rating,
          profession: lawyer.profession,
          index: index,
        );
      },
    );
  }

  Widget buildCategoryFilter() {
    return DefaultTabController(
      length: _categories.length,
      child: Container(
        height: 45,
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Material(
          color: Colors.transparent,
          child: Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: TabBar(
              controller: _categoryTabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[700],
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              indicator: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(0),
              ),
              indicatorPadding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: List<Widget>.generate(
                _categories.length,
                (index) => Tab(child: Text(_categories[index])),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildLawyerCard({
    required String name,
    required String imageUrl,
    required double rating,
    required int index,
    String profession = "محامية",
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    profession,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: const Color(0xFF3E64FF),
          unselectedItemColor: Colors.grey[400],
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 0 ? Icons.person : Icons.person_outline,
              ),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 1
                    ? Icons.chat_bubble
                    : Icons.chat_bubble_outline,
              ),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: _selectedIndex == 2 ? 50 : 0,
                    height: _selectedIndex == 2 ? 50 : 0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3E64FF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(
                    _selectedIndex == 2
                        ? Icons.calendar_today
                        : Icons.calendar_today_outlined,
                  ),
                ],
              ),
              label: 'Appointment',
            ),
            BottomNavigationBarItem(
              icon: Icon(_selectedIndex == 3 ? Icons.search : Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 4 ? Icons.home : Icons.home_outlined,
              ),
              label: 'Home',
            ),
          ],
        ),
      ),
    );
  }
}
