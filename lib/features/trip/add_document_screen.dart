import 'dart:io';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_button.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text_filed.dart';
import 'package:trael_app_abdelhamid/core/widgets/dropdown_text_filed.dart';
import 'package:trael_app_abdelhamid/provider/home/home_provider.dart';
import 'package:trael_app_abdelhamid/provider/trip/my_trip_provider.dart';

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key, this.tripId});

  /// Preferred; falls back to [TripProvider.selectedTrip] if null.
  final String? tripId;

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  File? pickedImage;
  final TextEditingController _documentNameController = TextEditingController();

  @override
  void dispose() {
    _documentNameController.dispose();
    super.dispose();
  }

  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });
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
      backgroundColor: Colors.white,
      body: Consumer2<MyTripProvider, TripProvider>(
        builder: (context, myTrip, trip, child) {
          final resolvedTripId =
              widget.tripId ?? trip.selectedTrip?.id ?? '';

          return SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 35.h),
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                          ),
                        ),
                        80.w.horizontalSpace,
                        AppText(
                          textAlign: TextAlign.center,
                          text: "Add New \nDocument",
                          style: textStyle32Bold.copyWith(
                            fontSize: 26.sp,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    CustomMultiSelectDropdown(
                      labelText: "",
                      hintText: "Select Document Type",
                      items: myTrip.documentTypes,
                      selectedItems: myTrip.selectedDocumentType,
                      onChanged: myTrip.selectDocumentType,
                      titleText: "Select Document Type",
                      showRadio: true,
                    ),
                    22.h.verticalSpace,
                    AppTextField(
                      hintText: "Enter Document Name",
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
                        child: pickedImage == null
                            ? Padding(
                                padding: const EdgeInsets.all(36),
                                child: SvgIcon(AppAssets.imagePicker),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.file(
                                  pickedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                    ),
                    350.h.verticalSpace,
                    AppButton(
                      title: "Save Document",
                      isLoading: myTrip.isUploadingDocument,
                      onTap: myTrip.isUploadingDocument
                          ? null
                          : () async {
                              if (resolvedTripId.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "No trip selected. Open this screen from My Trips.",
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (myTrip.selectedDocumentType.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please select document type"),
                                  ),
                                );
                                return;
                              }
                              if (pickedImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please upload document image",
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
                                file: pickedImage!,
                                documentName: docName,
                              );

                              if (!context.mounted) return;

                              if (err != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(err)),
                                );
                                return;
                              }

                              _documentNameController.clear();
                              setState(() => pickedImage = null);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Document added successfully!"),
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
