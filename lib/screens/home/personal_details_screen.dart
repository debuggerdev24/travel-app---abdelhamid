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
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Consumer<TripProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                40.h.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 31.w),
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
                        text: "Person Details",
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
                        4.h.verticalSpace,
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: AppText(
                            text: "Personal details of the main booker",
                            style: textStyle14Medium.copyWith(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        AppTextField(
                          labelText: "First Name",
                          hintText: "Enter Your First Name",
                        ),
                        AppTextField(
                          labelText: "Surname",
                          hintText: "Enter Your Surname",
                        ),
                        AppTextField(
                          labelText: "Date of Birth",
                          hintText: "Select Date of Birth",
                          suffixIcon: Padding(
                            padding: EdgeInsets.all(13.0),
                            child: SvgIcon(AppAssets.date, size: 24.w),
                          ),
                        ),
                        AppTextField(
                          labelText: "Place of birth",
                          hintText: "Enter Your Place of birth",
                        ),
                        AppTextField(
                          labelText: "Nationality",
                          hintText: "Enter Your Nationality",
                        ),
                        AppTextField(
                          labelText: "Email Address",
                          hintText: "Enter Your Email Address",
                        ),
                        AppTextField(
                          labelText: "Address",
                          hintText: "Enter Your Address",
                        ),
                        AppTextField(
                          labelText: "House number",
                          hintText: "Enter Your House number",
                        ),
                        AppTextField(
                          labelText: "Postal code",
                          hintText: "Enter Postal code",
                        ),
                        AppTextField(
                          labelText: "Place of residence",
                          hintText: "Enter Place of residence",
                        ),
                        AppTextField(
                          labelText: "Phone Number",
                          hintText: "Enter Your Phone Number",
                        ),

                        2.h.verticalSpace,
                        AppButton(
                          title: "Add Second Person Details",
                          onTap: () {
                            context.pushNamed(UserAppRoutes.personalDetailsScreen2.name);
                          },
                        ),
                        10.h.verticalSpace,
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
