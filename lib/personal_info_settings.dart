import 'package:flutter/material.dart';
import 'services/profile_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PersonalInfoSettingsPage extends StatefulWidget {
  const PersonalInfoSettingsPage({super.key});

  @override
  _PersonalInfoSettingsPageState createState() =>
      _PersonalInfoSettingsPageState();
}

class _PersonalInfoSettingsPageState extends State<PersonalInfoSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _officeLocationController =
      TextEditingController();
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _userType;
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _lawyerDescriptionData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await ProfileService.initialize();
      _userType = await _profileService.getCurrentUserRole();
      _profileData = await _profileService.getProfile();

      // If user is a lawyer, try to get lawyer description
      if (_userType == 'lawyer') {
        try {
          _lawyerDescriptionData = await _profileService.getLawyerDescription();
        } catch (e) {
          print('Error loading lawyer description: $e');
          // Continue even if description can't be loaded
        }
      }

      // Set initial values from profile data or lawyer description if available
      _bioController.text =
          _lawyerDescriptionData?['bio'] ?? _profileData?['bio'] ?? '';
      _experienceController.text =
          (_lawyerDescriptionData?['yearsOfExperience'] ??
                  _profileData?['yearsOfExperience'] ??
                  0)
              .toString();
      _educationController.text = _lawyerDescriptionData?['education'] ??
          _profileData?['education'] ??
          '';
      _officeLocationController.text =
          _lawyerDescriptionData?['officeLocation'] ??
              _profileData?['officeLocation'] ??
              '';
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfileInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        _isSaving = true;
        _error = null;
      });

      bool success;

      // Create the data for the API
      final Map<String, dynamic> descriptionData = {
        'bio': _bioController.text,
        'yearsOfExperience': int.tryParse(_experienceController.text) ?? 0,
        'education': _educationController.text,
        'officeLocation': _officeLocationController.text,
      };

      if (_userType == 'lawyer') {
        // Use the lawyer description API
        success =
            await _profileService.createLawyerDescription(descriptionData);
      } else {
        // Fall back to regular profile update for clients
        final Map<String, dynamic> payload = {
          ..._profileData ?? {},
          ...descriptionData,
        };
        success = await _profileService.updateProfile(payload);
      }

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ المعلومات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh data
        _loadData();
      } else {
        throw Exception('فشل تحديث المعلومات');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $_error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _officeLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'السيرة الذاتية',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1F41BB),
                ),
              )
            : _error != null && _profileData == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'حدث خطأ: $_error',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F41BB),
                          ),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Info Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF1F41BB),
                                  const Color(0xFF1F41BB).withOpacity(0.85)
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF1F41BB).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'السيرة الذاتية',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _userType == 'lawyer'
                                      ? 'أضف معلومات سيرتك الذاتية لتساعد العملاء على التعرف عليك بشكل أفضل'
                                      : 'أضف معلومات سيرتك الذاتية لتحسين تجربتك على التطبيق',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Bio
                          _buildFormSection(
                            title: 'نبذة عني',
                            icon: Icons.person_outline,
                            child: TextFormField(
                              controller: _bioController,
                              decoration: _inputDecoration(
                                hintText: 'أدخل نبذة مختصرة عن نفسك',
                                icon: Icons.info_outline,
                              ),
                              maxLines: 5,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال نبذة عن نفسك';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Years of Experience
                          _buildFormSection(
                            title: 'سنوات الخبرة',
                            icon: Icons.work_outline,
                            child: TextFormField(
                              controller: _experienceController,
                              decoration: _inputDecoration(
                                hintText: 'أدخل عدد سنوات الخبرة',
                                icon: Icons.calendar_today_outlined,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال سنوات الخبرة';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'الرجاء إدخال رقم صحيح';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Education
                          _buildFormSection(
                            title: 'التعليم',
                            icon: Icons.school_outlined,
                            child: TextFormField(
                              controller: _educationController,
                              decoration: _inputDecoration(
                                hintText: 'أدخل معلومات التعليم والشهادات',
                                icon: Icons.school_outlined,
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال معلومات التعليم';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Office Location
                          _buildFormSection(
                            title: 'موقع المكتب',
                            icon: Icons.location_on_outlined,
                            child: TextFormField(
                              controller: _officeLocationController,
                              decoration: _inputDecoration(
                                hintText: 'أدخل عنوان المكتب',
                                icon: Icons.location_on_outlined,
                              ),
                              maxLines: 2,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال موقع المكتب';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Save Button
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveProfileInfo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1F41BB),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'حفظ المعلومات',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1F41BB), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String hintText, required IconData icon}) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1F41BB), width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade500, width: 1.5),
      ),
    );
  }
}
