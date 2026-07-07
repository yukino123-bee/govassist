import 'package:flutter/material.dart';
import '../core/translations.dart';
import 'home/home_screen.dart';
import 'eligibility/eligibility_home_screen.dart';
import 'inquiry/inquiry_home_screen.dart';
import 'profile/profile_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import '../core/user_session.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const EligibilityHomeScreen(),
    const InquiryHomeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isAdmin = UserSession().currentUser?['is_admin'] == 1 || UserSession().currentUser?['is_admin'] == true;

    if (isAdmin) {
      return const AdminDashboardScreen();
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // Use fixed for 4+ items
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: 'Home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment_outlined),
            activeIcon: const Icon(Icons.assignment),
            label: 'Eligibility'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.help_outline),
            activeIcon: const Icon(Icons.help),
            label: 'Inquiry'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: 'Profile'.tr(),
          ),
        ],
      ),
    );
  }
}
