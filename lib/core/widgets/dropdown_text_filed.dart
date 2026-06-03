// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';

class DropdownController {
  static _CustomMultiSelectDropdownState? openedDropdown;

  static void closeOthers(_CustomMultiSelectDropdownState current) {
    if (openedDropdown != null && openedDropdown != current) {
      openedDropdown!.closeDropdown();
    }
    openedDropdown = current;
  }
}

class CustomMultiSelectDropdown extends StatefulWidget {
  final String? labelText;
  final String hintText;
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onChanged;
  final Widget? prefixIcon;
  final String titleText;
  final bool showRadio;
  final String? errorText;

  const CustomMultiSelectDropdown({
    super.key,
    this.labelText,
    required this.hintText,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    required this.titleText,
    this.prefixIcon,
    this.showRadio = false,
    this.errorText,
  });

  @override
  State<CustomMultiSelectDropdown> createState() =>
      _CustomMultiSelectDropdownState();
}

class _CustomMultiSelectDropdownState extends State<CustomMultiSelectDropdown> {
  bool isExpanded = false;

  void closeDropdown() {
    if (mounted) {
      setState(() {
        isExpanded = false;
      });
    }
  }

  bool _isItemSelected(String item) {
    if (widget.selectedItems.isEmpty) return false;
    return widget.selectedItems.any(
      (s) => s.toLowerCase() == item.toLowerCase(),
    );
  }

  String? _radioGroupValue() {
    if (widget.selectedItems.isEmpty) return null;
    final selected = widget.selectedItems.first;
    for (final item in widget.items) {
      if (item.toLowerCase() == selected.toLowerCase()) return item;
    }
    return selected;
  }

  String _displaySelectedText() {
    if (widget.selectedItems.isEmpty) return widget.hintText;
    if (widget.showRadio) {
      return _radioGroupValue() ?? widget.selectedItems.first;
    }
    return widget.selectedItems.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null)
          Text(
            widget.labelText!,
            style: textStyle14Medium.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),

        SizedBox(height: 5.h),

        // TextField UI
        GestureDetector(
          onTap: () {
            DropdownController.closeOthers(this);
            setState(() => isExpanded = !isExpanded);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 16.h),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.setOpacity(0.1),
                  blurRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.white,
              border: Border.all(
                color: widget.errorText != null
                    ? Colors.red.setOpacity(0.5)
                    : AppColors.primaryColor.setOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    text: _displaySelectedText(),
                    style: textStyle14Regular.copyWith(
                      color: widget.selectedItems.isEmpty
                          ? AppColors.primaryColor.setOpacity(0.6)
                          : AppColors.primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SvgIcon(
                  AppAssets.dropdown,
                  color: AppColors.primaryColor,
                  size: 26.w,
                ),
              ],
            ),
          ),
        ),

        if (widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h, left: 12.w),
            child: Text(
              widget.errorText!,
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          ),

        // Dropdown
        if (isExpanded)
          Container(
            margin: EdgeInsets.only(top: 6.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.primaryColor.setOpacity(0.2)),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 25.w,
                    vertical: 16.h,
                  ),
                  child: AppText(
                    text: widget.titleText,
                    style: textStyle18Bold.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.primaryColor.setOpacity(0.6),
                    ),
                  ),
                ),

                const Divider(height: 2),
                SizedBox(height: 5.h),
                // Items List
                ...widget.items.map((item) {
                  final isSelected = _isItemSelected(item);

                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (widget.showRadio) {
                          widget.onChanged([item]);
                          isExpanded = false;
                        } else {
                          final next = List<String>.from(widget.selectedItems);
                          if (isSelected) {
                            next.removeWhere(
                              (s) => s.toLowerCase() == item.toLowerCase(),
                            );
                          } else {
                            next.add(item);
                          }
                          widget.onChanged(next);
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.showRadio ? 20.w : 25.w,
                        vertical: widget.showRadio ? 0 : 7.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(text: item, style: textStyle14Regular),
                          widget.showRadio
                              ? Radio<String>(
                                  activeColor: AppColors.blueColor,
                                  value: item,
                                  groupValue: _radioGroupValue(),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => isExpanded = false);
                                      widget.onChanged([val]);
                                    }
                                  },
                                )
                              : SvgIcon(
                                  isSelected
                                      ? AppAssets.checkFill
                                      : AppAssets.checkbox,
                                  size: 22.w,
                                ),
                        ],
                      ),
                    ),
                  );
                }),
                SizedBox(height: 5.h),
              ],
            ),
          ),
      ],
    );
  }
}
