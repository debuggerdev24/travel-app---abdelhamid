import 'package:easy_localization/easy_localization.dart';
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
import 'package:travel_app_abdelhamid/model/home/trip_model.dart';
import 'package:travel_app_abdelhamid/provider/booking/trip_booking_provider.dart';
import 'package:travel_app_abdelhamid/provider/home/home_provider.dart' as hp;
import 'package:travel_app_abdelhamid/routes/user_routes.dart';

class RoomDetailsState extends ChangeNotifier {
  String? _roomTypeError;
  String? _bedTypeError;
  String? _childTypeError;
  String? _childCountError;
  String? _babyTypeError;
  String? _babyCountError;

  String? get roomTypeError => _roomTypeError;
  String? get bedTypeError => _bedTypeError;
  String? get childTypeError => _childTypeError;
  String? get childCountError => _childCountError;
  String? get babyTypeError => _babyTypeError;
  String? get babyCountError => _babyCountError;

  void setRoomTypeError(String? error) {
    _roomTypeError = error;
    notifyListeners();
  }

  void setBedTypeError(String? error) {
    _bedTypeError = error;
    notifyListeners();
  }

  void setChildTypeError(String? error) {
    _childTypeError = error;
    notifyListeners();
  }

  void setChildCountError(String? error) {
    _childCountError = error;
    notifyListeners();
  }

  void setBabyTypeError(String? error) {
    _babyTypeError = error;
    notifyListeners();
  }

  void setBabyCountError(String? error) {
    _babyCountError = error;
    notifyListeners();
  }
}

class RoomDetailsScreen extends StatelessWidget {
  const RoomDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RoomDetailsView();
  }
}

class _RoomDetailsView extends StatefulWidget {
  const _RoomDetailsView();

  @override
  State<_RoomDetailsView> createState() => _RoomDetailsViewState();
}

class _RoomDetailsViewState extends State<_RoomDetailsView> {
  final _formKey = GlobalKey<FormState>();
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
        if (mounted) {
          _personController.text = bookingProvider.adultCount.toString();
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
    final tripProvider = context.read<hp.TripProvider>();
    bool isValid = true;

    final state = context.read<RoomDetailsState>();

    if (bookingProvider.selectedRoomTypeId == null) {
      state.setRoomTypeError("Please select a room type".tr());
      isValid = false;
    } else {
      state.setRoomTypeError(null);
    }

    if (bookingProvider.selectedBedType == null) {
      state.setBedTypeError("Please select a bed type".tr());
      isValid = false;
    } else {
      state.setBedTypeError(null);
    }

    if (bookingProvider.selectedChildDetailsId != null &&
        bookingProvider.selectedChildCount == 0) {
      state.setChildCountError("Please select number of child".tr());
      isValid = false;
    } else {
      state.setChildCountError(null);
    }

    if (bookingProvider.selectedChildCount > 0 &&
        bookingProvider.selectedChildDetailsId == null) {
      state.setChildTypeError("Please select child type".tr());
      isValid = false;
    } else {
      state.setChildTypeError(null);
    }

    if (tripProvider.selectedBabyTypes.isNotEmpty &&
        bookingProvider.babyCount == 0) {
      state.setBabyCountError("Please select number of baby".tr());
      isValid = false;
    } else {
      state.setBabyCountError(null);
    }

    if (bookingProvider.babyCount > 0 &&
        tripProvider.selectedBabyTypes.isEmpty) {
      state.setBabyTypeError("Please select baby type".tr());
      isValid = false;
    } else {
      state.setBabyTypeError(null);
    }

    return isValid;
  }

