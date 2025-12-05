import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/screens/home/home_screen.dart';
import 'package:trael_app_abdelhamid/screens/profile/profile_screen.dart';
import 'package:trael_app_abdelhamid/screens/trip/trip_screen.dart';
import 'package:trael_app_abdelhamid/screens/chat/chat_screen.dart';

class TabScreen extends StatefulWidget {
  final int initialIndex;
  const TabScreen({super.key, this.initialIndex = 0});

  @override
  State<StatefulWidget> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  late int currentIndex;

  final List<Widget> screens = [
    HomeScreen(),
    TripScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  Widget bottomNavigationBar() {
    return KBottomNavBar(
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      items: [
        BottomNavItem(
          icon: AppAssets.homeTab,
          isSelected: currentIndex == 0,
          label: "Home",
        ),
        BottomNavItem(
          icon: AppAssets.tripTab,
          isSelected: currentIndex == 1,
          label: "Trip",
        ),
        BottomNavItem(
          icon: AppAssets.chatTab,
          isSelected: currentIndex == 2,
          label: "Chat",
        ),
        BottomNavItem(
          icon: AppAssets.profileTab,
          isSelected: currentIndex == 3,
          label: "Profile",
        ),
      ],
    );
  }
}

class KBottomNavBar extends StatelessWidget {
  const KBottomNavBar({
    super.key,
    required this.items,
    this.onTap,
    this.currentIndex = 0,
  });

  final List<BottomNavItem> items;
  final ValueChanged<int>? onTap;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
        ),
      ),
      height: 75.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < items.length; i++)
            GestureDetector(onTap: () => onTap?.call(i), child: items[i]),
        ],
      ),
    );
  }
}

class BottomNavItem extends StatelessWidget {
  const BottomNavItem({
    Key? key,
    required this.icon,
    this.label,
    this.isSelected = false,
  }) : super(key: key);

  final String icon;
  final String? label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected ? AppColors.secondary : AppColors.tabcolor;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            width: 32.w,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label!,
                style: textStyle12semiBold.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
