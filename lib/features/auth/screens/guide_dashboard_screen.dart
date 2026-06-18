import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:travel_app_abdelhamid/features/auth/screens/guide_chat_screen.dart';
import 'package:travel_app_abdelhamid/features/auth/screens/guide_home_screen.dart';
import 'package:travel_app_abdelhamid/features/auth/screens/guide_profile_screen.dart';

import 'package:provider/provider.dart';

class GuideDashboardState extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

class GuideDashboardScreen extends StatelessWidget {
  const GuideDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GuideDashboardState(),
      child: const _GuideDashboardView(),
    );
  }
}

class _GuideDashboardView extends StatefulWidget {
  const _GuideDashboardView();

  @override
  State<_GuideDashboardView> createState() => _GuideDashboardViewState();
}

class _GuideDashboardViewState extends State<_GuideDashboardView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GuideHomeScreen(),
    const GuideChatScreen(),
    const GuideProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GuideDashboardState>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _screens[state.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: state.currentIndex,
        onTap: (index) {
          context.read<GuideDashboardState>().setIndex(index);
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: 'Home'.tr(context: context)),
          BottomNavigationBarItem(icon: const Icon(Icons.chat), label: 'Chat'.tr(context: context)),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: 'Profile'.tr(context: context)),
        ],
      ),
    );
  }
}
