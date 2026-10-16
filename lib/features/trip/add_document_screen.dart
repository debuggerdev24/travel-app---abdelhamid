import 'package:easy_localization/easy_localization.dart';
import 'dart:io';
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
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<File?> pickedImage = ValueNotifier(null);
  final TextEditingController _documentNameController = TextEditingController();
  String? _documentTypeError;
  String? _imageError;

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
      setState(() {
        _imageError = null;
      });
    }
  }

  bool _validateFields(MyTripProvider myTrip) {
    final nameValid = _formKey.currentState?.validate() ?? false;
    final typeMissing = myTrip.selectedDocumentType.isEmpty;
    final imageMissing = pickedImage.value == null;

    setState(() {
      _documentTypeError =
          typeMissing ? "Please select document type".tr() : null;
      _imageError =
          imageMissing ? "Please upload document image".tr() : null;
    });

    return nameValid && !typeMissing && !imageMissing;
  }

  Widget _requiredLabel(BuildContext context, String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: textStyle14Medium.copyWith(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        children: [
          TextSpan(
            text: ' *',
            style: textStyle14Medium.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer2<MyTripProvider, TripProvider>(
        builder: (consumerContext, myTrip, trip, child) {
          final resolvedTripId = widget.tripId ?? trip.selectedTrip?.id ?? '';

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(11.w, 20.h, 11.w, 13.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: SingleChildScrollView(
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface,
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
                              label: "Document Type".tr(),
                              emptyHint: "Select your document type".tr(),
                              options: myTrip.documentTypes,
                              selected: myTrip.selectedDocumentType.isEmpty
                                  ? null
                                  : myTrip.selectedDocumentType.first,
                              errorText: _documentTypeError,
                              isRequired: true,
                              onSelected: (value) {
                                myTrip.selectDocumentType([value]);
                                setState(() {
                                  _documentTypeError = null;
                                });
                              },
                            ),
                            22.h.verticalSpace,
                            AppTextField(
                              labelText: "Document Name".tr(),
                              hintText: "Enter your document name".tr(),
                              controller: _documentNameController,
                              borderOpacity: 0.35,
                              isRequired: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter document name".tr();
                                }
                                return null;
                              },
                            ),
                            22.h.verticalSpace,
                            _requiredLabel(context, "Upload Document".tr()),
                            SizedBox(height: 8.h),
                            GestureDetector(
                              onTap: pickImageFromGallery,
                              child: Container(
                                width: 164.w,
                                height: 120.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: _imageError != null
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.35),
                                    width: 1.w,
                                  ),
                                ),
                                child: ValueListenableBuilder<File?>(
                                  valueListenable: pickedImage,
                                  builder: (context, imageFile, child) {
                                    return imageFile == null
                                        ? Padding(
                                            padding: const EdgeInsets.all(36),
                                            child:
                                                SvgIcon(AppAssets.imagePicker),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                            child: Image.file(
                                              imageFile,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                  },
                                ),
                              ),
                            ),
                            if (_imageError != null) ...[
                              SizedBox(height: 6.h),
                              Text(
                                _imageError!,
                                style: textStyle14Regular.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
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
                            if (!_validateFields(myTrip)) return;

                            final selectedType =
                                myTrip.selectedDocumentType.first;
                            final docName =
                                _documentNameController.text.trim();

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
          );
        },
      ),
    );
  }
}

class _DocumentTypePicker extends StatefulWidget {
  final String label;
  final String emptyHint;
  final List<String> options;
  final String? selected;
  final String? errorText;
  final bool isRequired;
  final ValueChanged<String> onSelected;

  const _DocumentTypePicker({
    required this.label,
    required this.emptyHint,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.errorText,
    this.isRequired = false,
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
    final hasError =
        widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: widget.label,
            style: textStyle14Medium.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            children: [
              if (widget.isRequired)
                TextSpan(
                  text: ' *',
                  style: textStyle14Medium.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: hasError
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.35),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 6,
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
                borderRadius: BorderRadius.circular(10.r),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text: hasSelection ? selected : widget.emptyHint,
                          style: textStyle14Regular.copyWith(
                            color: hasSelection
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.45),
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
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.2),
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
        ),
        if (hasError) ...[
          SizedBox(height: 6.h),
          Text(
            widget.errorText!,
            style: textStyle14Regular.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
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
