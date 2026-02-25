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
import 'package:trael_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:trael_app_abdelhamid/core/widgets/dropdown_text_filed.dart';
import 'package:trael_app_abdelhamid/provider/booking/trip_booking_provider.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart' as hp;
import 'package:trael_app_abdelhamid/routes/user_routes.dart';

class RoomDetailsScreen extends StatefulWidget {
  const RoomDetailsScreen({super.key});

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _roomTypeError;
  String? _bedTypeError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider = context.read<TripBookingProvider>();
      if (bookingProvider.tripDetails?.id != null) {
        bookingProvider.fetchPackageOptions(bookingProvider.tripDetails!.id!);
      }
    });
  }

  bool _validateDropdowns() {
    final bookingProvider = context.read<TripBookingProvider>();
    bool isValid = true;

    setState(() {
      if (bookingProvider.selectedRoomTypeId == null) {
        _roomTypeError = "Please select a room type";
        isValid = false;
      } else {
        _roomTypeError = null;
      }

      if (bookingProvider.selectedBedType == null) {
        _bedTypeError = "Please select a bed type";
        isValid = false;
      } else {
        _bedTypeError = null;
      }
    });

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer2<hp.TripProvider, TripBookingProvider>(
        builder: (context, tripProvider, bookingProvider, child) {
          final selectedPackage = bookingProvider.selectedPackage;

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
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 31.w),
                      child: Column(
                        children: [
                          AppTextField(
                            labelText: "Person",
                            hintText: "Enter Person Number",
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter number of persons";
                              }
                              final n = int.tryParse(value);
                              if (n == null || n < 1) {
                                return "Please enter a valid number (min 1)";
                              }
                              return null;
                            },
                            onChanged: (value) {
                              bookingProvider.updateAdultCount(
                                int.tryParse(value ?? '') ?? 1,
                              );
                            },
                          ),
                          SizedBox(height: 22.h),
                          CustomMultiSelectDropdown(
                            labelText: "Room Type",
                            hintText: "Select Room Type",
                            errorText: _roomTypeError,
                            items:
                                selectedPackage?.roomOptions ??
                                tripProvider.roomTypes,
                            selectedItems:
                                (bookingProvider.selectedRoomTypeId != null &&
                                    selectedPackage != null)
                                ? [
                                    selectedPackage.roomOptions.firstWhere((
                                      opt,
                                    ) {
                                      final rooms = selectedPackage.roomDetails
                                          .where(
                                            (r) =>
                                                r.id ==
                                                bookingProvider
                                                    .selectedRoomTypeId,
                                          );
                                      if (rooms.isEmpty) return false;
                                      return opt.contains(rooms.first.roomType);
                                    }, orElse: () => ''),
                                  ]
                                : [],
                            onChanged: (values) {
                              if (values.isNotEmpty &&
                                  selectedPackage != null) {
                                final selectedOpt = values.first;
                                final rooms = selectedPackage.roomDetails.where(
                                  (r) => selectedOpt.contains(r.roomType),
                                );
                                if (rooms.isNotEmpty) {
                                  bookingProvider.updateSelectedRoomTypeId(
                                    rooms.first.id,
                                  );
                                  setState(() => _roomTypeError = null);
                                }
                              }
                            },
                            titletext: "Room Type",
                            showRadio: true,
                          ),
                          SizedBox(height: 22.h),
                          AppTextField(
                            labelText: "Default Price (Adult)",
                            hintText: bookingProvider.totalAmount > 0
                                ? "€${bookingProvider.totalAmount}"
                                : "Auto Filled",
                            hintStyle: textStyle14Regular.copyWith(
                              color: AppColors.black,
                            ),
                            keyboardType: TextInputType.number,
                            readOnly: true,
                          ),
                          SizedBox(height: 22.h),
                          CustomMultiSelectDropdown(
                            labelText: "Bed Type",
                            hintText: "Select Bed Type",
                            errorText: _bedTypeError,
                            items: tripProvider.bedTypes,
                            selectedItems:
                                bookingProvider.selectedBedType != null
                                ? [bookingProvider.selectedBedType!]
                                : [],
                            onChanged: (values) {
                              if (values.isNotEmpty) {
                                bookingProvider.updateSelectedBedType(
                                  values.first,
                                );
                                setState(() => _bedTypeError = null);
                              }
                            },
                            titletext: "Bed Type",
                            showRadio: true,
                          ),
                          SizedBox(height: 22.h),
                          CustomMultiSelectDropdown(
                            labelText: "Child",
                            hintText: "Select Child",
                            items:
                                selectedPackage?.childPrices ??
                                tripProvider.childOptions,
                            selectedItems:
                                (bookingProvider.selectedChildDetailsId !=
                                        null &&
                                    selectedPackage != null)
                                ? [
                                    selectedPackage.childPrices.firstWhere((
                                      opt,
                                    ) {
                                      final children = selectedPackage
                                          .childDetails
                                          .where(
                                            (c) =>
                                                c.id ==
                                                bookingProvider
                                                    .selectedChildDetailsId,
                                          );
                                      if (children.isEmpty) return false;
                                      return opt.contains(
                                        children.first.childName,
                                      );
                                    }, orElse: () => ''),
                                  ]
                                : [],
                            onChanged: (values) {
                              if (values.isNotEmpty &&
                                  selectedPackage != null) {
                                final selectedOpt = values.first;
                                final children = selectedPackage.childDetails
                                    .where(
                                      (c) => selectedOpt.contains(c.childName),
                                    );
                                if (children.isNotEmpty) {
                                  bookingProvider.updateSelectedChildDetailsId(
                                    children.first.id,
                                  );
                                }
                              }
                            },
                            titletext: "Child",
                            showRadio: true,
                          ),
                          SizedBox(height: 22.h),
                          CustomMultiSelectDropdown(
                            labelText: "No. of Child",
                            hintText: "Select Child Count",
                            items: tripProvider.numberOfChildren,
                            selectedItems: [
                              bookingProvider.selectedChildCount
                                  .toString()
                                  .padLeft(2, '0'),
                            ],
                            onChanged: (values) {
                              if (values.isNotEmpty) {
                                bookingProvider.updateSelectedChildCount(
                                  int.tryParse(values.first) ?? 0,
                                );
                              }
                            },
                            titletext: "Select Child Count",
                            showRadio: true,
                          ),
                          SizedBox(height: 22.h),
                          AppTextField(
                            labelText: "Child Price",
                            hintText:
                                bookingProvider.selectedChildDetailsId !=
                                        null &&
                                    selectedPackage != null
                                ? "€${(selectedPackage.childDetails.where((c) => c.id == bookingProvider.selectedChildDetailsId).isNotEmpty ? selectedPackage.childDetails.firstWhere((c) => c.id == bookingProvider.selectedChildDetailsId).childPrice : 0) * bookingProvider.selectedChildCount}"
                                : "Auto Filled",
                            hintStyle: textStyle14Regular.copyWith(
                              color: AppColors.black,
                            ),
                            keyboardType: TextInputType.number,
                            readOnly: true,
                          ),
                          SizedBox(height: 22.h),
                          // Baby
                          CustomMultiSelectDropdown(
                            labelText: "Baby",
                            hintText: "Select Baby",
                            items: tripProvider.babyOptions,
                            selectedItems: tripProvider.selectedBabyTypes,
                            onChanged: tripProvider.updateBabyTypes,
                            titletext: "Baby",
                            showRadio: true,
                          ),
                          SizedBox(height: 22.h),
                          CustomMultiSelectDropdown(
                            labelText: "No. of Baby",
                            hintText: "Select No. of Baby",
                            items: tripProvider.numberOfBaby,
                            selectedItems: [
                              bookingProvider.babyCount.toString().padLeft(
                                2,
                                '0',
                              ),
                            ],
                            onChanged: (values) {
                              if (values.isNotEmpty) {
                                bookingProvider.updateBabyCount(
                                  int.tryParse(values.first) ?? 0,
                                );
                              }
                            },
                            titletext: "Select Baby Count",
                            showRadio: true,
                          ),
                          SizedBox(height: 22.h),
                          AppTextField(
                            labelText: "Baby Price",
                            hintText: bookingProvider.babyCount > 0
                                ? "€${500 * bookingProvider.babyCount}"
                                : "Auto filled",
                            hintStyle: textStyle14Regular.copyWith(
                              color: AppColors.black,
                            ),
                            keyboardType: TextInputType.number,
                            readOnly: true,
                          ),
                          SizedBox(height: 27.h),
                          AppButton(
                            title: "Next",
                            isLoading: bookingProvider.isLoading,
                            onTap: () async {
                              final isFormValid = _formKey.currentState!
                                  .validate();
                              final areDropdownsValid = _validateDropdowns();

                              if (isFormValid && areDropdownsValid) {
                                final success = await bookingProvider
                                    .saveRoomPreference();
                                if (success) {
                                  ToastHelper.showSuccess(
                                    "Preferences saved successfully",
                                  );
                                  if (context.mounted) {
                                    context.pushNamed(
                                      UserAppRoutes.personalDetailsScreen.name,
                                    );
                                  }
                                }
                              } else {
                                ToastHelper.showError(
                                  "Please fix the errors in the form",
                                );
                              }
                            },
                          ),
                          SizedBox(height: 10.h),
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
    );
  }
}
