import 'package:flutter/material.dart';
import 'package:travel_app_abdelhamid/features/auth/screens/guide_chat_screen.dart';
import 'package:travel_app_abdelhamid/features/auth/screens/guide_home_screen.dart';
import 'package:travel_app_abdelhamid/features/auth/screens/guide_profile_screen.dart';

class GuideDashboardScreen extends StatefulWidget {
  const GuideDashboardScreen({super.key});

  @override
  State<GuideDashboardScreen> createState() => _GuideDashboardScreenState();
}

class _GuideDashboardScreenState extends State<GuideDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GuideHomeScreen(),
    const GuideChatScreen(),
    const GuideProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
