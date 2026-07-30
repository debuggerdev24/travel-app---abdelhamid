import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:travel_app_abdelhamid/core/extensions/routes_extensions.dart';
import 'package:travel_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/model/umrah/umrah_guide_step_model.dart';
import 'package:travel_app_abdelhamid/routes/user_routes.dart';
import 'package:travel_app_abdelhamid/services/umrah_guide_service.dart';

class UmrahGuideState extends ChangeNotifier {
  bool _loading = true;
  String? _error;
  List<UmrahGuideStepModel> _steps = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<UmrahGuideStepModel> get steps => _steps;

  UmrahGuideState() {
    load();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final steps = await UmrahGuideService.instance.fetchSteps(
        showErrorToast: false,
      );
      _steps = steps;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = userFacingApiError(e);
      _loading = false;
      notifyListeners();
    }
  }
}

class UmrahGuideScreen extends StatelessWidget {
  const UmrahGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UmrahGuideState(),
      child: const _UmrahGuideScreenView(),
    );
  }
}

class _UmrahGuideScreenView extends StatelessWidget {
  const _UmrahGuideScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  Expanded(
                    child: AppText(
                      textAlign: TextAlign.center,
                      text: "Umrah Guide\n(Step-by-Step)".tr(),
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

              Expanded(child: _body(context)),

              42.h.verticalSpace,

              _bottomButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final state = context.watch<UmrahGuideState>();

    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
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
              text: state.error!,
              textAlign: TextAlign.center,
              style: textStyle14Regular.copyWith(
                color: AppColors.primaryColor.setOpacity(0.65),
              ),
            ),
          ),
          16.h.verticalSpace,
          TextButton(
            onPressed: () => context.read<UmrahGuideState>().load(),
            child: AppText(
              text: 'Retry'.tr(),
              style: textStyle14Medium.copyWith(color: AppColors.secondary),
            ),
          ),
        ],
      );
    }

    if (state.steps.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<UmrahGuideState>().load(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: AppText(
                    text: 'No Umrah guide steps available yet'.tr(),
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
      onRefresh: () => context.read<UmrahGuideState>().load(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.steps.length,
        separatorBuilder: (_, __) => SizedBox(height: 20.h),
        itemBuilder: (context, index) {
          return _UmrahStepTile(step: state.steps[index]);
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
              color: Theme.of(con).colorScheme.surface,
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
                  text: " Download".tr(),
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
                    text: " View Dua List".tr(),
                    style: textStyle14Medium.copyWith(
                      color: Theme.of(con).colorScheme.onSurface,
                    ),
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
