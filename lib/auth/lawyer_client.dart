import 'package:flutter/material.dart';
import 'package:flutter_application_4/auth/signup.dart';
import 'package:flutter_application_4/auth/login_as_client.dart';
import 'package:flutter_application_4/auth/login_as_lawyer.dart';

void main() {
  runApp(const LawyerConsultationApp());
}

class LawyerConsultationApp extends StatelessWidget {
  const LawyerConsultationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0A2F5E),
        fontFamily: 'SF Pro Display',
      ),
      home: const ConsultationScreen(),
    );
  }
}

class ConsultationScreen extends StatelessWidget {
  const ConsultationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const NetworkImage(
                    'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?q=80&w=2070&auto=format&fit=crop',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.7),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),

          // Bottom sheet with modern design
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'More Comfortable Chat With\nthe Lawyer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: Color(0xFF0A2F5E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Book an appointment with Lawyer. Chat with\nLawyer for Free and get consultation.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildButton(
                    context,
                    'Continue as Lawyer',
                    Colors.white,
                    const Color(0xFF0A2F5E),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LawyerSignupScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildButton(
                    context,
                    'Continue as User',
                    Colors.white,
                    Colors.grey[300]!,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginAsClient(),
                        ),
                      );
                    },
                    isOutlined: true,
                  ),
                  // SizedBox(height: 12),
                  // _buildButton(
                  //   context,
                  //   'Already have an account?',
                  //   Colors.white,
                  //   Colors.grey[300]!,
                  //   () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const LoginScreen(),
                  //       ),
                  //     );
                  //   },
                  //   isOutlined: true,
                  // ),
                  const SizedBox(height: 16),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
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

  Widget _buildButton(
    BuildContext context,
    String text,
    Color textColor,
    Color backgroundColor,
    VoidCallback onPressed, {
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child:
          isOutlined
              ? OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: backgroundColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A2F5E),
                  ),
                ),
              )
              : ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
    );
  }
}

String buildDateTimeString(String year, String month, String day, String slot) {
  // slot is "06:00", "13:00", etc.
  int hour = int.parse(slot.split(':')[0]);
  String minute = slot.split(':')[1];
  String suffix = hour >= 12 ? 'PM' : 'AM';
  int hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  String hourStr = hour12.toString().padLeft(2, '0');
  return "$year-$month-$day $hourStr:$minute $suffix";
}
