import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:trael_app_abdelhamid/core/widgets/dropdown_text_filed.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class RoomDetailsScreen extends StatelessWidget {
  const RoomDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 31.w,
                    vertical: 30.h,
                  ),
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
                        text: "Room Details",
                        style: textStyle32Bold.copyWith(
                          fontSize: 26.sp,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 31.w),
                    child: Column(
                      spacing: 22.h,
                      children: [
                        AppTextField(
                          labelText: "Person",
                          hintText: "Enter Person Number",
                          keyboardType: TextInputType.number,
                        ),

                        CustomMultiSelectDropdown(
                          labelText: "Room Type",
                          hintText: "Select Room Type",
                          items: provider.roomTypes,
                          selectedItems: provider.selectedRoomTypes,
                          onChanged: provider.updateRoomTypes,
                          titletext: "Room Type",
                        ),

                        AppTextField(
                          labelText: "Default Price (Adult)",
                          hintText: "Auto Filled",
                          keyboardType: TextInputType.number,
                        ),

                        CustomMultiSelectDropdown(
                          labelText: "Bed Type",
                          hintText: "Select Bed Type",
                          items: provider.bedTypes,
                          selectedItems: provider.selectedBedTypes,
                          onChanged: provider.updateBedTypes,
                          titletext: "Bed Type",
                        ),

                        CustomMultiSelectDropdown(
                          labelText: "Child",
                          hintText: "Select Child",
                          items: provider.childOptions,
                          selectedItems: provider.selectedChildTypes,
                          onChanged: provider.updateChildTypes,
                          titletext: "Child",
                        ),

                        CustomMultiSelectDropdown(
                          labelText: "No. of Child",
                          hintText: "Select Child",
                          items: provider.numberOfChildren,
                          selectedItems: provider.selectedChildCountList,
                          onChanged: provider.updateChildCount,
                          titletext: "Select Child Count",
                          showRadio: true, // 👈 Enable Radio buttons
                        ),

                        AppTextField(
                          labelText: "Child Price",
                          hintText: "Auto Filled",
                          keyboardType: TextInputType.number,
                        ),

                        // Baby
                        CustomMultiSelectDropdown(
                          labelText: "Baby",
                          hintText: "Select Baby",
                          items: provider.babyOptions,
                          selectedItems: provider.selectedBabyTypes,
                          onChanged: provider.updateBabyTypes,
                          titletext: "Baby",
                        ),

                        CustomMultiSelectDropdown(
                          labelText: "No. of Baby",
                          hintText: "Select No. of Baby",
                          items: provider.numberOfBaby,
                          selectedItems: provider.selectedBabyCount,
                          onChanged: provider.updateBabyCount,
                          titletext: "Select Baby Count",
                          showRadio: true,
                        ),

                        AppTextField(
                          labelText: "Baby Price",
                          hintText: "Auto filled",
                          keyboardType: TextInputType.number,
                        ),5.h.verticalSpace,                        AppButton(
                          title: "Next",
                          onTap: (){
                        context.pushNamed(UserAppRoutes.personalDetailsScreen.name);
                          },
                        ),10.h.verticalSpace,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
