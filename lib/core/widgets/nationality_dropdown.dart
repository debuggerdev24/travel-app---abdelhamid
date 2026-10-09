import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/nationalities.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';

class NationalityDropdown extends StatefulWidget {
  const NationalityDropdown({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.fieldKey,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final GlobalKey<FormFieldState<String>>? fieldKey;

  @override
  State<NationalityDropdown> createState() => _NationalityDropdownState();
}

class _NationalityDropdownState extends State<NationalityDropdown> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(NationalityDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _openList(FormFieldState<String> field) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return _NationalityList(selected: widget.controller.text.trim());
      },
    );
    if (picked == null || !mounted) return;
    widget.controller.text = picked;
    field.didChange(picked);
    field.validate();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.controller.text.trim();
    final hint = widget.hintText ?? 'Select nationality'.tr();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null && widget.labelText!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 5.h),
            child: AppText(
              text: widget.labelText!,
              style: textStyle14Medium.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        FormField<String>(
          key: widget.fieldKey,
          initialValue: selected,
          validator: (value) {
            if (widget.validator == null) return null;
            return widget.validator!(widget.controller.text);
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _openList(field),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22.w,
                      vertical: 17.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: field.hasError
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
                    child: Row(
                      children: [
                        Expanded(
                          child: AppText(
                            text: selected.isEmpty ? hint : selected,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textStyle14Regular.copyWith(
                              color: selected.isEmpty
                                  ? Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        SvgIcon(
                          AppAssets.dropdown,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 26.w,
                        ),
                      ],
                    ),
                  ),
                ),
                if (field.errorText != null) ...[
                  SizedBox(height: 6.h),
                  Text(
                    field.errorText!,
                    style: textStyle14Regular.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _NationalityList extends StatefulWidget {
  const _NationalityList({required this.selected});

  final String selected;

  @override
  State<_NationalityList> createState() => _NationalityListState();
}

class _NationalityListState extends State<_NationalityList> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<String> _visibleItems() {
    final saved = widget.selected.trim();
    final all = <String>[];
    final alreadyListed = nationalities.any(
      (item) => item.toLowerCase() == saved.toLowerCase(),
    );
    if (saved.isNotEmpty && !alreadyListed) {
      all.add(saved);
    }
    all.addAll(nationalities);

    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return all;
    return all.where((item) => item.toLowerCase().contains(query)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems();
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.7,
        child: Column(
          children: [
            12.h.verticalSpace,
            AppText(
              text: 'Nationality'.tr(),
              style: textStyle16SemiBold.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(11.w, 12.h, 11.w, 8.h),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                style: textStyle14Regular.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Search nationality'.tr(),
                  hintStyle: textStyle14Regular.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: AppText(
                        text: 'No nationality found'.tr(),
                        style: textStyle14Regular.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected =
                            item.toLowerCase() ==
                            widget.selected.trim().toLowerCase();
                        return ListTile(
                          title: AppText(
                            text: item,
                            style: textStyle14Regular.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: Theme.of(context).colorScheme.primary,
                                )
                              : null,
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
