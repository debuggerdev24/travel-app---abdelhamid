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
import 'package:trael_app_abdelhamid/model/essential/currency_info_model.dart';
import 'package:trael_app_abdelhamid/services/essential_service.dart';

class CurrencyMoneyScreen extends StatefulWidget {
  const CurrencyMoneyScreen({super.key});

  @override
  State<CurrencyMoneyScreen> createState() => _CurrencyMoneyScreenState();
}

class _CurrencyMoneyScreenState extends State<CurrencyMoneyScreen> {
  bool _loading = true;
  String? _error;
  CurrencyInfoData? _data;

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
      final data = await EssentialService.instance.getCurrencyInfo(
        showErrorToast: false,
      );
      if (!mounted) return;
      setState(() {
        _data = data;
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
      backgroundColor: AppColors.whiteColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(context),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 27.w),
                child: _body(),
              ),
            ),
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
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            text: "Couldn't load currency information",
            textAlign: TextAlign.center,
            style: textStyle14Medium.copyWith(
              color: AppColors.primaryColor.setOpacity(0.85),
            ),
          ),
          10.h.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: AppText(
              text: _error!,
              textAlign: TextAlign.center,
              style: textStyle14Regular.copyWith(
                color: AppColors.primaryColor.setOpacity(0.65),
              ),
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
      );
    }
    final data = _data;
    if (data == null) {
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
                    text: "No currency information available",
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
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _contentSection(data),
            24.h.verticalSpace,
            _tipsSection(data),
            24.h.verticalSpace,
            _bannerSection(data),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 27.h),
      child: Row(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
            ),
          ),
          9.w.horizontalSpace,
          AppText(
            text: "Currency & Money",
            style: textStyle32Bold.copyWith(
              fontSize: 26.sp,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _contentSection(CurrencyInfoData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _priceRow("Recommended", data.recommendedLabel),
        _priceRow("Exchange Rate", data.exchangeRate),
        28.h.verticalSpace,
        AppText(
          text: "Payment Options",
          style: textStyle14Medium.copyWith(
            color: AppColors.primaryColor.setOpacity(0.8),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (data.paymentOptions.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 14.h, left: 10.w),
            child: AppText(
              text: "—",
              style: textStyle14Regular.copyWith(
                fontSize: 16.sp,
                color: AppColors.primaryColor.setOpacity(0.6),
              ),
            ),
          )
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.paymentOptions
                  .map((o) => _bullet(o, 0))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _tipsSection(CurrencyInfoData data) {
    final tips = data.tips?.trim();
    if (tips == null || tips.isEmpty) return const SizedBox.shrink();

    final lines = tips.split(RegExp(r'\r?\n')).map((s) => s.trim()).where(
          (s) => s.isNotEmpty,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: "Tips",
          style: textStyle14Medium.copyWith(
            color: AppColors.primaryColor.setOpacity(0.8),
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        12.h.verticalSpace,
        ...lines.map((line) => _bullet(line, 0)),
      ],
    );
  }

  Widget _bannerSection(CurrencyInfoData data) {
    final url = serverMediaUrl(data.bannerImagePath);
    if (url != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(AppAssets.currency),
        ),
      );
    }
    return Image.asset(AppAssets.currency);
  }

  Widget _bullet(String text, double leftPadding) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, left: leftPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: "•  ",
            style: textStyle14Regular.copyWith(
              fontSize: 16.sp,
              color: AppColors.primaryColor.setOpacity(0.6),
            ),
          ),
          Expanded(
            child: AppText(
              text: text,
              style: textStyle14Regular.copyWith(
                fontSize: 16.sp,
                color: AppColors.primaryColor.setOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: title,
            style: textStyle14Medium.copyWith(
              color: AppColors.primaryColor.setOpacity(0.8),
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          24.w.horizontalSpace,
          AppText(
            text: ":",
            style: textStyle14Regular.copyWith(
              color: AppColors.primaryColor.setOpacity(0.8),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          24.w.horizontalSpace,
          Expanded(
            child: AppText(
              text: value,
              style: textStyle14Regular.copyWith(
                color: AppColors.primaryColor.setOpacity(0.7),
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
