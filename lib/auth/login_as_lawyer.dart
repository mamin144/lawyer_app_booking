import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class LawyerRegistrationScreen extends StatefulWidget {
  const LawyerRegistrationScreen({super.key});

  @override
  _LawyerRegistrationScreenState createState() =>
      _LawyerRegistrationScreenState();
}

class _LawyerRegistrationScreenState extends State<LawyerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _lastNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _ssnController = TextEditingController();
  final _priceOfAppointmentController = TextEditingController();
  final _selectedCasesController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _barAssociationImage;
  File? _profilePicture;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // New variables for improved UX
  int _currentStep = 0;
  final List<String> _stepTitles = [
    'Personal Info',
    'Professional Details',
    'Credentials',
  ];

  Future<void> _pickImage(bool isBarAssociation) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isBarAssociation) {
          _barAssociationImage = File(image.path);
        } else {
          _profilePicture = File(image.path);
        }
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final formData = FormData.fromMap({
        'LastName': _lastNameController.text,
        'DisplayName': _displayNameController.text,
        'Email': _emailController.text,
        'PhoneNumber': _phoneNumberController.text,
        'Address': _addressController.text,
        'SSN': _ssnController.text,
        'PriceOfAppointment': _priceOfAppointmentController.text,
        'SelectedCases': _selectedCasesController.text,
        'Password': _passwordController.text,
        if (_barAssociationImage != null)
          'BarAssociationImage': await MultipartFile.fromFile(
            _barAssociationImage!.path,
          ),
        if (_profilePicture != null)
          'Picture': await MultipartFile.fromFile(_profilePicture!.path),
      });

      final response = await Dio().post(
        'http://mohamekapp.runasp.net/api/Account/register-as-lawyer',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    bool readOnly = false,
    String? helperText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboardType,
        readOnly: readOnly,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          helperText: helperText,
          helperStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF0A2F5E)),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey[600],
                    ),
                    onPressed:
                        () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF0A2F5E), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
        ),
        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
      ),
    );
  }

  Widget _buildImagePicker({
    required String label,
    required File? image,
    required VoidCallback onTap,
    String? helperText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                helperText,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            )
          else
            const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
              child:
                  image != null
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(image, fit: BoxFit.cover),
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A2F5E).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.cloud_upload,
                              size: 40,
                              color: Color(0xFF0A2F5E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Upload Image',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to select',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return Column(
          children: [
            _buildInputField(
              controller: _lastNameController,
              label: 'Last Name',
              icon: Icons.person_outline,
              helperText: 'Your family name',
            ),
            _buildInputField(
              controller: _displayNameController,
              label: 'Display Name',
              icon: Icons.badge_outlined,
              helperText: 'Name displayed to clients',
            ),
            _buildInputField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              helperText: 'Your professional email',
            ),
            _buildInputField(
              controller: _phoneNumberController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            _buildImagePicker(
              label: 'Profile Picture',
              image: _profilePicture,
              onTap: () => _pickImage(false),
              helperText: 'A professional photo of yourself',
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            _buildInputField(
              controller: _addressController,
              label: 'Office Address',
              icon: Icons.location_on_outlined,
              helperText: 'Your business address',
            ),
            _buildInputField(
              controller: _priceOfAppointmentController,
              label: 'Consultation Fee',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              helperText: 'Appointment fee in USD',
            ),
            _buildInputField(
              controller: _selectedCasesController,
              label: 'Practice Areas',
              icon: Icons.cases_outlined,
              helperText: 'Areas of law you specialize in',
            ),
            _buildImagePicker(
              label: 'Bar Association Certificate',
              image: _barAssociationImage,
              onTap: () => _pickImage(true),
              helperText: 'Upload your license/certificate',
            ),
          ],
        );
      case 2:
        return Column(
          children: [
            _buildInputField(
              controller: _ssnController,
              label: 'SSN/Tax ID',
              icon: Icons.credit_card_outlined,
              helperText: 'For verification purposes only',
            ),
            _buildInputField(
              controller: _passwordController,
              label: 'Account Password',
              icon: Icons.lock_outline,
              isPassword: true,
              helperText: 'Minimum 8 characters with at least 1 number',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.security, color: const Color(0xFF0A2F5E)),
                      const SizedBox(width: 12),
                      const Text(
                        'Privacy & Security',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your information is securely encrypted and only used for verification purposes. We follow strict privacy guidelines to protect your data.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        children: List.generate(
          _stepTitles.length,
          (index) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  // Circle indicator
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          index <= _currentStep
                              ? const Color(0xFF0A2F5E)
                              : Colors.grey[300],
                    ),
                    child: Center(
                      child:
                          index < _currentStep
                              ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                              : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color:
                                      index == _currentStep
                                          ? Colors.white
                                          : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Step title
                  Text(
                    _stepTitles[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          index == _currentStep
                              ? FontWeight.bold
                              : FontWeight.normal,
                      color:
                          index <= _currentStep
                              ? Colors.black87
                              : Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0A2F5E),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            )
          else
            const SizedBox(width: 100),
          ElevatedButton(
            onPressed:
                _isLoading
                    ? null
                    : () {
                      if (_currentStep < _stepTitles.length - 1) {
                        setState(() {
                          _currentStep++;
                        });
                      } else {
                        _register();
                      }
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A2F5E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentStep < _stepTitles.length - 1
                              ? 'Continue'
                              : 'Register',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        // if (_currentStep < _stepTitles.length - 1)
                        //   const Icon(Icons.arrow_forward, size: 16, marginLeft: 8),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Lawyer Registration',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A2F5E),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with blue background
            Container(
              width: double.infinity,
              color: const Color(0xFF0A2F5E),
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(Icons.gavel, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Join Our Network of Legal Professionals',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete the form to start connecting with clients',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Rounded content card
            Container(
              transform: Matrix4.translationValues(0, -24, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStepIndicator(),
                    _buildStepContent(_currentStep),
                    _buildNavButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _ssnController.dispose();
    _priceOfAppointmentController.dispose();
    _selectedCasesController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
