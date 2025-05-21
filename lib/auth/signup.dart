import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../main_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lawyer_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://mohamek-legel.runasp.net/api/Account/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      // print('Login response status: ${response.statusCode}');
      // print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract token from nested structure
        if (data['token'] != null && data['token']['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']['token']);
          // Navigate to home screen on successful login
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainScaffold()),
            );
          }
        } else {
          setState(() {
            _errorMessage = 'Login successful but no token received';
          });
        }
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage = errorData['message'] ?? 'Invalid email or password';
        });
      }
    } catch (e) {
      print('Login error: $e');
      setState(() {
        _errorMessage = 'Network error. Please check your connection.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back, color: Colors.indigo[900]),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      // ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7F8FA), Color(0xFFE3E6ED), Color(0xFFF7F8FA)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 36,
                    ),
                    child: Column(
                      // mainAxisSize: MainAxisSize.max,
                      children: [
                        // Logo
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: Image.asset(
                            'lib/assets/23f87c5e73ae7acd01687cec25693b1766d78c51.png',
                            height: 220,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.gavel,
                                size: 70,
                                color: Colors.indigo,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 0),
                        // Title
                        Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[900],
                            letterSpacing: 1.2,
                          ),
                        ),

                        // Sign Up link
                        const SizedBox(height: 32),
                        // Error message
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        // Email
                        TextFormField(
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Colors.indigo,
                                width: 0.7,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F6FD),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 18,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        // Password
                        TextFormField(
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(
                                color: Colors.indigo,
                                width: 0.7,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F6FD),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 18,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Remember me and Forgot Password
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (val) {
                                setState(() {
                                  _rememberMe = val ?? false;
                                });
                              },
                            ),
                            const Text(
                              'Remember me',
                              style: TextStyle(fontSize: 15),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                // TODO: Implement forgot password
                                Navigator.pushNamed(
                                  context,
                                  '/forgot-password',
                                );
                              },
                              child: Text(
                                'Forgot Password ?',
                                style: TextStyle(
                                  color: Colors.indigo[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        // Log In button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[900],
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 6,
                              shadowColor: Colors.indigo[200],
                            ),
                            onPressed: _isLoading ? null : _login,
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : const Text(
                                      'Log In',
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 26),
                        // Divider with Or
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 1.2,
                                color: Colors.indigo[100],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                              ),
                              child: Text(
                                'Or',
                                style: TextStyle(
                                  color: Colors.indigo[300],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 1.2,
                                color: Colors.indigo[100],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const LawyerConsultationApp(),
                                  ),
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Colors.indigo[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 26),
                        // // Google button
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: ElevatedButton(
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: Colors.white,
                        //       elevation: 2,
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //         side: BorderSide(color: Color(0xFFE0E0E0)),
                        //       ),
                        //       padding: EdgeInsets.symmetric(vertical: 14),
                        //     ),
                        //     onPressed: () {
                        //       // TODO: Implement Google login
                        //     },
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         Image.asset(
                        //           'assets/images/google_logo.png',
                        //           height: 22,
                        //           width: 70,
                        //           errorBuilder: (context, error, stackTrace) {
                        //             return Icon(Icons.g_mobiledata, size: 22);
                        //           },
                        //         ),
                        //         SizedBox(width: 12),
                        //         Text(
                        //           'Continue with Google',
                        //           style: TextStyle(
                        //             color: Colors.black87,
                        //             fontWeight: FontWeight.w600,
                        //             fontSize: 16,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(height: 12),
                        // // Facebook button
                        // SizedBox(
                        //   width: double.infinity,
                        //   child: ElevatedButton(
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: Colors.white,
                        //       elevation: 2,
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //         side: BorderSide(color: Color(0xFFE0E0E0)),
                        //       ),
                        //       padding: EdgeInsets.symmetric(vertical: 14),
                        //     ),
                        //     onPressed: () {
                        //       // TODO: Implement Facebook login
                        //     },
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         Image.asset(
                        //           'assets/images/facebook_logo.png',
                        //           height: 22,
                        //           width: 22,
                        //           errorBuilder: (context, error, stackTrace) {
                        //             return Icon(Icons.facebook, size: 22);
                        //           },
                        //         ),
                        //         SizedBox(width: 12),
                        //         Text(
                        //           'Continue with Facebook',
                        //           style: TextStyle(
                        //             color: Color(0xFF1877F3),
                        //             fontWeight: FontWeight.w600,
                        //             fontSize: 16,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
