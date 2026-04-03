import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/provider/trip/my_trip_provider.dart';

class PackageListScreen extends StatefulWidget {
  const PackageListScreen({super.key});

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MyTripProvider>().fetchPackingList(force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MyTripProvider>();

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 31.w, vertical: 27.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                    ),
                  ),
                  AppText(
                    text: "Packing List",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            /// List
            Expanded(
              child: Builder(
                builder: (context) {
                  if (provider.isPackingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.packingError != null) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 27.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            text: "Failed to load packing list",
                            style: textStyle14Regular.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          12.h.verticalSpace,
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context
                                  .read<MyTripProvider>()
                                  .fetchPackingList(force: true),
                              child: const Text("Retry"),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.packingCategories.isEmpty) {
                    return Center(
                      child: AppText(
                        text: "No packing list available",
                        style: textStyle14Regular.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }

                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: 27.w),
                    children: provider.packingCategories.map((cat) {
                      final items = cat.items.map((i) => i.name).toList();
                      final key = cat.title;
                      return buildCategory(
                        context,
                        title: key,
                        items: items,
                        checked: provider.categoryChecked[key] ?? false,
                        onTapCheck: () => provider.toggleCategory(key),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCategory(
    BuildContext context, {
    required String title,
    required List<String> items,
    required bool checked,
    required VoidCallback onTapCheck,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: title,
                style: textStyle16SemiBold.copyWith(
                  color: AppColors.primaryColor.setOpacity(0.8),
                  fontSize: 18.sp,
                ),
              ),

              GestureDetector(
                onTap: onTapCheck,
                child: SvgIcon(
                  checked ? AppAssets.checkbox : AppAssets.checkFill,
                  size: 24.w,
                ),
              ),
            ],
          ),

          14.h.verticalSpace,

          /// Bullet Items
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: 6.h, left: 12.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: "•  ",
                      style: textStyle14Regular.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.primaryColor.setOpacity(0.6),
                      ),
                    ),
                    Expanded(
                      child: AppText(
                        text: item,
                        style: textStyle14Regular.copyWith(
                          fontSize: 16.sp,
                          color: AppColors.primaryColor.setOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
