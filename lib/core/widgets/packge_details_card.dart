import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:travel_app_abdelhamid/model/home/trip_model.dart';

class PackageDetailsCard extends StatefulWidget {
  final PackageDetails package;
  final bool isSelected;
  final VoidCallback onTap;

  const PackageDetailsCard({
    super.key,
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<PackageDetailsCard> createState() => _PackageDetailsCardState();
}

class _PackageDetailsCardState extends State<PackageDetailsCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isSelected
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  AppText(
                    text: widget.package.title,
                    style: textStyle16SemiBold.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              if (widget.package.roomOptions.isNotEmpty)
                _buildSection(
                  context: context,
                  title: 'Room Options :'.tr(),
                  items: widget.package.roomOptions,
                ),

              if (_isExpanded) ...[
                if (widget.package.childPrices.isNotEmpty)
                  _buildSection(
                    context: context,
                    title: 'Child Prices :'.tr(),
                    items: widget.package.childPrices,
                  ),

                if (widget.package.inclusions.isNotEmpty)
                  _buildSection(
                    context: context,
                    title: 'Inclusions :'.tr(),
                    items: widget.package.inclusions,
                  ),

                if (widget.package.exclusions.isNotEmpty)
                  _buildSection(
                    context: context,
                    title: 'Exclusions:'.tr(),
                    items: widget.package.exclusions,
                    isLast: true,
                  ),
              ],

              10.h.verticalSpace,
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      AppText(
                        text: _isExpanded ? 'Read less'.tr() : 'Read more'.tr(),
                        style: textStyle14Medium.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      4.w.horizontalSpace,
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20.w,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<String> items,
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        8.h.verticalSpace,
        Row(
          children: [
            8.h.verticalSpace,
            AppText(
              text: title,
              style: textStyle14Medium.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        10.h.verticalSpace,
        ...items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 5.h, left: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 4.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface,
                    shape: BoxShape.circle,
                  ),
                ),
                12.w.horizontalSpace,
                Expanded(
                  child: AppText(
                    text: item,
                    style: textStyle14Regular.copyWith(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        8.h.verticalSpace,
      ],
    );
  }
}
