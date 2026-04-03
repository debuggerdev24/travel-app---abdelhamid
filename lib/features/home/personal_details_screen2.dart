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
import 'package:trael_app_abdelhamid/core/utils/validators.dart';
import 'package:trael_app_abdelhamid/provider/booking/trip_booking_provider.dart';
import 'package:trael_app_abdelhamid/provider/home/person_details_provider.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class FamilyMembersScreen extends StatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  late final PersonDetailsProvider _personDetailsProvider;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _personDetailsProvider = PersonDetailsProvider();
    debugPrint('✅ [FamilyMembersScreen] Provider initialized');
  }

  @override
  void dispose() {
    _personDetailsProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      resizeToAvoidBottomInset: true,
      body: ChangeNotifierProvider.value(
        value: _personDetailsProvider,
        child: Consumer<PersonDetailsProvider>(
          builder: (context, personProvider, child) {
            final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
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
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        // Keep keyboard open while scrolling.
                        padding: EdgeInsets.fromLTRB(
                          27.w,
                          0,
                          27.w,
                          bottomInset + 24.h,
                        ),
                        child: Column(
                          spacing: 22.h,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              controller:
                                  personProvider.familyFirstNameController,
                              validator: (v) => Validator.validatePersonName(
                                v,
                                'First name',
                              ),
                              autoValidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            AppTextField(
                              labelText: "Surname",
                              hintText: "Enter Your Surname",
                              controller: personProvider.familySurnameController,
                              validator: (v) => Validator.validatePersonName(
                                v,
                                'Surname',
                              ),
                              autoValidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            AppTextField(
                              labelText: "Phone Number",
                              hintText: "Enter Your Phone Number",
                              controller:
                                  personProvider.familyPhoneNumberController,
                              keyboardType: TextInputType.phone,
                              validator: Validator.validatePersonPhoneFlexible,
                              autoValidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            AppTextField(
                              labelText: "Relationship",
                              hintText: "Enter a relationship with this person.",
                              controller:
                                  personProvider.familyRelationshipController,
                              validator: (v) => Validator.validateRequiredText(
                                v,
                                'Relationship',
                                minLen: 2,
                                maxLen: 60,
                              ),
                              autoValidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            24.h.verticalSpace,
                            AppButton(
                              title: personProvider.isFamilyLoading
                                  ? "Saving..."
                                  : "Done & Next",
                              onTap: personProvider.isFamilyLoading
                                  ? null
                                  : () async {
                                    if (!(_formKey.currentState?.validate() ??
                                        false)) {
                                      return;
                                    }

                                    // Read bookingId from TripBookingProvider
                                    final bookingId = context
                                        .read<TripBookingProvider>()
                                        .bookingId;

                                    debugPrint('🔵 [FamilyMembersScreen] Button tapped');
                                    debugPrint('🔵 bookingId: $bookingId');
                                    debugPrint('🔵 firstName: ${personProvider.familyFirstNameController.text}');
                                    debugPrint('🔵 surname: ${personProvider.familySurnameController.text}');
                                    debugPrint('🔵 phoneNumber: ${personProvider.familyPhoneNumberController.text}');
                                    debugPrint('🔵 relationship: ${personProvider.familyRelationshipController.text}');

                                    if (bookingId == null || bookingId.isEmpty) {
                                      debugPrint('❌ [FamilyMembersScreen] bookingId is null or empty — cannot save');
                                      return;
                                    }

                                    final success = await personProvider
                                        .saveFamilyDetails(bookingId);

                                    debugPrint(success
                                        ? '✅ [FamilyMembersScreen] Family details saved successfully'
                                        : '❌ [FamilyMembersScreen] Failed to save family details');

                                    if (success && context.mounted) {
                                      context.pushNamed(
                                        UserAppRoutes.packageSummaryScreen.name,
                                      );
                                    }
                                  },
                          ),
                          10.h.verticalSpace,
                        ],
                      ),
                    ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}