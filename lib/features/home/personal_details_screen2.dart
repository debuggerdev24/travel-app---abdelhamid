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

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
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
                  padding: EdgeInsets.symmetric(horizontal: 27.w),
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
                  child: Padding(
                                     padding: EdgeInsets.symmetric(horizontal: 27.w),

                    child: Column(
                      spacing: 22.h,
                      children: [
                        4.h.verticalSpace,
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: AppText(
                            text: "Surviving Family Members",
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
                          labelText: "Phone Number",
                          hintText: "Enter Your Phone Number",
                        ),
                       
                        AppTextField(
                          labelText: "Relationship",
                          hintText: "Enter a relationship with this person.",
                        ),
Spacer(),                        
                        AppButton(
                          title: "Done & Next",
                          onTap: () {
                            context.pushNamed(UserAppRoutes.packageSummaryScreen.name);
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