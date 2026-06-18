import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:travel_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:travel_app_abdelhamid/core/utils/server_media_url.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/model/essential/health_tip_model.dart';
import 'package:travel_app_abdelhamid/services/essential_service.dart';

class HealthSafetyState extends ChangeNotifier {
  bool _loading = true;
  String? _error;
  List<HealthTipItem> _tips = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<HealthTipItem> get tips => _tips;

  HealthSafetyState() {
    load();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final tips = await EssentialService.instance.getHealthTips(
        showErrorToast: false,
      );
      final sorted = List<HealthTipItem>.from(tips)
        ..sort((a, b) => a.tipNumber.compareTo(b.tipNumber));
      _tips = sorted;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = userFacingApiError(e);
      _loading = false;
      notifyListeners();
    }
  }
}

class HealthSafetyScreen extends StatelessWidget {
  const HealthSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HealthSafetyState(),
      child: const _HealthSafetyScreenView(),
    );
  }
}

class _HealthSafetyScreenView extends StatelessWidget {
  const _HealthSafetyScreenView();

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
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  16.w.horizontalSpace,
                  Expanded(
                    child: AppText(
                      textAlign: TextAlign.center,
                      text: "Health & Safety \nTips".tr(),
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
            Expanded(child: _body(context)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final state = context.watch<HealthSafetyState>();

    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
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
              text: state.error!,
              textAlign: TextAlign.center,
              style: textStyle14Regular.copyWith(
                color: AppColors.primaryColor.setOpacity(0.65),
              ),
            ),
            16.h.verticalSpace,
            TextButton(
              onPressed: () => context.read<HealthSafetyState>().load(),
              child: AppText(
                text: "Retry".tr(),
                style: textStyle14Medium.copyWith(color: AppColors.secondary),
              ),
            ),
          ],
        ),
      );
    }

    if (state.tips.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<HealthSafetyState>().load(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: AppText(
                    text: "No health tips available".tr(),
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
      onRefresh: () => context.read<HealthSafetyState>().load(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 8.h),
        itemCount: state.tips.length,
        separatorBuilder: (_, __) => SizedBox(height: 14.h),
        itemBuilder: (context, index) {
          return _tipCard(context, state.tips[index]);
        },
      ),
    );
  }

  Widget _tipCard(BuildContext context, HealthTipItem tip) {
    final imageUrl = serverMediaUrl(tip.bannerImagePath);
    final label = tip.tipNumber > 0
        ? "Tip ${tip.tipNumber} : ${tip.tipTitle}"
        : tip.tipTitle;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: Theme.of(context).colorScheme.surface,
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
