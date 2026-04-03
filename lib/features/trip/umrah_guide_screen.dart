import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:trael_app_abdelhamid/core/constants/app_assets.dart';
import 'package:trael_app_abdelhamid/core/constants/app_colors.dart';
import 'package:trael_app_abdelhamid/core/constants/text_style.dart';
import 'package:trael_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:trael_app_abdelhamid/core/extensions/routes_extensions.dart';
import 'package:trael_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:trael_app_abdelhamid/core/widgets/app_text.dart';
import 'package:trael_app_abdelhamid/model/umrah/umrah_guide_step_model.dart';
import 'package:trael_app_abdelhamid/routes/user_routes.dart';
import 'package:trael_app_abdelhamid/services/umrah_guide_service.dart';

class UmrahGuideScreen extends StatefulWidget {
  const UmrahGuideScreen({super.key});

  @override
  State<UmrahGuideScreen> createState() => _UmrahGuideScreenState();
}

class _UmrahGuideScreenState extends State<UmrahGuideScreen> {
  bool _loading = true;
  String? _error;
  List<UmrahGuideStepModel> _steps = const [];

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
      final steps = await UmrahGuideService.instance.fetchSteps(
        showErrorToast: false,
      );
      if (!mounted) return;
      setState(() {
        _steps = steps;
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w),
                    ),
                  ),
                  Expanded(
                    child: AppText(
                      textAlign: TextAlign.center,
                      text: "Umrah Guide\n(Step-by-Step)",
                      style: textStyle32Bold.copyWith(
                        fontSize: 26.sp,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  SizedBox(width: 28.5.w),
                ],
              ),

              16.h.verticalSpace,

              Expanded(child: _body()),

              42.h.verticalSpace,

              _bottomButtons(context),
            ],
          ),
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
            text: "Couldn't load Umrah guide",
            textAlign: TextAlign.center,
            style: textStyle14Medium.copyWith(
              color: AppColors.primaryColor.setOpacity(0.85),
            ),
          ),
          10.h.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
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
              text: 'Retry',
              style: textStyle14Medium.copyWith(color: AppColors.secondary),
            ),
          ),
        ],
      );
    }

    if (_steps.isEmpty) {
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
                    text: 'No Umrah guide steps available yet',
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
        itemCount: _steps.length,
        separatorBuilder: (_, __) => SizedBox(height: 20.h),
        itemBuilder: (context, index) {
          return _UmrahStepTile(step: _steps[index]);
        },
      ),
    );
  }

  Widget _bottomButtons(BuildContext con) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blueColor.setOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 12),
                ),
              ],
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(color: AppColors.blueColor),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgIcon(AppAssets.save, size: 20.w),
                10.w.horizontalSpace,
                AppText(
                  text: " Download",
                  style: textStyle14Medium.copyWith(color: AppColors.blueColor),
                ),
              ],
            ),
          ),
        ),
        14.w.horizontalSpace,
        Expanded(
          child: GestureDetector(
            onTap: () => con.pushNamed(
                  UserAppRoutes.duaListScreen.name,
                  extra: freshRouteNonce(),
                ),
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blueColor.setOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                color: AppColors.blueColor,
                borderRadius: BorderRadius.circular(25.r),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgIcon(AppAssets.eye, size: 20.w),
                  10.w.horizontalSpace,
                  AppText(
                    text: " View Dua List",
                    style: textStyle14Medium.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UmrahStepTile extends StatelessWidget {
  final UmrahGuideStepModel step;

  const _UmrahStepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(text: step.title, style: textStyle16SemiBold),
        if (step.bullets.isNotEmpty) ...[
          9.h.verticalSpace,
          ...step.bullets.map(_bulletLine),
        ],
      ],
    );
  }

  Widget _bulletLine(String line) {
    final lines = line.split('\n');
    return Padding(
      padding: EdgeInsets.only(left: 12.w, bottom: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: "•  ",
            style: textStyle14Regular.copyWith(
              color: AppColors.primaryColor.setOpacity(0.5),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: lines
                  .map(
                    (segment) => AppText(
                      text: segment,
                      style: textStyle14Regular.copyWith(
                        color: AppColors.primaryColor.setOpacity(0.5),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
