import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LawyerSignupData {
  String fullName = '';
  String displayName = '';
  String email = '';
  String phoneNumber = '';
  String ssn = '';
  String priceOfAppointment = '';
  String password = '';
  String recaptchaToken = '';
  List<int> selectedCaseIds = [];
  File? barAssociationImage;
  File? picture;
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

  final List<Map<String, dynamic>> _caseOptions = [
    {'id': 1, 'name': 'Family Law'},
    {'id': 2, 'name': 'Business Law'},
    {'id': 3, 'name': 'Criminal Law'},
    {'id': 4, 'name': 'Property Law'},
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

  void _toggleCase(String caseName) {
    setState(() {
      if (_data.selectedCaseIds.contains(int.parse(caseName))) {
        _data.selectedCaseIds.remove(int.parse(caseName));
      } else {
        _data.selectedCaseIds.add(int.parse(caseName));
      }
    });
  }

  Future<void> _testApi() async {
    try {
      print('Testing API endpoint...');
      final testResponse = await http
          .get(
            Uri.parse(
              'http://mohamek-legel.runasp.net/api/Account/register-as-lawyer',
            ),
          )
          .timeout(Duration(seconds: 10));

      print('API Test Response Status: ${testResponse.statusCode}');
      print('API Test Response Headers: ${testResponse.headers}');
      print('API Test Response Body: ${testResponse.body}');

      if (testResponse.statusCode == 405) {
        print('API endpoint exists but method not allowed (expected for GET)');
        return;
      }

      throw Exception('Unexpected response: ${testResponse.statusCode}');
    } catch (e) {
      print('API Test Error: $e');
      rethrow;
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      // Validate and log all data before submission
      print('\n=== Validating Registration Data ===');
      print('Full Name: ${_data.fullName} (${_data.fullName.length} chars)');
      print(
        'Display Name: ${_data.displayName} (${_data.displayName.length} chars)',
      );
      print('Email: ${_data.email}');
      print('Phone: ${_data.phoneNumber}');
      print('SSN: ${_data.ssn}');
      print('Price: ${_data.priceOfAppointment}');
      print('Selected Cases: ${_data.selectedCaseIds.join(', ')}');
      print('Has Profile Picture: ${_data.picture != null}');
      print('Has Bar Association Image: ${_data.barAssociationImage != null}');
      print('==================================\n');

      // Validate required fields
      if (_data.fullName.isEmpty) throw Exception('Full Name is required');
      if (_data.displayName.isEmpty)
        throw Exception('Display Name is required');
      if (_data.email.isEmpty) throw Exception('Email is required');
      if (_data.phoneNumber.isEmpty)
        throw Exception('Phone Number is required');
      if (_data.ssn.isEmpty) throw Exception('SSN is required');
      if (_data.priceOfAppointment.isEmpty)
        throw Exception('Price is required');
      if (_data.password.isEmpty) throw Exception('Password is required');
      if (_data.recaptchaToken.isEmpty)
        throw Exception('Recaptcha Token is required');
      if (_data.selectedCaseIds.isEmpty)
        throw Exception('At least one case type must be selected');
      if (_data.picture == null) throw Exception('Profile picture is required');
      if (_data.barAssociationImage == null)
        throw Exception('Bar association image is required');

      // Validate email format
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(_data.email)) {
        throw Exception('Please enter a valid email address');
      }

      // Validate phone number format (basic validation)
      final phoneRegex = RegExp(r'^\+?[0-9]{10,}$');
      if (!phoneRegex.hasMatch(
        _data.phoneNumber.replaceAll(RegExp(r'[^0-9+]'), ''),
      )) {
        throw Exception('Please enter a valid phone number');
      }

      // Validate price is a positive number
      final price = double.tryParse(_data.priceOfAppointment);
      if (price == null || price <= 0) {
        throw Exception('Price must be a positive number');
      }

      var uri = Uri.parse(
        'http://mohamek-legel.runasp.net/api/Account/register-as-lawyer',
      );
      var request = http.MultipartRequest('POST', uri);

      // Add all required fields
      request.fields['FullName'] = _data.fullName;
      request.fields['DisplayName'] = _data.displayName;
      request.fields['Email'] = _data.email.trim().toLowerCase();
      request.fields['PhoneNumber'] = _data.phoneNumber;
      request.fields['SSN'] = _data.ssn;
      request.fields['PriceOfAppointment'] = _data.priceOfAppointment;
      request.fields['Password'] = _data.password;
      request.fields['RecaptchaToken'] = _data.recaptchaToken;
      request.fields['SelectedCases'] = jsonEncode(
        _data.selectedCaseIds
            .map((e) => _caseOptions.firstWhere((c) => c['id'] == e)['id'])
            .toList(),
      );

      // Add images
      if (_data.picture != null) {
        print('Adding profile picture: ${_data.picture!.path}');
        request.files.add(
          await http.MultipartFile.fromPath('Picture', _data.picture!.path),
        );
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
      }

      // Log the complete request
      print('\n=== Sending Request ===');
      print('URL: ${uri.toString()}');
      print('Method: ${request.method}');
      print('Headers: ${request.headers}');
      print('Fields: ${request.fields}');
      print('Files: ${request.files.length}');
      print('========================\n');

      // Add timeout to the request
      var streamedResponse = await request.send().timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutError('Request timed out after 30 seconds');
        },
      );

      var response = await http.Response.fromStream(streamedResponse);

      setState(() => _isLoading = false);

      // Log the response
      print('\n=== Received Response ===');
      print('Status Code: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');
      print('========================\n');

      if (response.statusCode == 200 || response.statusCode == 201) {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text('Success'),
                content: Text('Registration successful!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      } else {
        String errorMsg = 'Registration failed.';
        try {
          final decoded = json.decode(response.body);
          print('Error response: ${response.body}');
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
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text('Error'),
                content: Text('Status Code: ${response.statusCode}\n$errorMsg'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      }
    } on TimeoutError catch (e) {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Error'),
              content: Text(
                'The request timed out. Please check your internet connection and try again.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
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
              title: Text('Error'),
              content: Text('An error occurred: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Color(0xFFF7F8FA),
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
                      duration: Duration(milliseconds: 400),
                      transitionBuilder:
                          (child, anim) => SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(_step == 1 ? 1 : -1, 0),
                              end: Offset(0, 0),
                            ).animate(anim),
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                      child: Container(
                        key: ValueKey(_step),
                        constraints: BoxConstraints(maxWidth: 400),
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
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color: Colors.indigo[900],
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
          duration: Duration(milliseconds: 300),
          width: isActive ? 36 : 28,
          height: isActive ? 36 : 28,
          decoration: BoxDecoration(
            color: isActive ? Colors.indigo[900] : Colors.grey[300],
            shape: BoxShape.circle,
            boxShadow:
                isActive
                    ? [
                      BoxShadow(
                        color: Colors.indigo.shade100,
                        blurRadius: 8,
                        offset: Offset(0, 2),
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
        SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.indigo[900] : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _progressLine() {
    return Container(
      width: 40,
      height: 2,
      color: Colors.indigo[900],
      margin: EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to App',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[900],
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Help Us Understand Your Legal Needs',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          SizedBox(height: 28),
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundColor: Colors.indigo[50],
                  backgroundImage:
                      _data.picture != null ? FileImage(_data.picture!) : null,
                  child:
                      _data.picture == null
                          ? Icon(
                            Icons.person,
                            size: 54,
                            color: Colors.indigo[200],
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
                        color: Colors.indigo[900],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.indigo.shade100,
                            blurRadius: 8,
                            offset: Offset(0, 2),
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
          SizedBox(height: 32),
          _modernTextField(
            label: 'Full Name',
            icon: Icons.person_outline,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            onSaved: (v) => _data.fullName = v ?? '',
            initialValue: _data.fullName,
          ),
          SizedBox(height: 18),
          _modernTextField(
            label: 'Display Name',
            icon: Icons.badge_outlined,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            onSaved: (v) => _data.displayName = v ?? '',
            initialValue: _data.displayName,
          ),
          SizedBox(height: 18),
          _modernTextField(
            label: 'Email address',
            icon: Icons.email_outlined,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            onSaved: (v) => _data.email = v ?? '',
            keyboardType: TextInputType.emailAddress,
            initialValue: _data.email,
          ),
          SizedBox(height: 18),
          _modernTextField(
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            onSaved: (v) => _data.phoneNumber = v ?? '',
            keyboardType: TextInputType.phone,
            initialValue: _data.phoneNumber,
          ),
          SizedBox(height: 18),
          _modernTextField(
            label: 'SSN',
            icon: Icons.credit_card,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            onSaved: (v) => _data.ssn = v ?? '',
            keyboardType: TextInputType.number,
            initialValue: _data.ssn,
          ),
          SizedBox(height: 18),
          _modernTextField(
            label: 'Price Of Appointment',
            icon: Icons.attach_money,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            onSaved: (v) => _data.priceOfAppointment = v ?? '',
            keyboardType: TextInputType.number,
            initialValue: _data.priceOfAppointment,
          ),
          SizedBox(height: 18),
          _modernTextField(
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            onSaved: (v) => _data.password = v ?? '',
            initialValue: _data.password,
          ),
          SizedBox(height: 18),
          _modernTextField(
            label: 'Recaptcha Token',
            icon: Icons.verified_user,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            onSaved: (v) => _data.recaptchaToken = v ?? '',
            initialValue: _data.recaptchaToken,
          ),
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
              ),
              onPressed: _nextStep,
              child: Text(
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
        prefixIcon: Icon(icon, color: Colors.indigo[900]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.indigo[50],
        contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
          SizedBox(height: 8),
          Text(
            'Tell us about your legal expertise',
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
          SizedBox(height: 24),
          Text(
            'Select experience',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.indigo[900],
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                _caseOptions
                    .map(
                      (c) => FilterChip(
                        label: Text(
                          c['name'],
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        selected: _data.selectedCaseIds.contains(c['id']),
                        onSelected: (_) => _toggleCase(c['id'].toString()),
                        selectedColor: Colors.indigo[900],
                        checkmarkColor: Colors.white,
                        backgroundColor: Colors.indigo[50],
                        labelStyle: TextStyle(
                          color:
                              _data.selectedCaseIds.contains(c['id'])
                                  ? Colors.white
                                  : Colors.indigo[900],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation:
                            _data.selectedCaseIds.contains(c['id']) ? 4 : 0,
                        showCheckmark: true,
                      ),
                    )
                    .toList(),
          ),
          SizedBox(height: 32),
          Text(
            'Update Your Qualification',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.indigo[900],
            ),
          ),
          SizedBox(height: 12),
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
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child:
                  _data.barAssociationImage == null
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
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
                      : Center(
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
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
              ),
              onPressed: _nextStep,
              child: Text(
                'submit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
