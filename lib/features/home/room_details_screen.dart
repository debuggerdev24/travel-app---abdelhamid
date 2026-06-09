import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_button.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:travel_app_abdelhamid/core/utils/toast_helper.dart';
import 'package:travel_app_abdelhamid/core/widgets/dropdown_text_filed.dart';
import 'package:travel_app_abdelhamid/provider/booking/trip_booking_provider.dart';
import 'package:travel_app_abdelhamid/provider/home/home_provider.dart' as hp;
import 'package:travel_app_abdelhamid/routes/user_routes.dart';

class RoomDetailsScreen extends StatefulWidget {
  const RoomDetailsScreen({super.key});

  @override
  State<RoomDetailsScreen> createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _roomTypeError;
  String? _bedTypeError;
  late TextEditingController _personController;

  @override
  void initState() {
    super.initState();
    final bookingProvider = context.read<TripBookingProvider>();
    _personController = TextEditingController(
      text: bookingProvider.adultCount.toString(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Only fetch package options from backend if no package is selected locally
      // With the new flow, package is stored locally until payment
      if (bookingProvider.selectedPackage == null &&
          bookingProvider.tripDetails?.id != null) {
        await bookingProvider.fetchPackageOptions(
          bookingProvider.tripDetails!.id!,
        );
      }
      // If room preference is already saved, fetch the saved data
      // This will fallback to package options data if API fails
      if (bookingProvider.isRoomPreferenceSaved &&
          bookingProvider.bookingId != null) {
        await bookingProvider.fetchSavedRoomPreference();
        // Update the controller with the fetched adult count
        if (mounted) {
          setState(() {
            _personController.text = bookingProvider.adultCount.toString();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _personController.dispose();
    super.dispose();
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

          // Update person controller when adult count changes (e.g., after fetching saved data)
          if (_personController.text != bookingProvider.adultCount.toString()) {
            _personController.text = bookingProvider.adultCount.toString();
          }

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
                            controller: _personController,
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
                              if (!bookingProvider.isRoomPreferenceSaved) {
                                bookingProvider.updateAdultCount(
                                  int.tryParse(value ?? '') ?? 1,
                                );
                              }
                            },
                            readOnly: bookingProvider.isRoomPreferenceSaved,
                          ),
                          SizedBox(height: 22.h),
                          IgnorePointer(
                            ignoring: bookingProvider.isRoomPreferenceSaved,
                            child: CustomMultiSelectDropdown(
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
                                        final rooms = selectedPackage
                                            .roomDetails
                                            .where(
                                              (r) =>
                                                  r.id ==
                                                  bookingProvider
                                                      .selectedRoomTypeId,
                                            );
                                        if (rooms.isEmpty) return false;
                                        return opt.contains(
                                          rooms.first.roomType,
                                        );
                                      }, orElse: () => ''),
                                    ]
                                  : [],
                              onChanged: (values) {
                                if (bookingProvider.isRoomPreferenceSaved)
                                  return;
                                if (values.isNotEmpty &&
                                    selectedPackage != null) {
                                  final selectedOpt = values.first;
                                  final rooms = selectedPackage.roomDetails
                                      .where(
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
                              titleText: "Room Type",
                              showRadio: true,
                            ),
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
                          IgnorePointer(
                            ignoring: bookingProvider.isRoomPreferenceSaved,
                            child: CustomMultiSelectDropdown(
                              labelText: "Bed Type",
                              hintText: "Select Bed Type",
                              errorText: _bedTypeError,
                              items: tripProvider.bedTypes,
                              selectedItems:
                                  bookingProvider.selectedBedType != null
                                  ? [bookingProvider.selectedBedType!]
                                  : [],
                              onChanged: (values) {
                                if (bookingProvider.isRoomPreferenceSaved)
                                  return;
                                if (values.isNotEmpty) {
                                  bookingProvider.updateSelectedBedType(
                                    values.first,
                                  );
                                  setState(() => _bedTypeError = null);
                                }
                              },
                              titleText: "Bed Type",
                              showRadio: true,
                            ),
                          ),
                          SizedBox(height: 22.h),
                          IgnorePointer(
                            ignoring: bookingProvider.isRoomPreferenceSaved,
                            child: CustomMultiSelectDropdown(
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
                                if (bookingProvider.isRoomPreferenceSaved)
                                  return;
                                if (values.isNotEmpty &&
                                    selectedPackage != null) {
                                  final selectedOpt = values.first;
                                  final children = selectedPackage.childDetails
                                      .where(
                                        (c) =>
                                            selectedOpt.contains(c.childName),
                                      );
                                  if (children.isNotEmpty) {
                                    bookingProvider
                                        .updateSelectedChildDetailsId(
                                          children.first.id,
                                        );
                                  }
                                }
                              },
                              titleText: "Child",
                              showRadio: true,
                            ),
                          ),
                          SizedBox(height: 22.h),
                          IgnorePointer(
                            ignoring: bookingProvider.isRoomPreferenceSaved,
                            child: CustomMultiSelectDropdown(
                              labelText: "No. of Child",
                              hintText: "Select Child Count",
                              items: tripProvider.numberOfChildren,
                              selectedItems: [
                                bookingProvider.selectedChildCount
                                    .toString()
                                    .padLeft(2, '0'),
                              ],
                              onChanged: (values) {
                                if (bookingProvider.isRoomPreferenceSaved)
                                  return;
                                if (values.isNotEmpty) {
                                  bookingProvider.updateSelectedChildCount(
                                    int.tryParse(values.first) ?? 0,
                                  );
                                }
                              },
                              titleText: "Select Child Count",
                              showRadio: true,
                            ),
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
                          IgnorePointer(
                            ignoring: bookingProvider.isRoomPreferenceSaved,
                            child: CustomMultiSelectDropdown(
                              labelText: "Baby",
                              hintText: "Select Baby",
                              items: tripProvider.babyOptions,
                              selectedItems: tripProvider.selectedBabyTypes,
                              onChanged: (values) {
                                if (bookingProvider.isRoomPreferenceSaved)
                                  return;
                                tripProvider.updateBabyTypes(values);
                              },
                              titleText: "Baby",
                              showRadio: true,
                            ),
                          ),
                          SizedBox(height: 22.h),
                          IgnorePointer(
                            ignoring: bookingProvider.isRoomPreferenceSaved,
                            child: CustomMultiSelectDropdown(
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
                                if (bookingProvider.isRoomPreferenceSaved)
                                  return;
                                if (values.isNotEmpty) {
                                  bookingProvider.updateBabyCount(
                                    int.tryParse(values.first) ?? 0,
                                  );
                                }
                              },
                              titleText: "Select Baby Count",
                              showRadio: true,
                            ),
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
                          if (bookingProvider.isRoomPreferenceSaved) ...[
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.primaryColor,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SvgIcon(AppAssets.check, size: 24.w),
                                  12.w.horizontalSpace,
                                  Expanded(
                                    child: AppText(
                                      text: "Room preferences already saved",
                                      style: textStyle14Regular.copyWith(
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 22.h),
                            AppButton(
                              title: "Continue to Personal Details",
                              onTap: () {
                                if (context.mounted) {
                                  context.pushNamed(
                                    UserAppRoutes.personalDetailsScreen.name,
                                  );
                                }
                              },
                            ),
                          ] else
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
                                        UserAppRoutes
                                            .personalDetailsScreen
                                            .name,
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
