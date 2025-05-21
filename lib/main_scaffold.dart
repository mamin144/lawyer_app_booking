import 'package:flutter/material.dart';
import 'Homepage.dart';
import 'routes.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex =
      3; // Home tab selected by default (now index 3 instead of 4)

  final List<Widget> _pages = [
    const ProfilePage(),
    const ChatPage(),
    const AppointmentPage(),
    const HomePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
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
                icon: Icon(
                  _selectedIndex == 3 ? Icons.home : Icons.home_outlined,
                ),
                label: 'Home',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
