// core/widgets/custom_dropdown_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
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
  final String titletext;

  /// NEW: option to show radio buttons
  final bool showRadio;

  const CustomMultiSelectDropdown({
    super.key,
     this.labelText,
    required this.hintText,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    required this.titletext,
    this.prefixIcon,
    this.showRadio = false,
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText ?? "",
          style: textStyle14Medium.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        // 10.h.verticalSpace,

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
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.white,
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    text: widget.selectedItems.isEmpty
                        ? widget.hintText
                        : widget.selectedItems.join(", "),
                    style: textStyle14Regular.copyWith(
                      color: widget.selectedItems.isEmpty
                          ? AppColors.primaryColor.withOpacity(0.6)
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

        // Dropdown
        if (isExpanded)
          Container(
            margin: EdgeInsets.only(top: 6.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.2),
              ),
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
                    text: widget.titletext,
                    style: textStyle18Bold.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.primaryColor.withOpacity(0.6),
                    ),
                  ),
                ),

                Divider(height: 2),
5.h.verticalSpace,
                // Items List
                ...widget.items.map((item) {
                  final isSelected = widget.selectedItems.contains(item);

                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (widget.showRadio) {
                          // radio mode → only one selected
                          widget.selectedItems
                            ..clear()
                            ..add(item);
                        } else {
                          // checkbox mode
                          if (isSelected) {
                            widget.selectedItems.remove(item);
                          } else {
                            widget.selectedItems.add(item);
                          }
                        }
                      });
                      widget.onChanged(widget.selectedItems);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.showRadio ? 20.w : 25.w,
    vertical: widget.showRadio ? 0 : 7.h,   
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(
                            text: item,
                            style: textStyle14Regular,
                          ),

                          /// NEW: Radio or Checkbox condition
                          widget.showRadio
                              ? Radio<String>(
                                activeColor: AppColors.blueColor,
                                  value: item,
                                  groupValue:
                                      widget.selectedItems.isNotEmpty
                                          ? widget.selectedItems.first
                                          : null,
                                  onChanged: (val) {
                                    setState(() {
                                      widget.selectedItems
                                        ..clear()
                                        ..add(val!);
                                    });
                                    widget.onChanged(widget.selectedItems);
                                  },
                                )
                              : SvgIcon(
                                  isSelected
                                      ? AppAssets.checkfill
                                      : AppAssets.checkbox,
                                  size: 22.w,
                                ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                5.h.verticalSpace,
              ],
            ),
          ),
      ],
    );
  }
}
