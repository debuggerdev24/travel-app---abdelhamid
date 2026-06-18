import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_app_abdelhamid/core/constants/app_assets.dart';
import 'package:travel_app_abdelhamid/core/constants/app_colors.dart';
import 'package:travel_app_abdelhamid/core/constants/text_style.dart';
import 'package:travel_app_abdelhamid/core/extensions/color_extensions.dart';
import 'package:travel_app_abdelhamid/core/utils/api_error_message.dart';
import 'package:travel_app_abdelhamid/core/widgets/app_text.dart';
import 'package:provider/provider.dart';
import 'package:travel_app_abdelhamid/model/essential/local_info_model.dart';
import 'package:travel_app_abdelhamid/services/essential_service.dart';

class LocalInformationState extends ChangeNotifier {
  bool _loading = true;
  String? _error;
  List<LocalInfoItem> _items = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<LocalInfoItem> get items => _items;

  LocalInformationState() {
    load();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final items = await EssentialService.instance.getLocalInfo(
        showErrorToast: false,
      );
      _items = items;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = userFacingApiError(e);
      _loading = false;
      notifyListeners();
    }
  }
}

class LocalInformationScreen extends StatelessWidget {
  const LocalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocalInformationState(),
      child: const _LocalInformationScreenView(),
    );
  }
}

class _LocalInformationScreenView extends StatelessWidget {
  const _LocalInformationScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                      child: SvgIcon(AppAssets.backIcon, size: 28.5.w, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  14.w.horizontalSpace,
                  AppText(
                    text: "Local Information".tr(),
                    style: textStyle32Bold.copyWith(
                      fontSize: 26.sp,
                      color: AppColors.secondary,
                    ),
                  ),
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
    final state = context.watch<LocalInformationState>();

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
              text: "Couldn't load local information",
              textAlign: TextAlign.center,
              style: textStyle14Medium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            10.h.verticalSpace,
            AppText(
              text: state.error!,
              textAlign: TextAlign.center,
              style: textStyle14Regular.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            16.h.verticalSpace,
            TextButton(
              onPressed: () => context.read<LocalInformationState>().load(),
              child: AppText(
                text: "Retry".tr(),
                style: textStyle14Medium.copyWith(color: AppColors.secondary),
              ),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => context.read<LocalInformationState>().load(),
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
                      text: "No local information available".tr(),
                      textAlign: TextAlign.center,
                      style: textStyle14Regular.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
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
      onRefresh: () => context.read<LocalInformationState>().load(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 27.w, vertical: 8.h),
        itemCount: state.items.length,
        separatorBuilder: (_, __) => SizedBox(height: 20.h),
        itemBuilder: (context, index) {
          final item = state.items[index];
          return _infoCard(context, item);
        },
      ),
    );
  }

  Widget _infoCard(BuildContext context, LocalInfoItem item) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 18.w),
      decoration: _boxDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.title.isNotEmpty)
            AppText(
              text: item.title,
              style: textStyle16SemiBold.copyWith(
                fontSize: 18.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          if (item.shortDescription != null &&
              item.shortDescription!.trim().isNotEmpty) ...[
            10.h.verticalSpace,
            AppText(
              text: item.shortDescription!,
              style: textStyle14Regular.copyWith(
                fontSize: 15.sp,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.85),
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
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
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
