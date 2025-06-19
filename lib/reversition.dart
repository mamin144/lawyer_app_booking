import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher.dart';
import 'services/review_service.dart';
import 'services/profile_service.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lawyer Profile',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Cairo'),
      home: const LawyerProfilePage(lawyerId: '1'),
    );
  }
}

class LawyerProfilePage extends StatefulWidget {
  final String lawyerId;
  final Map<String, dynamic>? lawyerData;
  const LawyerProfilePage({
    super.key,
    required this.lawyerId,
    this.lawyerData,
  });

  @override
  State<LawyerProfilePage> createState() => _LawyerProfilePageState();
}

class _LawyerProfilePageState extends State<LawyerProfilePage> {
  Map<String, dynamic>? _lawyerData;
  Map<String, dynamic>? _lawyerDescription;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> timeSlots = [];
  Map<String, dynamic>? selectedTimeSlot;
  String clientName = '';

  @override
  void initState() {
    super.initState();
    if (widget.lawyerData != null) {
      setState(() {
        _lawyerData = widget.lawyerData;
        _isLoading = false;
      });
      _fetchLawyerDescription();
    } else {
      _fetchLawyerData();
    }
  }

  Future<void> _fetchLawyerData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://mohamek-legel.runasp.net/api/LayOut/get-lawyer-by-id?id=${widget.lawyerId}',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _lawyerData = json.decode(response.body);
          _isLoading = false;
        });

        // After getting lawyer data, fetch the description
        _fetchLawyerDescription();
      } else {
        setState(() {
          _error = 'Failed to load lawyer data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchLawyerDescription() async {
    if (_lawyerData == null || _lawyerData?['id'] == null) return;

    try {
      final response = await http.get(
        Uri.parse(
            'http://mohamek-legel.runasp.net/api/LayOut/get-description-by-lawyer-id?lawyerId=${_lawyerData!['id']}'),
      );

      print('Lawyer description API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _lawyerDescription = data;
        });
        print('Lawyer description fetched: $_lawyerDescription');
      }
    } catch (e) {
      print('Error fetching lawyer description: $e');
      // Don't set error state as this is supplementary information
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: const Color(0xFF1F41BB),
          elevation: 0,
          title: const Text(
            'محامي',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F41BB)),
              ))
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshData,
                    color: const Color(0xFF1F41BB),
                    backgroundColor: Colors.white,
                    displacement: 40.0,
                    strokeWidth: 3.0,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildProfileHeader(),
                          const SizedBox(height: 0),
                          _buildStatistics(),
                          const SizedBox(height: 0),
                          _buildAboutSection(),
                          const SizedBox(height: 0),
                          _buildReviewsSection(),
                          const SizedBox(height: 0),
                        ],
                      ),
                    ),
                  ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: _showBookingDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F41BB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'حجز موعد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final lawyerData = _lawyerData;

    // Calculate average rating from 'averageRating' field if present
    double avgRating = 3.0;
    if (lawyerData != null && lawyerData['averageRating'] != null) {
      final ratingStr = lawyerData['averageRating'].toString();
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
    } else if (lawyerData != null &&
        lawyerData['rating'] != null &&
        lawyerData['rating'] != 0) {
      avgRating = lawyerData['rating'] is num
          ? lawyerData['rating'].toDouble()
          : double.tryParse(lawyerData['rating'].toString()) ?? 3.0;
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  lawyerData?['pictureUrl'] ??
                      'https://t4.ftcdn.net/jpg/02/14/74/61/360_F_214746128_31JkeaP6rU0NzzzdFC4khGkmqc8noe6h.jpg',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              // Add rating badge on the image
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${avgRating.toStringAsFixed(1)}/5',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            lawyerData?['fullName'] ?? 'Unknown',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F41BB),
            ),
          ),
          const SizedBox(height: 8),
          // Show specializations in a horizontal list
          if (lawyerData?['specializations'] != null &&
              (lawyerData!['specializations'] as List).isNotEmpty)
            SizedBox(
              height: 32,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (lawyerData['specializations'] as List).length,
                itemBuilder: (context, index) {
                  final specialization = lawyerData['specializations'][index];
                  // Check if specialization is a Map and has a 'name' field
                  final specializationName = specialization is Map
                      ? specialization['name'] ?? ''
                      : specialization.toString();

                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F41BB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF1F41BB).withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      specializationName,
                      style: const TextStyle(
                        color: Color(0xFF1F41BB),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final lawyerData = _lawyerData;

    // Get experience from lawyer description if available
    final experienceYears = _lawyerDescription?['yearsOfExperience'] ??
        lawyerData?['experience'] ??
        0;

    // Get price of appointment
    final price = lawyerData?['priceOfAppointment']?.toString() ?? '0';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            '$experienceYears+',
            'سنوات الخبرة',
            Icons.work_history_outlined,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.withOpacity(0.2),
          ),
          _buildStatItem(
            '$price جنيه',
            'سعر الاستشارة',
            Icons.attach_money_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1F41BB).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1F41BB), size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildAboutSection() {
    // Get bio from lawyer description if available, otherwise use lawyer data
    final bio = _lawyerDescription?['bio'] ??
        _lawyerData?['bio'] ??
        'لم يتم إضافة نبذة بعد';

    final education = _lawyerDescription?['education'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نبذة عن المحامي',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F41BB),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1F41BB).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF1F41BB).withOpacity(0.1),
              ),
            ),
            child: Text(
              bio,
              style: TextStyle(
                color: Colors.grey[800],
                height: 1.5,
                fontSize: 14,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          if (education != null && education.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'المؤهلات العلمية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F41BB),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F41BB).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1F41BB).withOpacity(0.1),
                ),
              ),
              child: Text(
                education,
                style: TextStyle(
                  color: Colors.grey[800],
                  height: 1.5,
                  fontSize: 14,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final reviews = _lawyerData?['reviews'] as List<dynamic>? ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'المراجعات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F41BB),
                ),
              ),
              GestureDetector(
                onTap: _showAddReviewDialog,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F41BB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'إضافة تقييم',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 48,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'لا توجد مراجعات بعد',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F41BB).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF1F41BB).withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                const Color(0xFF1F41BB).withOpacity(0.2),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF1F41BB),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review['clientName'] ?? 'عميل',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                if (review['rating'] != null)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${review['rating']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          if (review['date'] != null)
                            Text(
                              review['date'].toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      if (review['comment'] != null &&
                          review['comment'].toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          review['comment'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showBookingDialog() {
    final lawyerData = _lawyerData;
    String? selectedDay;
    String? selectedMonth;
    String? selectedYear;
    String? selectedTime;
    TimeOfDay? pickedTime;
    List<Map<String, dynamic>> filteredTimeSlots = [];
    String? nearestTimeMessage;

    // Get experience from lawyer description if available
    final experienceYears = _lawyerDescription?['yearsOfExperience'] ??
        lawyerData?['experience'] ??
        0;

    // Format experience for display
    final experienceText = "${experienceYears}yr";

    // Get rating with default of 3.0
    double displayRating = 3.0;
    if (lawyerData != null && lawyerData['averageRating'] != null) {
      final ratingStr = lawyerData['averageRating'].toString();
      switch (ratingStr) {
        case 'FiveStars':
          displayRating = 5.0;
          break;
        case 'FourStars':
          displayRating = 4.0;
          break;
        case 'ThreeStars':
          displayRating = 3.0;
          break;
        case 'TwoStars':
          displayRating = 2.0;
          break;
        case 'OneStar':
          displayRating = 1.0;
          break;
        default:
          displayRating = 3.0;
      }
    } else if (lawyerData != null &&
        lawyerData['rating'] != null &&
        lawyerData['rating'] != 0) {
      displayRating = lawyerData['rating'] is num
          ? lawyerData['rating'].toDouble()
          : double.tryParse(lawyerData['rating'].toString()) ?? 3.0;
    }

    // Function to find the nearest available time to the picked time
    void findNearestAvailableTime() {
      if (pickedTime == null || filteredTimeSlots.isEmpty) {
        nearestTimeMessage = null;
        return;
      }

      // Convert picked time to minutes since midnight for comparison
      final pickedMinutes = pickedTime!.hour * 60 + pickedTime!.minute;

      // Check if any slot matches the exact time
      bool hasExactMatch = false;
      for (var slot in filteredTimeSlots) {
        final slotDate = DateTime.parse(slot['availableFrom']);
        final slotTime = TimeOfDay.fromDateTime(slotDate);
        final slotMinutes = slotTime.hour * 60 + slotTime.minute;

        if (slotMinutes == pickedMinutes) {
          hasExactMatch = true;
          break;
        }
      }

      // If there's an exact match, no need for a message
      if (hasExactMatch) {
        nearestTimeMessage = null;
        return;
      }

      // Find the nearest time if no exact match
      int? nearestSlotMinutes;
      DateTime? nearestSlotDateTime;
      int smallestDifference = 24 * 60; // Initialize with max minutes in a day

      for (var slot in filteredTimeSlots) {
        final slotDate = DateTime.parse(slot['availableFrom']);
        final slotTime = TimeOfDay.fromDateTime(slotDate);
        final slotMinutes = slotTime.hour * 60 + slotTime.minute;

        final difference = (slotMinutes - pickedMinutes).abs();
        if (difference < smallestDifference) {
          smallestDifference = difference;
          nearestSlotMinutes = slotMinutes;
          nearestSlotDateTime = slotDate;
        }
      }

      if (nearestSlotDateTime != null) {
        final formattedTime = DateFormat('h:mm a').format(nearestSlotDateTime);
        nearestTimeMessage =
            'الوقت المحدد غير متاح. أقرب وقت متاح هو $formattedTime';
      }
    }

    // Function to filter time slots based on selected date
    void filterTimeSlotsByDate() {
      if (selectedDay == null ||
          selectedMonth == null ||
          selectedYear == null) {
        filteredTimeSlots = List<Map<String, dynamic>>.from(timeSlots);
        return;
      }

      final selectedDateStr = "$selectedYear-$selectedMonth-$selectedDay";
      final selectedDate = DateTime.parse(selectedDateStr);

      // Filter slots for the selected date
      filteredTimeSlots = timeSlots.where((slot) {
        final slotDate = DateTime.parse(slot['availableFrom']);
        return slotDate.year == selectedDate.year &&
            slotDate.month == selectedDate.month &&
            slotDate.day == selectedDate.day;
      }).toList();

      // If no slots available on selected date, find the next closest date
      if (filteredTimeSlots.isEmpty && timeSlots.isNotEmpty) {
        // Sort all slots by date
        final sortedSlots = List<Map<String, dynamic>>.from(timeSlots);
        sortedSlots.sort((a, b) {
          final dateA = DateTime.parse(a['availableFrom']);
          final dateB = DateTime.parse(b['availableFrom']);
          return dateA.compareTo(dateB);
        });

        // Find the next closest date after the selected date
        final nextAvailableSlots = sortedSlots.where((slot) {
          final slotDate = DateTime.parse(slot['availableFrom']);
          return slotDate.isAfter(selectedDate);
        }).toList();

        if (nextAvailableSlots.isNotEmpty) {
          final nextDate =
              DateTime.parse(nextAvailableSlots.first['availableFrom']);

          // Update the selected date to the next available date
          selectedDay = nextDate.day.toString().padLeft(2, '0');
          selectedMonth = nextDate.month.toString().padLeft(2, '0');
          selectedYear = nextDate.year.toString();

          // Filter slots for this next available date
          filteredTimeSlots = timeSlots.where((slot) {
            final slotDate = DateTime.parse(slot['availableFrom']);
            return slotDate.year == nextDate.year &&
                slotDate.month == nextDate.month &&
                slotDate.day == nextDate.day;
          }).toList();
        }
      }

      // Check for nearest time after filtering
      findNearestAvailableTime();
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final days = List.generate(
          31,
          (i) => (i + 1).toString().padLeft(2, '0'),
        );
        final months = List.generate(
          12,
          (i) => (i + 1).toString().padLeft(2, '0'),
        );
        final now = DateTime.now();
        final years = List.generate(3, (i) => (now.year + i).toString());

        // Initialize filtered slots with all slots
        filteredTimeSlots = List<Map<String, dynamic>>.from(timeSlots);

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 24,
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 18),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    displayRating.toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      lawyerData?['fullName'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      lawyerData?['displayName'] ?? 'محامي',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const SizedBox(width: 4),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      "${lawyerData?['priceOfAppointment'] ?? ''}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const Text(
                                      "متوسط السعر",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 32,
                                  color: Colors.grey[300],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      "${displayRating.toString()}+",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const Text(
                                      "التقييم",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 32,
                                  color: Colors.grey[300],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      experienceText,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const Text(
                                      "الخبرة",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            "اختر الموعد",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedDay,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  hint: const Text("يوم"),
                                  items: days
                                      .map(
                                        (d) => DropdownMenuItem(
                                          value: d,
                                          child: Text(d),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) async {
                                    setState(() => selectedDay = val);
                                    if (selectedDay != null &&
                                        selectedMonth != null &&
                                        selectedYear != null) {
                                      final date =
                                          "$selectedYear-$selectedMonth-$selectedDay";
                                      print(
                                        'lawyerId: ${lawyerData?['id']}, date: $date',
                                      );

                                      if (timeSlots.isEmpty) {
                                        final slots = await fetchAvailableSlots(
                                          lawyerData?['id'],
                                        );
                                        setState(() {
                                          timeSlots =
                                              List<Map<String, dynamic>>.from(
                                                  slots);
                                          filterTimeSlotsByDate();
                                          selectedTimeSlot =
                                              null; // reset selection
                                        });
                                      } else {
                                        setState(() {
                                          filterTimeSlotsByDate();
                                          selectedTimeSlot =
                                              null; // reset selection
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedMonth,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  hint: const Text("شهر"),
                                  items: months
                                      .map(
                                        (m) => DropdownMenuItem(
                                          value: m,
                                          child: Text(m),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) async {
                                    setState(() => selectedMonth = val);
                                    if (selectedDay != null &&
                                        selectedMonth != null &&
                                        selectedYear != null) {
                                      final date =
                                          "$selectedYear-$selectedMonth-$selectedDay";
                                      print(
                                        'lawyerId: ${lawyerData?['id']}, date: $date',
                                      );

                                      if (timeSlots.isEmpty) {
                                        final slots = await fetchAvailableSlots(
                                          lawyerData?['id'],
                                        );
                                        setState(() {
                                          timeSlots =
                                              List<Map<String, dynamic>>.from(
                                                  slots);
                                          filterTimeSlotsByDate();
                                          selectedTimeSlot =
                                              null; // reset selection
                                        });
                                      } else {
                                        setState(() {
                                          filterTimeSlotsByDate();
                                          selectedTimeSlot =
                                              null; // reset selection
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: selectedYear,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  hint: const Text("سنة"),
                                  items: years
                                      .map(
                                        (y) => DropdownMenuItem(
                                          value: y,
                                          child: Text(y),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) async {
                                    setState(() => selectedYear = val);
                                    if (selectedDay != null &&
                                        selectedMonth != null &&
                                        selectedYear != null) {
                                      final date =
                                          "$selectedYear-$selectedMonth-$selectedDay";
                                      print(
                                        'lawyerId: ${lawyerData?['id']}, date: $date',
                                      );

                                      if (timeSlots.isEmpty) {
                                        final slots = await fetchAvailableSlots(
                                          lawyerData?['id'],
                                        );
                                        setState(() {
                                          timeSlots =
                                              List<Map<String, dynamic>>.from(
                                                  slots);
                                          filterTimeSlotsByDate();
                                          selectedTimeSlot =
                                              null; // reset selection
                                        });
                                      } else {
                                        setState(() {
                                          filterTimeSlotsByDate();
                                          selectedTimeSlot =
                                              null; // reset selection
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          // Time Picker
                          InkWell(
                            onTap: () async {
                              final TimeOfDay? time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                builder: (BuildContext context, Widget? child) {
                                  return Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                setState(() {
                                  pickedTime = time;
                                  // Check for nearest available time
                                  findNearestAvailableTime();
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time,
                                      color: Colors.grey[700]),
                                  const SizedBox(width: 8),
                                  Text(
                                    pickedTime != null
                                        ? '${pickedTime!.format(context)}'
                                        : 'اختر الوقت',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: pickedTime != null
                                          ? Colors.black
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Nearest time message
                          if (nearestTimeMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.amber.shade300),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Colors.amber.shade700, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        nearestTimeMessage!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 18),
                          const Text(
                            "الجداول الزمنية",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          if (selectedDay != null &&
                              selectedMonth != null &&
                              selectedYear != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "المواعيد المتاحة في $selectedDay/$selectedMonth/$selectedYear",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          filteredTimeSlots.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'لا توجد جداول زمنية متاحة لهذا اليوم',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      if (selectedDay != null &&
                                          selectedMonth != null &&
                                          selectedYear != null &&
                                          timeSlots.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Text(
                                            'يرجى اختيار تاريخ آخر',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12),
                                          ),
                                        ),
                                    ],
                                  ),
                                )
                              : Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: filteredTimeSlots.map((slot) {
                                    final isSelected = selectedTimeSlot == slot;
                                    final slotDate =
                                        DateTime.parse(slot['availableFrom']);
                                    final formattedTime =
                                        DateFormat('h:mm a').format(slotDate);

                                    // Check if this slot matches the picked time
                                    bool isPickedTime = false;
                                    if (pickedTime != null) {
                                      final slotTime =
                                          TimeOfDay.fromDateTime(slotDate);
                                      isPickedTime = slotTime.hour ==
                                              pickedTime!.hour &&
                                          slotTime.minute == pickedTime!.minute;
                                    }

                                    return ChoiceChip(
                                      label: Text(formattedTime),
                                      selected: isSelected,
                                      onSelected: (_) => setState(
                                        () => selectedTimeSlot = slot,
                                      ),
                                      selectedColor: Colors.indigo[900],
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : (isPickedTime
                                                ? Colors.green[700]
                                                : Colors.black),
                                        fontWeight: isPickedTime
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      backgroundColor: isPickedTime
                                          ? Colors.green[50]
                                          : Colors.grey[100],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: isPickedTime
                                            ? BorderSide(
                                                color: Colors.green[300]!,
                                                width: 1.5)
                                            : BorderSide.none,
                                      ),
                                      elevation: isSelected
                                          ? 2
                                          : (isPickedTime ? 1 : 0),
                                    );
                                  }).toList(),
                                ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo[900],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () {
                                if (selectedYear != null &&
                                    selectedMonth != null &&
                                    selectedDay != null &&
                                    selectedTimeSlot != null) {
                                  final bookingTime = formatRequestedTime(
                                    selectedTimeSlot!['availableFrom'],
                                  );
                                  print(
                                    'Booking for lawyerId: ${lawyerData?['id']} at $bookingTime',
                                  );
                                  bookAppointment(
                                      lawyerData?['id'], bookingTime);
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text(
                                "تاكيد الحجز",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchAvailableSlots(
    String lawyerId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        print('No authentication token found');
        return [];
      }

      final response = await http.get(
        Uri.parse(
          'http://mohamek-legel.runasp.net/api/ClientDashBoard/available-slots?lawyerId=$lawyerId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('Slots API response: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          return [];
        }
      } else {
        print('Failed to load slots: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception fetching slots: $e');
      return [];
    }
  }

  Future<void> bookAppointment(String lawyerId, String requestedTime) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        print('No authentication token found');
        return;
      }

      final response = await http.post(
        Uri.parse(
          'http://mohamek-legel.runasp.net/api/Consultation/book-consultation',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'lawyerId': lawyerId,
          'requestedTime': requestedTime,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['paymentUrl'] != null) {
          final url = data['paymentUrl'];
          print('Trying to open: $url');
          await openInBrowser(url);
        }
      }
    } catch (e) {
      print('Exception booking appointment: $e');
    }
  }

  Future<void> openInBrowser(String urlString) async {
    try {
      final url = Uri.parse(urlString);
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      )) {
        throw 'Could not launch $urlString';
      }
    } catch (e) {
      print('Error launching URL: $e');
      // You might want to show a snackbar or dialog to inform the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open payment link: $e')),
        );
      }
    }
  }

  String formatTimeSlot(String slot) {
    final hour = int.parse(slot.split(':')[0]);
    final minute = int.parse(slot.split(':')[1]);
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${hour12.toString().padLeft(2, '0')}:${slot.split(':')[1]} $suffix';
  }

  String formatDateTimeForApi(
    String year,
    String month,
    String day,
    String slot,
  ) {
    int hour = int.parse(slot.split(':')[0]);
    int minute = int.parse(slot.split(':')[1]);
    String suffix = hour >= 12 ? 'PM' : 'AM';
    int hour12 = hour % 12 == 0 ? 12 : hour % 12;
    String formattedTime =
        '${hour12.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $suffix';
    return '$year-$month-$day $formattedTime';
  }

  String formatRequestedTime(String isoString) {
    final dt = DateTime.parse(isoString);
    return DateFormat('yyyy-MM-dd hh:mm a').format(dt);
  }

  // Widget _buildBottomNavBar() {
  //   return BottomNavigationBar(
  //     currentIndex: 0,
  //     type: BottomNavigationBarType.fixed,
  //     selectedItemColor: Colors.blue,
  //     unselectedItemColor: Colors.grey,
  //     items: const [
  //       BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
  //       BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.calendar_today),
  //         label: 'Appointment',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.chat_bubble_outline),
  //         label: 'Chat',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.person_outline),
  //         label: 'Profile',
  //       ),
  //     ],
  //   );
  // }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Refresh lawyer data
      await _fetchLawyerData();

      // After getting lawyer data, fetch the description
      if (_lawyerData != null && _lawyerData?['id'] != null) {
        await _fetchLawyerDescription();
      }

      // Set loading to false if it's still true
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Add this method to check for consultations
  Future<String?> _getLatestConsultationId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(
          'http://mohamek-legel.runasp.net/api/ClientDashBoard/client-consultations?includeCompleted=true',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final consultations = json.decode(response.body) as List;
        // Find the latest completed consultation with this lawyer
        final lawyerConsultation = consultations.firstWhere(
          (consultation) =>
              consultation['lawyerId'] == widget.lawyerId &&
              consultation['status'] == 'Completed',
          orElse: () => null,
        );

        if (lawyerConsultation != null) {
          return lawyerConsultation['id'];
        }
      }
      return null;
    } catch (e) {
      print('Error getting consultations: $e');
      return null;
    }
  }

  // Update the show review dialog to check for consultations first
  void _showAddReviewDialog() {
    double rating = 3.0;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'إضافة تقييم',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F41BB),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'اكتب تعليقك هنا...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1F41BB),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1F41BB),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F41BB),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (commentController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('الرجاء كتابة تعليق'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    isSubmitting = true;
                                  });

                                  try {
                                    final reviewService = ReviewService();
                                    await ReviewService.initialize();

                                    await reviewService.postReview(
                                      lawyerId: widget.lawyerId,
                                      rating: rating,
                                      comment: commentController.text.trim(),
                                    );

                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('تم إضافة تقييمك بنجاح'),
                                          backgroundColor: Color(0xFF1F41BB),
                                        ),
                                      );
                                      _refreshData();
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(e.toString()),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        isSubmitting = false;
                                      });
                                    }
                                  }
                                },
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'إرسال التقييم',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
