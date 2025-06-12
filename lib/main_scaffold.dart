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
      bottomNavigationBar: Material(
        color: Colors.white, // Background color for the modern design
        shadowColor: Colors.black.withOpacity(0.1),
        elevation: 20, // Increased elevation for a more pronounced shadow
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30), // Curved top-left corner
          topRight: Radius.circular(30), // Curved top-right corner
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).padding.bottom, // Account for safe area
          ), // Only apply bottom padding for safe area
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: const Color(0xFF3E64FF),
            unselectedItemColor: Colors.grey[400],
            type: BottomNavigationBarType.fixed,
            backgroundColor:
                Colors.transparent, // Make transparent to show Material's color
            elevation: 0, // No internal elevation as Material handles it
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1.0, // Keep compact for height
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.0, // Keep compact for height
            ),
            items: [
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8), // Adjusted padding
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0
                        ? const Color(0xFF3E64FF).withOpacity(0.1)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: _selectedIndex == 0
                        ? [
                            BoxShadow(
                              color: const Color(0xFF3E64FF).withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _selectedIndex == 0 ? Icons.person : Icons.person_outline,
                    size: 26, // Slightly reduced icon size for better fit
                  ),
                ),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(
                      milliseconds:
                          300), // Slightly longer duration for prominence
                  padding: const EdgeInsets.all(8), // Keep padding consistent
                  decoration: BoxDecoration(
                    color: _selectedIndex == 1
                        ? const Color(0xFF3E64FF)
                            .withOpacity(0.9) // More vibrant color
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: _selectedIndex == 1
                        ? [
                            BoxShadow(
                              color: const Color(0xFF3E64FF)
                                  .withOpacity(0.4), // More pronounced shadow
                              blurRadius: 15,
                              offset: const Offset(0, 4), // Larger offset
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _selectedIndex == 1 ? Icons.home : Icons.home_outlined,
                    size: 32, // Larger icon size for prominence
                    color: _selectedIndex == 1
                        ? Colors.white
                        : Colors.grey[400], // White icon when selected
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8), // Adjusted padding
                  decoration: BoxDecoration(
                    color: _selectedIndex == 2
                        ? const Color(0xFF3E64FF).withOpacity(0.1)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: _selectedIndex == 2
                        ? [
                            BoxShadow(
                              color: const Color(0xFF3E64FF).withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _selectedIndex == 2
                        ? Icons.calendar_today
                        : Icons.calendar_today_outlined,
                    size: 26, // Slightly reduced icon size for better fit
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
