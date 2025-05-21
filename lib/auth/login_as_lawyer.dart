import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:dio/dio.dart';

class LawyerSignupData {
  String fullName = '';
  String email = '';
  String phoneNumber = '';
  String ssn = '';
  String priceOfAppointment = '';
  String password = '';
  List<String> selectedCaseIds = [];
  File? barAssociationImage;
  File? picture;
}

class Specialization {
  final String id;
  final String name;
  Specialization({required this.id, required this.name});
  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}

class LawyerSignupScreen extends StatefulWidget {
  const LawyerSignupScreen({super.key});

  @override
  State<LawyerSignupScreen> createState() => _LawyerSignupScreenState();
}

class TimeoutError implements Exception {
  final String message;
  TimeoutError(this.message);
}

class _LawyerSignupScreenState extends State<LawyerSignupScreen> {
  int _step = 1;
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final LawyerSignupData _data = LawyerSignupData();
  bool _isLoading = false;
  String? _gender;
  DateTime? _dateOfBirth;
  List<Specialization> _specializations = [];
  bool _isLoadingSpecializations = true;

  // final List<Map<String, dynamic>> _caseOptions = [
  //   {'id': 1, 'name': 'Family Law'},
  //   {'id': 2, 'name': 'Business Law'},
  //   {'id': 3, 'name': 'Criminal Law'},
  //   {'id': 4, 'name': 'Property Law'},
  // ];

