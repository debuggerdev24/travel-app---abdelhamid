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
import 'package:trael_app_abdelhamid/provider/trip/my_trip_provider.dart';

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  File? pickedImage;

  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        pickedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<MyTripProvider>(
        builder: (context, provider, child) {
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
                      items: provider.documenttypes,
                      selectedItems: provider.seelcteddocumetype,
                      onChanged: provider.selcteddocumetype,
                      titletext: "Select Document Type",
                      showRadio: true,
                    ),
                    22.h.verticalSpace,
                    AppTextField(
                      hintText: "Enter Document Name",
                      labelText: "",
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
                                child: SvgIcon(AppAssets.imagepicker),
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
                      onTap: () {
                        if (provider.seelcteddocumetype.isEmpty) {
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
                              content: Text("Please upload document image"),
                            ),
                          );
                          return;
                        }

                        final selectedType = provider.seelcteddocumetype.first;
                        // final TextEditingController nameController = TextEditingController(); // You should add this field!

                        // Suggestion: Add a text field for name
                        // Or auto-generate name like "My Passport", "Visa Copy"

                        String docName =
                            {
                              "Passport": "Passport",
                              "Visa": "Visa",
                              "Flight Ticket": "Mumbai → Jeddah",
                              "Medical Certificate": "Medical Certificate",
                            }[selectedType] ??
                            selectedType;

                        provider.addDocument(
                          selectedType,
                          pickedImage!,
                          docName,
                        );

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