  String _childPriceText(TripBookingProvider booking, PackageDetails? package) {
    if (booking.selectedChildDetailsId == null || package == null) {
      return 'Auto Filled'.tr();
    }

    double unitPrice = 0;
    for (final child in package.childDetails) {
      if (child.id == booking.selectedChildDetailsId) {
        unitPrice = child.childPrice;
        break;
      }
    }

    final total = unitPrice * booking.selectedChildCount;
    if (total == total.roundToDouble()) {
      return '€${total.toInt()}';
    }
    return '€${total.toStringAsFixed(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RoomDetailsState>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                    horizontal: 11.w,
                    vertical: 30.h,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: SvgIcon(
                            AppAssets.backIcon,
                            size: 28.5.w,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      AppText(
                        text: "Room Details".tr(),
                        style: textStyle32Bold.copyWith(
                          fontSize: 26.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 11.w),
                      child: Column(
                        children: [
                          AppTextField(
                            labelText: "Person".tr(),
                            hintText: "Enter Person Number".tr(),
                            keyboardType: TextInputType.number,
                            controller: _personController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Please enter number of persons".tr();
                              }
                              final n = int.tryParse(value);
                              if (n == null || n < 1) {
                                return "Please enter a valid number (min 1)"
                                    .tr();
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
                          _RoomTypePicker(
                            rooms: selectedPackage?.roomDetails ?? const [],
                            selectedRoomId: bookingProvider.selectedRoomTypeId,
                            errorText: state.roomTypeError,
                            readOnly: bookingProvider.isRoomPreferenceSaved,
                            onSelected: (roomId) {
                              if (bookingProvider.isRoomPreferenceSaved) return;
                              bookingProvider.updateSelectedRoomTypeId(roomId);
                              context.read<RoomDetailsState>().setRoomTypeError(
                                null,
                              );
                            },
                          ),
                          SizedBox(height: 22.h),
                          AppTextField(
                            labelText: "Default Price (Adult)".tr(),
                            hintText: bookingProvider.totalAmount > 0
                                ? "€${bookingProvider.totalAmount}"
                                : "Auto Filled",
                            hintStyle: textStyle14Regular.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            keyboardType: TextInputType.number,
                            readOnly: true,
                          ),
                          SizedBox(height: 22.h),
                          _ChoicePicker(
                            label: 'Bed Type'.tr(),
                            hint: 'Select Bed Type'.tr(),
                            emptyText: 'No bed types available'.tr(),
                            options: tripProvider.bedTypes,
                            selected: bookingProvider.selectedBedType,
                            errorText: state.bedTypeError,
                            readOnly: bookingProvider.isRoomPreferenceSaved,
                            onSelected: (value) {
                              if (bookingProvider.isRoomPreferenceSaved) return;
                              bookingProvider.updateSelectedBedType(value);
                              context.read<RoomDetailsState>().setBedTypeError(
                                null,
                              );
                            },
                          ),
                          SizedBox(height: 22.h),
                          _ChildPicker(
                            children: selectedPackage?.childDetails ?? const [],
                            selectedChildId:
                                bookingProvider.selectedChildDetailsId,
                            errorText: state.childTypeError,
                            readOnly: bookingProvider.isRoomPreferenceSaved,
                            onSelected: (childId) {
                              if (bookingProvider.isRoomPreferenceSaved) return;
                              bookingProvider.updateSelectedChildDetailsId(
                                childId,
                              );
                              context
                                  .read<RoomDetailsState>()
                                  .setChildTypeError(null);
                              context
                                  .read<RoomDetailsState>()
                                  .setChildCountError(null);
                            },
                          ),
                          SizedBox(height: 22.h),
                          _ChoicePicker(
                            label: 'No. of Child'.tr(),
                            hint: 'Select Child Count'.tr(),
                            emptyText: 'No child counts available'.tr(),
                            options: tripProvider.numberOfChildren,
                            selected: bookingProvider.selectedChildCount
                                .toString()
                                .padLeft(2, '0'),
                            errorText: state.childCountError,
                            readOnly: bookingProvider.isRoomPreferenceSaved,
                            onSelected: (value) {
                              if (bookingProvider.isRoomPreferenceSaved) return;
                              bookingProvider.updateSelectedChildCount(
                                int.tryParse(value) ?? 0,
                              );
                              context
                                  .read<RoomDetailsState>()
                                  .setChildCountError(null);
                              context
                                  .read<RoomDetailsState>()
                                  .setChildTypeError(null);
                            },
                          ),
                          SizedBox(height: 22.h),
                          _ReadOnlyValue(
                            label: 'Child Price'.tr(),
                            value: _childPriceText(
                              bookingProvider,
                              selectedPackage,
                            ),
                          ),
                          SizedBox(height: 22.h),
                          _ChoicePicker(
                            label: 'Baby'.tr(),
                            hint: 'Select Baby'.tr(),
                            emptyText: 'No baby options available'.tr(),
                            options: tripProvider.babyOptions,
                            selected: tripProvider.selectedBabyTypes.isEmpty
                                ? null
                                : tripProvider.selectedBabyTypes.first,
                            errorText: state.babyTypeError,
                            readOnly: bookingProvider.isRoomPreferenceSaved,
                            onSelected: (value) {
                              if (bookingProvider.isRoomPreferenceSaved) return;
                              tripProvider.updateBabyTypes([value]);
                              context.read<RoomDetailsState>().setBabyTypeError(
                                null,
                              );
                              context
                                  .read<RoomDetailsState>()
                                  .setBabyCountError(null);
                            },
                          ),
                          SizedBox(height: 22.h),
                          _ChoicePicker(
                            label: 'No. of Baby'.tr(),
                            hint: 'Select No. of Baby'.tr(),
                            emptyText: 'No baby counts available'.tr(),
                            options: tripProvider.numberOfBaby,
                            selected: bookingProvider.babyCount
                                .toString()
                                .padLeft(2, '0'),
                            errorText: state.babyCountError,
                            readOnly: bookingProvider.isRoomPreferenceSaved,
                            onSelected: (value) {
                              if (bookingProvider.isRoomPreferenceSaved) return;
                              bookingProvider.updateBabyCount(
                                int.tryParse(value) ?? 0,
                              );
                              context
                                  .read<RoomDetailsState>()
                                  .setBabyCountError(null);
                              context.read<RoomDetailsState>().setBabyTypeError(
                                null,
                              );
                            },
                          ),
                          SizedBox(height: 22.h),
                          AppTextField(
                            labelText: "Baby Price".tr(),
                            hintText: bookingProvider.babyCount > 0
                                ? "€${500 * bookingProvider.babyCount}"
                                : "Auto filled",
                            hintStyle: textStyle14Regular.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            keyboardType: TextInputType.number,
                            readOnly: true,
                          ),
                          SizedBox(height: 27.h),
                          if (bookingProvider.isRoomPreferenceSaved) ...[
                            Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  SvgIcon(
                                    AppAssets.check,
                                    size: 24.w,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  12.w.horizontalSpace,
                                  Expanded(
                                    child: AppText(
                                      text: "Room preferences already saved"
                                          .tr(),
                                      style: textStyle14Regular.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 22.h),
                            AppButton(
                              title: "Continue to Personal Details".tr(),
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
                              title: "Next".tr(),
                              isLoading: bookingProvider.isLoading,
                              onTap: () async {
                                final isFormValid = _formKey.currentState!
                                    .validate();
                                final areDropdownsValid = _validateDropdowns();

                                if (isFormValid && areDropdownsValid) {
                                  final success = await bookingProvider
                                      .saveRoomPreference();
                                  if (success) {
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
                                    "Please fill the required details".tr(),
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

class _RoomTypePicker extends StatefulWidget {
  final List<RoomDetailModel> rooms;
  final String? selectedRoomId;
  final String? errorText;
  final bool readOnly;
  final ValueChanged<String?> onSelected;

  const _RoomTypePicker({
    required this.rooms,
    required this.selectedRoomId,
    required this.errorText,
    required this.readOnly,
    required this.onSelected,
  });

  @override
  State<_RoomTypePicker> createState() => _RoomTypePickerState();
}

class _RoomTypePickerState extends State<_RoomTypePicker> {
  bool _isOpen = false;

  void _toggle() {
    if (widget.readOnly) return;
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _selectRoom(String? roomId) {
    if (widget.readOnly) return;
    widget.onSelected(roomId);
    setState(() {
      _isOpen = false;
    });
  }

  String _priceText(double price) {
    if (price == price.roundToDouble()) {
      return '€${price.toInt()}';
    }
    return '€${price.toStringAsFixed(1)}';
  }

  @override
  Widget build(BuildContext context) {
    RoomDetailModel? selectedRoom;
    for (final room in widget.rooms) {
      if (room.id == widget.selectedRoomId) {
        selectedRoom = room;
        break;
      }
    }

    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final headerText = selectedRoom == null
        ? 'Select Room Type'.tr()
        : selectedRoom.roomType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Room Type'.tr(),
          style: textStyle14Medium.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        8.h.verticalSpace,
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: hasError
                  ? Theme.of(context).colorScheme.error
                  : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: _toggle,
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text: headerText,
                          style: textStyle14Regular.copyWith(
                            color: selectedRoom == null
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: _isOpen
                    ? _roomList(context, selectedRoom)
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          6.h.verticalSpace,
          AppText(
            text: widget.errorText!,
            style: textStyle14Regular.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
    );
  }

  Widget _roomList(BuildContext context, RoomDetailModel? selectedRoom) {
    if (widget.rooms.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: AppText(
          text: 'No room types available'.tr(),
          style: textStyle14Regular.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        for (var i = 0; i < widget.rooms.length; i++)
          _roomRow(
            context,
            widget.rooms[i],
            widget.rooms[i].id != null &&
                widget.rooms[i].id == selectedRoom?.id,
            i < widget.rooms.length - 1,
          ),
      ],
    );
  }

  Widget _roomRow(
    BuildContext context,
    RoomDetailModel room,
    bool isSelected,
    bool showDivider,
  ) {
    return InkWell(
      onTap: () => _selectRoom(room.id),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 22.w,
                  color: isSelected
                      ? AppColors.secondary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.45),
                ),
                12.w.horizontalSpace,
                Expanded(
                  child: AppText(
                    text: room.roomType,
                    style: textStyle14Medium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                AppText(
                  text: _priceText(room.roomPrice),
                  style: textStyle14Medium.copyWith(
                    color: isSelected
                        ? AppColors.secondary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              indent: 16.w,
              endIndent: 16.w,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.15),
            ),
        ],
      ),
    );
  }
}

class _ChoicePicker extends StatefulWidget {
  final String label;
  final String hint;
  final String emptyText;
  final List<String> options;
  final String? selected;
  final String? errorText;
  final bool readOnly;
  final ValueChanged<String> onSelected;

  const _ChoicePicker({
    required this.label,
    required this.hint,
    required this.emptyText,
    required this.options,
    required this.selected,
    required this.errorText,
    required this.readOnly,
    required this.onSelected,
  });

  @override
  State<_ChoicePicker> createState() => _ChoicePickerState();
}

class _ChoicePickerState extends State<_ChoicePicker> {
  bool _isOpen = false;

  void _toggle() {
    if (widget.readOnly) return;
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _select(String value) {
    if (widget.readOnly) return;
    widget.onSelected(value);
    setState(() {
      _isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final hasSelection = widget.selected != null && widget.selected!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: widget.label,
          style: textStyle14Medium.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        8.h.verticalSpace,
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: hasError
                  ? Theme.of(context).colorScheme.error
                  : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: _toggle,
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text: hasSelection ? widget.selected! : widget.hint,
                          style: textStyle14Regular.copyWith(
                            color: hasSelection
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: _isOpen
                    ? _optionList(context)
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          6.h.verticalSpace,
          AppText(
            text: widget.errorText!,
            style: textStyle14Regular.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
    );
  }

  Widget _optionList(BuildContext context) {
    if (widget.options.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: AppText(
          text: widget.emptyText,
          style: textStyle14Regular.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        for (var i = 0; i < widget.options.length; i++)
          _optionRow(
            context,
            widget.options[i],
            widget.options[i] == widget.selected,
            i < widget.options.length - 1,
          ),
      ],
    );
  }

  Widget _optionRow(
    BuildContext context,
    String title,
    bool isSelected,
    bool showDivider,
  ) {
    return InkWell(
      onTap: () => _select(title),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 22.w,
                  color: isSelected
                      ? AppColors.secondary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.45),
                ),
                12.w.horizontalSpace,
                Expanded(
                  child: AppText(
                    text: title,
                    style: textStyle14Medium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              indent: 16.w,
              endIndent: 16.w,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.15),
            ),
        ],
      ),
    );
  }
}

class _ChildPicker extends StatefulWidget {
  final List<ChildDetailModel> children;
  final String? selectedChildId;
  final String? errorText;
  final bool readOnly;
  final ValueChanged<String?> onSelected;

  const _ChildPicker({
    required this.children,
    required this.selectedChildId,
    required this.errorText,
    required this.readOnly,
    required this.onSelected,
  });

  @override
  State<_ChildPicker> createState() => _ChildPickerState();
}

class _ChildPickerState extends State<_ChildPicker> {
  bool _isOpen = false;

  void _toggle() {
    if (widget.readOnly) return;
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  void _selectChild(String? childId) {
    if (widget.readOnly) return;
    widget.onSelected(childId);
    setState(() {
      _isOpen = false;
    });
  }

  String _priceText(double price) {
    if (price == price.roundToDouble()) {
      return '€${price.toInt()}';
    }
    return '€${price.toStringAsFixed(1)}';
  }

  @override
  Widget build(BuildContext context) {
    ChildDetailModel? selectedChild;
    for (final child in widget.children) {
      if (child.id == widget.selectedChildId) {
        selectedChild = child;
        break;
      }
    }

    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final headerText = selectedChild == null
        ? 'Select Child'.tr()
        : selectedChild.childName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: 'Child'.tr(),
          style: textStyle14Medium.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        8.h.verticalSpace,
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: hasError
                  ? Theme.of(context).colorScheme.error
                  : Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: _toggle,
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text: headerText,
                          style: textStyle14Regular.copyWith(
                            color: selectedChild == null
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: _isOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: _isOpen
                    ? _childList(context, selectedChild)
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          6.h.verticalSpace,
          AppText(
            text: widget.errorText!,
            style: textStyle14Regular.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
    );
  }

  Widget _childList(BuildContext context, ChildDetailModel? selectedChild) {
    if (widget.children.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: AppText(
          text: 'No child options available'.tr(),
          style: textStyle14Regular.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        for (var i = 0; i < widget.children.length; i++)
          _childRow(
            context,
            widget.children[i],
            widget.children[i].id != null &&
                widget.children[i].id == selectedChild?.id,
            i < widget.children.length - 1,
          ),
      ],
    );
  }

  Widget _childRow(
    BuildContext context,
    ChildDetailModel child,
    bool isSelected,
    bool showDivider,
  ) {
    return InkWell(
      onTap: () => _selectChild(child.id),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 22.w,
                  color: isSelected
                      ? AppColors.secondary
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.45),
                ),
                12.w.horizontalSpace,
                Expanded(
                  child: AppText(
                    text: child.childName,
                    style: textStyle14Medium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                AppText(
                  text: _priceText(child.childPrice),
                  style: textStyle14Medium.copyWith(
                    color: isSelected
                        ? AppColors.secondary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              indent: 16.w,
              endIndent: 16.w,
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.15),
            ),
        ],
      ),
    );
  }
}

class _ReadOnlyValue extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          style: textStyle14Medium.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        8.h.verticalSpace,
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.1),
                blurRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AppText(
            text: value,
            style: textStyle14Regular.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
