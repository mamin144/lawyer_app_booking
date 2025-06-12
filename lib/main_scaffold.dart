import 'package:flutter/material.dart';
import 'Homepage.dart';
import 'routes.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 1; // Home tab selected by default (now in middle)

  final List<Widget> _pages = [
    const ProfilePage(),
    const HomePage(),
    const AppointmentPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color(0xFF3E64FF),
            unselectedItemColor: Colors.grey[400],
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.2,
            ),
            items: [
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        _selectedIndex == 0
                            ? const Color(0xFF3E64FF).withOpacity(0.1)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow:
                        _selectedIndex == 0
                            ? [
                              BoxShadow(
                                color: const Color(0xFF3E64FF).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Icon(
                    _selectedIndex == 0 ? Icons.person : Icons.person_outline,
                    size: 22,
                  ),
                ),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        _selectedIndex == 1
                            ? const Color(0xFF3E64FF).withOpacity(0.1)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow:
                        _selectedIndex == 1
                            ? [
                              BoxShadow(
                                color: const Color(0xFF3E64FF).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Icon(
                    _selectedIndex == 1 ? Icons.home : Icons.home_outlined,
                    size: 22,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        _selectedIndex == 2
                            ? const Color(0xFF3E64FF).withOpacity(0.1)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow:
                        _selectedIndex == 2
                            ? [
                              BoxShadow(
                                color: const Color(0xFF3E64FF).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: Icon(
                    _selectedIndex == 2
                        ? Icons.calendar_today
                        : Icons.calendar_today_outlined,
                    size: 22,
                  ),
                ),
                label: 'Appointment',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