  // TextEditingController _selectedCasesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSpecializations();
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
      print('Specializations API response: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _specializations =
              data.map((e) => Specialization.fromJson(e)).toList();
          _isLoadingSpecializations = false;
        });
      } else {
        setState(() {
          _isLoadingSpecializations = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load specializations.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoadingSpecializations = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error loading specializations.')));
    }
  }

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

  void _nextStep() {
    if (_step == 1 && _formKey1.currentState!.validate()) {
      _formKey1.currentState!.save();
      setState(() => _step = 2);
    } else if (_step == 2 && _formKey2.currentState!.validate()) {
      _formKey2.currentState!.save();
      _submit();
    }
  }

  void _previousStep() {
    if (_step == 2) {
      setState(() => _step = 1);
    }
  }

  // void _toggleCase(String caseName) {
  //   setState(() {
  //     if (_data.selectedCaseIds.contains(caseName)) {
  //       _data.selectedCaseIds.remove(caseName);
  //     } else {
  //       _data.selectedCaseIds.add(caseName);
  //     }
  //   });
  // }

  // Future<void> _testApi() async {
  //   try {
  //     print('Testing API endpoint...');
  //     final testResponse = await http
  //         .get(
  //           Uri.parse(
  //             'http://mohamek-legel.runasp.net/api/Account/register-as-lawyer',
  //           ),
  //         )
  //         .timeout(Duration(seconds: 10));

  //     print('API Test Response Status: ${testResponse.statusCode}');
  //     print('API Test Response Headers: ${testResponse.headers}');
  //     print('API Test Response Body: ${testResponse.body}');

  //     if (testResponse.statusCode == 405) {
  //       print('API endpoint exists but method not allowed (expected for GET)');
  //       return;
  //     }

  //     throw Exception('Unexpected response: ${testResponse.statusCode}');
  //   } catch (e) {
  //     print('API Test Error: $e');
  //     rethrow;
  //   }
  // }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      // Validate and log all data before submission
      // print('\n=== Validating Registration Data ===');
      // print('Full Name: ${_data.fullName} (${_data.fullName.length} chars)');
      // print('Email: ${_data.email}');
      // print('Phone: ${_data.phoneNumber}');
      // print('SSN: ${_data.ssn}');
      // print('Price: ${_data.priceOfAppointment}');
      // print('SelectedCaseIds list: ${_data.selectedCaseIds}');
      // print('Has Profile Picture: ${_data.picture != null}');
      // print('Has Bar Association Image: ${_data.barAssociationImage != null}');
      // print('==================================\n');

      // Validate required fields
      if (_data.fullName.isEmpty) throw Exception('Full Name is required');
      if (_data.email.isEmpty) throw Exception('Email is required');
      if (_data.phoneNumber.isEmpty) {
        throw Exception('Phone Number is required');
      }
      if (_data.ssn.isEmpty) throw Exception('SSN is required');
      if (_data.priceOfAppointment.isEmpty) {
        throw Exception('Price is required');
      }
      if (_data.password.isEmpty) throw Exception('Password is required');
      if (_data.selectedCaseIds.isEmpty) {
        throw Exception('You must choose at least one major.');
      }
      if (_data.selectedCaseIds.length > 5) {
        throw Exception('You can choose up to 5 majors only.');
      }
      if (_data.picture == null) throw Exception('Profile picture is required');
      if (_data.barAssociationImage == null) {
        throw Exception('Bar association image is required');
      }

      // Validate email format
      final emailRegex = RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$");
      if (!emailRegex.hasMatch(_data.email)) {
        throw Exception('Please enter a valid email address');
      }

      // Validate phone number format (basic validation)
      final phoneRegex = RegExp(r"^\+?[0-9]{10,}$");
      if (!phoneRegex.hasMatch(
        _data.phoneNumber.replaceAll(RegExp(r'[^0-9+]'), ''),
      )) {
        throw Exception('The phone number is invalid.');
      }

      // Validate National ID format (14 digits)
      final nationalIdRegex = RegExp(r"^\d{14}$");
      final cleanNationalId = _data.ssn.replaceAll(RegExp(r'[^0-9]'), '');
      if (!nationalIdRegex.hasMatch(cleanNationalId)) {
        throw Exception('National ID must be exactly 14 digits');
      }

      // Validate price is a positive number
      final price = double.tryParse(_data.priceOfAppointment);
      if (price == null || price <= 0) {
        throw Exception('Price must be a positive number');
      }

      FormData formData = FormData.fromMap({
        'FullName': _data.fullName,
        'Email': _data.email.trim().toLowerCase(),
        'PhoneNumber': _data.phoneNumber,
        'SSN': cleanNationalId,
        'PriceOfAppointment': int.parse(_data.priceOfAppointment).toString(),
        'Password': _data.password,
        'SelectedCases': _data.selectedCaseIds.map((id) => '"$id"').join(','),
        'Gender': _gender,
        'DateOfBirth':
            _dateOfBirth != null
                ? '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}'
                : null,
        'Picture': await MultipartFile.fromFile(_data.picture!.path),
        'BarAssociationImage': await MultipartFile.fromFile(
          _data.barAssociationImage!.path,
        ),
      });

      // Log the complete request
      // print('\n=== Sending Request ===');
      // print(
      //   'URL: ${Uri.parse('http://mohamek-legel.runasp.net/api/Account/register-as-lawyer').toString()}',
      // );
      // print('Method: POST');
      // print('Fields: ${formData.fields}');
      // print('Files: ${formData.files.length}');
      // print('========================\n');

      // Add timeout to the request
      var streamedResponse = await Dio()
          .post(
            'http://mohamek-legel.runasp.net/api/Account/register-as-lawyer',
            data: formData,
            options: Options(
              sendTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutError('Request timed out after 30 seconds');
            },
          );

      var response = streamedResponse;

      setState(() => _isLoading = false);

      // Log the response
      // print('\n=== Received Response ===');
      // print('Status Code: ${response.statusCode}');
      // print('Headers: ${response.headers}');
      // print('Body: ${response.data}');
      // print('========================\n');

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Success'),
                content: const Text('Registration successful!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      } else {
        String errorMsg = 'Registration failed.';
        try {
          final decoded = json.decode(response.data.toString());
          print('Error response: ${response.data}');
          if (decoded is Map) {
            if (decoded['message'] != null) {
              errorMsg = decoded['message'];
            } else if (decoded['errors'] != null) {
              errorMsg = decoded['errors'].toString();
            }
          }
        } catch (e) {
          print('Error parsing response: $e');
        }
        print('Registration error: $errorMsg');
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Error'),
                content: Text('Status Code: ${response.statusCode}\n$errorMsg'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } on TimeoutError {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Error'),
              content: const Text(
                'The request timed out. Please check your internet connection and try again.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error during submission: $e');
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Error'),
              content: Text('An error occurred: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  Future<bool> _submitWithResult() async {
    setState(() => _isLoading = true);
    try {
      // (copy the logic from _submit, but return true if success, false if not)
      print('\n=== Validating Registration Data ===');
      print('Full Name: ${_data.fullName} (${_data.fullName.length} chars)');
      print('Email: ${_data.email}');
      print('Phone: ${_data.phoneNumber}');
      print('SSN: ${_data.ssn}');
      print('Price: ${_data.priceOfAppointment}');
      print('SelectedCaseIds list: ${_data.selectedCaseIds}');
      print('Has Profile Picture: ${_data.picture != null}');
      print('Has Bar Association Image: ${_data.barAssociationImage != null}');
      print('==================================\n');
      if (_data.fullName.isEmpty) throw Exception('Full Name is required');
      if (_data.email.isEmpty) throw Exception('Email is required');
      if (_data.phoneNumber.isEmpty) {
        throw Exception('Phone Number is required');
      }
      if (_data.ssn.isEmpty) throw Exception('SSN is required');
      if (_data.priceOfAppointment.isEmpty) {
        throw Exception('Price is required');
      }
      if (_data.password.isEmpty) throw Exception('Password is required');
      if (_data.selectedCaseIds.isEmpty) {
        throw Exception('You must choose at least one major.');
      }
      if (_data.selectedCaseIds.length > 5) {
        throw Exception('You can choose up to 5 majors only.');
      }
      if (_data.picture == null) throw Exception('Profile picture is required');
      if (_data.barAssociationImage == null) {
        throw Exception('Bar association image is required');
      }
      final emailRegex = RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}");
      if (!emailRegex.hasMatch(_data.email)) {
        throw Exception('Please enter a valid email address');
      }
      final phoneRegex = RegExp(r"^\+?[0-9]{10,}");
      if (!phoneRegex.hasMatch(
        _data.phoneNumber.replaceAll(RegExp(r'[^0-9+]'), ''),
      )) {
        throw Exception('The phone number is invalid.');
      }
      final nationalIdRegex = RegExp(r"^\d{14}");
      final cleanNationalId = _data.ssn.replaceAll(RegExp(r'[^0-9]'), '');
      if (!nationalIdRegex.hasMatch(cleanNationalId)) {
        throw Exception('National ID must be exactly 14 digits');
      }
      final price = double.tryParse(_data.priceOfAppointment);
      if (price == null || price <= 0) {
        throw Exception('Price must be a positive number');
      }
      var uri = Uri.parse(
        'http://mohamek-legel.runasp.net/api/Account/register-as-lawyer',
      );
      var request = http.MultipartRequest('POST', uri);
      request.fields['FullName'] = _data.fullName;
      request.fields['Email'] = _data.email.trim().toLowerCase();
      request.fields['PhoneNumber'] = _data.phoneNumber;
      request.fields['SSN'] = cleanNationalId;
      request.fields['PriceOfAppointment'] =
          int.parse(_data.priceOfAppointment).toString();
      request.fields['Password'] = _data.password;
      for (final id in _data.selectedCaseIds) {
        request.fields.putIfAbsent('SelectedCases', () => id);
      }
      if (_data.picture != null) {
        print('Adding profile picture: ${_data.picture!.path}');
        request.files.add(
          await http.MultipartFile.fromPath('Picture', _data.picture!.path),
        );
      } else {
        print('No profile picture selected!');
      }
      if (_data.barAssociationImage != null) {
        print(
          'Adding bar association image: ${_data.barAssociationImage!.path}',
        );
        request.files.add(
          await http.MultipartFile.fromPath(
            'BarAssociationImage',
            _data.barAssociationImage!.path,
          ),
        );
      } else {
        print('No bar association image selected!');
      }
      if (_gender != null && _gender!.isNotEmpty) {
        request.fields['Gender'] = _gender!;
      }
      if (_dateOfBirth != null) {
        request.fields['DateOfBirth'] =
            '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}';
      }
      print('Fields: ${request.fields}');
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutError('Request timed out after 30 seconds');
        },
      );
      var response = streamedResponse;
      setState(() => _isLoading = false);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        String errorMsg = 'Registration failed.';
        try {
          final responseBody = await response.stream.bytesToString();
          final decoded = json.decode(responseBody);
          if (decoded is Map) {
            if (decoded['message'] != null) {
              errorMsg = decoded['message'];
            } else if (decoded['errors'] != null) {
              errorMsg = decoded['errors'].toString();
            }
          }
        } catch (e) {}
        print('Registration error: $errorMsg');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
        return false;
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            toolbarHeight: 0,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    _buildProgressIndicator(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder:
                          (child, anim) => SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(_step == 1 ? 1 : -1, 0),
                              end: const Offset(0, 0),
                            ).animate(anim),
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                      child: Container(
                        key: ValueKey(_step),
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_step == 2)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back,
                                      color: Color(0xFF0A2F5E),
                                    ),
                                    onPressed: _previousStep,
                                    tooltip: 'Back',
                                  ),
                                ),
                              _step == 1 ? _buildStep1() : _buildStep2(),
                            ],
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
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepCircle(1, 'Account'),
          _progressLine(),
          _stepCircle(2, 'Details'),
        ],
      ),
    );
  }

  Widget _stepCircle(int step, String label) {
    final isActive = _step == step;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 36 : 28,
          height: isActive ? 36 : 28,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0A2F5E) : Colors.grey[300],
            shape: BoxShape.circle,
            boxShadow:
                isActive
                    ? [
                      BoxShadow(
                        color: const Color(0xFF0A2F5E).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: isActive ? 18 : 15,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF0A2F5E) : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _progressLine() {
    return Container(
      width: 40,
      height: 2,
      color: const Color(0xFF0A2F5E),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to App',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A2F5E),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Help Us Understand Your Legal Needs',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 28),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundColor: const Color(0xFF0A2F5E).withOpacity(0.1),
                  backgroundImage:
                      _data.picture != null ? FileImage(_data.picture!) : null,
                  child:
                      _data.picture == null
                          ? Icon(
                            Icons.person,
                            size: 54,
                            color: const Color(0xFF0A2F5E).withOpacity(0.3),
                          )
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () => _pickImage(true),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A2F5E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0A2F5E).withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _modernTextField(
            label: 'Full Name',
            icon: Icons.person_outline,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Name required.';
              if (v.length > 25) {
                return 'The name must not exceed 25 characters.';
              }
              if (!RegExp(r"^[A-Za-z ]+$").hasMatch(v)) {
                return 'The name must contain only English letters.';
              }
              return null;
            },
            onSaved: (v) => _data.fullName = v ?? '',
            initialValue: _data.fullName,
          ),
          const SizedBox(height: 18),
          _modernTextField(
            label: 'Email address',
            icon: Icons.email_outlined,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required.';
              if (!RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,4}$").hasMatch(v)) {
                return 'Invalid email.';
              }
              return null;
            },
            onSaved: (v) => _data.email = v ?? '',
            keyboardType: TextInputType.emailAddress,
            initialValue: _data.email,
          ),
          const SizedBox(height: 18),
          _modernTextField(
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Phone number is required.';
              if (!RegExp(r"^\+?[0-9]{10,}$").hasMatch(v)) {
                return 'The phone number is invalid.';
              }
              return null;
            },
            onSaved: (v) => _data.phoneNumber = v ?? '',
            keyboardType: TextInputType.phone,
            initialValue: _data.phoneNumber,
          ),
          const SizedBox(height: 18),
          _modernTextField(
            label: 'SSN',
            icon: Icons.credit_card,
            validator: (v) {
              if (v == null || v.isEmpty) return 'National ID is required.';
              if (!RegExp(r"^\d{14}$").hasMatch(v)) {
                return 'The national ID number must consist of 14 digits and contain only numbers.';
              }
              return null;
            },
            onSaved: (v) => _data.ssn = v ?? '',
            keyboardType: TextInputType.number,
            initialValue: _data.ssn,
          ),
          const SizedBox(height: 18),
          _modernTextField(
            label: 'Price Of Appointment',
            icon: Icons.attach_money,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Consultation fee required.';
              final value = int.tryParse(v);
              if (value == null) return 'Consultation fee must be a number.';
              if (value < 100 || value > 500) {
                return 'The consultation fee should be between 100 and 500 pounds.';
              }
              return null;
            },
            onSaved: (v) => _data.priceOfAppointment = v ?? '',
            keyboardType: TextInputType.number,
            initialValue: _data.priceOfAppointment,
          ),
          const SizedBox(height: 18),
          _modernTextField(
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password required.';
              if (v.length < 6 || v.length > 12) {
                return 'The password must be between 6 and 12 characters.';
              }
              return null;
            },
            onSaved: (v) => _data.password = v ?? '',
            initialValue: _data.password,
          ),
          const SizedBox(height: 18),
          // Gender Dropdown
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: InputDecoration(
              labelText: 'Gender',
              prefixIcon: const Icon(Icons.wc, color: Color(0xFF0A2F5E)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: const Color(0xFF0A2F5E).withOpacity(0.1),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 16,
              ),
            ),
            items:
                ['Male', 'Female', 'Other']
                    .map(
                      (gender) =>
                          DropdownMenuItem(value: gender, child: Text(gender)),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                _gender = value;
              });
            },
          ),
          const SizedBox(height: 18),
          // Date of Birth Picker
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _dateOfBirth = picked;
                });
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: const Icon(Icons.cake, color: Color(0xFF0A2F5E)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF0A2F5E).withOpacity(0.1),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 16,
                  ),
                ),
                controller: TextEditingController(
                  text:
                      _dateOfBirth == null
                          ? ''
                          : '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}',
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A2F5E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
              ),
              onPressed: _nextStep,
              child: const Text(
                'Next',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernTextField({
    required String label,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    TextInputType? keyboardType,
    String? initialValue,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0A2F5E)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: const Color(0xFF0A2F5E).withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      ),
      obscureText: obscureText,
      validator: validator,
      onSaved: onSaved,
      keyboardType: keyboardType,
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Experience & Qualification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[900],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us about your legal expertise',
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          Text(
            'Select Specializations',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.indigo[900],
            ),
          ),
          const SizedBox(height: 12),
          _isLoadingSpecializations
              ? const Center(child: CircularProgressIndicator())
              : MultiSelectDialogField<Specialization>(
                items:
                    _specializations
                        .map(
                          (spec) =>
                              MultiSelectItem<Specialization>(spec, spec.name),
                        )
                        .toList(),
                title: const Text("Select Specializations"),
                selectedColor: Colors.indigo,
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  border: Border.all(color: Colors.indigo[100]!, width: 2),
                ),
                buttonIcon: Icon(Icons.list, color: Colors.indigo[900]),
                buttonText: Text(
                  _data.selectedCaseIds.isEmpty
                      ? "Tap to select specializations"
                      : _specializations
                          .where((s) => _data.selectedCaseIds.contains(s.id))
                          .map((s) => s.name)
                          .join(', '),
                  style: TextStyle(
                    color:
                        _data.selectedCaseIds.isEmpty
                            ? Colors.grey
                            : Colors.indigo[900],
                    fontSize: 16,
                  ),
                ),
                onConfirm: (results) {
                  setState(() {
                    _data.selectedCaseIds = results.map((e) => e.id).toList();
                  });
                },
                chipDisplay: MultiSelectChipDisplay.none(),
                initialValue:
                    _specializations
                        .where((s) => _data.selectedCaseIds.contains(s.id))
                        .toList(),
                searchable: true,
                listType: MultiSelectListType.LIST,
                validator: (values) {
                  if (values == null || values.isEmpty) {
                    return "You must choose at least one specialization.";
                  }
                  if (values.length > 5) {
                    return "You can choose up to 5 specializations only.";
                  }
                  return null;
                },
              ),
          const SizedBox(height: 32),
          Text(
            'Update Your Qualification',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.indigo[900],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _pickImage(false),
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                border: Border.all(color: Colors.indigo[100]!),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.shade50,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child:
                  _data.barAssociationImage == null
                      ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 40,
                            color: Colors.indigo,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add Your Certificate',
                            style: TextStyle(color: Colors.indigo),
                          ),
                        ],
                      )
                      : const Center(
                        child: Text(
                          'Certificate Selected',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
            ),
          ),
          if (_data.barAssociationImage == null)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(
                'Union ID photo required.',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
              ),
              onPressed: () async {
                if (_formKey2.currentState!.validate()) {
                  _formKey2.currentState!.save();
                  final result = await _submitWithResult();
                  if (result == true && mounted) {
                    Navigator.pushReplacementNamed(context, '/lawyer_client');
                  }
                }
              },
              child: const Text(
                'Submit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
