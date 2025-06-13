import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:url_launcher/url_launcher.dart';

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
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> timeSlots = [];
  Map<String, dynamic>? selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    if (widget.lawyerData != null) {
      setState(() {
        _lawyerData = widget.lawyerData;
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'محامي',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : SingleChildScrollView(
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
    );
  }

  Widget _buildProfileHeader() {
    final lawyer = _lawyerData;
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
                  lawyer?['pictureUrl'] ??
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
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                lawyer?['fullName'] ?? 'Unknown',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${lawyer?['rating'] ?? 0}/5',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            lawyer?['displayName'] ?? 'محامي خبير',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final lawyer = _lawyerData;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            '${lawyer?['experience'] ?? 0}+',
            'خبرة',
            Icons.person,
          ),
          _buildStatItem(
            '${lawyer?['reviewsCount'] ?? 0}+',
            'التقييم',
            Icons.edit_note,
          ),
          _buildStatItem('${lawyer?['rating'] ?? 0}', 'التقييم', Icons.star),
          _buildStatItem(
            '${lawyer?['consultationsCount'] ?? 0}+',
            'استشارات',
            Icons.chat,
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
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue, size: 22),
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
    final lawyer = _lawyerData;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نبذة عن',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            lawyer?['bio'] ?? 'No biography available',
            style: TextStyle(color: Colors.grey[700], height: 1.5),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showBookingDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'حجز الموعد',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final reviews = _lawyerData?['reviews'] as List<dynamic>? ?? [];
    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'لا توجد مراجعات بعد.',
          style: TextStyle(color: Color.fromARGB(255, 253, 253, 253)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text(
            'المراجعات',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ...reviews.map((review) {
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(review['comment'] ?? ''),
            ),
          );
        }),
      ],
    );
  }

  void _showBookingDialog() {
    final lawyer = _lawyerData;
    String? selectedDay;
    String? selectedMonth;
    String? selectedYear;
    String? selectedTime;
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
                                    (lawyer?['rating']?.toString() ?? '0'),
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
                                      lawyer?['fullName'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      lawyer?['displayName'] ?? 'محامي',
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
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "10:30am - 5:30pm",
                                style: const TextStyle(fontSize: 13),
                              ),
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
                                      "${lawyer?['priceOfAppointment'] ?? ''}",
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
                                      "${lawyer?['rating'] ?? '0'}+",
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
                                      "15yr", // Replace with actual experience if available
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
                                        'lawyerId: ${lawyer?['id']}, date: $date',
                                      );
                                      final slots = await fetchAvailableSlots(
                                        lawyer?['id'],
                                      );
                                      setState(() {
                                        timeSlots =
                                            List<Map<String, dynamic>>.from(
                                          slots,
                                        );
                                        selectedTimeSlot =
                                            null; // reset selection
                                      });
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
                                        'lawyerId: ${lawyer?['id']}, date: $date',
                                      );
                                      final slots = await fetchAvailableSlots(
                                        lawyer?['id'],
                                      );
                                      setState(() {
                                        timeSlots =
                                            List<Map<String, dynamic>>.from(
                                          slots,
                                        );
                                        selectedTimeSlot =
                                            null; // reset selection
                                      });
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
                                        'lawyerId: ${lawyer?['id']}, date: $date',
                                      );
                                      final slots = await fetchAvailableSlots(
                                        lawyer?['id'],
                                      );
                                      setState(() {
                                        timeSlots =
                                            List<Map<String, dynamic>>.from(
                                          slots,
                                        );
                                        selectedTimeSlot =
                                            null; // reset selection
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            "الجداول الزمنية",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          timeSlots.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'لا توجد جداول زمنية متاحة لهذا اليوم',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: timeSlots.map((slot) {
                                    final isSelected = selectedTimeSlot == slot;
                                    return ChoiceChip(
                                      label: Text(
                                        slot['availableFromDateFormatted'],
                                      ),
                                      selected: isSelected,
                                      onSelected: (_) => setState(
                                        () => selectedTimeSlot = slot,
                                      ),
                                      selectedColor: Colors.indigo[900],
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      backgroundColor: Colors.grey[100],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ),
                                      ),
                                      elevation: isSelected ? 2 : 0,
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
                                    'Booking for lawyerId: ${lawyer?['id']} at $bookingTime',
                                  );
                                  bookAppointment(lawyer?['id'], bookingTime);
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
}
