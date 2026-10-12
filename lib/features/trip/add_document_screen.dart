import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_button.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:travel_app_abdelhamid/provider/home/home_provider.dart';
import 'package:travel_app_abdelhamid/provider/trip/my_trip_provider.dart';

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key, this.tripId});

  final String? tripId;

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  final ValueNotifier<File?> pickedImage = ValueNotifier(null);
  final TextEditingController _documentNameController = TextEditingController();

  @override
  void dispose() {
    _documentNameController.dispose();
    pickedImage.dispose();
    super.dispose();
  }

  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      pickedImage.value = File(image.path);
    }
  }

  String _defaultNameForType(String selectedType) {
    return {
          "Passport": "Passport",
          "Visa": "Visa",
          "Medical Certificate": "Medical Certificate",
        }[selectedType] ??
        selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer2<MyTripProvider, TripProvider>(
        builder: (consumerContext, myTrip, trip, child) {
          final resolvedTripId = widget.tripId ?? trip.selectedTrip?.id ?? '';

          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: SvgIcon(
                            AppAssets.backIcon,
                            size: 28.5.w,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),

                        AppText(
                          textAlign: TextAlign.center,
                          text: "Add New Document".tr(),
                          style: textStyle32Bold.copyWith(
                            fontSize: 26.sp,
                            color: AppColors.secondary,
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    20.h.verticalSpace,
                    _DocumentTypePicker(
                      hint: "Select Document Type".tr(),
                      options: myTrip.documentTypes,
                      selected: myTrip.selectedDocumentType.isEmpty
                          ? null
                          : myTrip.selectedDocumentType.first,
                      onSelected: (value) {
                        myTrip.selectDocumentType([value]);
                      },
                    ),
                    22.h.verticalSpace,
                    AppTextField(
                      hintText: "Enter Document Name".tr(),
                      labelText: "",
                      controller: _documentNameController,
                    ),
                    22.h.verticalSpace,

                    GestureDetector(
                      onTap: pickImageFromGallery,
                      child: Container(
                        width: 164.w,
                        height: 120.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.primaryColor.setOpacity(0.1),
                            width: 1.w,
                          ),
                        ),
                        child: ValueListenableBuilder<File?>(
                          valueListenable: pickedImage,
                          builder: (context, imageFile, child) {
                            return imageFile == null
                                ? Padding(
                                    padding: const EdgeInsets.all(36),
                                    child: SvgIcon(AppAssets.imagePicker),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Image.file(
                                      imageFile,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                          },
                        ),
                      ),
                    ),
                    350.h.verticalSpace,
                    AppButton(
                      title: "Save Document".tr(),
                      isLoading: myTrip.isUploadingDocument,
                      onTap: myTrip.isUploadingDocument
                          ? null
                          : () async {
                              if (resolvedTripId.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "No trip selected. Open this screen from My Trips."
                                          .tr(),
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (myTrip.selectedDocumentType.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Please select document type".tr(),
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (pickedImage.value == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Please upload document image".tr(),
                                    ),
                                  ),
                                );
                                return;
                              }

                              final selectedType =
                                  myTrip.selectedDocumentType.first;
                              final rawName = _documentNameController.text
                                  .trim();
                              final docName = rawName.isNotEmpty
                                  ? rawName
                                  : _defaultNameForType(selectedType);

                              final err = await myTrip.uploadUserDocument(
                                tripId: resolvedTripId,
                                uiDocumentType: selectedType,
                                file: pickedImage.value!,
                                documentName: docName,
                              );

                              if (!mounted) return;

                              if (err != null) {
                                ScaffoldMessenger.of(
                                  context,
                                ).showSnackBar(SnackBar(content: Text(err)));
                                return;
                              }

                              _documentNameController.clear();
                              pickedImage.value = null;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Document added successfully!".tr(),
                                  ),
                                ),
                              );
                              context.pop();
                            },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DocumentTypePicker extends StatefulWidget {
  final String hint;
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _DocumentTypePicker({
    required this.hint,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_DocumentTypePicker> createState() => _DocumentTypePickerState();
}

class _DocumentTypePickerState extends State<_DocumentTypePicker> {
  bool _isOpen = false;

  void _select(String value) {
    widget.onSelected(value);
    setState(() {
      _isOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final hasSelection = selected != null && selected.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isOpen = !_isOpen;
              });
            },
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: AppText(
                      text: hasSelection ? selected : widget.hint,
                      style: textStyle14Regular.copyWith(
                        color: hasSelection
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
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
                ? Column(
                    children: [
                      Divider(
                        height: 1,
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      for (var i = 0; i < widget.options.length; i++)
                        _optionRow(
                          widget.options[i],
                          widget.options[i].toLowerCase() ==
                              (selected ?? '').toLowerCase(),
                          i < widget.options.length - 1,
                        ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _optionRow(String title, bool isSelected, bool showDivider) {
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
