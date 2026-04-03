import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:trael_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/model/essential/health_tip_model.dart';
import 'package:trael_app_abdelhamid/services/essential_service.dart';

class HealthSafetyScreen extends StatefulWidget {
  const HealthSafetyScreen({super.key});

  @override
  State<HealthSafetyScreen> createState() => _HealthSafetyScreenState();
}

class _HealthSafetyScreenState extends State<HealthSafetyScreen> {
  bool _loading = true;
  String? _error;
  List<HealthTipItem> _tips = const [];

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
      final tips = await EssentialService.instance.getHealthTips(
        showErrorToast: false,
      );
      if (!mounted) return;
      // Service may return an unmodifiable empty list; sort mutates in place.
      final sorted = List<HealthTipItem>.from(tips)
        ..sort((a, b) => a.tipNumber.compareTo(b.tipNumber));
      setState(() {
        _tips = sorted;
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 20.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                    ),
                  ),
                  16.w.horizontalSpace,
                  Expanded(
                    child: AppText(
                      textAlign: TextAlign.center,
                      text: "Health & Safety \nTips",
                      style: textStyle16SemiBold.copyWith(
                        fontSize: 26.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  SizedBox(width: 28.5.w),
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
              text: "Couldn't load health tips",
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

    if (_tips.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: AppText(
                    text: "No health tips available",
                    textAlign: TextAlign.center,
                    style: textStyle14Regular.copyWith(
                      color: AppColors.primaryColor.setOpacity(0.7),
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
        itemCount: _tips.length,
        separatorBuilder: (_, __) => SizedBox(height: 14.h),
        itemBuilder: (context, index) {
          return _tipCard(_tips[index]);
        },
      ),
    );
  }

  Widget _tipCard(HealthTipItem tip) {
    final imageUrl = serverMediaUrl(tip.bannerImagePath);
    final label = tip.tipNumber > 0
        ? "Tip ${tip.tipNumber} : ${tip.tipTitle}"
        : tip.tipTitle;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.setOpacity(0.3),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 180.h,
              width: double.infinity,
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImage(),
                    )
                  : _placeholderImage(),
            ),
            Container(
              width: double.infinity,
              color: AppColors.primaryColor.setOpacity(0.06),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: label,
                    style: textStyle16SemiBold.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.primaryColor.setOpacity(0.9),
                    ),
                  ),
                  if (tip.description != null &&
                      tip.description!.trim().isNotEmpty) ...[
                    10.h.verticalSpace,
                    AppText(
                      text: tip.description!,
                      style: textStyle14Regular.copyWith(
                        fontSize: 15.sp,
                        height: 1.4,
                        color: AppColors.primaryColor.setOpacity(0.75),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      color: AppColors.primaryColor.setOpacity(0.12),
      alignment: Alignment.center,
      child: Icon(
        Icons.health_and_safety_outlined,
        size: 56.sp,
        color: AppColors.primaryColor.setOpacity(0.35),
      ),
    );
  }
}
