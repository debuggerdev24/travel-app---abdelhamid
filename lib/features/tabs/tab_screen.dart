import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:travel_app_abdelhamid/provider/chat/chat_provider.dart';
import 'package:travel_app_abdelhamid/provider/home/home_provider.dart';
import 'package:travel_app_abdelhamid/provider/home/prayer_times_provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/features/home/home_screen.dart';
import 'package:travel_app_abdelhamid/features/profile/profile_screen.dart';
import 'package:travel_app_abdelhamid/features/trip/trip_screen.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:travel_app_abdelhamid/features/chat/chat_screen.dart';

class TabState extends ChangeNotifier {
  int _currentIndex;
  bool _showBottomNav = true;

  TabState({int initialIndex = 0}) : _currentIndex = initialIndex;

  int get currentIndex => _currentIndex;
  bool get showBottomNav => _showBottomNav;

  void setIndex(int index) {
    _currentIndex = index;
    _showBottomNav = true;
    notifyListeners();
  }

  void setShowBottomNav(bool show) {
    _showBottomNav = show;
    notifyListeners();
  }
}

class TabScreen extends StatelessWidget {
  final int initialIndex;
  const TabScreen({super.key, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TabState(initialIndex: initialIndex),
      child: const _TabScreenView(),
    );
  }
}

class _TabScreenView extends StatefulWidget {
  const _TabScreenView();

  @override
  State<StatefulWidget> createState() => _TabScreenViewState();
}

class _TabScreenViewState extends State<_TabScreenView> {
  DateTime? lastBackPressed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final index = context.read<TabState>().currentIndex;
      if (index == 1) {
        context.read<TripProvider>().fetchUpcomingBookingsForTripsTab();
      } else if (index == 2) {
        context.read<ChatProvider>().loadConversations(silent: true);
      }
    });
  }

  Widget build(BuildContext context) {
    final state = context.watch<TabState>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final now = DateTime.now();
        if (lastBackPressed == null ||
            now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
          lastBackPressed = now;
          Fluttertoast.showToast(
            msg: 'Press back again to exit',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black87,
            textColor: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          );
        } else {
          // Allow the pop to happen
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: state.currentIndex,
          children: [
            HomeScreen(),
            TripScreen(
              onShowTripDetails: (show) {
                context.read<TabState>().setShowBottomNav(!show);
              },
            ),
            ChatScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: state.showBottomNav ? bottomNavigationBar(context, state) : null,
      ),
    );
  }

  // ... rest of code unchanged
  Widget bottomNavigationBar(BuildContext context, TabState state) {
    return KBottomNavBar(
      currentIndex: state.currentIndex,
      onTap: (index) {
        context.read<TabState>().setIndex(index);
        if (index == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.read<PrayerTimesProvider>().fetchPrayerTimes();
          });
        } else if (index == 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.read<TripProvider>().fetchUpcomingBookingsForTripsTab();
          });
        } else if (index == 2) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.read<ChatProvider>().loadConversations(silent: true);
          });
        }
      },
      items: [
        BottomNavItem(
          icon: AppAssets.homeTab,
          isSelected: state.currentIndex == 0,
          label: "Home".tr(context: context),
        ),
        BottomNavItem(
          icon: AppAssets.tripTab,
          isSelected: state.currentIndex == 1,
          label: "Trip".tr(context: context),
        ),
        BottomNavItem(
          icon: AppAssets.chatTab,
          isSelected: state.currentIndex == 2,
          label: "Chat".tr(context: context),
        ),
        BottomNavItem(
          icon: AppAssets.profileTab,
          isSelected: state.currentIndex == 3,
          label: "Profile".tr(context: context),
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
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.grey.setOpacity(0.3), width: 1),
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
    super.key,
    required this.icon,
    this.label,
    this.isSelected = false,
  });

  final String icon;
  final String? label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected
        ? AppColors.secondary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

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
