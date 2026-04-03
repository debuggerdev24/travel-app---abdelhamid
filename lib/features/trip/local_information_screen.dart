import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/model/essential/local_info_model.dart';
import 'package:trael_app_abdelhamid/services/essential_service.dart';

class LocalInformationScreen extends StatefulWidget {
  const LocalInformationScreen({super.key});

  @override
  State<LocalInformationScreen> createState() => _LocalInformationScreenState();
}

class _LocalInformationScreenState extends State<LocalInformationScreen> {
  bool _loading = true;
  String? _error;
  List<LocalInfoItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await EssentialService.instance.getLocalInfo(
        showErrorToast: false,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userFacingApiError(e);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 31.w, vertical: 27.h),
              child: Row(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                    ),
                  ),
                  14.w.horizontalSpace,
                  AppText(
                    text: "Local Information",
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 27.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              text: "Couldn't load local information",
              textAlign: TextAlign.center,
              style: textStyle14Medium.copyWith(
                color: AppColors.primaryColor.setOpacity(0.85),
              ),
            ),
            10.h.verticalSpace,
            AppText(
              text: _error!,
              textAlign: TextAlign.center,
              style: textStyle14Regular.copyWith(
                color: AppColors.primaryColor.setOpacity(0.65),
              ),
            ),
            16.h.verticalSpace,
            TextButton(
              onPressed: _load,
              child: AppText(
                text: "Retry",
                style: textStyle14Medium.copyWith(color: AppColors.secondary),
              ),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 27.w),
                    child: AppText(
                      text: "No local information available",
                      textAlign: TextAlign.center,
                      style: textStyle14Regular.copyWith(
                        color: AppColors.primaryColor.setOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 8.h),
        itemCount: _items.length,
        separatorBuilder: (_, __) => SizedBox(height: 20.h),
        itemBuilder: (context, index) {
          final item = _items[index];
          return _infoCard(item);
        },
      ),
    );
  }

  Widget _infoCard(LocalInfoItem item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 18.w),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.title.isNotEmpty)
            AppText(
              text: item.title,
              style: textStyle16SemiBold.copyWith(
                fontSize: 18.sp,
                color: AppColors.primaryColor.setOpacity(0.85),
              ),
            ),
          if (item.shortDescription != null &&
              item.shortDescription!.trim().isNotEmpty) ...[
            10.h.verticalSpace,
            AppText(
              text: item.shortDescription!,
              style: textStyle14Regular.copyWith(
                fontSize: 15.sp,
                color: AppColors.primaryColor.setOpacity(0.75),
              ),
            ),
          ],
          if (item.description != null &&
              item.description!.trim().isNotEmpty) ...[
            12.h.verticalSpace,
            AppText(
              text: item.description!,
              style: textStyle14Regular.copyWith(
                fontSize: 16.sp,
                height: 1.45,
                color: AppColors.primaryColor.setOpacity(0.65),
              ),
            ),
          ],
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: AppColors.blueColor.setOpacity(0.1),
          blurRadius: 3,
          offset: const Offset(0, 2),
        ),
      ],
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: AppColors.primaryColor.setOpacity(0.2)),
    );
  }
}
