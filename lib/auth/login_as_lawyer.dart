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
  List<String> selectedCases = [];
  File? barAssociationImage;
  File? picture;
}

class LawyerSignupScreen extends StatefulWidget {
  const LawyerSignupScreen({Key? key}) : super(key: key);

  @override
  State<LawyerSignupScreen> createState() => _LawyerSignupScreenState();
}

class _LawyerSignupScreenState extends State<LawyerSignupScreen> {
  int _step = 1;
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final LawyerSignupData _data = LawyerSignupData();
  bool _isLoading = false;

  final List<String> _caseOptions = [
    'Family Law',
    'Business Law',
    'Criminal Law',
    'Property Law',
  ];
  final List<String> _qualifications = ['LLB', 'LLM', 'JD', 'PhD Law', 'Other'];

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

  void _toggleCase(String caseName) {
    setState(() {
      if (_data.selectedCases.contains(caseName)) {
        _data.selectedCases.remove(caseName);
      } else {
        _data.selectedCases.add(caseName);
      }
    });
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      var uri = Uri.parse(
        'http://mohamek-legel.runasp.net/api/Account/register-as-lawyer',
      );
      var request = http.MultipartRequest('POST', uri);
      request.fields['FullName'] = _data.fullName;
      request.fields['DisplayName'] = _data.displayName;
      request.fields['Email'] = _data.email;
      request.fields['PhoneNumber'] = _data.phoneNumber;
      request.fields['SSN'] = _data.ssn;
      request.fields['PriceOfAppointment'] = _data.priceOfAppointment;
      request.fields['Password'] = _data.password;
      request.fields['RecaptchaToken'] = _data.recaptchaToken;
      // SelectedCases as comma separated string
      request.fields['SelectedCases'] = _data.selectedCases.join(',');
      // Add images if present
      if (_data.picture != null) {
        request.files.add(
          await http.MultipartFile.fromPath('Picture', _data.picture!.path),
        );
      }
      if (_data.barAssociationImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'BarAssociationImage',
            _data.barAssociationImage!.path,
          ),
        );
      }
      // You can add more fields as needed (e.g., RecaptchaToken, etc.)
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      setState(() => _isLoading = false);
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
          if (decoded is Map && decoded['message'] != null) {
            errorMsg = decoded['message'];
          }
        } catch (_) {}
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text('Error'),
                content: Text(errorMsg),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Error'),
              content: Text('An error occurred: \$e'),
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
                                    onPressed: () => setState(() => _step = 1),
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
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
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
          ),
          SizedBox(height: 18),
          _modernTextField(
            label: 'Display Name',
            icon: Icons.badge_outlined,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            onSaved: (v) => _data.displayName = v ?? '',
          ),
          SizedBox(height: 18),
          _modernTextField(
            label: 'Email address',
            icon: Icons.email_outlined,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            onSaved: (v) => _data.email = v ?? '',
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 18),
          _modernTextField(
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            onSaved: (v) => _data.phoneNumber = v ?? '',
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 18),
          _modernTextField(
            label: 'SSN',
            icon: Icons.credit_card,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            onSaved: (v) => _data.ssn = v ?? '',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 18),
          _modernTextField(
            label: 'Price Of Appointment',
            icon: Icons.attach_money,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            onSaved: (v) => _data.priceOfAppointment = v ?? '',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 18),
          _modernTextField(
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: true,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            onSaved: (v) => _data.password = v ?? '',
          ),
          SizedBox(height: 18),
          _modernTextField(
            label: 'Recaptcha Token',
            icon: Icons.verified_user,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            onSaved: (v) => _data.recaptchaToken = v ?? '',
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
  }) {
    return TextFormField(
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
                          c,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        selected: _data.selectedCases.contains(c),
                        onSelected: (_) => _toggleCase(c),
                        selectedColor: Colors.indigo[900],
                        checkmarkColor: Colors.white,
                        backgroundColor: Colors.indigo[50],
                        labelStyle: TextStyle(
                          color:
                              _data.selectedCases.contains(c)
                                  ? Colors.white
                                  : Colors.indigo[900],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: _data.selectedCases.contains(c) ? 4 : 0,
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
                'Next',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
